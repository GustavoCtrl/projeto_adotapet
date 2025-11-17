import 'package:flutter/material.dart';
import 'feed_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'manage_pets_page.dart';
import 'admin_dashboard.dart';
import '../utils/auth_helper.dart';

class HomePage extends StatefulWidget {
  final String userRole;

  const HomePage({Key? key, this.userRole = 'adotante'}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // Estado interno para controlar a visão do admin
  late String _currentViewRole;

  @override
  void initState() {
    super.initState();
    // Se for admin, a visão inicial é 'adotante'. Senão, é o papel do usuário.
    _currentViewRole = widget.userRole == 'admin'
        ? 'adotante'
        : widget.userRole;
  }

  // Função para o admin trocar de visão
  void _switchAdminView() {
    setState(() {
      // Alterna entre a visão de adotante e de abrigo
      if (_currentViewRole == 'adotante') {
        _currentViewRole = 'abrigo';
      } else {
        _currentViewRole = 'adotante';
      }
      // Reseta o índice para a primeira aba ao trocar de interface
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se for um abrigo/ong, mostra a interface com gerenciamento de pets
    if (_currentViewRole == 'abrigo') {
      return _buildOngInterface();
    }

    // Por padrão (ou se for adotante), mostra a interface de adotante
    return _buildAdoptantInterface();
  }

  Widget _buildAdoptantInterface() {
    const pastelOrange = Color(0xFFFFB74D);

    final pages = [
      const FeedPage(),
      const FavoritesPage(),
      ProfilePage(
        userRole: widget.userRole,
        onSwitchView: widget.userRole == 'admin' ? _switchAdminView : null,
        currentAdminView: _currentViewRole,
      ),
    ];

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

  Widget _buildOngInterface() {
    const pastelBlue = Color(0xFF64B5F6);

    final pages = [
      const AdminDashboard(),
      const ManagePetsPage(),
      ProfilePage(
        userRole: widget.userRole,
        onSwitchView: widget.userRole == 'admin' ? _switchAdminView : null,
        currentAdminView: _currentViewRole,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: pastelBlue,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Meus Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
