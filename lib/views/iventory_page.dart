import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:myapp/models/iventory.dart';
import 'package:myapp/providers/firestore_service.dart';
import 'package:flutter/services.dart';

class IventoryPage extends StatefulWidget {
  const IventoryPage({super.key, this.iventory, this.id});

  final Iventory? iventory;
  final String? id;

  @override
  State<IventoryPage> createState() => _IventoryPageState();
}

class _IventoryPageState extends State<IventoryPage> {
  late TextEditingController nameController;
  late TextEditingController kategoriController;
  late TextEditingController stokController;
  late TextEditingController dateController;
  late TextEditingController brandController;
  late TextEditingController hargaController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    kategoriController = TextEditingController();
    stokController = TextEditingController();
    dateController = TextEditingController();
    brandController = TextEditingController();
    hargaController = TextEditingController();

    if (widget.iventory != null) {
      nameController.text = widget.iventory!.name;
      kategoriController.text = widget.iventory!.kategori;
      stokController.text = widget.iventory!.stok;
      dateController.text = widget.iventory!.date;
      brandController.text = widget.iventory!.brand;
      hargaController.text = widget.iventory!.harga;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    kategoriController.dispose();
    stokController.dispose();
    dateController.dispose();
    brandController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iventory Page'),
        actions: [
          IconButton(
              onPressed: () async {
                if (widget.iventory != null) {
                  await FirestoreService.editIventory(
                      Iventory(
                        date: dateController.text,
                        name: nameController.text,
                        brand: brandController.text,
                        kategori: kategoriController.text,
                        stok: stokController.text,
                        harga: hargaController.text,
                      ),
                      widget.id!);
                } else {
                  await FirestoreService.addIventory(
                    Iventory(
                      date: dateController.text,
                      name: nameController.text,
                      brand: brandController.text,
                      kategori: kategoriController.text,
                      stok: stokController.text,
                      harga: hargaController.text,
                    ),
                  );
                }

                Navigator.pop(context);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                hintText: 'Pilih Tanggal',
                label: Text('Tanggal'),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // Prevent keyboard from appearing
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), // Earliest date
                  lastDate: DateTime(2101), // Latest date
                );

                if (pickedDate != null) {
                  setState(() {
                    // Format the picked date to a string
                    dateController.text =
                        "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Input Nama Barang',
                label: Text('Nama Barang'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: brandController,
              decoration: InputDecoration(
                hintText: 'Input Brand',
                label: Text('Input Brand'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: kategoriController,
              decoration: InputDecoration(
                hintText: 'Kategori Barang',
                label: Text('Input Kategori'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: stokController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter
                    .digitsOnly, // Membatasi input hanya angka
              ],
              decoration: InputDecoration(
                hintText: 'Masukan Stok',
                label: Text('Stok Barang'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter
                    .digitsOnly, // Membatasi input hanya angka
              ],
              decoration: InputDecoration(
                hintText: 'Input Harga Barang',
                label: Text('Rp. '),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
