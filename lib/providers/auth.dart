import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:state_management/exception/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  bool get isAuth {
    //print("insde isAuth method");
    return token != null ? true : false;
  }

  Future<void> logOut()async {
   // print("Inside logout method");
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.clear();

    notifyListeners();
  }

  Future<void> authenticate(
      String email, String password, String urlElement) async {
       // print("inside authenticate method");
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlElement?key=AIzaSyCA0VIgGUy5NsKVmb9iIpvQsEuHe9XCQuQ';
    //print("Inside authenticate method");
    try {
      print("Inside authenticate method");
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(message: "${responseData['error']['message']}");
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      print("All data has been set");
      _autoLogout();
      notifyListeners();
      final _sharedPreferences = await SharedPreferences.getInstance();
      final _userData = json.encode({
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
        'token': _token,
      });
      _sharedPreferences.setString('userData', _userData);

    } catch (error) {
      throw (error);
    }
  }

  Future<bool> tryAutoLogin() async {
    //print("inside try auto login method");
    final _sharedPreferences = await SharedPreferences.getInstance();
    if (_sharedPreferences.containsKey('userData') == false) return false;
    //print("Data verified");
    final _userData = json.decode(_sharedPreferences.getString('userData'))
        as Map<String, dynamic>;
    //print("expiry date verified");
    final _fetchedExpiryDate =
        DateTime.parse(_userData['expiryDate']);

    if (_fetchedExpiryDate.isBefore(DateTime.now())) return false;
    //print("verification done");
    _token = _userData['token'];
    _expiryDate = _fetchedExpiryDate;
    _userId = _userData['userId'];

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    //print("Inside signUp");
    return authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    //print("Inside of signIN method");
    return authenticate(email, password, 'signInWithPassword');
  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;

    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
