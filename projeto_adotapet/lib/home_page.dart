// lib/home_page.dart
// AdotaPet - Página inicial estilo Instagram com cores pastel

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _mockPets = [
    {
      'name': 'Andrews',
      'photo': 'https://i.imgur.com/I1Zsu1m.jpeg',
      'description': 'Carinhoso e brincalhão, ama correr no parque.',
    },
    {
      'name': 'Aniquilador',
      'photo': 'https://i.imgur.com/TsMeC8m.jpeg',
      'description': 'Muito obediente e protetor, ideal para família.',
    },
    {
      'name': 'Melzinha',
      'photo': 'https://i.imgur.com/ZJUNyTh.png',
      'description': 'Doce e calma, se dá bem com outros pets.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const pastelOrange = Color(0xFFFFB74D);
    const pastelBlue = Color(0xFF64B5F6);

    final _pages = [
      _buildFeedPage(pastelOrange, pastelBlue),
      const Center(child: Text('Favoritos', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Abrigo', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: pastelBlue,
        title: const Text('AdotaPet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: pastelOrange,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Abrigo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildFeedPage(Color pastelOrange, Color pastelBlue) {
    return ListView.builder(
      itemCount: _mockPets.length,
      itemBuilder: (context, i) {
        final pet = _mockPets[i];
        return _PetCard(
          name: pet['name']!,
          description: pet['description']!,
          photoUrl: pet['photo']!,
          pastelOrange: pastelOrange,
          pastelBlue: pastelBlue,
        );
      },
    );
  }
}

class _PetCard extends StatefulWidget {
  final String name;
  final String description;
  final String photoUrl;
  final Color pastelOrange;
  final Color pastelBlue;

  const _PetCard({
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.pastelOrange,
    required this.pastelBlue,
  });

  @override
  State<_PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<_PetCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📸 FOTO GRANDE DO PET (sem cortes)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

          // ❤️ ÍCONES DE INTERAÇÃO (CURTIR + ADOTAR)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? widget.pastelOrange : Colors.grey[700],
                    size: 28,
                  ),
                  onPressed: () => setState(() => _liked = !_liked),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.pastelBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Solicitação de adoção enviada para ${widget.name}!'),
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

          // 🐾 NOME E DESCRIÇÃO ABAIXO (tipo legenda do post)
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
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
