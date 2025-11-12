import 'package:flutter/material.dart';
import '../pages/home_page.dart'; // Seus imports
import 'package:firebase_core/firebase_core.dart'; // Import do Firebase
import 'firebase_options.dart'; // Import do arquivo de configuração

void main() async {
  // 1. GARANTE que o Flutter está pronto ANTES de tudo.
  //    Esta linha DEVE ser a primeira.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIALIZA o Firebase.
  //    Usa o 'await' para esperar a conexão antes de continuar.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. RODA o seu App.
  //    Esta linha DEVE ser a última.
  runApp(const AdotaPetApp());
}

class AdotaPetApp extends StatelessWidget {
  const AdotaPetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AdotaPet',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}