import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String nome;
  final String especie;
  final String sexo;
  final String porte;
  final String idade;
  final String raca;
  final String descricao;
  final String imagemUrl;
  final String abrigoId;
  final String status;

  Pet({
    required this.id,
    required this.nome,
    required this.especie,
    required this.sexo,
    required this.porte,
    required this.idade,
    required this.raca,
    required this.descricao,
    required this.imagemUrl,
    required this.abrigoId,
    required this.status,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      nome: data['nome'] ?? '',
      especie: data['especie'] ?? '',
      sexo: data['sexo'] ?? '',
      porte: data['porte'] ?? '',
      idade: data['idade'] ?? '',
      raca: data['raca'] ?? '',
      descricao: data['descricao'] ?? '',
      imagemUrl: data['imagemUrl'] ?? '',
      abrigoId: data['abrigoId'] ?? '',
      status: data['status'] ?? '',
    );
  }
}
