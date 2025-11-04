import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/favorites.dart';

class PetDetailsPage extends StatefulWidget {
  final String name;
  final String description;
  final String photoUrl;
  final Color pastelOrange;
  final Color pastelBlue;
  final String shelterName;
  final String age;
  final String breed;
  final String size;
  final String sex;

  const PetDetailsPage({
    super.key,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.pastelOrange,
    required this.pastelBlue,
    required this.shelterName,
    required this.age,
    required this.breed,
    required this.size,
    required this.sex,
  });

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = favoritePets.any((p) => p['name'] == widget.name);
  }

  void _toggleFavorite() {
    setState(() {
      if (_liked) {
        favoritePets.removeWhere((p) => p['name'] == widget.name);
        _liked = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.name} removido dos favoritos')),
        );
      } else {
        favoritePets.add({
          'name': widget.name,
          'photo': widget.photoUrl,
          'description': widget.description,
          'shelter': widget.shelterName,
          'age': widget.age,
          'breed': widget.breed,
          'size': widget.size,
          'sex': widget.sex,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: widget.pastelOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('🐾 Veja ${widget.name}: ${widget.description}');
            },
          ),
          IconButton(
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.photoUrl,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 320,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(Icons.pets, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildChip('Idade: ${widget.age}', widget.pastelBlue),
                      _buildChip('Raça: ${widget.breed}', widget.pastelOrange),
                      _buildChip('Tamanho: ${widget.size}', Colors.teal),
                      _buildChip(
                        'Sexo: ${widget.sex}',
                        widget.sex == 'Fêmea'
                            ? Colors.pinkAccent
                            : Colors.lightBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Abrigo',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(widget.shelterName),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.pastelOrange,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Solicitação de adoção enviada para ${widget.name}!',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.pets, color: Colors.white),
                        label: const Text(
                          'Adotar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}
