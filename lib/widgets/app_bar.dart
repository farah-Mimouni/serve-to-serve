import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/assistant_methods/cart_item_counter.dart';

import '../mainScreens/cart_screen.dart';
//import 'package:client/mainScreens/cart_screen.dart';

class MyAppbar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String? sellerUID;

  MyAppbar({this.bottom, this.sellerUID});
  @override
  State<MyAppbar> createState() => _MyAppbarState();

  @override
  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}

class _MyAppbarState extends State<MyAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)),
      title: const Text(
        "save to serve",
        style: TextStyle(fontSize: 20, fontFamily: "Signatra"),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartScreen(sellerUID: widget.sellerUID)));
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
            Stack(
              children: [
                const Icon(Icons.brightness_1, size: 20, color: Colors.white),
                Positioned(
                  top: 3,
                  right: 4,
                  child: Center(
                    child: Consumer<CartItemCounter>(
                        builder: (context, counter, c) {
                      return Text(
                        counter.count.toString(),
                        style:
                            const TextStyle(color: Colors.green, fontSize: 12),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
