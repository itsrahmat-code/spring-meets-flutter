class Product {
  int? id;
  String? productName;
  String? description;
  double? price;
  int? quantity;

  Product({this.id, this.productName, this.description, this.price, this.quantity});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
    description = json['description'];
    price = json['price']?.toDouble(); // safe cast
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    data['productName'] = productName;
    data['description'] = description;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}
