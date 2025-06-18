import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:client/models/items.dart';
import 'package:client/widgets/app_bar.dart';
import '../assistant_methods/assistant_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Items? model;
  const ItemDetailsScreen({super.key, this.model});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController counterTextEditingController = TextEditingController();
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    counterTextEditingController.text = '1';
  }

  @override
  void dispose() {
    counterTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Inquiry about ${widget.model!.title}'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Fluttertoast.showToast(msg: 'Could not open email client');
    }
  }

  @override
  Widget build(BuildContextContext) {
    return Scaffold(
      appBar: MyAppbar(sellerUID: widget.model!.sellerUID),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: widget.model!.itemImageBase64 != null
                    ? Image.memory(
                        base64Decode(widget.model!.itemImageBase64!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.broken_image,
                          size: 120,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 120,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Status and Discount Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      widget.model!.status ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: widget.model!.status == 'available'
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (widget.model!.discountedPrice != null &&
                      widget.model!.discountPercentage != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          ' - ${widget.model!.formattedDiscountPercentage} % ',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.model!.title ?? 'Untitled Item',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Seller Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _launchEmail(
                    'seller@example.com'), // Replace with actual seller email
                child: Text(
                  'par ${widget.model!.sellerName ?? 'Unknown Seller'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            // Price Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'DZD ${widget.model!.discountedPrice != null ? widget.model!.formattedDiscountedPrice : widget.model!.formattedOriginalPrice}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.green.shade700,
                    ),
                  ),
                  if (widget.model!.discountedPrice != null &&
                      widget.model!.originalPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'DZD ${widget.model!.formattedOriginalPrice}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Offer Timer
            if (widget.model!.discountedPrice != null &&
                widget.model!.timeRemaining != null &&
                widget.model!.timeRemaining!.isNegative == false)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Fin de l’offre dans: ${widget.model!.timeRemaining!.inHours}h ${widget.model!.timeRemaining!.inMinutes % 60}m',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.model!.longDescription ??
                            'No description available',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quantity Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: NumberInputPrefabbed.roundedButtons(
                    controller: counterTextEditingController,
                    incDecBgColor: Colors.green.shade600,
                    min: 1,
                    max: widget.model!.quantity != null &&
                            widget.model!.quantity! > 0
                        ? widget.model!.quantity!
                        : 9, // Limit max to available quantity or default to 9
                    initialValue: 1,
                    buttonArrangement: ButtonArrangement.incRightDecLeft,
                    numberFieldDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    scaleHeight: 0.9,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add to Cart Button
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  height: 50,
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isAddingToCart ||
                              widget.model!.quantity == null ||
                              widget.model!.quantity! < 1
                          ? null // Disable button if quantity is insufficient
                          : () async {
                              setState(() {
                                isAddingToCart = true;
                              });
                              int itemCounter =
                                  int.parse(counterTextEditingController.text);

                              // Check if requested quantity exceeds available quantity
                              if (widget.model!.quantity != null &&
                                  itemCounter > widget.model!.quantity!) {
                                Fluttertoast.showToast(
                                    msg: "Quantité insuffisante en stock");
                                setState(() {
                                  isAddingToCart = false;
                                });
                                return;
                              }

                              List<String> separateItemIdsList =
                                  separateItemIds();

                              if (separateItemIdsList
                                  .contains(widget.model!.itemId)) {
                                Fluttertoast.showToast(
                                    msg: "Article déjà dans le panier");
                              } else {
                                await addItemToCart(
                                    widget.model!.itemId, context, itemCounter);
                              }
                              setState(() {
                                isAddingToCart = false;
                              });
                            },
                      child: Center(
                        child: isAddingToCart
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Ajouter au panier",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
