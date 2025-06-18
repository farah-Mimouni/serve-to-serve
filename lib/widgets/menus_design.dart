import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/mainScreens/items_screen.dart';
import 'package:client/models/menus.dart';

class MenusDesignWidget extends StatelessWidget {
  final Menus? model;

  const MenusDesignWidget(
      {super.key, required this.model, required BuildContext context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (model != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemsScreen(model: model),
            ),
          );
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: model?.menuImageBase64 != null &&
                      model!.menuImageBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(model!.menuImageBase64!),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model?.menuTitle ?? 'Unknown Menu',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Menu by ${model?.sellerUID ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
