import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth/login_page.dart';
import 'package:myapp/models/iventory.dart';
import 'package:myapp/providers/firestore_service.dart';
import 'package:myapp/views/iventory_page.dart';
import 'package:myapp/views/laporan_page.dart';
import 'package:myapp/views/transaksi_page.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.email,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return IventoryPage();
            },
          ));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Container(
              height: 40, // Mengatur tinggi kolom secara langsung
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cari Barang',
                  filled: true,
                  fillColor: const Color.fromARGB(64, 175, 175, 175),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0), // Menambah ruang di dalam kolom
                ),
              ),
            ),
          ),

          // Card untuk total pemasukan
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: 160, // Sesuaikan tinggi card
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white, // Background card
                ),
                child: FutureBuilder(
                  future:
                      _getTotalPemasukan(), // Memanggil fungsi untuk mengambil data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(), // Loading indicator
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Terjadi kesalahan!'),
                      );
                    }

                    if (snapshot.hasData) {
                      final data = snapshot.data as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            // Bagian Total Pemasukan Hari Ini
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Pemasukan Hari Ini',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${data['hariIni'].toString()}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            // Garis pembatas
                            Divider(
                              color: Colors.grey,
                              thickness: 1.0,
                            ),
                            SizedBox(height: 8),
                            // Bagian Total Pemasukan Bulan dan Tahun
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Total Pemasukan Bulan Ini
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Bulan Ini',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${data['bulanIni'].toString()}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1.0,
                                  width: 20,
                                ),
                                // Total Pemasukan Tahun Ini
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tahun Ini',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${data['tahunIni'].toString()}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Text('Tidak ada data'),
                    );
                  },
                ),
              ),
            ),
          ),

          // Row untuk menu Laporan dan Transaksi
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Laporan
                Expanded(
                  child: Card(
                    color: Colors.yellow[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LaporanPage(), // Pastikan TransaksiPage diimpor
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart,
                                size: 50, color: Colors.orange),
                            SizedBox(height: 5),
                            Text(
                              'Laporan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Jarak antar card
                // Menu Transaksi
                Expanded(
                  child: Card(
                    color: Colors.green[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TransaksiPage(), // Pastikan TransaksiPage diimpor
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Icon(Icons.attach_money,
                                size: 50, color: Colors.green),
                            SizedBox(height: 5),
                            Text(
                              'Transaksi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // StreamBuilder untuk menampilkan list
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('iventory').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var iventory = snapshot.data!.docs
                    .map((iventory) => Iventory.fromSnapshot(iventory))
                    .where((iventory) =>
                        iventory.name.toLowerCase().contains(searchQuery))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Keterangan jumlah data
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 4.0),
                      child: Text(
                        'data: ${iventory.length}', // Menampilkan jumlah data
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ListView Builder
                    Expanded(
                      child: ListView.builder(
                        itemCount: iventory.length,
                        itemBuilder: (context, index) {
                          var id = snapshot.data!.docs[index].id;

                          return ListTile(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return IventoryPage(
                                    iventory: iventory[index],
                                    id: id,
                                  );
                                },
                              ));
                            },
                            title: Text(iventory[index].name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rp. ${NumberFormat('#,###').format(int.parse(iventory[index].harga))}', // Format harga dengan pemisah ribuan
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text('Stok: ${iventory[index].stok}'),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                FirestoreService.deleteIventory(id);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: const Color.fromARGB(160, 253, 50, 35),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: Lottie.asset('assets/loading_animation.json'),
              );
            },
          )),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getTotalPemasukan() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    // Query untuk total pemasukan hari ini
    final hariIniSnapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .get();

    // Query untuk total pemasukan bulan ini
    final bulanIniSnapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
        .get();

    // Query untuk total pemasukan tahun ini
    final tahunIniSnapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: startOfYear.toIso8601String())
        .get();

    double totalHariIni = hariIniSnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['total'] ?? 0),
    );

    double totalBulanIni = bulanIniSnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['total'] ?? 0),
    );

    double totalTahunIni = tahunIniSnapshot.docs.fold(
      0.0,
      (sum, doc) => sum + (doc['total'] ?? 0),
    );

    // Format angka menjadi Rupiah
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return {
      'hariIni': currencyFormatter.format(totalHariIni),
      'bulanIni': currencyFormatter.format(totalBulanIni),
      'tahunIni': currencyFormatter.format(totalTahunIni),
    };
  }

  // Fungsi untuk melakukan logout
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
