import 'dart:convert';

class Menus {
  String? menuId;
  String? sellerUID;
  String? menuTitle;
  String? menuInfo;
  String? publishedDate;
  String? menuImageBase64;
  String? status;
  String? sellerName;

  Menus(
      {this.menuId,
      this.menuInfo,
      this.menuTitle,
      this.sellerUID,
      this.publishedDate,
      this.status,
      this.menuImageBase64,
      this.sellerName});

  Menus.fromJson(Map<String, dynamic> json) {
    menuId = json["menuId"];
    sellerUID = json["sellerUID"];
    menuTitle = json["menuTitle"];
    menuInfo = json["menuInfo"];
    sellerName = json['sellerName'];
    menuImageBase64 = json['menuImageBase64'];
    status = json["status"];
    // publishedDate = json['publishedDate'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuId"] = menuId;
    data["sellerUID"] = sellerUID;
    data["menuTitle"] = menuTitle;
    data["menuInfo"] = menuInfo;
    data["publishedDate"] = publishedDate;
    data["thumbnailUrl"] = menuImageBase64;
    data["status"] = status;
    data["sellerName"] = sellerName;
    return data;
  }
}
