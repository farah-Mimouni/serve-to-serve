import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/models/address.dart';
import 'package:client/widgets/progress_bar.dart';
import 'package:client/widgets/shipment_address_design.dart';
import 'package:client/widgets/status_banner.dart';
import '../global/global.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String? orderId;

  const OrderDetailsScreen({this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";
  Map<String, dynamic> orderData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<List<Map<String, dynamic>>> fetchItemsForOrder(
      List<String> productIds) async {
    List<Map<String, dynamic>> items = [];
    double calculatedTotal = 0;

    for (String productId in productIds) {
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
          itemData['quantity'] = quantity;
          itemData['price'] = itemData['isOfferValid'] == true &&
                  itemData['discountedPrice'] != null
              ? itemData['discountedPrice'].toDouble()
              : itemData['originalPrice']?.toDouble() ?? 0.0;
          calculatedTotal += itemData['price'] * quantity;
          items.add(itemData);
        } else {
          print('Item not found: $itemId');
        }
      } catch (e) {
        print('Error fetching item $itemId: $e');
      }
    }

    return items..add({'calculatedTotal': calculatedTotal});
  }

  Future<void> fetchOrderDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()! as Map<String, dynamic>;
        final productIds = List<String>.from(data['productIds'] ?? []);

        // Fetch item details and calculated total
        final items = await fetchItemsForOrder(productIds);

        // Extract calculated total from items list
        final calculatedTotal =
            items.isNotEmpty ? items.removeLast()['calculatedTotal'] : 0.0;

        setState(() {
          orderData = {
            ...data,
            'items': items,
            'orderId': widget.orderId,
            'totalAmount': calculatedTotal, // Use calculated total
            'orderTime': data['orderTime'].toString(),
            'isSuccess': data['status'] == 'normal',
          };
          orderStatus = data['status'].toString();
          isLoading = false;
        });
      } else {
        print("Order not found: ${widget.orderId}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching order details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final price = item["price"]?.toDouble() ?? 0.0;
    final originalPrice = item["originalPrice"]?.toDouble();
    final hasDiscount = originalPrice != null && originalPrice > price;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["title"] ?? "Sans titre",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "Quantité : ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  item["quantity"]?.toString() ?? "1",
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Prix : ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "DA ${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (hasDiscount) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Prix initial : ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "DA ${originalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${((originalPrice - price) / originalPrice * 100).toStringAsFixed(0)}% de réduction",
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (item["shortInfo"] != null && item["shortInfo"].isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                item["shortInfo"],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green[800] : Colors.grey[800],
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Détails de la commande',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBanner(
                    status: orderData["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                  SizedBox(height: 24),

                  // Order Summary Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("ID de commande :",
                              orderData["orderId"] ?? "N/A"),
                          _buildInfoRow(
                            "Date de commande :",
                            DateFormat("hh:mm dd MMMM ").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(orderData["orderTime"]),
                              ),
                            ),
                          ),
                          _buildInfoRow(
                            "Méthode de paiement :",
                            orderData["paymentDetails"] ??
                                "Paiement à la livraison",
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Order Items
                  Text(
                    "Articles (${orderData["items"]?.length ?? 0})",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),

                  if (orderData["items"] != null)
                    ...(orderData["items"] as List).map<Widget>((item) {
                      if (item is Map<String, dynamic>) {
                        return _buildOrderItem(item);
                      }
                      return SizedBox.shrink();
                    }).toList(),

                  SizedBox(height: 16),

                  // Order Total
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: _buildInfoRow(
                        "Montant total :",
                        "DA ${orderData["totalAmount"]?.toStringAsFixed(2) ?? "0.00"}",
                        isTotal: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Shipping Address
                  Text(
                    "Adresse de livraison",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),

                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(sharedPreferences!.getString("uid"))
                        .collection("userAddress")
                        .doc(orderData["addressId"])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ShipmentAddressDesign(
                            model: Address.fromJson(
                              snapshot.data!.data()! as Map<String, dynamic>,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Erreur lors du chargement de l'adresse",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }
                      return Center(child: circularProgress());
                    },
                  ),

                  SizedBox(height: 24),

                  // Order Status
                  Text(
                    "Statut de la commande",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 10),

                  Center(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: orderStatus == "ended"
                            ? Image.asset('assets/images/delivered.jpg')
                            : Image.asset('assets/images/state.jpg'),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
