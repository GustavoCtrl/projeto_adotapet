import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/auth_helper.dart';
import 'home_page.dart';
import 'login_or_register_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se o usuário está logado
          if (snapshot.hasData) {
            // Busca os dados do usuário para verificar se é admin ou qual seu tipo
            return FutureBuilder<Map<String, dynamic>?>(
              future: AuthHelper.getCurrentUserData(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = userSnapshot.data;
                final bool isAdmin = userData?['isAdmin'] ?? false;
                final String userType = userData?['tipoUsuario'] ?? 'adotante';

                // Se é admin, mostrar seleção de papel
                if (isAdmin && _selectedRole == null) {
                  return _buildRoleSelector(context);
                }

                // Se for admin, usa o papel selecionado.
                // Se não for admin, usa o tipo de usuário do banco de dados.
                final role = isAdmin ? _selectedRole : userType;

                // Mostra a HomePage com o papel correto
                return HomePage(userRole: role ?? 'adotante');
              },
            );
          }
          // Se o usuário NÃO está logado
          else {
            _selectedRole = null; // Reset role quando faz logout
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecione o Papel'), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Você é um usuário administrador.\nEscolha como deseja acessar:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            // Botão Adotante
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRole = 'adotante';
                });
              },
              icon: const Icon(Icons.person),
              label: const Text('Acessar como Adotante'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botão Admin ONG
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRole = 'admin';
                });
              },
              icon: const Icon(Icons.business),
              label: const Text('Acessar como Admin ONG'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Botão para fazer logout
            TextButton.icon(
              onPressed: () {
                AuthHelper.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair (Logout)'),
            ),
          ],
        ),
      ),
    );
  }
}
