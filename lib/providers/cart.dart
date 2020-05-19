import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../exception/http_exception.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final String _authToken;

  Cart(
    this._authToken,
    this._items,
  );

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchAndSetCartItem() async {
    final url = 'https://first-flutter-firebase-77ef9.firebaseio.com/cart.json?auth=$_authToken';
    try {
      final response = await http.get(url);
      final _data = json.decode(response.body) as Map<String, dynamic>;
      Map<String, CartItem> _fetchedData = {};
      if (_data == null) {
        _items = {};
      } else {
        _data.forEach((key, item) {
          _fetchedData.putIfAbsent(
            item['productId'],
            () => CartItem(
              id: key,
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            ),
          );
        });
        _items = _fetchedData;
      }
    } catch (error) {
      throw HttpException(message: "Error Occured: ${error}");
    }
  }

  Future<void> addItem(
    String productId,
    double price,
    String title,
  ) async {
    if (_items.containsKey(productId)) {
      // change quantity...
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
      notifyListeners();
      final _id = _items[productId].id;
      final url =
          'https://first-flutter-firebase-77ef9.firebaseio.com/cart/$_id.json?auth=$_authToken';
      final _updatedQuantity = _items[productId].quantity;

      final response = await http.patch(url,
          body: json.encode({'quantity': _updatedQuantity}));

      if (response.statusCode >= 400) {
        _items.update(
            productId,
            (existingItem) => CartItem(
                id: existingItem.id,
                price: existingItem.price,
                quantity: _updatedQuantity - 1,
                title: existingItem.title));
        notifyListeners();
        throw HttpException(
            message: "Some error while updating the qunatity of the cart item");
      }
    } else {
      final url =
          'https://first-flutter-firebase-77ef9.firebaseio.com/cart.json?auth=$_authToken';
      final response = await http.post(url,
          body: json.encode({
            'productId': productId,
            'title': title,
            'price': price,
            'quantity': 1
          }));

      if (response.statusCode >= 400) {
        print("error occured");
        throw HttpException(
            message: "Some error occurred during updating the cart item ");
      }

      final _id = json.decode(response.body)['name'];
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: _id,
          title: title,
          price: price,
          quantity: 1,
        ),
      );
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    final _oldItem = _items[productId];
    final _id = _items[productId].id;
    _items.remove(productId);
    notifyListeners();
    final _url =
        'https://first-flutter-firebase-77ef9.firebaseio.com/cart/$_id.json?auth=$_authToken';

    final response = await http.delete(_url);
    if (response.statusCode >= 400) {
      _items.putIfAbsent(productId, () => _oldItem);
      notifyListeners();
      throw HttpException(
          message:
              "Some Error Occured during the removal of item from the cart");
    }
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    final _id = items[productId].id;
    final _url =
        'https://first-flutter-firebase-77ef9.firebaseio.com/cart/$_id.json?auth=$_authToken';
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
      notifyListeners();
      try {
        final _updatedQuantity = items[productId].quantity;
        final response = await http.patch(_url,
            body: json.encode({'quantity': _updatedQuantity}));
      } catch (error) {
        _items.update(
            productId,
            (existingCartItem) => CartItem(
                  id: existingCartItem.id,
                  title: existingCartItem.title,
                  price: existingCartItem.price,
                  quantity: existingCartItem.quantity - 1,
                ));
        notifyListeners();
        throw HttpException(
            message:
                "Error occurred while processing this remove request\n${error}");
      }
    } else {
      final _oldItem = _items[productId];
      _items.remove(productId);
      notifyListeners();
      final response = await http.delete(_url);
      if (response.statusCode >= 400) {
        _items.putIfAbsent(productId, () => _oldItem);
        notifyListeners();
        throw HttpException(
            message: 'Error occurred while processing this remove request');
      }
    }
  }

  Future<void> clear() async {
    final _oldList = _items;
    _items = {};
    notifyListeners();
    final url = 'https://first-flutter-firebase-77ef9.firebaseio.com/cart.json?auth=$_authToken';
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items = _oldList;
      notifyListeners();
      throw HttpException(message: "Error occurred during clearing the cart");
    }
  }
}
