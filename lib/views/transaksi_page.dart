import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/iventory.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<Iventory> selectedProducts = [];

  void _addProduct() async {
    final inventorySnapshot =
        await FirebaseFirestore.instance.collection('iventory').get();

    List<Iventory> inventoryList = inventorySnapshot.docs
        .map((doc) => Iventory.fromSnapshot(doc))
        .toList();

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ProductSelectionModal(
            inventoryList: inventoryList,
            onProductSelected: (Iventory product, int quantity) {
              setState(() {
                // Cek apakah produk sudah ada dalam daftar
                final existingProductIndex =
                    selectedProducts.indexWhere((p) => p.name == product.name);
                if (existingProductIndex != -1) {
                  // Jika ada, tambahkan jumlahnya
                  selectedProducts[existingProductIndex].quantity += quantity;
                } else {
                  // Jika tidak, tambahkan produk baru
                  selectedProducts.add(
                    product.copyWith(quantity: quantity),
                  );
                }
              });
            },
          );
        });
  }

  double _calculateTotal() {
    return selectedProducts.fold(
        0,
        (total, product) =>
            total + (double.tryParse(product.harga) ?? 0) * product.quantity);
  }

  Future<void> _processTransaction() async {
    final batch = FirebaseFirestore.instance.batch();
    final transaksiCollection =
        FirebaseFirestore.instance.collection('transaksi');
    final now = DateTime.now();

    for (var product in selectedProducts) {
      // Update stok di database
      final inventoryDoc = await FirebaseFirestore.instance
          .collection('iventory')
          .where('name', isEqualTo: product.name)
          .limit(1)
          .get();

      if (inventoryDoc.docs.isNotEmpty) {
        final doc = inventoryDoc.docs.first;
        final currentStok = int.tryParse(doc['stok']) ?? 0;
        final updatedStok = currentStok - product.quantity;

        if (updatedStok >= 0) {
          batch.update(doc.reference, {'stok': updatedStok.toString()});
        } else {
          // Stok tidak mencukupi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stok tidak mencukupi untuk ${product.name}'),
            ),
          );
          return;
        }
      }

      // Simpan transaksi ke tabel 'transaksi'
      batch.set(transaksiCollection.doc(), {
        'name': product.name,
        'brand': product.brand,
        'kategori': product.kategori,
        'jumlah': product.quantity,
        'harga': product.harga,
        'total': (double.tryParse(product.harga) ?? 0) * product.quantity,
        'date': now.toIso8601String(),
      });
    }

    // Jalankan batch
    await batch.commit();

    // Reset data setelah transaksi selesai
    setState(() {
      selectedProducts.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaksi berhasil diproses'),
      ),
    );

    // Navigasi kembali ke halaman home
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi (out)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Tambahkan Produk +'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama Produk: ${product.name}'),
                          Text('Brand: ${product.brand}'),
                          Text('Kategori: ${product.kategori}'),
                          Text('Jumlah: ${product.quantity}'),
                          Text('Harga: Rp${product.harga}'),
                          Text(
                              'Total: Rp${((double.tryParse(product.harga) ?? 0) * product.quantity).toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
                'Total Keseluruhan: Rp${_calculateTotal().toStringAsFixed(0)}'),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _processTransaction,
              child: Text('Proses'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSelectionModal extends StatelessWidget {
  final List<Iventory> inventoryList;
  final Function(Iventory, int) onProductSelected;

  const ProductSelectionModal({
    required this.inventoryList,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: inventoryList.length,
      itemBuilder: (context, index) {
        final product = inventoryList[index];
        final TextEditingController quantityController =
            TextEditingController();

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('Harga: Rp${product.harga}'),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Jumlah'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      final quantity =
                          int.tryParse(quantityController.text) ?? 1;
                      onProductSelected(product, quantity);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
