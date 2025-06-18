import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/mainScreens/item_detail_screen.dart';
import 'package:client/models/items.dart';

class ItemsDesignWidget extends StatelessWidget {
  final Items model;
  final BuildContext context;

  const ItemsDesignWidget({
    super.key,
    required this.model,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    // Debug prints to verify field values
    debugPrint('ItemsDesignWidget - Item ID: ${model.itemId}');
    debugPrint('Title: ${model.title}');
    debugPrint('Original Price: ${model.originalPrice}');
    debugPrint('Discounted Price: ${model.discountedPrice}');
    debugPrint('Discount Percentage: ${model.discountPercentage}');
    debugPrint('Is Offer Valid: ${model.isOfferValid}');
    debugPrint('Status: ${model.status}');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to ItemDetailsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(model: model),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: model.itemImageBase64 != null &&
                        model.itemImageBase64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(model.itemImageBase64!),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image decode error: $error');
                          return const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      model.title ?? 'Untitled Item',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Seller Name
                    Text(
                      model.sellerName ?? 'Unknown Seller',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price Row
                    Row(
                      children: [
                        // Discounted Price (if valid)
                        if (model.isOfferValid && model.discountedPrice != null)
                          Text(
                            model.formattedDiscountedPrice,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        // Original Price (always shown, strikethrough if discounted)
                        Padding(
                          padding: EdgeInsets.only(
                            left: model.isOfferValid &&
                                    model.discountedPrice != null
                                ? 8
                                : 0,
                          ),
                          child: Text(
                            model.formattedOriginalPrice,
                            style: TextStyle(
                              fontSize: model.isOfferValid &&
                                      model.discountedPrice != null
                                  ? 14
                                  : 16,
                              fontWeight: model.isOfferValid &&
                                      model.discountedPrice != null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: model.isOfferValid &&
                                      model.discountedPrice != null
                                  ? Colors.grey[600]
                                  : Colors.green,
                              decoration: model.isOfferValid &&
                                      model.discountedPrice != null
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Status and Discount Chips
                    Wrap(
                      spacing: 8,
                      children: [
                        // Status Chip
                        Chip(
                          label: Text(
                            model.status ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: model.status == 'available'
                              ? Colors.green
                              : Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        // Discount Chip (if valid)
                        if (model.isOfferValid &&
                            model.discountPercentage != null)
                          Chip(
                            label: Text(
                              '${model.formattedDiscountPercentage}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                      ],
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
