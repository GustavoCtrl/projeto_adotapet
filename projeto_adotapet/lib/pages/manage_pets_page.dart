import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro_pet.dart';
import 'edit_pet_page.dart';
import '../widgets/pet_load.dart';

class ManagePetsPage extends StatefulWidget {
  const ManagePetsPage({Key? key}) : super(key: key);

  @override
  State<ManagePetsPage> createState() => _ManagePetsPageState();
}

class _ManagePetsPageState extends State<ManagePetsPage> {
  String? uid;
  late Query petsQuery;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    petsQuery = FirebaseFirestore.instance
        .collection('pets')
        .where('abrigoId', isEqualTo: uid)
        .orderBy('cadastradoEm', descending: true);
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    QueryDocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    final imagePath = (data['imagePath'] ?? '') as String;

    // Capture ScaffoldMessenger early to avoid using BuildContext across async gaps
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja remover este pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('pets').doc(doc.id).delete();

      if (imagePath.isNotEmpty) {
        try {
          await FirebaseStorage.instance.ref().child(imagePath).delete();
        } catch (_) {
          // ignore
        }
      }

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Pet removido')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Pets')),
        body: const Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPetPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: petsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PetLoader());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum pet cadastrado ainda'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final nome = data['nome'] ?? 'Sem nome';
              final imagemUrl = data['imagemUrl'] as String?;
              final status = data['status'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: imagemUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imagemUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.pets, size: 48),
                  title: Text(nome),
                  subtitle: Text('Status: $status'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await _confirmAndDelete(context, doc);
                      } else if (value == 'edit') {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditPetPage(petId: doc.id, petData: data),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Remover'),
                      ),
                    ],
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
