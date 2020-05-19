import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:state_management/exception/http_exception.dart';
import 'dart:convert';

import './cart.dart';
import '../exception/http_exception.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String _authToken;
  final String _userId;

  Orders(this._authToken,this._userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final _url =
        'https://first-flutter-firebase-77ef9.firebaseio.com/orders/$_userId.json?auth=$_authToken';
    final timestamp = DateTime.now();
    try {
      final response = await http.post(_url,
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
          }));

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      throw HttpException(
          message: "Error occured during processing the order\n$error");
    }
  }

  Future<void> fetchAndSetOrders() async {
    final _url =
        'https://first-flutter-firebase-77ef9.firebaseio.com/orders/$_userId.json?auth=$_authToken';
    try {
      final response = await http.get(_url);
      final _data = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> _fetchedData = [];
      if (_data == null) return;
      _data.forEach((key, item) {
        _fetchedData.add(OrderItem(
            id: key,
            amount: item['amount'],
            dateTime: DateTime.parse(item['dateTime']),
            products: (item['products'] as List<dynamic>)
                .map(
                  (cartItem) => CartItem(
                    id: cartItem['id'],
                    price: cartItem['price'],
                    quantity: cartItem['quantity'],
                    title: cartItem['title'],
                  ),
                )
                .toList()));
        _orders = _fetchedData.reversed.toList();
      });
    } catch (error) {}
  }
}
