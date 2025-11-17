import 'package:flutter/material.dart';
import '../widgets/pet_card.dart';
import '../data/favorites.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Configura um timer para atualizar a página periodicamente
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favoritePets.isEmpty
          ? const Center(
              child: Text(
                'Você ainda não tem pets favoritos!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favoritePets.length,
              itemBuilder: (context, index) {
                final pet = favoritePets[index];
                return PetCard(
                  name: pet['name']!,
                  description: pet['description']!,
                  photoUrl: pet['photo']!,
                  shelterName: pet['ongName'] ?? pet['shelter']!,
                  age: pet['age']!,
                  breed: pet['breed']!,
                  size: pet['size']!,
                  sex: pet['sex']!,
                  especie: pet['especie'] ?? '',
                  pelagem: pet['pelagem'] ?? '',
                  petId: pet['petId']!,
                  ongId: pet['ongId']!,
                  ongName: pet['ongName']!,
                );
              },
            ),
    );
  }
}
