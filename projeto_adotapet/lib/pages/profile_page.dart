import 'package:flutter/material.dart';
import '../utils/auth_helper.dart';
import '../widgets/pet_load.dart';
import 'my_adoptions_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import '../main.dart' as main;

class ProfilePage extends StatefulWidget {
  final String? userRole;
  final VoidCallback? onSwitchView;
  final String? currentAdminView;

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
            },
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), elevation: 0),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PetLoader());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Erro ao carregar dados do perfil'),
            );
          }

          final userData = snapshot.data!;
          final nomeUsuario = userData['nomeUsuario'] ?? 'Usuário';
          final email = userData['email'] ?? 'Sem email';
          final isAdmin = userData['isAdmin'] ?? false;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Card com Nome do Usuário (Clicável)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userData: userData),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeUsuario,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Toque para editar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Menu em Lista
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Minhas Adoções
                      _buildMenuTile(
                        icon: Icons.pets,
                        title: 'Minhas Adoções',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MyAdoptionsPage(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 0, color: Theme.of(context).dividerColor),

                      // Configurações
                      _buildMenuTile(
                        icon: Icons.settings,
                        title: 'Configurações',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                isDarkMode: main.themeNotifier.value,
                                onThemeChanged: (isDark) {
                                  main.themeNotifier.value = isDark;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(height: 0, color: Theme.of(context).dividerColor),

                      // Logout
                      _buildMenuTile(
                        icon: Icons.logout,
                        title: 'Sair',
                        color: Colors.red,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de Trocar Visão (Apenas para Admins)
                if (isAdmin && widget.userRole == 'admin')
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(                        
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: const Text(
                        'Trocar Visão de Usuário',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: widget.onSwitchView,
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color != Colors.black87
            ? color
            : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color != Colors.black87
              ? color
              : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).hintColor,
      ),
      onTap: onTap,
    );
  }
}
