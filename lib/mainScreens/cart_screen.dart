import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:client/assistant_methods/assistant_methods.dart';
import 'package:client/assistant_methods/cart_item_counter.dart';
import 'package:client/mainScreens/address_screen.dart';
import 'package:client/models/items.dart';
import 'package:client/widgets/cart_item_design.dart';
import 'package:client/widgets/progress_bar.dart';
import 'package:client/assistant_methods/total_ammount.dart';
import 'package:client/splashScreen/splash_screen.dart';
import 'package:client/widgets/text_widget_header.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;
  const CartScreen({super.key, this.sellerUID});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int>? separateItemQuantityList;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    Provider.of<TotalAmmount>(context, listen: false).displayTotolAmmount(0);
    separateItemQuantityList = separateItemQuantities();
    // Log initial cart state for debugging
    print(
        'CartScreen init: separateItemIds: ${separateItemIds()}, quantities: $separateItemQuantityList');
  }

  @override
  Widget build(BuildContext context) {
    // Check if cart is empty early to avoid unnecessary Firestore query
    final itemIds = separateItemIds();
    if (itemIds.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('Votre panier est vide')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: 'btn1',
              onPressed: () {
                clearCartNow(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MySplashScreen()),
                );
                Fluttertoast.showToast(msg: "Panier vidé");
              },
              label: const Text("Vider le panier"),
              backgroundColor: Colors.greenAccent,
              icon: const Icon(Icons.clear_all),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: 'btn2',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressScreen(
                      totolAmmount: totalAmount.toDouble(),
                      sellerUID: widget.sellerUID,
                    ),
                  ),
                );
              },
              label: const Text("Commander"),
              backgroundColor: Colors.greenAccent,
              icon: const Icon(Icons.navigate_next),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextWidgetHeader(title: "Mon panier"),
          ),
          SliverToBoxAdapter(
            child: Consumer2<TotalAmmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: cartProvider.count == 0
                        ? const Text('panier est vide')
                        : Text(
                            "prixTotal : Dz${amountProvider.tAmmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("items")
                .where("itemId", whereIn: itemIds)
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress()),
                );
              }
              if (snapshot.hasError) {
                print('Firestore error: ${snapshot.error}');
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print('No items found for itemIds: $itemIds');
                return const SliverToBoxAdapter(
                    // child: Center(child: Text('Panier vide')),
                    );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    Items model;
                    try {
                      model = Items.fromJson(data);
                    } catch (e) {
                      print('Error parsing item at index $index: $e');
                      return const SizedBox.shrink(); // Skip invalid items
                    }

                    // Calculate total amount
                    final quantity = separateItemQuantityList![index];
                    final price =
                        model.discountedPrice ?? model.originalPrice ?? 0.0;
                    if (index == 0) {
                      totalAmount = price * quantity;
                    } else {
                      totalAmount += price * quantity;
                    }

                    // Update total amount in provider after last item
                    if (index == snapshot.data!.docs.length - 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Provider.of<TotalAmmount>(context, listen: false)
                            .displayTotolAmmount(totalAmount.toDouble());
                      });
                    }

                    return CartItemDesign(
                      model: model,
                      quanNumber: quantity,
                      context: context,
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Extracted AppBar to reduce code duplication
  AppBar _buildAppBar() {
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
          clearCartNow(context);
          Fluttertoast.showToast(msg: "Panier vidé");
        },
        icon: const Icon(Icons.clear_all),
      ),
      title: const Text(
        "save to serve ",
        style: TextStyle(fontSize: 20, fontFamily: "Signatra"),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
    );
  }
}
