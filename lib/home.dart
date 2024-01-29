import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'account.dart';
import 'data.dart';
import 'data_provider.dart';
import 'login.dart';
import 'order.dart';
import 'order_details.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? url;
  DateFormat format = DateFormat.yMMMMd('en_US');
  DateFormat time = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Color(0xff4CAF50)),
        ),
        title: Text('Active Orders'),
        actions: [],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: dataProvider.orderTobeDelivered(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.docs.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Card(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: CachedNetworkImage(
                                          imageUrl: snapshot.data?.docs[index]
                                              ['image'],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )),
                                Expanded(
                                    flex: 7,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text.rich(
                                              TextSpan(text: '', children: [
                                            TextSpan(
                                                text: snapshot.data
                                                    ?.docs[index]['booking']
                                                    .toString(),
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])),
                                          subtitle: Text.rich(TextSpan(
                                              text:
                                                  '${format.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data?.docs[index]['booking']))}   ',
                                              style: GoogleFonts.poppins(),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${time.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data?.docs[index]['booking']))}',
                                                )
                                              ])),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Text(
                                                  '₹${snapshot.data?.docs[index]['total']}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: snapshot.data?.docs[index][
                                                                    'status'] ==
                                                                'Order Placed'
                                                            ? Colors.blue
                                                                .withOpacity(
                                                                    0.1)
                                                            : snapshot.data?.docs[index]
                                                                        [
                                                                        'status'] ==
                                                                    'Order Progress'
                                                                ? Colors.amber
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Color(0xff32CC34)
                                                                    .withOpacity(
                                                                        0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8)),
                                                    padding: EdgeInsets.all(4),
                                                    child: Text(
                                                      '${snapshot.data?.docs[index]['status']}',
                                                      style: GoogleFonts
                                                          .poppins(
                                                              fontSize: 14,
                                                              color: snapshot.data
                                                                              ?.docs[index]
                                                                          [
                                                                          'status'] ==
                                                                      'Order Placed'
                                                                  ? Colors.blue
                                                                  : snapshot.data?.docs[index]
                                                                              [
                                                                              'status'] ==
                                                                          'Order Progress'
                                                                      ? Colors
                                                                          .amber
                                                                      : Color(
                                                                          0xff32CC34),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                              ])),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OrderDetails(
                                            snapshot.data!.docs[index])));
                          },
                        );
                      },
                    )
                  : Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/atus-kart.appspot.com/o/static%2Fbasket.png?alt=media&token=4ca7a331-90d3-4ce0-8113-0226e577085e',
                                width: 120,
                                height: 120),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, top: 12),
                              child: Text('No items in your cart!',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 60, right: 60),
                              child: Text(
                                "We are looking to provide our services for you",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _drawer() {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.78,
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 10,
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: dataProvider.profile('doc'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 110,
                          height: 110,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70.0),
                              child: snapshot.data?['image'] != null &&
                                      snapshot.data?['image'].isNotEmpty
                                  ? CachedNetworkImage(
                                      // snapshot.data?.docs[index]
                                      //           ['image']
                                      imageUrl: snapshot.data?['image'],
                                      fit: BoxFit.contain,
                                    )
                                  : CircleAvatar(
                                      radius: 67,
                                      backgroundColor: Color(0xff6fb840),
                                      child: Icon(Icons.person,
                                          size: 45, color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          snapshot.data?['name'] ?? 'Guest',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 10),
                        child: Center(
                            child: Text(
                          snapshot.data?['phone'] ?? '+91 xxxxxxxx',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black),
                        )),
                      ),
                    ],
                  );
                }
                return CircularProgressIndicator();
              }),
          ListTile(
            leading: Icon(
              Icons.home_outlined,
              color: Colors.black,
            ),
            title: Text('Home',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
            },
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_outlined, color: Colors.black),
            title: Text('Orders',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Orders()));
            },
            contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
          ),
          ListTile(
            leading: Icon(Icons.support_agent, color: Colors.black),
            title: Text('Contact US',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {},
            trailing: Icon(Icons.navigate_next, color: Colors.black),
          ),
          ListTile(
            title: Text('Sign Out',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            leading: Icon(Icons.logout, color: Colors.black),
            trailing: Icon(Icons.navigate_next, color: Colors.black),
            onTap: () async {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LogIN()));
            },
          ),
          ListTile(
            title: Text('Terms of Use',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {},
          ),
          ListTile(
            title: Text('Privacy policy',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
