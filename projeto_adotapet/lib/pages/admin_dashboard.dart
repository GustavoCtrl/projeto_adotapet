import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adoption_request_detail_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late String _ongId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initOngId();
  }

  Future<void> _initOngId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _ongId = user.uid;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Stream<int> _getPendingRequestsCount() {
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: _ongId)
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getApprovedRequestsCount() {
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: _ongId)
        .where('status', isEqualTo: 'aprovado')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getRejectedRequestsCount() {
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: _ongId)
        .where('status', isEqualTo: 'rejeitado')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> _getAvailablePetsCount() {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('abrigoId', isEqualTo: _ongId)
        .where('status', isEqualTo: 'disponivel')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard da ONG'),
        backgroundColor: const Color(0xFF64B5F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              '📊 Dashboard de Adoções',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Estatísticas em Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  title: 'Solicitações Pendentes',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  stream: _getPendingRequestsCount(),
                  onTap: () => _showPendingRequests(),
                ),
                _buildStatCard(
                  title: 'Pets Disponíveis',
                  icon: Icons.pets,
                  color: Colors.blue,
                  stream: _getAvailablePetsCount(),
                ),
                _buildStatCard(
                  title: 'Adoções Aprovadas',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  stream: _getApprovedRequestsCount(),
                ),
                _buildStatCard(
                  title: 'Solicitações Rejeitadas',
                  icon: Icons.cancel,
                  color: Colors.red,
                  stream: _getRejectedRequestsCount(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Seção de Solicitações Recentes
            const Text(
              '📋 Solicitações Recentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('adoption_requests')
                  .where('ongId', isEqualTo: _ongId)
                  .where('status', isEqualTo: 'pendente')
                  .orderBy('requestDate', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Nenhuma solicitação pendente',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final requests = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final requestId = requests[index].id;
                    final petName = data['petName'] ?? 'Pet desconhecido';
                    final adotanteEmail = data['adotanteEmail'] ?? 'N/A';
                    final requestDate = (data['requestDate'] as Timestamp)
                        .toDate();
                    final formattedDate =
                        '${requestDate.day}/${requestDate.month}/${requestDate.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.assignment,
                          color: Colors.blue,
                        ),
                        title: Text(petName),
                        subtitle: Text(
                          '$adotanteEmail • $formattedDate',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<int> stream,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final count = snapshot.data ?? 0;
                return Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingRequests() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('adoption_requests')
              .where('ongId', isEqualTo: _ongId)
              .where('status', isEqualTo: 'pendente')
              .orderBy('requestDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhuma solicitação pendente'));
            }

            final requests = snapshot.data!.docs;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final data = requests[index].data() as Map<String, dynamic>;
                final requestId = requests[index].id;
                final petName = data['petName'] ?? 'Pet desconhecido';
                final adotanteEmail = data['adotanteEmail'] ?? 'N/A';

                return ListTile(
                  title: Text('$petName - $adotanteEmail'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdoptionRequestDetailPage(
                          requestId: requestId,
                          requestData: data,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
