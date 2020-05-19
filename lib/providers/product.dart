import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../exception/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token,String userId) async{
    bool oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
     final url = 'https://first-flutter-firebase-77ef9.firebaseio.com/favoriteProduct/$userId/$id.json?auth=$token';
     final response = await http.put(url,body: json.encode(isFavorite));

     if(response.statusCode>=400)
     {
       isFavorite = oldStatus;
       notifyListeners();
       throw HttpException(message: "Unable to change the favorite status of the item!...");
     }


  }
}
