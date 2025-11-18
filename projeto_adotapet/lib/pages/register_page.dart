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
  final _formKey = GlobalKey<FormState>();
  // Controladores de texto
  final _nomeUsuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Campos específicos para ONG
  final _nomeOngController = TextEditingController();
  final _nomeAdministradorController = TextEditingController();
  final _enderecoController = TextEditingController();

  // Variável para guardar o tipo de usuário selecionado
  UserType _selectedUserType = UserType.adotante;

  // Variável para marcar como admin
  bool _isAdmin = false;

  // Variável para controlar o estado de loading
  bool _isLoading = false;

  // Limpa os controladores quando o widget é descartado
  @override
  void dispose() {
    _nomeUsuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomeOngController.dispose();
    _nomeAdministradorController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  // Função principal de cadastro
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

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
        final userDoc = <String, dynamic>{
          'nomeUsuario': _nomeUsuarioController.text.trim(),
          'email': _emailController.text.trim(),
          'tipoUsuario': userTypeString,
          'uid': uid,
          'isAdmin': _isAdmin, // Campo de administrador
          'criadoEm': Timestamp.now(),
        };

        // Se for abrigo, adiciona informações específicas da ONG
        if (_selectedUserType == UserType.abrigo) {
          userDoc.addAll({
            'nomeOng': _nomeOngController.text.trim(),
            'nomeAdministrador': _nomeAdministradorController.text.trim(),
            'endereco': _enderecoController.text.trim(),
          });
        }

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .set(userDoc);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone ou Logo
                  Icon(Icons.pets,
                      size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    'Criar conta no AdotaPet',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color ??
                          Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Seleção de Tipo de Usuário (MUITO IMPORTANTE)
                  Text(
                    'Eu sou...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.grey[700],
                    ),
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
                                    ? Theme.of(context).colorScheme.primary
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
                                      ? Theme.of(context).colorScheme.primary
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
                                    ? Theme.of(context).colorScheme.primary
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
                                      ? Theme.of(context).colorScheme.primary
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

                  // Campo de Nome
                  TextFormField(
                    controller: _nomeUsuarioController,
                    decoration: InputDecoration(
                      labelText: 'Seu Nome',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 15),

                  // Campo de Email
                  TextFormField(
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
                    validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Email é obrigatório' : null,
                  ),
                  const SizedBox(height: 15),

                  // Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Senha é obrigatória';
                      if (value!.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Confirmar Senha
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Campos específicos para ONG (aparecem somente quando selecionado Abrigo)
                  if (_selectedUserType == UserType.abrigo) ...[
                    TextFormField(
                      controller: _nomeOngController,
                      decoration: InputDecoration(
                        labelText: 'Nome da ONG',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => _selectedUserType == UserType.abrigo &&
                              (value?.isEmpty ?? true)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomeAdministradorController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Administrador',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => _selectedUserType == UserType.abrigo &&
                              (value?.isEmpty ?? true)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: InputDecoration(
                        labelText: 'Endereço',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => _selectedUserType == UserType.abrigo &&
                              (value?.isEmpty ?? true)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 15),
                  ],

                  const SizedBox(height: 30),

                  // Botão de Cadastrar
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
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
                        child: Text(
                          'Faça login!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }
}
