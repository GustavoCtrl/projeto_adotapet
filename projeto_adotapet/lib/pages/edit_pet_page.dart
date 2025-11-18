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

  final List<String> _especies = ['Cão', 'Gato', 'Pássaro', 'Roedor', 'Outro'];
  final List<String> _racas = [
    'SRD (Sem Raça Definida)',
    'Poodle',
    'Labrador',
    'Golden Retriever',
    'Siamês',
    'Persa',
    'Outra',
  ];
  final List<String> _portes = ['Pequeno', 'Médio', 'Grande'];
  final List<String> _pelagens = ['Curto', 'Médio', 'Longo', 'Sem Pelo'];
  final List<String> _idades = [
    'Filhote (até 1 ano)',
    'Adulto (1 a 7 anos)',
    'Idoso (acima de 7 anos)',
  ];
  final List<String> _sexos = ['Macho', 'Fêmea'];

  String? _selectedEspecie;
  String? _selectedRaca;
  String? _selectedPorte;
  String? _selectedPelagem;
  String? _selectedIdade;
  String? _selectedSexo;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.petData['nome'] ?? '');
    _descricaoController = TextEditingController(
      text: widget.petData['descricao'] ?? '',
    );
    _currentImageUrl = widget.petData['imagemUrl'];
    _selectedEspecie = widget.petData['especie'] ?? _especies.first;
    _selectedRaca = widget.petData['raca'] ?? _racas.first;
    _selectedPorte = widget.petData['porte'] ?? _portes.first;
    _selectedPelagem = widget.petData['pelagem'] ?? _pelagens.first;
    _selectedIdade = widget.petData['idade'] ?? _idades.first;
    _selectedSexo = widget.petData['sexo'] ?? _sexos.first;
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

      // Se uma nova imagem foi selecionada
      if (_selectedImage != null) {
        // Deletar imagem antiga
        final oldImagePath = widget.petData['imagePath'] as String?;
        if (oldImagePath != null && oldImagePath.isNotEmpty) {
          try {
            await FirebaseStorage.instance.ref().child(oldImagePath).delete();
          } catch (_) {}
        }

        // Upload da nova imagem
        final fileName = 'pets/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_selectedImage!);
        newImageUrl = await ref.getDownloadURL();
        newImagePath = fileName;
      }

      // Atualizar Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagem
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
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Theme.of(context).hintColor,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedImage != null
                  ? 'Nova imagem selecionada'
                  : 'Toque para alterar imagem',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Nome
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Pet',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Espécie
            DropdownButtonFormField<String>(
              value: _selectedEspecie,
              items: _especies
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEspecie = v),
              decoration: InputDecoration(
                labelText: 'Espécie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Raça
            DropdownButtonFormField<String>(
              value: _selectedRaca,
              items: _racas
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRaca = v),
              decoration: InputDecoration(
                labelText: 'Raça',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Porte
            DropdownButtonFormField<String>(
              value: _selectedPorte,
              items: _portes
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPorte = v),
              decoration: InputDecoration(
                labelText: 'Porte',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pelagem
            DropdownButtonFormField<String>(
              value: _selectedPelagem,
              items: _pelagens
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPelagem = v),
              decoration: InputDecoration(
                labelText: 'Pelagem',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Idade
            DropdownButtonFormField<String>(
              value: _selectedIdade,
              items: _idades
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedIdade = v),
              decoration: InputDecoration(
                labelText: 'Idade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sexo
            DropdownButtonFormField<String>(
              value: _selectedSexo,
              items: _sexos
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSexo = v),
              decoration: InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Descrição
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descrição',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savePet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Alterações'),
                    ),
                  ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
