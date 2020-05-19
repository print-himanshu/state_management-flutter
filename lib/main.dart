import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/auth_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/void_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousSelectedItem) => Products(
            auth.token,
            auth.userId,
            previousSelectedItem == null ? [] : previousSelectedItem.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          update: (ctx, auth, previousSelectedItem) => Cart(
            auth.token,
            previousSelectedItem == null ? {} : previousSelectedItem.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousSelectedItem) => Orders(
            auth.token,
            auth.userId,
            previousSelectedItem == null ? [] : previousSelectedItem.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? VoidScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            }),
      ),
    );
  }
}
