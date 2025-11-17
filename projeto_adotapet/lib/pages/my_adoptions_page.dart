import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adoption_request_edit_page.dart';

class MyAdoptionsPage extends StatefulWidget {
  const MyAdoptionsPage({super.key});

  @override
  State<MyAdoptionsPage> createState() => _MyAdoptionsPageState();
}

class _MyAdoptionsPageState extends State<MyAdoptionsPage> {
  late final Stream<QuerySnapshot> _requestsStream;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      _requestsStream = FirebaseFirestore.instance
          .collection('adoption_requests')
          .where('adotanteId', isEqualTo: _userId)
          .orderBy('requestDate', descending: true)
          .snapshots();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'aprovado':
        return Colors.green;
      case 'rejeitado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pendente':
        return '⏳ Pendente';
      case 'aprovado':
        return '✅ Aprovado';
      case 'rejeitado':
        return '❌ Rejeitado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Adoções'),
        backgroundColor: const Color(0xFF64B5F6),
      ),
      body: _userId == null
          ? const Center(child: Text('Usuário não autenticado.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Ocorreu um erro: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 80,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma solicitação de adoção ainda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final requestId = requests[index].id;
                    final status = data['status'] ?? 'pendente';
                    final petName = data['petName'] ?? 'Pet desconhecido';
                    final ongName = data['ongName'] ?? 'ONG desconhecida';
                    final requestDate =
                        (data['requestDate'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final formattedDate =
                        '${requestDate.day}/${requestDate.month}/${requestDate.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdoptionRequestEditPage(
                                requestId: requestId,
                                requestData: data,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          petName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ongName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        status,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                    child: Text(
                                      _getStatusLabel(status),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (status == 'rejeitado' &&
                                  data['rejectionReason'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.red[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          size: 16,
                                          color: Colors.red[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Motivo: ${data['rejectionReason']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
