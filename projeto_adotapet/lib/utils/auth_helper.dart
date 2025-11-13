import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifica se o usuário atual é administrador
  static Future<bool> isCurrentUserAdmin() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return false;

      return userDoc.get('isAdmin') as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtém todos os dados do usuário
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Atualiza o status de admin (apenas para testes/desenvolvimento)
  static Future<void> setAdminStatus(String uid, bool isAdmin) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'isAdmin': isAdmin,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Obtém o tipo de usuário (adotante ou abrigo)
  static Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.get('tipoUsuario') as String?;
    } catch (e) {
      return null;
    }
  }

  /// Faz logout do usuário
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
