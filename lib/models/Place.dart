class Place {
  final int id;
  String name;
  String city;
  String description;
  String imageUrl;
  double price;

  Place({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.imageUrl,
    this.price = 99.99,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price']?.toDouble() ?? 99.99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}