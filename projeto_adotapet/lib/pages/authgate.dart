import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/auth_helper.dart';
import 'home_page.dart';
import 'login_or_register_page.dart';
import '../widgets/pet_load.dart';
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
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
                  return const Center(child: PetLoader());
                }

                final userData = userSnapshot.data;
                final bool isAdmin = userData?['isAdmin'] ?? false;
                final String userType = userData?['tipoUsuario'] ?? 'adotante';

                // Se for admin, passa o papel 'admin'. A HomePage vai gerenciar a troca.
                // Senão, passa o tipo de usuário normal ('abrigo' ou 'adotante').
                final role = isAdmin ? 'admin' : userType;

                // Mostra a HomePage com o papel correto
                return HomePage(userRole: role ?? 'adotante');
              },
            );
          }
          // Se o usuário NÃO está logado
          else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
