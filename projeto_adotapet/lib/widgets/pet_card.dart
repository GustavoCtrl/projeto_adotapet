import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/favorites.dart';
import '../pages/pet_details_page.dart';

class PetCard extends StatefulWidget {
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

  const PetCard({
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
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
    bool _liked = favoritePets.any((pet) => pet['name'] == widget.name);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PetDetailsPage(
              name: widget.name,
              description: widget.description,
              photoUrl: widget.photoUrl,
              pastelOrange: widget.pastelOrange,
              pastelBlue: widget.pastelBlue,
              shelterName: widget.shelterName,
              age: widget.age,
              breed: widget.breed,
              size: widget.size,
              sex: widget.sex,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 🏷️ ÓRGÃO DOADOR
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.home_work, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.shelterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),

            // 📸 FOTO GRANDE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
              child: Image.network(
                widget.photoUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.pets, size: 60, color: Colors.grey),
                ),
              ),
            ),

            // ❤️ ÍCONES DE INTERAÇÃO (CURTIR + COMPARTILHAR + ADOTAR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // ❤️ FAVORITAR
                      IconButton(
                        icon: Icon(
                          _liked ? Icons.favorite : Icons.favorite_border,
                          color: _liked
                              ? widget.pastelOrange
                              : widget.pastelOrange,
                          size: 28,
                        ),
                        onPressed: () {
                          if (_liked) {
                            favoritePets.removeWhere(
                              (pet) => pet['name'] == widget.name,
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
                          }
                          setState(() {}); // Atualiza o ícone do coração

                          // Mostra uma mensagem de confirmação
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _liked
                                    ? '${widget.name} removido dos favoritos'
                                    : '${widget.name} adicionado aos favoritos',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      // 📤 COMPARTILHAR
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: widget.pastelOrange,
                          size: 26,
                        ),
                        onPressed: () {
                          Share.share(
                            '🐾 Olha só o ${widget.name}! ${widget.description}\nAdote também no AdotaPet 💕',
                          );
                        },
                      ),
                    ],
                  ),
                  // 🐶 ADOTAR
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.pastelOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                    icon: const Icon(Icons.pets, color: Colors.white, size: 18),
                    label: const Text(
                      'Adotar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 🐾 INFORMAÇÕES DO PET
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
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
                  Text(
                    widget.description,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // 🏷️ CATEGORIAS (idade, raça, tamanho, sexo)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
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
                ],
              ),
            ),
            const SizedBox(height: 8),
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
