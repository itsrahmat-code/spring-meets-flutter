class Supplier {
  final int? id;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? companyName;

  Supplier({
    this.id,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.companyName,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as int?,
      contactPerson: json['contactPerson'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      companyName: json['companyName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'address': address,
    'companyName': companyName,
  };
}
