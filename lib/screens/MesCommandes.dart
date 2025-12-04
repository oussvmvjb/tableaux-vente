import 'package:flutter/material.dart';
import 'package:reservation_express/models/Place.dart';
import 'package:reservation_express/services/auth_service.dart';
import 'package:reservation_express/services/api_service.dart';

class MesCommandesScreen extends StatefulWidget {
  const MesCommandesScreen({super.key});

  @override
  State<MesCommandesScreen> createState() => _MesCommandesScreenState();
}

class _MesCommandesScreenState extends State<MesCommandesScreen> {
  List<Place> _purchasedPlaces = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'Toutes';
  final TextEditingController _searchController = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initUserAndPurchasedPlaces();
  }

  Future<void> _initUserAndPurchasedPlaces() async {
    await _loadUserId();
    await _loadPurchasedPlaces();
  }

  Future<void> _loadUserId() async {
    final userId = await AuthService.getUserId();
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _loadPurchasedPlaces() async {
    if (_userId == null) {
      _showError("Veuillez vous connecter");
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // في الإصدار النهائي، استخدم API حقيقي
      final purchasedPlaces = await _getPurchasedPlacesFromAPI(_userId!);
      
      // استخراج التصنيفات الفريدة
      final uniqueCities = purchasedPlaces.map((p) => p.city).toSet().toList();

      setState(() {
        _purchasedPlaces = purchasedPlaces;
        _categories = ['Toutes', ...uniqueCities];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur de chargement: $e');
    }
  }

  Future<List<Place>> _getPurchasedPlacesFromAPI(int userId) async {
    try {
      // TODO: استبدل بطلب API حقيقي
      await Future.delayed(const Duration(milliseconds: 800));
      
      return [
        Place(
          id: 1,
          name: "Bizerte",
          city: "Bizerte",
          description: "Tableau de Bizerte - Acheté le 15/11/2024\n\nCette œuvre capture l'essence de Bizer avec ses plages méditerranéennes et son ambiance historique.",
          imageUrl: "assets/images/bizer.jpg",
          price: 129.99,
        ),
        Place(
          id: 2,
          name: "Sousse",
          city: "Sousse",
          description: "Tableau de Sousse - Acheté le 10/11/2024\n\nUn tableau représentant la perle du Sahel avec ses plages dorées et son architecture historique.",
          imageUrl: "assets/images/sousse1.jpg",
          price: 139.99,
        ),
        Place(
          id: 3,
          name: "Hammamet",
          city: "Hammamet",
          description: "Tableau de Hammamet - Acheté le 5/11/2024\n\nCette peinture dépeint Hammamet avec ses jardins luxuriants et sa médina animée.",
          imageUrl: "assets/images/hammamet1.jpg",
          price: 119.99,
        ),
        Place(
          id: 4,
          name: "Tozeur",
          city: "Tozeur",
          description: "Tableau du désert - Acheté le 1/11/2024\n\nCette peinture montre Tozeur avec ses oasis spectaculaires et son architecture en briques ocres.",
          imageUrl: "assets/images/touzer.jpg",
          price: 179.99,
        ),
        Place(
          id: 5,
          name: "Sidi Bou Said",
          city: "Sidi Bou Said",
          description: "Village bleu et blanc - Acheté le 28/10/2024\n\nUn tableau pittoresque représentant les maisons blanches aux volets bleus.",
          imageUrl: "assets/images/sidi_bou_said.jpg",
          price: 169.99,
        ),
      ];
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }

  void _filterPlaces(String category) {
    setState(() => _selectedCategory = category);
  }

  List<Place> get _filteredPlaces {
    if (_selectedCategory == 'Toutes') {
      return _purchasedPlaces;
    }
    return _purchasedPlaces.where((place) => place.city == _selectedCategory).toList();
  }

  void _searchPlaces(String query) {
    setState(() => _selectedCategory = 'Toutes');
  }

  List<Place> get _searchedPlaces {
    if (_searchController.text.isEmpty) {
      return _filteredPlaces;
    }
    final query = _searchController.text.toLowerCase();
    return _filteredPlaces.where((place) =>
        place.name.toLowerCase().contains(query) ||
        place.city.toLowerCase().contains(query) ||
        place.description.toLowerCase().contains(query)).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(place.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                place.city,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Acheté: ${place.price.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        place.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPlaceDetails(place),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(place.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${place.price.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          place.city,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Dans votre collection',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) => _filterPlaces(category),
        selectedColor: Colors.orange,
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ma Collection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            onPressed: _loadPurchasedPlaces,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : _purchasedPlaces.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'Aucun tableau dans votre collection',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Visitez notre galerie pour découvrir et acheter des tableaux inspirés des plus belles régions de la Tunisie.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // العودة للشاشة السابقة
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Explorer la galerie',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchPlaces,
                        decoration: InputDecoration(
                          hintText: 'Rechercher dans votre collection...',
                          prefixIcon: const Icon(Icons.search, color: Colors.orange),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchPlaces('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 15),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) => _buildCategoryChip(_categories[index]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.collections, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  '${_searchedPlaces.length} tableau${_searchedPlaces.length > 1 ? 'x' : ''}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Votre collection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _searchedPlaces.length,
                        itemBuilder: (context, index) => _buildPlaceCard(_searchedPlaces[index]),
                      ),
                    ),
                  ],
                ),
    );
  }
}