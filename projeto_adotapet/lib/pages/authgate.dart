import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_or_register_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // 'authStateChanges' é o "ouvinte" do Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se o usuário está logado (snapshot tem dados)
          if (snapshot.hasData) {
            return const HomePage();
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
