import 'package:flutter/material.dart';
import 'package:reservation_express/services/api_service.dart';
import '../models/place.dart';

class PlacesCard extends StatefulWidget {
  const PlacesCard({super.key});

  @override
  State<PlacesCard> createState() => _PlacesCardState();
}

class _PlacesCardState extends State<PlacesCard> {
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  List<CartItem> _cartItems = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'Toutes';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    try {
      final places = await ApiService.getPlaces();
      final categories = await ApiService.getPlaceCategories();

      setState(() {
        _places = places;
        _filteredPlaces = places;
        _categories = ['Toutes', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: $e');
    }
  }

  void _filterPlaces(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredPlaces = category == 'Toutes' 
          ? _places 
          : _places.where((place) => place.city == category).toList();
    });
  }

  void _searchPlaces(String query) {
    setState(() {
      _filteredPlaces = _places
          .where((place) =>
              place.name.toLowerCase().contains(query.toLowerCase()) ||
              place.city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
            int quantity = _getItemQuantity(place.id);

            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 200,
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.green, size: 20),
                              const SizedBox(width: 5),
                              Text(
                                '${place.price.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            place.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Quantité',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.orange),
                                ),
                                onPressed: quantity > 0 ? () {
                                  _updateQuantity(place, quantity - 1);
                                  setSheetState(() {
                                    quantity = _getItemQuantity(place.id);
                                  });
                                } : null,
                              ),
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(
                                  quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white),
                                ),
                                onPressed: () {
                                  _updateQuantity(place, quantity + 1);
                                  setSheetState(() {
                                    quantity = _getItemQuantity(place.id);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          if (quantity > 0)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_cart, color: Colors.green, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total: ${(place.price * quantity).toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Continuer'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _cartItems.isNotEmpty ? _showCart : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart, size: 18),
                                const SizedBox(width: 5),
                                Text('Panier (${_getTotalItemCount()})'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getItemQuantity(int placeId) {
    for (var cartItem in _cartItems) {
      if (cartItem.place.id == placeId) {
        return cartItem.quantity;
      }
    }
    return 0;
  }

  void _updateQuantity(Place place, int newQuantity) {
    setState(() {
      if (newQuantity == 0) {
        _cartItems.removeWhere((cartItem) => cartItem.place.id == place.id);
      } else {
        final existingIndex = _cartItems.indexWhere(
          (cartItem) => cartItem.place.id == place.id,
        );
        if (existingIndex >= 0) {
          _cartItems[existingIndex] = CartItem(place, newQuantity);
        } else {
          _cartItems.add(CartItem(place, newQuantity));
        }
      }
    });

    if (newQuantity == 0) {
      _showSuccess('${place.name} retiré du panier');
    } else if (newQuantity == 1) {
      _showSuccess('${place.name} ajouté au panier');
    } else {
      _showSuccess('${place.name} (x$newQuantity) dans le panier');
    }
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const Text(
                'Votre Panier',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              if (_cartItems.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Votre panier est vide',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ajoutez des tableaux de Tunisie',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = _cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage(cartItem.place.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.place.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cartItem.place.city,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${cartItem.place.price.toStringAsFixed(2)}€ x ${cartItem.quantity}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(cartItem.place.price * cartItem.quantity).toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () {
                                    _updateQuantity(cartItem.place, 0);
                                    if (_cartItems.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (_cartItems.isNotEmpty) ...[
                const Divider(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          '${_getTotalPrice().toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _cartItems.clear());
                          Navigator.pop(context);
                          _showSuccess('Panier vidé');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Vider le panier'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cartItems.isNotEmpty ? _checkout : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Commander'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  double _getTotalPrice() {
    return _cartItems.fold(0.0, (total, item) => total + (item.place.price * item.quantity));
  }

  void _checkout() {
    _showSuccess('Commande passée avec succès!');
    setState(() => _cartItems.clear());
    Navigator.pop(context);
  }

  int _getTotalItemCount() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  Widget _buildPlaceCard(Place place) {
    final quantity = _getItemQuantity(place.id);

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
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.city,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${place.price.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: quantity > 0 ? Colors.orange : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: quantity > 0
                      ? Text(
                          quantity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.add, size: 18, color: Colors.orange),
                ),
              ),
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
          'Galerie Tunisienne',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white),
                ),
                onPressed: _cartItems.isNotEmpty ? _showCart : null,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getTotalItemCount().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
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
                      hintText: 'Rechercher un tableau...',
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
                      Text(
                        '${_filteredPlaces.length} tableau${_filteredPlaces.length > 1 ? 'x' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const Spacer(),
                      if (_cartItems.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_cart, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                _getTotalItemCount().toString(),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredPlaces.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 70,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Aucun tableau trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _filteredPlaces.length,
                          itemBuilder: (context, index) => _buildPlaceCard(_filteredPlaces[index]),
                        ),
                ),
              ],
            ),
    );
  }
}

class CartItem {
  final Place place;
  int quantity;

  CartItem(this.place, this.quantity);
}