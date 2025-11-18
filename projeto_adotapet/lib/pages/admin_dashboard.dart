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
  String? _getOngId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Stream<int> _getPendingRequestsCount() {
    final ongId = _getOngId();
    if (ongId == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: ongId)
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .asBroadcastStream();
  }

  Stream<int> _getApprovedRequestsCount() {
    final ongId = _getOngId();
    if (ongId == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: ongId)
        .where('status', isEqualTo: 'aprovado')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .asBroadcastStream();
  }

  Stream<int> _getRejectedRequestsCount() {
    final ongId = _getOngId();
    if (ongId == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('ongId', isEqualTo: ongId)
        .where('status', isEqualTo: 'rejeitado')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .asBroadcastStream();
  }

  Stream<int> _getAvailablePetsCount() {
    final ongId = _getOngId();
    if (ongId == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('pets')
        .where('abrigoId', isEqualTo: ongId)
        .where('status', isEqualTo: 'disponivel')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard da ONG')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard de Adoções',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            const Text(
              'Solicitações Recentes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRecentRequestsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestsList(BuildContext context) {
    final ongId = _getOngId();
    if (ongId == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Usuário não autenticado',
          style: TextStyle(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('adoption_requests')
          .where('ongId', isEqualTo: ongId)
          .where('status', isEqualTo: 'pendente')
          .snapshots()
          .asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Nenhuma solicitação pendente',
              style: TextStyle(color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          );
        }

        var requests = snapshot.data!.docs;

        // Ordenar por data decrescente e limitar a 5
        requests.sort((a, b) {
          final dateA =
              (a['requestDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
          final dateB =
              (b['requestDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
        requests = requests.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            final requestId = requests[index].id;
            final petName = data['petName'] ?? 'Pet desconhecido';
            final requestDate =
                (data['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedDate =
                '${requestDate.day}/${requestDate.month}/${requestDate.year}';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.assignment, color: Colors.blue),
                title: Text(petName),
                subtitle: Text(
                  formattedDate,
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
    final ongId = _getOngId();
    if (ongId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('adoption_requests')
              .where('ongId', isEqualTo: ongId)
              .where('status', isEqualTo: 'pendente')
              .snapshots()
              .asBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhuma solicitação pendente'));
            }

            var requests = snapshot.data!.docs;

            // Ordenar por data decrescente
            requests.sort((a, b) {
              final dateA =
                  (a['requestDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
              final dateB =
                  (b['requestDate'] as Timestamp?)?.toDate() ?? DateTime(1970);
              return dateB.compareTo(dateA);
            });

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final data = requests[index].data() as Map<String, dynamic>;
                final requestId = requests[index].id;
                final petName = data['petName'] ?? 'Pet desconhecido';

                return ListTile(
                  title: Text(petName),
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
