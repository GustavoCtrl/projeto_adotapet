import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/pet_load.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({Key? key}) : super(key: key);

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  // Controladores para o formulário
  final _nameController = TextEditingController();
  final _descricaoController = TextEditingController();
  final Map<String, List<String>> racasPorEspecie = {
    'Cão': [
      'SRD',
      'Poodle',
      'Labrador',
      'Golden Retriever',
      'Bulldog',
      'Beagle',
      'Pinscher',
      'Shih-tzu',
    ],
    'Gato': ['SRD', 'Siamês', 'Persa', 'Angorá', 'Maine Coon', 'Sphynx'],
    'Pássaro': ['Calopsita', 'Periquito', 'Papagaio', 'Outro'],
    'Roedor': ['Hamster', 'Porquinho da Índia', 'Coelho', 'Outro'],
    'Outro': ['Outro'],
  };
  final Map<String, List<String>> pelagensPorEspecie = {
    'Cão': [
      'Curto',
      'Médio',
      'Longo',
      'Dupla',
      'Rústica',
      'Encaracolada',
      'Sem Pelo',
    ],
    'Gato': [
      'Curto',
      'Médio',
      'Longo',
      'Denso',
      'Cacheado',
      'Sem Pelo (Sphynx)',
    ],
    'Pássaro': ['Penas curtas', 'Penas longas', 'Colorido'],
    'Roedor': ['Curto', 'Longo', 'Liso', 'Crespo'],
    'Outro': ['Indefinido'],
  };

  // Variável para guardar o arquivo da imagem selecionada
  File? _selectedImage;

  // Lista de espécies e valor selecionado
  final List<String> _especies = ['Cão', 'Gato', 'Pássaro', 'Roedor', 'Outro'];
  String? _selectedEspecie;

  // Lista de portes e valor selecionado
  final List<String> _portes = ['Pequeno', 'Médio', 'Grande'];
  String? _selectedPorte;

  // Lista de pelagens e valor selecionado
  List<String> _pelagensDinamicas = [];
  String? _selectedPelagem;

  // Lista de idades e valor selecionado
  final List<String> _idades = List.generate(
    21,
    (i) => i == 0 ? 'Filhote (< 1 ano)' : '$i anos',
  );
  String? _selectedIdade;

  // Lista de raças (simplificada) e valor selecionado
  List<String> _racasDinamicas = [];
  String? _selectedRaca;

  // Variável para guardar o sexo selecionado
  String? _selectedSex;

  // Variável para controlar o estado de loading
  bool _isLoading = false;

  // Instância do ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Função para pegar a imagem da galeria
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Qualidade JPEG 80% para reduzir tamanho
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Função para fazer o upload da imagem e salvar o pet
  Future<void> _savePet() async {
    // 1. Validar o formulário
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      _showErrorDialog("Por favor, selecione uma imagem para o pet.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      File imageToUpload = _selectedImage!;

      // 3. Fazer o UPLOAD da Imagem para o Firebase Storage
      String fileName = 'pets/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageToUpload);
      TaskSnapshot snapshot = await uploadTask;

      // 4. Pegar a URL de Download da imagem
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 5. Pegar o ID do usuário logado (o "abrigo")
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("Usuário não está logado.");
      }

      // 6. Buscar o nome do abrigo (nomeOng) do documento do usuário
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();
      final nomeOng = userDoc.data()?['nomeOng'] ?? 'Sem nome';

      // 7. Criar o array de palavras-chave para a busca
      final nome = _nameController.text.trim().toLowerCase();
      final especie = _selectedEspecie!.toLowerCase();
      final raca = _selectedRaca!.toLowerCase();
      final porte = _selectedPorte!.toLowerCase();

      // Gera um conjunto de palavras-chave únicas
      final keywords = <String>{
        ...nome.split(' '),
        ...especie.split(' '),
        ...raca.split(' '),
        ...porte.split(' '),
      }..removeWhere((k) => k.isEmpty); // Remove strings vazias

      // 7. Salvar os dados do Pet no Cloud FIRESTORE
      await FirebaseFirestore.instance.collection('pets').add({
        'nome': _nameController.text.trim(),
        'especie': _selectedEspecie,
        'raca': _selectedRaca,
        'porte': _selectedPorte,
        'pelagem': _selectedPelagem,
        'idade': _selectedIdade,
        'sexo': _selectedSex, // Adiciona o sexo do pet
        'descricao': _descricaoController.text.trim(),
        'imagemUrl': downloadUrl, // A URL da imagem que acabamos de subir
        'imagePath': fileName, // caminho no Storage (ex: 'pets/123456789.jpg')
        'abrigoId': userId, // ID do abrigo que cadastrou
        'nomeOng': nomeOng, // Nome do abrigo para exibição no feed
        'cadastradoEm': Timestamp.now(),
        'searchKeywords': keywords.toList(), // Adiciona o array de busca
        'status': 'disponivel', // Status inicial
      });

      // 8. Voltar para a tela anterior após o sucesso
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet cadastrado com sucesso!')),
        );
      }
    } catch (e) {
      // 9. Tratar erros
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Erro ao salvar: $e");
    }
  }

  // Função de diálogo de erro genérica
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Novo Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Área de Visualização da Imagem
              GestureDetector(
                onTap: _pickImage, // Chama o seletor de imagem
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Clique no ícone para adicionar uma foto',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 30),

              // Formulário
              // Seleção de Espécie
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Espécie'),
                value: _selectedEspecie,
                hint: const Text('Selecione a espécie'),
                items: _especies.map((String especie) {
                  return DropdownMenuItem<String>(
                    value: especie,
                    child: Text(especie),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEspecie = newValue;

                    // RAÇAS DINÂMICAS
                    _racasDinamicas = racasPorEspecie[newValue] ?? [];
                    _selectedRaca = null;

                    // PELAGENS DINÂMICAS
                    _pelagensDinamicas = pelagensPorEspecie[newValue] ?? [];
                    _selectedPelagem = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nome do Pet'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              // Seleção de Raça
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Raça'),
                value: _selectedRaca,
                hint: const Text('Selecione a raça'),
                items: _racasDinamicas.map((String raca) {
                  return DropdownMenuItem<String>(
                    value: raca,
                    child: Text(raca),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedRaca = newValue);
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              // Seleção de Porte
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Porte'),
                value: _selectedPorte,
                hint: const Text('Selecione o porte'),
                items: _portes.map((String porte) {
                  return DropdownMenuItem<String>(
                    value: porte,
                    child: Text(porte),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedPorte = newValue);
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              // Seleção de Pelagem
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Pelagem'),
                value: _selectedPelagem,
                hint: const Text('Selecione a pelagem'),
                items: _pelagensDinamicas.map((String pelagem) {
                  return DropdownMenuItem<String>(
                    value: pelagem,
                    child: Text(pelagem),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedPelagem = newValue);
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),
              // Seleção de Idade
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Faixa de Idade'),
                value: _selectedIdade,
                hint: const Text('Selecione a faixa de idade'),
                items: _idades.map((String idade) {
                  return DropdownMenuItem<String>(
                    value: idade,
                    child: Text(idade),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedIdade = newValue);
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              // Seleção de Sexo
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Sexo'),
                value: _selectedSex,
                hint: const Text('Selecione o sexo'),
                items: ['Macho', 'Fêmea'].map((String sexo) {
                  return DropdownMenuItem<String>(
                    value: sexo,
                    child: Text(sexo),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedSex = newValue);
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: _inputDecoration('Descrição'),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 40),

              // Botão de Salvar
              _isLoading
                  ? const PetLoader()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Pet'),
                        onPressed: _savePet,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para decoração do Input
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      label: Text(label),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}
