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
            // Se é um usuário admin, mostrar seleção de papel
            return FutureBuilder<bool>(
              future: AuthHelper.isCurrentUserAdmin(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool isAdmin = adminSnapshot.data ?? false;

                // Se é admin, mostrar seleção de papel
                if (isAdmin && _selectedRole == null) {
                  return _buildRoleSelector(context);
                }

                // Caso contrário, mostrar HomePage normalmente
                return HomePage(userRole: _selectedRole ?? 'adotante');
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
            // Botão para mudar papel
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRole = null;
                });
              },
              child: const Text('Trocar de Papel'),
            ),
          ],
        ),
      ),
    );
  }
}
