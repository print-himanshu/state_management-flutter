import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  bool _isInit = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final cartInstance = Provider.of<Cart>(context);
      cartInstance.fetchAndSetCartItem().then((response) {
        setState(() {
          _isLoading = false;
        });
      }).catchError(
        (error) {
          print(error);
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              duration: Duration(seconds: 10),
            ),
          );
        },
      );
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  IgnorePointer(
                    ignoring: cart.totalAmount <= 0 ? true : false,
                    ignoringSemantics: true,
                    child: 
                    FlatButton(
                      child: Text('ORDER NOW'),
                      onPressed: () async {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<Orders>(context, listen: false)
                              .addOrder(
                            cart.items.values.toList(),
                            cart.totalAmount,
                          );
                          await cart.clear();
                          setState(() {
                            _isLoading = false;
                          });
                        } catch (error) {
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(error.toString()),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      textColor: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartItem(
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i],
                      cart.items.values.toList()[i].price,
                      cart.items.values.toList()[i].quantity,
                      cart.items.values.toList()[i].title,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
