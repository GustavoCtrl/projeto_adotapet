import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Opções de tipo de usuário
enum UserType { adotante, abrigo }

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage; // Função para alternar para a tela de login
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variável para guardar o tipo de usuário selecionado
  UserType _selectedUserType = UserType.adotante;

  // Variável para marcar como admin
  bool _isAdmin = false;

  // Variável para controlar o estado de loading
  bool _isLoading = false;

  // Limpa os controladores quando o widget é descartado
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função principal de cadastro
  Future<void> _register() async {
    // 1. Validar se as senhas coincidem
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showErrorDialog("As senhas não coincidem.");
      return;
    }

    // 2. Mostrar indicador de loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Criar o usuário no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 4. Salvar os dados extras no Cloud Firestore
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String userTypeString = _selectedUserType == UserType.adotante
            ? 'adotante'
            : 'abrigo';

        // Criamos um 'documento' na coleção 'usuarios' com o ID do usuário
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'email': _emailController.text.trim(),
          'tipoUsuario': userTypeString,
          'uid': uid,
          'isAdmin': _isAdmin, // Campo de administrador
          'criadoEm': Timestamp.now(),
        });
      }

      // 5. Parar o loading (se o widget ainda estiver montado)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Não é preciso navegar, o AuthGate fará isso
    } on FirebaseAuthException catch (e) {
      // 6. Parar o loading e tratar erros do Firebase Auth
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'weak-password') {
        _showErrorDialog("A senha é muito fraca.");
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog("Este email já está em uso.");
      } else {
        _showErrorDialog("Erro ao cadastrar: ${e.message}");
      }
    } catch (e) {
      // 7. Tratar outros erros
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Ocorreu um erro inesperado: $e");
    }
  }

  // Função para mostrar um diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone ou Logo
                const Icon(Icons.pets, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                Text(
                  'Criar conta no AdotaPet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 30),

                // Seleção de Tipo de Usuário (MUITO IMPORTANTE)
                Text(
                  'Eu sou...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUserType = UserType.adotante;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedUserType == UserType.adotante
                                  ? Colors.teal
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedUserType == UserType.adotante
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _selectedUserType == UserType.adotante
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text('Adotante'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUserType = UserType.abrigo;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedUserType == UserType.abrigo
                                  ? Colors.teal
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedUserType == UserType.abrigo
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _selectedUserType == UserType.abrigo
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text('Abrigo / ONG'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo de Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'seuemail@exemplo.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Campo de Senha
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Confirmar Senha
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Checkbox para Administrador
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: const Text('Marcar como administrador'),
                    subtitle: const Text('Para testes e gerenciamento do app'),
                    value: _isAdmin,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAdmin = value ?? false;
                      });
                    },
                    activeColor: Colors.teal,
                    dense: true,
                  ),
                ),
                const SizedBox(height: 30),

                // Botão de Cadastrar
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Alternar para Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem uma conta?'),
                    TextButton(
                      onPressed: widget.showLoginPage, // Chama a função
                      child: const Text(
                        'Faça login!',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
