import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/models/items.dart';
import 'package:client/mainScreens/order_details_screen.dart';

class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<Map<String, dynamic>>? data;
  final String? orderId;
  final List<String>? seperateQuantitiesList;
  final String totalAmount;

  const OrderCard({
    super.key,
    this.itemCount,
    this.data,
    this.orderId,
    required this.totalAmount,
    this.seperateQuantitiesList,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == null || data == null || data!.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Commande vide'),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (orderId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: orderId),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(10),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black12, Colors.white54],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: \$$totalAmount",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: itemCount,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (c, index) {
                  if (index >= data!.length) {
                    return const SizedBox.shrink();
                  }
                  final itemData = data![index];
                  if (itemData == null) {
                    return const Text('Invalid item data');
                  }
                  Items model = Items.fromJson(itemData);
                  return placedOrderDesignWidget(
                    model,
                    context,
                    seperateQuantitiesList != null &&
                            index < seperateQuantitiesList!.length
                        ? seperateQuantitiesList![index]
                        : '1',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(
    Items model, BuildContext context, String? quantity) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: model.itemImageBase64 != null
                ? Image.memory(
                    base64Decode(model.itemImageBase64!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model.title ?? 'Untitled Item',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "Acme",
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${model.isOfferValid && model.discountedPrice != null ? model.formattedDiscountedPrice : model.formattedOriginalPrice}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (model.isOfferValid && model.discountedPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '\$${model.formattedOriginalPrice}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "x",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: "Acme",
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      quantity ?? '1',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontFamily: "Acme",
                      ),
                    ),
                  ],
                ),
                if (model.isOfferValid && model.discountPercentage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      label: Text(
                        '${model.formattedDiscountPercentage}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
