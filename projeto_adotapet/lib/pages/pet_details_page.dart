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

class _PetDetailsPageState extends State<PetDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _liked = favoritePets.any((p) => p['petId'] == widget.petId);
  }

  void _toggleFavorite() {
    setState(() {
      if (_liked) {
        favoritePets.removeWhere((p) => p['petId'] == widget.petId);
      } else {
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
      _liked = !_liked;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            leading: _buildAppBarAction(
              context: context,
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
              _buildAppBarAction(
                context: context,
                icon: Icons.share,
                onPressed: () {
                  Share.share('Veja ${widget.name}: ${widget.description}');
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.3)
                      .chain(CurveTween(curve: Curves.easeOut))
                      .animate(_animationController),
                  child: _buildAppBarAction(
                    context: context,
                    icon: _liked ? Icons.favorite : Icons.favorite_border,
                    iconColor: _liked
                        ? Colors.red
                        : isLightMode
                            ? Colors.black87
                            : Colors.white,
                    onPressed: _toggleFavorite,
                  ),
                ),
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
                  SelectableText(
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
                        'Oferecido por ${widget.shelterName}',
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
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                    ),
                    children: [
                      _buildInfoCard('Idade', widget.age, Icons.cake_outlined),
                      _buildInfoCard('Sexo', widget.sex,
                          widget.sex == 'Macho' ? Icons.male : Icons.female),
                      _buildInfoCard('Porte', widget.size, Icons.height),
                      _buildInfoCard('Raça', widget.breed, Icons.pets),
                      if (widget.especie.isNotEmpty)
                        _buildInfoCard(
                            'Espécie', widget.especie, Icons.category_outlined),
                      if (widget.pelagem.isNotEmpty)
                        _buildInfoCard(
                            'Pelagem', widget.pelagem, Icons.style_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sobre
                  const Text(
                    'Sobre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
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

  Widget _buildAppBarAction({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white70 : Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? (isLightMode ? Colors.black87 : Colors.white)),
        onPressed: onPressed,
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
