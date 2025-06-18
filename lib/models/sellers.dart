import 'package:cloud_firestore/cloud_firestore.dart';

class Sellers {
  String? id;
  String? sellerUID;
  String? sellerName;
  String? sellerEmail;
  String? phone;
  String? address;
  String? sellerImageBase64;
  double? lat;
  double? lng;
  String? status;
  Timestamp? registeredAt;

  Sellers({
    this.id,
    this.sellerUID,
    this.sellerName,
    this.sellerEmail,
    this.phone,
    this.address,
    this.sellerImageBase64,
    this.lat,
    this.lng,
    this.status,
    this.registeredAt,
  });

  Sellers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sellerUID = json['sellerUID'];
    sellerName = json['sellerName'];
    sellerEmail = json['sellerEmail'];
    phone = json['phone'];
    address = json['address'];
    sellerImageBase64 = json['sellerImageBase64'];
    lat = json['lat']?.toDouble();
    lng = json['lng']?.toDouble();
    status = json['status'];
    registeredAt = json['registeredAt'];
  }
}
