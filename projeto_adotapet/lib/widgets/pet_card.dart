import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/favorites.dart';
import '../pages/pet_details_page.dart';
import '../pages/adoption_form_page.dart';

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
    required this.pastelOrange,
    required this.pastelBlue,
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

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
    final bool liked = favoritePets.any((pet) => pet['name'] == widget.name);

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
              especie: widget.especie,
              pelagem: widget.pelagem,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 🏷️ ABRIGO HEADER
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
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.more_vert, size: 20),
                ],
              ),
            ),

            // 📸 IMAGEM COM OVERLAY (nome + idade + gradiente)
            Stack(
              children: [
                // Imagem de fundo
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(0),
                  ),
                  child: Image.network(
                    widget.photoUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 240,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pets,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Gradiente overlay (preto no fundo para contraste)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Nome + Idade no overlay
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.age,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.especie.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.especie,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ❤️ Botão de favoritar no canto superior direito
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      final wasLiked = liked;
                      if (wasLiked) {
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
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasLiked
                                ? '${widget.name} removido dos favoritos'
                                : '${widget.name} adicionado aos favoritos',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: widget.pastelOrange,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // � DESCRIÇÃO + DETALHES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    widget.description,
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.black87,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // 🏷️ CHIPS COM CARACTERÍSTICAS
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildMiniChip(
                        'Raça: ${widget.breed}',
                        widget.pastelOrange,
                      ),
                      _buildMiniChip('Porte: ${widget.size}', Colors.teal),
                      if (widget.pelagem.isNotEmpty)
                        _buildMiniChip(
                          'Pelagem: ${widget.pelagem}',
                          Colors.brown,
                        ),
                      _buildMiniChip(
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

            // 🔘 AÇÕES (COMPARTILHAR + ADOTAR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: widget.pastelOrange,
                      size: 22,
                    ),
                    iconSize: 28,
                    onPressed: () {
                      Share.share(
                        '🐾 Olha só o ${widget.name}! ${widget.description}\nAdote também no AdotaPet 💕',
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.pastelOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
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
                    icon: const Icon(Icons.pets, color: Colors.white, size: 16),
                    label: const Text(
                      'Adotar',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
