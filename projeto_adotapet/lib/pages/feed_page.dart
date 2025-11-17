import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../widgets/pet_card.dart';
import '../widgets/pet_load.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Variáveis para paginação
  final List<DocumentSnapshot> _pets = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _petsPerPage = 8;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchInitialPets();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoadingMore) {
        _fetchMorePets();
      }
    });
  }

  // Constrói a query base para pets
  Query _buildBaseQuery() {
    Query query = FirebaseFirestore.instance
        .collection('pets')
        .where('status', isEqualTo: 'disponivel');

    if (_search.isNotEmpty) {
      query = query.where(
        'searchKeywords',
        arrayContains: _search.trim().toLowerCase(),
      );
    }

    return query.orderBy('cadastradoEm', descending: true);
  }

  // Busca os pets iniciais (ou reseta a busca)
  Future<void> _fetchInitialPets() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMore = true; // Mostra loading inicial
      _pets.clear();
      _hasMore = true;
      _lastDocument = null;
    });

    try {
      final query = _buildBaseQuery().limit(_petsPerPage);
      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _pets.addAll(snapshot.docs);
          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
          }
          _hasMore = snapshot.docs.length == _petsPerPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      // Tratar erro se necessário
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // Busca mais pets para a paginação
  Future<void> _fetchMorePets() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    if (mounted) setState(() => _isLoadingMore = true);

    try {
      final query = _buildBaseQuery()
          .startAfterDocument(_lastDocument!)
          .limit(_petsPerPage);
      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _pets.addAll(snapshot.docs);
          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
          }
          _hasMore = snapshot.docs.length == _petsPerPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar pets, abrigo ou raça...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).hintColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).hintColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _search = '');
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    setState(() {
                      _search = value;
                    });
                    _fetchInitialPets(); // Reinicia a busca
                  });
                },
              ),
            ),
          ),
        ),
      ),
      body: _pets.isEmpty && _isLoadingMore
          ? const Center(child: PetLoader())
          : _pets.isEmpty
          ? Center(
              child: Text(
                'Nenhum pet encontrado.',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).hintColor,
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _pets.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _pets.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = _pets[index].data() as Map<String, dynamic>;
                return PetCard(
                  name: (data['nome'] ?? '').toString(),
                  description: (data['descricao'] ?? '').toString(),
                  photoUrl: (data['imagemUrl'] ?? '').toString(),
                  shelterName: (data['nomeOng'] ?? '').toString(),
                  age: (data['idade'] ?? '').toString(),
                  breed: (data['raca'] ?? '').toString(),
                  size: (data['porte'] ?? '').toString(),
                  sex: (data['sexo'] ?? '').toString(),
                  especie: (data['especie'] ?? '').toString(),
                  pelagem: (data['pelagem'] ?? '').toString(),
                  petId: _pets[index].id,
                  ongId: (data['abrigoId'] ?? '').toString(),
                  ongName: (data['nomeOng'] ?? '').toString(),
                );
              },
            ),
    );
  }
}
