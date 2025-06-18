import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  String? menuId;
  String? sellerUID;
  String? itemId;
  String? title;

  String? shortInfo;
  int? quantity; // Store quantity as integer
  String? publishedDate;
  String? itemImageBase64;
  String? sellerName;
  String? longDescription;
  String? status;
  double? originalPrice;
  double? discountedPrice;
  DateTime? offerEndTime;
  double? discountPercentage;

  Items({
    this.menuId,
    this.sellerUID,
    this.itemId,
    this.title,
    this.shortInfo,
    this.quantity, // Include in constructor
    this.publishedDate,
    this.itemImageBase64,
    this.sellerName,
    this.longDescription,
    this.status,
    this.originalPrice,
    this.discountedPrice,
    this.offerEndTime,
    this.discountPercentage,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    try {
      final originalPrice = _parseDouble(json['originalPrice']);
      final discountedPrice = _parseDouble(json['discountedPrice']);
      final quantity = _parseInt(json['quantity']); // Parse quantity

      double? discountPercentage = _parseDouble(json['discountPercentage']);
      if (discountPercentage == null &&
          originalPrice != null &&
          discountedPrice != null &&
          originalPrice > 0) {
        discountPercentage =
            ((originalPrice - discountedPrice) / originalPrice * 100)
                .roundToDouble();
      }

      DateTime? offerEndTime;
      if (json['offerEndTime'] != null) {
        offerEndTime = json['offerEndTime'] is Timestamp
            ? (json['offerEndTime'] as Timestamp).toDate()
            : DateTime.tryParse(json['offerEndTime'].toString());
      }

      return Items(
        menuId: json['menuId']?.toString(),
        sellerUID: json['sellerUID']?.toString(),
        itemId: json['id']?.toString() ?? json['itemId']?.toString(),
        title: json['title']?.toString(),
        quantity: quantity, // Set quantity
        shortInfo: json['shortInfo']?.toString(),
        publishedDate: json['publishedDate']?.toString(),
        itemImageBase64: json['itemImageBase64']?.toString(),
        sellerName: json['sellerName']?.toString(),
        longDescription: json['longDescription']?.toString(),
        status: json['status']?.toString(),
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        offerEndTime: offerEndTime,
        discountPercentage: discountPercentage,
      );
    } catch (e) {
      print('Error parsing Items.fromJson: $e');
      rethrow;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'sellerUID': sellerUID,
      'itemId': itemId,
      'title': title,
      'quantity': quantity, // Include quantity in JSON
      'shortInfo': shortInfo,
      'publishedDate': publishedDate,
      'itemImageBase64': itemImageBase64,
      'sellerName': sellerName,
      'longDescription': longDescription,
      'status': status,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'offerEndTime':
          offerEndTime != null ? Timestamp.fromDate(offerEndTime!) : null,
      'discountPercentage': discountPercentage,
    };
  }

  bool get isOfferValid {
    if (discountedPrice == null || originalPrice == null) return false;
    if (offerEndTime == null) return true;
    return DateTime.now().isBefore(offerEndTime!);
  }

  Duration? get timeRemaining {
    if (offerEndTime == null) return null;
    return offerEndTime!.difference(DateTime.now());
  }

  String get formattedOriginalPrice {
    return originalPrice?.toStringAsFixed(2) ?? '0.00';
  }

  String get formattedDiscountedPrice {
    return discountedPrice?.toStringAsFixed(2) ?? formattedOriginalPrice;
  }

  String get formattedDiscountPercentage {
    return discountPercentage?.toStringAsFixed(0) ?? '0';
  }

  String get formattedQuantity {
    return quantity?.toString() ?? '0';
  }
}
