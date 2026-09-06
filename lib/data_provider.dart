import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_bazaar_delivery/data.dart';

class DataProvider {
  final db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> orderTobeDelivered() {
    return db
        .collection('Orders')
        .where('deliveryBoy', isEqualTo: UserAuth().user?.uid)
        .where('status', isEqualTo: 'Order Accepted')
        .snapshots();
  }

  Stream<QuerySnapshot> boyOrders() {
    return db
        .collection('Orders')
        .where('status', isEqualTo: 'Order Completed')
        .where('deliveryBoy', isEqualTo: UserAuth().user?.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> orderItems(String id) {
    return db.collection('Items').where('orderID', isEqualTo: id).snapshots();
  }

  Stream<DocumentSnapshot> orderDetails(String doc) {
    return db.collection('Orders').doc(doc).snapshots();
  }

  Stream<DocumentSnapshot> profile(String doc) {
    return db.collection('Employee').doc(UserAuth().user?.uid).snapshots();
  }
}

DataProvider dataProvider = new DataProvider();
