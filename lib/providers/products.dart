import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../exception/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  final String _token;
  final String _userId;
  Products(this._token, this._userId, this._items);
  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProduct(bool filter) async {
    // print("Filter = $filter");
    // print("Inside fetchAndSetProduct method");
    String filterString = filter ? 'orderBy="creatorId"&equalTo="$_userId"': '';
    
    // print("Fitering String is $filterString");


    try {
      final url =
          'https://first-flutter-firebase-77ef9.firebaseio.com/products.json?auth=$_token&$filterString';
      final response = await http.get(url);

      final _data = json.decode(response.body) as Map<String, dynamic>;
      if (_data == null) return;

      final favoriteUrl =
          'https://first-flutter-firebase-77ef9.firebaseio.com/favoriteProduct/$_userId.json?auth=$_token';
      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      //print(favoriteData);
      final List<Product> _fetchedData = [];
      _data.forEach((key, item) {
        // print(favoriteData.containsKey(key) ? favoriteData[key] : false);
        _fetchedData.add(
          Product(
            id: key,
            description: item['description'],
            imageUrl: item['imageUrl'],
            price: item['price'],
            title: item['title'],
            // isFavorite: favoriteData == null
            //     ? false
            //     : favoriteData.containsKey(key)
            //         ? favoriteData[key]
            //         : false),
            // isFavorite: false,
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false,
          ),
        );
      });
      _items = _fetchedData;
      notifyListeners();
    } catch (error) {
      throw HttpException(
          message:
              "Some Error during fetching the data from the server \n${error}");
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url =
          'https://first-flutter-firebase-77ef9.firebaseio.com/products.json?auth=$_token';
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': _userId,
          }));

      if (response.statusCode >= 400) {
        throw HttpException(
            message: "Error in adding the product to the database");
      }
      final fetchId = json.decode(response.body)['name'];

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: fetchId,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      throw HttpException(message: error.toString());
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    try {
      final prodIndex = _items.indexWhere((prod) => prod.id == id);
      final url =
          'https://first-flutter-firebase-77ef9.firebaseio.com/products/$id.json?auth=$_token';
      final oldProduct = _items[prodIndex];

      if (prodIndex >= 0) {
        _items[prodIndex] = newProduct;
        notifyListeners();

        final response = await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
            }));
        print(response.statusCode);
        if (response.statusCode >= 400) {
          _items[prodIndex] = oldProduct;
          notifyListeners();
          throw HttpException(message: 'Error during updating the item');
        }
      } else {
        print('...');
      }
    } catch (error) {
      throw HttpException(message: error.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    final _productId = _items.indexWhere((prod) => prod.id == id);
    final _oldProduct = _items[_productId];
    _items.remove(_oldProduct);
    notifyListeners();
    final url =
        'https://first-flutter-firebase-77ef9.firebaseio.com/products/$id.json?auth=$_token';
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(_productId, _oldProduct);
      notifyListeners();
      throw HttpException(
          message: "Error occurred during deleting the item from the database");
    }
  }
}
