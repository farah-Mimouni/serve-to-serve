import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/items.dart';

class CartItemDesign extends StatefulWidget {
  final Items? model;
  final int? quanNumber;

  const CartItemDesign({
    super.key,
    this.model,
    this.quanNumber,
    required BuildContext context,
  });

  @override
  State<CartItemDesign> createState() => _CartItemDesignState();
}

class _CartItemDesignState extends State<CartItemDesign> {
  // Future to handle async image decoding
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    // Load image asynchronously
    if (widget.model?.itemImageBase64 != null) {
      _imageFuture = _decodeImage(widget.model!.itemImageBase64!);
    }
  }

  // Decode base64 image asynchronously to avoid blocking UI
  Future<Uint8List?> _decodeImage(String base64String) async {
    try {
      return await Future.microtask(() => base64Decode(base64String));
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback if model is null
    if (widget.model == null) {
      return const Center(child: Text('No item data available'));
    }

    final item = widget.model!;
    final isOfferValid = item.isOfferValid && item.discountedPrice != null;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 165,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Item Image with loading indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _imageFuture != null
                      ? FutureBuilder<Uint8List?>(
                          future: _imageFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Icon(Icons.image_not_supported,
                                  size: 100);
                            }
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            );
                          },
                        )
                      : const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
              const SizedBox(width: 10),
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Item Title
                    Text(
                      item.title ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: "Roboto", // Fallback font
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Quantity
                    Row(
                      children: [
                        const Text(
                          "x",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontFamily: "Roboto", // Fallback font
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (widget.quanNumber ?? 1).toString(),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price Section
                    Row(
                      children: [
                        // Discounted or Original Price
                        Text(
                          "Dz${isOfferValid ? item.formattedDiscountedPrice : item.formattedOriginalPrice}",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isOfferValid ? Colors.redAccent : Colors.blue,
                            fontWeight: isOfferValid
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Original Price (strikethrough if discounted)
                        if (isOfferValid && item.originalPrice != null)
                          Text(
                            "Dz${item.formattedOriginalPrice}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    // Discount Percentage
                    if (isOfferValid && item.discountPercentage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "${item.formattedDiscountPercentage}% OFF",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
