import 'package:flutter/material.dart';
import 'feed_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../utils/auth_helper.dart';

class HomePage extends StatefulWidget {
  final String userRole;

  const HomePage({Key? key, this.userRole = 'adotante'}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Se for admin, mostrar painel admin
    if (widget.userRole == 'admin') {
      return _buildAdminInterface();
    }

    // Caso contrário, mostrar interface de adotante
    return _buildAdoptantInterface();
  }

  Widget _buildAdoptantInterface() {
    const pastelOrange = Color(0xFFFFB74D);

    final pages = const [FeedPage(), FavoritesPage(), ProfilePage()];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: pastelOrange,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildAdminInterface() {
    const pastelBlue = Color(0xFF64B5F6);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel Admin - ONG'),
        elevation: 0,
        backgroundColor: pastelBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _handleLogout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao Painel Administrativo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Card Gerenciar Pets
            _buildAdminCard(
              icon: Icons.pets,
              title: 'Gerenciar Pets',
              description: 'Adicionar, editar ou remover animais',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gerenciar Pets - Em desenvolvimento'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Card Ver Adoções
            _buildAdminCard(
              icon: Icons.handshake,
              title: 'Ver Adoções',
              description: 'Visualizar solicitações de adoção',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ver Adoções - Em desenvolvimento'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Card Configurações
            _buildAdminCard(
              icon: Icons.settings,
              title: 'Configurações da ONG',
              description: 'Editar informações da organização',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configurações - Em desenvolvimento'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32, color: const Color(0xFF64B5F6)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Você deseja sair da conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthHelper.logout();
    }
  }
}
