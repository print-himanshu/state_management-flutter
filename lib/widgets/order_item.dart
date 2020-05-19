// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../providers/orders.dart' as ord;

// class OrderItem extends StatefulWidget {
//   final ord.OrderItem order;

//   OrderItem(this.order);

//   @override
//   _OrderItemState createState() => _OrderItemState();
// }

// class _OrderItemState extends State<OrderItem>
//     with SingleTickerProviderStateMixin {
//   var _expanded = false;
//   Animation<Size> _sizeAnimation;
//   AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 350),
//     );
//     _sizeAnimation = Tween<Size>(
//             begin: Size(double.infinity, 0),
//             end: Size(double.infinity,
//                 min(widget.order.products.length * 20.0 + 10, 100)))
//         .animate(CurvedAnimation(
//             parent: _animationController, curve: Curves.easeIn));
//     _animationController.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _animationController.removeListener(() {});
//     _animationController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _sizeAnimation,
//       builder: (ctx, ch) => Card(
//         margin: EdgeInsets.all(10),
//         child: Column(
//           children: <Widget>[
//             ListTile(
//               title: Text('\$${widget.order.amount}'),
//               subtitle: Text(
//                 DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
//               ),
//               trailing: IconButton(
//                 icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
//                 onPressed: () {
//                   if (!_expanded) {
//                     setState(() {
//                       _expanded = !_expanded;
//                     });
//                     _animationController.forward();
//                   } else {
//                     setState(() {
//                       _expanded = !_expanded;
//                     });
//                     _animationController.reverse();
//                   }
//                 },
//               ),
//             ),
//             if (_expanded)
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//                 height: _sizeAnimation.value.height,
//                 child: ListView(
//                   children: widget.order.products
//                       .map(
//                         (prod) => Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Text(
//                               prod.title,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               '${prod.quantity}x \$${prod.price}',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             )
//                           ],
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  var _expanded = false;
  Animation<Size> _sizeAnimation;
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _sizeAnimation = Tween<Size>(
      begin: Size(double.infinity, 0),
      end: Size(
        double.infinity,
        min(widget.order.products.length * 20.0 + 10, 100),
      ),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.removeListener(() {});
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                if (!_expanded) {
                  setState(() {
                    _expanded = !_expanded;
                  });
                  _animationController.forward();
                } else {
                  setState(() {
                    _expanded = !_expanded;
                  });
                  _animationController.reverse();
                }
              },
            ),
          ),
          if (_expanded)
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: min(widget.order.products.length * 20.0 + 10, 100),
                child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x \$${prod.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
