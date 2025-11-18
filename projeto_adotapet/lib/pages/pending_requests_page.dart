import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adoption_request_detail_page.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  String? _getOngId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final ongId = _getOngId();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações Pendentes')),
      body: ongId == null
          ? const Center(child: Text('Usuário não autenticado.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('adoption_requests')
                  .where('ongId', isEqualTo: ongId)
                  .where('status', isEqualTo: 'pendente')
                  .orderBy('requestDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma solicitação pendente no momento.'),
                  );
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final requestId = requests[index].id;
                    final petName = data['petName'] ?? 'Pet desconhecido';
                    final adotanteEmail =
                        data['adotanteEmail'] ?? 'Email desconhecido';
                    final requestDate =
                        (data['requestDate'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final formattedDate =
                        '${requestDate.day}/${requestDate.month}/${requestDate.year}';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_ind),
                        title: Text(petName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(adotanteEmail),
                            const SizedBox(height: 4),
                            Text(
                              'Solicitado em: $formattedDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdoptionRequestDetailPage(
                                requestId: requestId,
                                requestData: data,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
