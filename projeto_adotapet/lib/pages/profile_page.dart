import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/auth_helper.dart';

class ProfilePage extends StatefulWidget {
  final String? userRole; // 'adotante' ou 'ong' (apenas para admins)
  final VoidCallback? onSwitchView; // Função para o admin trocar de visão
  final String? currentAdminView; // Visão atual do admin

  const ProfilePage({
    super.key,
    this.userRole,
    this.onSwitchView,
    this.currentAdminView,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userDataFuture = AuthHelper.getCurrentUserData();
  }

  Future<void> _logout() async {
    // Mostrar diálogo de confirmação
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja desconectar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthHelper.logout();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Você foi desconectado com sucesso.'),
                  ),
                );
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'), // Título do AppBar
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Erro ao carregar dados do perfil'),
            );
          }

          final userData = snapshot.data!;
          final email = userData['email'] ?? 'Sem email';
          final tipoUsuario = userData['tipoUsuario'] ?? 'Desconhecido';
          final isAdmin = userData['isAdmin'] ?? false;
          final nomeOng = userData['nomeOng'] ?? '';
          final nomeAdministrador = userData['nomeAdministrador'] ?? '';
          final endereco = userData['endereco'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header com avatar
                Container(
                  // Usando a cor primária do tema
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        // Removido const
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAdmin ? '👑 Administrador' : tipoUsuario,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Informações do usuário
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo de usuário
                      _buildInfoCard(
                        title: 'Tipo de Conta',
                        value: tipoUsuario == 'adotante'
                            ? '🐾 Adotante'
                            : '🏢 ONG/Abrigo',
                        icon: Icons.account_circle,
                      ),

                      const SizedBox(height: 16),

                      // Se for ONG, mostrar informações
                      if (tipoUsuario == 'abrigo') ...[
                        _buildInfoCard(
                          title: 'Nome da ONG',
                          value: nomeOng.isEmpty ? 'Não informado' : nomeOng,
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: 'Administrador',
                          value: nomeAdministrador.isEmpty
                              ? 'Não informado'
                              : nomeAdministrador,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          title: 'Endereço',
                          value: endereco.isEmpty ? 'Não informado' : endereco,
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Se for admin, mostrar opção de trocar role
                      if (isAdmin) ...[
                        const Divider(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onSwitchView,
                            icon: const Icon(Icons.switch_account),
                            label: Text(
                              widget.currentAdminView == 'adotante'
                                  ? 'Mudar para Visão ONG'
                                  : 'Mudar para Visão Adotante',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Como administrador, você pode alternar entre as interfaces.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],

                      // Botão de Logout
                      const Divider(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Sair da Conta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _logout,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Removido const
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
