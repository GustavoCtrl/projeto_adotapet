import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequestDetailPage extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const AdoptionRequestDetailPage({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  State<AdoptionRequestDetailPage> createState() =>
      _AdoptionRequestDetailPageState();
}

class _AdoptionRequestDetailPageState extends State<AdoptionRequestDetailPage> {
  bool _isLoading = false;
  late TextEditingController _rejectionReasonController;

  @override
  void initState() {
    super.initState();
    _rejectionReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveRequest() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .doc(widget.requestId)
          .update({'status': 'aprovado', 'responseDate': DateTime.now()});

      // Atualizar status do pet para indisponível
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.requestData['petId'])
          .update({'status': 'adotado'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação aprovada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao aprovar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest() async {
    if (_rejectionReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o motivo da rejeição'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .doc(widget.requestId)
          .update({
            'status': 'rejeitado',
            'rejectionReason': _rejectionReasonController.text,
            'responseDate': DateTime.now(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação rejeitada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao rejeitar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Solicitação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por que deseja rejeitar esta solicitação?'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Motivo da rejeição...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest();
            },
            child: const Text('Rejeitar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formData =
        widget.requestData['adoptionFormData'] as Map<String, dynamic>?;
    final status = widget.requestData['status'] ?? 'pendente';
    final responseDate = widget.requestData['responseDate'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Solicitação')),
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
              value: widget.requestData['petName'] ?? 'Não informado',
            ),
            const SizedBox(height: 20),

            // Informações do Adotante
            const Text(
              'Informações do Adotante',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Email',
              value: widget.requestData['adotanteEmail'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(label: 'Nome', value: formData?['nome'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Telefone',
              value: formData?['telefone'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Endereço',
              value: formData?['endereco'] ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              label: 'Ocupação',
              value: formData?['ocupacao'] ?? 'N/A',
            ),
            const SizedBox(height: 20),

            // Motivo da Adoção
            const Text(
              'Motivo da Adoção',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                formData?['motivo'] ?? 'N/A',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Data da Solicitação
            _buildInfoCard(
              label: 'Data da Solicitação',
              value: _formatDate(
                widget.requestData['requestDate'] as Timestamp?,
              ),
            ),
            const SizedBox(height: 12),

            // Data de Resposta (se houver)
            if (responseDate != null)
              _buildInfoCard(
                label: 'Data da Resposta',
                value: _formatDate(responseDate),
              ),

            // Motivo da Rejeição (se houver)
            if (status == 'rejeitado' &&
                widget.requestData['rejectionReason'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Motivo da Rejeição',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
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

            // Botões de Ação (apenas se status for pendente)
            if (status == 'pendente')
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
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
                              'Aprovar Solicitação',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      onPressed: _isLoading ? null : _approveRequest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        'Rejeitar Solicitação',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _isLoading ? null : _showRejectDialog,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String label, required String value}) {
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

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
