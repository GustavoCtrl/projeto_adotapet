import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequestEditPage extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const AdoptionRequestEditPage({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  State<AdoptionRequestEditPage> createState() =>
      _AdoptionRequestEditPageState();
}

class _AdoptionRequestEditPageState extends State<AdoptionRequestEditPage> {
  bool _isLoading = false;
  bool _isEditing = false;
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _ocupacaoController;
  late TextEditingController _motivoController;

  @override
  void initState() {
    super.initState();
    final formData =
        widget.requestData['adoptionFormData'] as Map<String, dynamic>?;
    _nomeController = TextEditingController(text: formData?['nome'] ?? '');
    _telefoneController = TextEditingController(
      text: formData?['telefone'] ?? '',
    );
    _enderecoController = TextEditingController(
      text: formData?['endereco'] ?? '',
    );
    _ocupacaoController = TextEditingController(
      text: formData?['ocupacao'] ?? '',
    );
    _motivoController = TextEditingController(text: formData?['motivo'] ?? '');
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

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final adoptionFormData = {
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'ocupacao': _ocupacaoController.text.trim(),
        'motivo': _motivoController.text.trim(),
        'termsAgreed': true,
      };

      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .doc(widget.requestId)
          .update({'adoptionFormData': adoptionFormData});

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações atualizadas com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData =
        widget.requestData['adoptionFormData'] as Map<String, dynamic>?;
    final status = widget.requestData['status'] ?? 'pendente';
    final responseDate = widget.requestData['responseDate'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        actions: [
          if (status == 'pendente')
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                  },
                  child: Text(
                    _isEditing ? 'Cancelar' : 'Editar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'pendente'
                    ? Colors.orange
                    : status == 'aprovado'
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Informações do Pet
            const Text(
              'Informações do Pet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Nome do Pet',
              value: widget.requestData['petName'] ?? 'N/A',
              enabled: false,
            ),
            const SizedBox(height: 20),

            // Informações do Adotante
            const Text(
              'Suas Informações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Email',
              value: widget.requestData['adotanteEmail'] ?? 'N/A',
              enabled: false,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Nome',
              controller: _nomeController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Telefone',
              controller: _telefoneController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Endereço',
              controller: _enderecoController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Ocupação',
              controller: _ocupacaoController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),

            // Motivo da Adoção
            const Text(
              'Motivo da Adoção',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildEditableTextArea(
              label: 'Por que deseja adotar este pet?',
              controller: _motivoController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 20),

            // Data da Solicitação
            _buildInfoCard(
              label: 'Data da Solicitação',
              value: _formatDate(
                widget.requestData['requestDate'] as Timestamp?,
              ),
              enabled: false,
            ),
            const SizedBox(height: 12),

            // Data de Resposta (se houver)
            if (responseDate != null)
              _buildInfoCard(
                label: 'Data da Resposta',
                value: _formatDate(responseDate),
                enabled: false,
              ),

            // Motivo da Rejeição (se houver)
            if (status == 'rejeitado' &&
                widget.requestData['rejectionReason'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Motivo da Rejeição',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Text(
                      widget.requestData['rejectionReason'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Botão de Salvar (apenas se estiver editando e status for pendente)
            if (_isEditing && status == 'pendente')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
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
                          'Salvar Alterações',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  onPressed: _isLoading ? null : _saveChanges,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: !enabled,
            fillColor: !enabled
                ? Theme.of(context).cardColor
                : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTextArea({
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: !enabled,
            fillColor: !enabled
                ? Theme.of(context).cardColor
                : Colors.transparent,
          ),
        ),
      ],
    );
  }

  BuildContext get context => super.context;

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
