import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPetPage extends StatefulWidget {
  final String petId;
  final Map<String, dynamic> petData;

  const EditPetPage({required this.petId, required this.petData, super.key});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;

  //----------------------------------------------------------
  // 🔥 1. MAPS DINÂMICOS DE ESPÉCIE → RAÇA / PELAGEM
  //----------------------------------------------------------

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
    'Gato': [
      'SRD',
      'Siamês',
      'Persa',
      'Angorá',
      'Maine Coon',
      'Sphynx',
    ],
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
    'Pássaro': [
      'Penas curtas',
      'Penas longas',
      'Colorido',
    ],
    'Roedor': [
      'Curto',
      'Longo',
      'Liso',
      'Crespo',
    ],
    'Outro': ['Indefinido'],
  };

  //----------------------------------------------------------
  // 🔥 2. LISTAS
  //----------------------------------------------------------

  final List<String> _especies = ['Cão', 'Gato', 'Pássaro', 'Roedor', 'Outro'];
  final List<String> _portes = ['Pequeno', 'Médio', 'Grande'];
  final List<String> _sexos = ['Macho', 'Fêmea'];

  // Raças / pelagens dinâmicas
  List<String> _racasDinamicas = [];
  List<String> _pelagensDinamicas = [];

  // Idades dinâmicas: 0 a 20 anos
  final List<String> _idades = List.generate(
    21,
    (i) => i == 0 ? 'Filhote (< 1 ano)' : '$i anos',
  );

  //----------------------------------------------------------
  // 🔥 3. VALORES SELECIONADOS
  //----------------------------------------------------------

  String? _selectedEspecie;
  String? _selectedRaca;
  String? _selectedPorte;
  String? _selectedPelagem;
  String? _selectedIdade;
  String? _selectedSexo;

  //----------------------------------------------------------
  // 🟦 INITSTATE
  //----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.petData['nome'] ?? '');
    _descricaoController = TextEditingController(
      text: widget.petData['descricao'] ?? '',
    );
    _currentImageUrl = widget.petData['imagemUrl'];

    // Carregar valores existentes
    _selectedEspecie = widget.petData['especie'] ?? 'Cão';

    // 🔥 Carrega as listas DINÂMICAS com base na espécie salva
    _racasDinamicas = racasPorEspecie[_selectedEspecie] ?? [];
    _pelagensDinamicas = pelagensPorEspecie[_selectedEspecie] ?? [];

    _selectedRaca = widget.petData['raca'];
    _selectedPorte = widget.petData['porte'];
    _selectedPelagem = widget.petData['pelagem'];
    _selectedIdade = widget.petData['idade'];
    _selectedSexo = widget.petData['sexo'];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  //----------------------------------------------------------
  // 🔥 SALVAR ALTERAÇÕES
  //----------------------------------------------------------

  Future<void> _savePet() async {
    if (_nomeController.text.trim().isEmpty) {
      _showError('Nome do pet é obrigatório');
      return;
    }
    if (_descricaoController.text.trim().isEmpty) {
      _showError('Descrição é obrigatória');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newImageUrl = _currentImageUrl;
      String? newImagePath = widget.petData['imagePath'];

      if (_selectedImage != null) {
        final oldImagePath = widget.petData['imagePath'] as String?;
        if (oldImagePath != null && oldImagePath.isNotEmpty) {
          try {
            await FirebaseStorage.instance.ref().child(oldImagePath).delete();
          } catch (_) {}
        }

        final fileName = 'pets/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_selectedImage!);
        newImageUrl = await ref.getDownloadURL();
        newImagePath = fileName;
      }

      await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.petId)
          .update({
        'nome': _nomeController.text.trim(),
        'especie': _selectedEspecie,
        'raca': _selectedRaca,
        'porte': _selectedPorte,
        'pelagem': _selectedPelagem,
        'idade': _selectedIdade,
        'sexo': _selectedSexo,
        'descricao': _descricaoController.text.trim(),
        'imagemUrl': newImageUrl,
        'imagePath': newImagePath,
        'atualizadoEm': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  //----------------------------------------------------------
  // 🔥 UI
  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //------------------------------------------------------
            // FOTO
            //------------------------------------------------------
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : _currentImageUrl != null
                        ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                        : Icon(
                            Icons.camera_alt,
                            size: 60,
                            color: Theme.of(context).hintColor,
                          ),
              ),
            ),
            const SizedBox(height: 20),

            //------------------------------------------------------
            // NOME
            //------------------------------------------------------
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Pet',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // ESPÉCIE  🔥 (DINÂMICO)
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedEspecie,
              items: _especies
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  _selectedEspecie = valor;

                  // Atualizar listas dinâmicas
                  _racasDinamicas = racasPorEspecie[valor] ?? [];
                  _pelagensDinamicas = pelagensPorEspecie[valor] ?? [];

                  _selectedRaca = null;
                  _selectedPelagem = null;
                });
              },
              decoration: InputDecoration(
                labelText: 'Espécie',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // RAÇA 🔥
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedRaca,
              items: _racasDinamicas
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRaca = v),
              decoration: InputDecoration(
                labelText: 'Raça',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // PORTE
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedPorte,
              items: _portes
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPorte = v),
              decoration: InputDecoration(
                labelText: 'Porte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // PELAGEM 🔥
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedPelagem,
              items: _pelagensDinamicas
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPelagem = v),
              decoration: InputDecoration(
                labelText: 'Pelagem',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // IDADE 🔥 (DINÂMICA)
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedIdade,
              items: _idades
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedIdade = v),
              decoration: InputDecoration(
                labelText: 'Idade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // SEXO
            //------------------------------------------------------
            DropdownButtonFormField<String>(
              value: _selectedSexo,
              items: _sexos
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSexo = v),
              decoration: InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            //------------------------------------------------------
            // DESCRIÇÃO
            //------------------------------------------------------
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descrição',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            //------------------------------------------------------
            // SALVAR
            //------------------------------------------------------
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savePet,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Alterações'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
