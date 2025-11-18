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

  // 🔥 FILTROS
  String? _selectedEspecie;
  String? _selectedPorte;
  String? _selectedSexo;
  String? _selectedIdade;

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

  // Constrói a query base para pets com filtros
  Query _buildBaseQuery() {
    Query query = FirebaseFirestore.instance
        .collection('pets')
        .where('status', isEqualTo: 'disponivel');

    // Filtro de busca por keywords
    if (_search.isNotEmpty) {
      query = query.where(
        'searchKeywords',
        arrayContains: _search.trim().toLowerCase(),
      );
    }

    // 🔥 Aplicar APENAS UM filtro adicional para evitar necessidade de índices
    // Os outros filtros serão aplicados no cliente
    if (_selectedEspecie != null) {
      query = query.where('especie', isEqualTo: _selectedEspecie);
    }

    return query.orderBy('cadastradoEm', descending: true);
  }

  // 🔥 Filtra os pets no lado do cliente
  List<DocumentSnapshot> _applyClientSideFilters(List<DocumentSnapshot> pets) {
    return pets.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Aplicar filtros restantes no cliente
      if (_selectedPorte != null && data['porte'] != _selectedPorte) {
        return false;
      }
      if (_selectedSexo != null && data['sexo'] != _selectedSexo) {
        return false;
      }
      if (_selectedIdade != null && data['idade'] != _selectedIdade) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Busca os pets iniciais (ou reseta a busca)
  Future<void> _fetchInitialPets() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMore = true;
      _pets.clear();
      _hasMore = true;
      _lastDocument = null;
    });

    try {
      // Buscar mais docs para compensar filtros no cliente
      final query = _buildBaseQuery().limit(_petsPerPage * 3);
      final snapshot = await query.get();

      if (mounted) {
        // 🔥 Aplicar filtros no cliente
        final filteredPets = _applyClientSideFilters(snapshot.docs);
        
        setState(() {
          _pets.addAll(filteredPets.take(_petsPerPage));
          if (filteredPets.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
          }
          _hasMore = snapshot.docs.length == _petsPerPage * 3;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
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
          .limit(_petsPerPage * 3);
      final snapshot = await query.get();

      if (mounted) {
        // 🔥 Aplicar filtros no cliente
        final filteredPets = _applyClientSideFilters(snapshot.docs);
        
        setState(() {
          _pets.addAll(filteredPets.take(_petsPerPage));
          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
          }
          _hasMore = snapshot.docs.length == _petsPerPage * 3;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // 🔥 Limpar todos os filtros
  void _clearFilters() {
    setState(() {
      _selectedEspecie = null;
      _selectedPorte = null;
      _selectedSexo = null;
      _selectedIdade = null;
    });
    _fetchInitialPets();
  }

  // 🔥 Widget de chip de filtro
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
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
    // Verifica se há algum filtro ativo
    final hasActiveFilters = _selectedEspecie != null ||
        _selectedPorte != null ||
        _selectedSexo != null ||
        _selectedIdade != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: SizedBox(
          height: 48,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar pets, abrigo ou raça...',
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).hintColor,
              ),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).hintColor,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _search = '');
                        _fetchInitialPets();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                setState(() => _search = value);
                _fetchInitialPets();
              });
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔥 BARRA DE FILTROS HORIZONTAL (estilo YouTube)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Botão "Todos" / Limpar filtros
                _buildFilterChip(
                  'Todos',
                  !hasActiveFilters,
                  () {
                    if (hasActiveFilters) _clearFilters();
                  },
                ),
                const SizedBox(width: 8),

                // Filtro Espécie
                _buildFilterChip(
                  _selectedEspecie ?? 'Espécie',
                  _selectedEspecie != null,
                  () => _showEspecieDialog(),
                ),
                const SizedBox(width: 8),

                // Filtro Porte
                _buildFilterChip(
                  _selectedPorte ?? 'Porte',
                  _selectedPorte != null,
                  () => _showPorteDialog(),
                ),
                const SizedBox(width: 8),

                // Filtro Sexo
                _buildFilterChip(
                  _selectedSexo ?? 'Sexo',
                  _selectedSexo != null,
                  () => _showSexoDialog(),
                ),
                const SizedBox(width: 8),

                // Filtro Idade
                _buildFilterChip(
                  _selectedIdade ?? 'Idade',
                  _selectedIdade != null,
                  () => _showIdadeDialog(),
                ),
              ],
            ),
          ),

          // Lista de pets
          Expanded(
            child: _pets.isEmpty && _isLoadingMore
                ? const Center(child: PetLoader())
                : _pets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              size: 64,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum pet encontrado.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Limpar filtros'),
                              ),
                            ],
                          ],
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

                          final data =
                              _pets[index].data() as Map<String, dynamic>;
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
          ),
        ],
      ),
    );
  }

  // 🔥 Diálogos de seleção de filtros

  void _showEspecieDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecionar Espécie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Cão', _selectedEspecie, (val) {
              setState(() => _selectedEspecie = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Gato', _selectedEspecie, (val) {
              setState(() => _selectedEspecie = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Pássaro', _selectedEspecie, (val) {
              setState(() => _selectedEspecie = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Roedor', _selectedEspecie, (val) {
              setState(() => _selectedEspecie = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            const Divider(),
            TextButton(
              onPressed: () {
                setState(() => _selectedEspecie = null);
                _fetchInitialPets();
                Navigator.pop(ctx);
              },
              child: const Text('Limpar filtro'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPorteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecionar Porte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Pequeno', _selectedPorte, (val) {
              setState(() => _selectedPorte = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Médio', _selectedPorte, (val) {
              setState(() => _selectedPorte = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Grande', _selectedPorte, (val) {
              setState(() => _selectedPorte = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            const Divider(),
            TextButton(
              onPressed: () {
                setState(() => _selectedPorte = null);
                _fetchInitialPets();
                Navigator.pop(ctx);
              },
              child: const Text('Limpar filtro'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSexoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecionar Sexo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption('Macho', _selectedSexo, (val) {
              setState(() => _selectedSexo = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            _buildDialogOption('Fêmea', _selectedSexo, (val) {
              setState(() => _selectedSexo = val);
              _fetchInitialPets();
              Navigator.pop(ctx);
            }),
            const Divider(),
            TextButton(
              onPressed: () {
                setState(() => _selectedSexo = null);
                _fetchInitialPets();
                Navigator.pop(ctx);
              },
              child: const Text('Limpar filtro'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIdadeDialog() {
    final idades = [
      'Filhote (< 1 ano)',
      ...List.generate(20, (i) => '${i + 1} anos')
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecionar Idade'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...idades.map((idade) => _buildDialogOption(
                    idade,
                    _selectedIdade,
                    (val) {
                      setState(() => _selectedIdade = val);
                      _fetchInitialPets();
                      Navigator.pop(ctx);
                    },
                  )),
              const Divider(),
              TextButton(
                onPressed: () {
                  setState(() => _selectedIdade = null);
                  _fetchInitialPets();
                  Navigator.pop(ctx);
                },
                child: const Text('Limpar filtro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogOption(
    String label,
    String? currentValue,
    Function(String) onSelect,
  ) {
    final isSelected = currentValue == label;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      onTap: () => onSelect(label),
    );
  }
}