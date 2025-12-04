import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservation_express/models/place.dart';
import 'package:reservation_express/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'email': user.email,
          'password': user.password,
          'fullName': user.fullName,
          'phoneNumber': user.phoneNumber,
        }),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur de connexion lors de l\'inscription: $e');
    }
  }

  static Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: json.encode({'email': email, 'password': password}),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur de connexion lors de la connexion: $e');
    }
  }

  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check-email/$email'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Erreur de vérification email: $e');
    }
  }

  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> addToCart(int placeId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'placeId': placeId,
          'userId': userId,
          'quantity': 1,
        }),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  
  static Future<List<Place>> getPlaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPlaces: $e');
      throw Exception('Error: $e');
    }
  }
  
  static Future<List<String>> getPlaceCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places/cities'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        return ['Bizerte', 'Djerba', 'Hammamet', 'Sousse', 'Kairaoun', 'Sidi Bou Said', 'Tozeur'];
      }
    } catch (e) {
      return ['Bizerte', 'Djerba', 'Hammamet', 'Sousse', 'Kairaoun', 'Sidi Bou Said', 'Tozeur'];
    }
  }
  
  static Future<Place> getPlaceById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Place.fromJson(data);
      } else {
        throw Exception('Failed to load place: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/places/search?q=$query'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

