import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/mainScreens/menus_screen.dart';
import 'package:client/models/sellers.dart';

class SellersDesignWidget extends StatelessWidget {
  final Sellers? model;
  final BuildContext context;

  const SellersDesignWidget({
    super.key,
    required this.model,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (model != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenusScreen(model: model),
            ),
          );
        }
      },
      splashColor: Colors.amber.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: model?.sellerImageBase64 != null &&
                          model!.sellerImageBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(model!.sellerImageBase64!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.store,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  model?.sellerName ?? 'Unknown Seller',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model?.sellerEmail ?? 'No Email',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'voir Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
