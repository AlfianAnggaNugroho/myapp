import 'package:cloud_firestore/cloud_firestore.dart';

class Iventory {
  String date;
  String kategori;
  String harga;
  String name;
  String brand;
  String stok;
  int quantity;

  Iventory({
    required this.date,
    required this.name,
    required this.brand,
    required this.kategori,
    required this.stok,
    required this.harga,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'name': name,
      'brand': brand,
      'kategori': kategori,
      'stok': stok,
      'harga': harga,
    };
  }

  factory Iventory.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> json) {
    return Iventory(
      date: json['date'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      kategori: json['kategori'] ?? '',
      stok: json['stok'] ?? '',
      harga: json['harga'] ?? '0',
    );
  }

  Iventory copyWith({
    String? date,
    String? name,
    String? brand,
    String? kategori,
    String? stok,
    String? harga,
    int? quantity,
  }) {
    return Iventory(
      date: date ?? this.date,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      kategori: kategori ?? this.kategori,
      stok: stok ?? this.stok,
      harga: harga ?? this.harga,
      quantity: quantity ?? this.quantity,
    );
  }
}
