import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/favorites.dart';
import 'adoption_form_page.dart';

class PetDetailsPage extends StatefulWidget {
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

  const PetDetailsPage({
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
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = favoritePets.any((p) => p['petId'] == widget.petId);
  }

  void _toggleFavorite() {
    setState(() {
      if (_liked) {
        favoritePets.removeWhere((p) => p['petId'] == widget.petId);
        _liked = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.name} removido dos favoritos')),
        );
      } else {
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
        _liked = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.name} adicionado aos favoritos')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pastelOrange = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: pastelOrange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                widget.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.pets, size: 80, color: Colors.grey),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  Share.share('🐾 Veja ${widget.name}: ${widget.description}');
                },
              ),
              IconButton(
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e Abrigo
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.home_work,
                        color: Theme.of(context).hintColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.shelterName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Características
                  const Text(
                    'Características',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoCard('Idade', widget.age, Icons.cake),
                      _buildInfoCard(
                        'Sexo',
                        widget.sex,
                        widget.sex == 'Macho' ? Icons.male : Icons.female,
                      ),
                      _buildInfoCard('Porte', widget.size, Icons.height),
                      _buildInfoCard('Raça', widget.breed, Icons.pets),
                      if (widget.especie.isNotEmpty)
                        _buildInfoCard(
                          'Espécie',
                          widget.especie,
                          Icons.category,
                        ),
                      if (widget.pelagem.isNotEmpty)
                        _buildInfoCard('Pelagem', widget.pelagem, Icons.style),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sobre
                  const Text(
                    'Sobre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: pastelOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdoptionFormPage(
                  petId: widget.petId,
                  petName: widget.name,
                  ongId: widget.ongId,
                  ongName: widget.ongName,
                ),
              ),
            );
          },
          icon: const Icon(Icons.pets),
          label: const Text(
            'Quero Adotar!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
