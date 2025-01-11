import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/iventory.dart';
import 'package:myapp/models/akun.dart';

class FirestoreService {
  static Future<List<Iventory>> getAllInventory() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('iventory').get();
    return querySnapshot.docs.map((doc) => Iventory.fromSnapshot(doc)).toList();
  }

  static Future<void> addIventory(Iventory iventory) async {
    await FirebaseFirestore.instance
        .collection('iventory')
        .add(iventory.toJson());
  }

  static Future<void> addAkun(Akun akun) async {
    await FirebaseFirestore.instance.collection('akun').add(akun.toJson());
  }

  static Future<List<Akun>> getAkunByEmail(String email) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('akun')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.map((doc) => Akun.fromSnapshot(doc)).toList();
  }

  static Future<void> deleteIventory(String id) async {
    await FirebaseFirestore.instance.collection('iventory').doc(id).delete();
  }

  static Future<void> editIventory(Iventory iventory, String id) async {
    await FirebaseFirestore.instance
        .collection('iventory')
        .doc(id)
        .update(iventory.toJson());
  }
}
