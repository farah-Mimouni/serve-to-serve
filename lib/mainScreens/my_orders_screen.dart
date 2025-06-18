import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:client/global/global.dart';
import 'package:client/models/items.dart';
import 'package:client/mainScreens/order_details_screen.dart';
import 'package:client/widgets/order_card.dart';
import 'package:client/widgets/simple_Appbar.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  Future<List<Map<String, dynamic>>> fetchItemsForOrder(
      List<String> productIds) async {
    List<Map<String, dynamic>> items = [];
    for (String productId in productIds) {
      // Parse itemId and quantity from format "<itemId>:<quantity>"
      final parts = productId.split(':');
      final itemId = parts[0];
      final quantity = int.parse(parts.length > 1 ? parts[1] : '1');

      try {
        final itemDoc = await FirebaseFirestore.instance
            .collection('items')
            .doc(itemId)
            .get();

        if (itemDoc.exists) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          itemData['quantity'] = quantity; // Add quantity to item data
          items.add(itemData);
        } else {
          print('Item not found: $itemId');
        }
      } catch (e) {
        print('Error fetching item $itemId: $e');
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(
          title: "Mes commandes",
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("orderedBy",
                  isEqualTo: sharedPreferences?.getString("uid"))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Error loading orders",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No orders found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final orderDoc = snapshot.data!.docs[index];
                final orderData = orderDoc.data() as Map<String, dynamic>;
                final productIds =
                    List<String>.from(orderData['productIds'] ?? []);
                final orderId = orderData['orderId'] as String;

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchItemsForOrder(productIds),
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (itemSnapshot.hasError ||
                        !itemSnapshot.hasData ||
                        itemSnapshot.data!.isEmpty) {
                      return const Card(
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('No valid items in order'),
                        ),
                      );
                    }

                    final items = itemSnapshot.data!;
                    double calculatedTotal = 0;
                    List<String> quantities = [];
                    for (var item in items) {
                      final quantity = item['quantity'] as int;
                      final itemModel = Items.fromJson(item);
                      final price = (itemModel.isOfferValid &&
                              itemModel.discountedPrice != null)
                          ? itemModel.discountedPrice!
                          : itemModel.originalPrice ?? 0;
                      calculatedTotal += quantity * price;
                      quantities.add(quantity.toString());
                    }

                    return OrderCard(
                      itemCount: items.length,
                      data: items,
                      orderId: orderId,
                      totalAmount: calculatedTotal.toStringAsFixed(2),
                      seperateQuantitiesList: quantities,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
