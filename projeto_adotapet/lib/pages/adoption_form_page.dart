import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/adoption_request.dart';

class AdoptionFormPage extends StatefulWidget {
  final String petId;
  final String petName;
  final String ongId;
  final String ongName;

  const AdoptionFormPage({
    super.key,
    required this.petId,
    required this.petName,
    required this.ongId,
    required this.ongName,
  });

  @override
  State<AdoptionFormPage> createState() => _AdoptionFormPageState();
}

class _AdoptionFormPageState extends State<AdoptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Controllers para o formulário
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _ocupacaoController;
  late TextEditingController _motivoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _ocupacaoController = TextEditingController();
    _motivoController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _ocupacaoController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _submitAdoptionRequest() async {
    if (!_formKey.currentState!.validate() || !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, preencha todos os campos e concorde com os termos',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Dados do formulário de adoção
      final adoptionFormData = {
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'ocupacao': _ocupacaoController.text.trim(),
        'motivo': _motivoController.text.trim(),
        'termsAgreed': _agreeToTerms,
      };

      // Criar documento de requisição de adoção
      final adoptionRequest = AdoptionRequest(
        id: '', // Será preenchido pelo Firestore
        petId: widget.petId,
        petName: widget.petName,
        adotanteId: user.uid,
        adotanteEmail: user.email ?? '',
        ongId: widget.ongId,
        ongName: widget.ongName,
        requestDate: DateTime.now(),
        status: 'pendente',
        adoptionFormData: adoptionFormData,
      );

      // Salvar no Firestore
      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .add(adoptionRequest.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação de adoção enviada com sucesso!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar solicitação: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Adoção'),
        backgroundColor: const Color(0xFF64B5F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com info do pet
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet: ${widget.petName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ONG: ${widget.ongName}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seção de Regras e Termos
              const Text(
                '📋 Termos e Condições',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermItem(
                      '1. O pet será sua responsabilidade permanente',
                    ),
                    _buildTermItem(
                      '2. Você deve providenciar cuidados veterinários regulares',
                    ),
                    _buildTermItem(
                      '3. Ambientes seguro e apropriado para o animal',
                    ),
                    _buildTermItem(
                      '4. Em caso de impossibilidade de cuidar, retornar à ONG',
                    ),
                    _buildTermItem(
                      '5. Aceitar visitas de acompanhamento da ONG (se necessário)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox de concordância
              CheckboxListTile(
                title: const Text('Concordo com os termos e condições'),
                value: _agreeToTerms,
                onChanged: (value) =>
                    setState(() => _agreeToTerms = value ?? false),
              ),
              const SizedBox(height: 24),

              // Seção de Dados do Adotante
              const Text(
                '👤 Seus Dados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Telefone é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Endereço é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _ocupacaoController,
                decoration: const InputDecoration(
                  labelText: 'Ocupação',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Ocupação é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Por que deseja adotar este pet?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Motivo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de envio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enviar Solicitação',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  onPressed: _isLoading ? null : _submitAdoptionRequest,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
