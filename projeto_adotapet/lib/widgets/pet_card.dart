import 'package:flutter/material.dart';
import '../data/favorites.dart';
import '../pages/pet_details_page.dart';

class PetCard extends StatefulWidget {
  final String name;
  final String description;
  final String photoUrl;
  final String shelterName;
  final String age;
  final String breed;
  final String size;
  final String sex;
  final String especie;
  final String pelagem;
  final String petId;
  final String ongId;
  final String ongName;

  const PetCard({
    super.key,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.shelterName,
    required this.age,
    required this.breed,
    required this.size,
    required this.sex,
    this.especie = '',
    this.pelagem = '',
    required this.petId,
    required this.ongId,
    required this.ongName,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFavorited =
        favoritePets.any((pet) => pet['petId'] == widget.petId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PetDetailsPage(
                name: widget.name,
                description: widget.description,
                photoUrl: widget.photoUrl,
                shelterName: widget.shelterName,
                age: widget.age,
                breed: widget.breed,
                size: widget.size,
                sex: widget.sex,
                especie: widget.especie,
                pelagem: widget.pelagem,
                petId: widget.petId,
                ongId: widget.ongId,
                ongName: widget.ongName,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Image.network(
                  widget.photoUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, size: 70, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {                      
                      if (isFavorited) {
                        favoritePets.removeWhere(
                          (pet) => pet['petId'] == widget.petId,
                        );
                      } else {
                        // Animação ao favoritar
                        _animationController.forward(from: 0.0);
                        favoritePets.add({
                          'petId': widget.petId,
                          'name': widget.name,
                          'photo': widget.photoUrl,
                          'description': widget.description,
                          'shelter': widget.shelterName,
                          'age': widget.age,
                          'breed': widget.breed,
                          'size': widget.size,
                          'sex': widget.sex,
                          'especie': widget.especie,
                          'pelagem': widget.pelagem,
                          'ongId': widget.ongId,
                          'ongName': widget.ongName,
                        });
                      }
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.redAccent : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            widget.sex == 'Macho' ? Icons.male : Icons.female,
                            size: 16,
                            color: widget.sex == 'Macho'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.sex,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
