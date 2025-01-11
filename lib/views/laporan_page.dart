import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String filterType = 'Tahun ini'; // Default filter
  final DateTime now = DateTime.now();

  // Fungsi untuk menghitung total transaksi berdasarkan filter
  static Future<int> _getTotalTransaksi(String filterType) async {
    DateTime startFilter;
    final DateTime now = DateTime.now();

    // Tentukan batas waktu berdasarkan filter yang dipilih
    if (filterType == 'Hari ini') {
      startFilter = DateTime(now.year, now.month, now.day);
    } else if (filterType == 'Bulan ini') {
      startFilter = DateTime(now.year, now.month, 1);
    } else {
      startFilter = DateTime(now.year, 1, 1); // Tahun ini
    }

    // Query data transaksi berdasarkan filter
    final snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: startFilter.toIso8601String())
        .get();

    return snapshot.docs.length; // Hitung jumlah transaksi
  }

  // Fungsi untuk mengambil laporan berdasarkan filter waktu
  Future<List<Map<String, dynamic>>> _getLaporan() async {
    DateTime startFilter;

    if (filterType == 'Hari ini') {
      startFilter = DateTime(now.year, now.month, now.day);
    } else if (filterType == 'Bulan ini') {
      startFilter = DateTime(now.year, now.month, 1);
    } else {
      startFilter = DateTime(now.year, 1, 1); // Tahun ini
    }

    // Query ke Firebase berdasarkan filter waktu
    final snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: startFilter.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    // Mengolah data hasil query
    final Map<String, Map<String, dynamic>> groupedData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final DateTime date = DateTime.parse(data['date']);
      final String monthKey = DateFormat('MMMM yyyy').format(date);

      if (!groupedData.containsKey(monthKey)) {
        groupedData[monthKey] = {
          'total': 0.0,
          'items': [],
        };
      }

      groupedData[monthKey]!['total'] += data['total'];
      groupedData[monthKey]!['items'].add({
        'name': data['name'],
        'jumlah': data['jumlah'],
        'total': data['total'],
      });
    }

    // Mengubah map ke list agar dapat digunakan pada ListView
    return groupedData.entries
        .map((entry) => {
              'bulan': entry.key,
              'total': entry.value['total'],
              'items': entry.value['items'],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getLaporan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada data untuk filter "$filterType"',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final laporan = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Pemasukan dan Total Saldo
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pemasukan Tahun Ini
                          Text(
                            'Pemasukan ${filterType}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rp${NumberFormat("#,###").format(laporan.fold(0.0, (sum, item) => sum + (item['total'] ?? 0)))}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(height: 24, thickness: 1),
                          // Total Transaksi
                          FutureBuilder<int>(
                            future: _getTotalTransaksi(filterType),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Menghitung...',
                                  style: TextStyle(color: Colors.black54),
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Terjadi kesalahan',
                                  style: TextStyle(color: Colors.red),
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Transaksi',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      '${snapshot.data} Transaksi',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Dropdown untuk filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unit Terjual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      DropdownButton<String>(
                        value: filterType,
                        items: ['Tahun ini', 'Bulan ini', 'Hari ini']
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            filterType =
                                value!; // Set filter type sesuai pilihan
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // List laporan per bulan
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: laporan.length,
                    itemBuilder: (context, index) {
                      final bulan = laporan[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Bulan dan Total
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bulan['bulan'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp${NumberFormat("#,###").format(bulan['total'])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                // List items per bulan
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: bulan['items'].length,
                                  itemBuilder: (context, itemIndex) {
                                    final item = bulan['items'][itemIndex];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('${item['jumlah']} Unit'),
                                          Text(
                                            'Rp${NumberFormat("#,###").format(item['total'])}',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
