import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequest {
  final String id;
  final String petId;
  final String petName;
  final String adotanteId;
  final String adotanteEmail;
  final String ongId;
  final String ongName;
  final DateTime requestDate;
  final String status; // 'pendente', 'aprovado', 'rejeitado'
  final Map<String, dynamic> adoptionFormData;
  final String? rejectionReason;
  final DateTime? responseDate;

  AdoptionRequest({
    required this.id,
    required this.petId,
    required this.petName,
    required this.adotanteId,
    required this.adotanteEmail,
    required this.ongId,
    required this.ongName,
    required this.requestDate,
    required this.status,
    required this.adoptionFormData,
    this.rejectionReason,
    this.responseDate,
  });

  // Converter para JSON para salvar no Firestore
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'petName': petName,
      'adotanteId': adotanteId,
      'adotanteEmail': adotanteEmail,
      'ongId': ongId,
      'ongName': ongName,
      'requestDate': requestDate,
      'status': status,
      'adoptionFormData': adoptionFormData,
      'rejectionReason': rejectionReason,
      'responseDate': responseDate,
    };
  }

  // Criar a partir de um documento do Firestore
  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdoptionRequest(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      adotanteId: data['adotanteId'] ?? '',
      adotanteEmail: data['adotanteEmail'] ?? '',
      ongId: data['ongId'] ?? '',
      ongName: data['ongName'] ?? '',
      requestDate:
          (data['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pendente',
      adoptionFormData: data['adoptionFormData'] ?? {},
      rejectionReason: data['rejectionReason'],
      responseDate: (data['responseDate'] as Timestamp?)?.toDate(),
    );
  }
}
