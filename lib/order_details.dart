import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_bazaar_delivery/live_tracking.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'data_provider.dart';
import 'items_details.dart';

class OrderDetails extends StatefulWidget {
  final DocumentSnapshot snapshot;

  OrderDetails(this.snapshot);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  List<dynamic> orderlist = [1, 2, 3];
  DateFormat format = DateFormat.yMMMMd('en_US');
  DateFormat time = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: dataProvider.orderDetails(widget.snapshot.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white10.withOpacity(0.95),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color(0xff4CAF50),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.location_on_outlined),
                      onPressed: () async {
                        var addresses = await GeocoderBuddy.query(
                            snapshot.data?['address']);
                        print("address captured from client");
                        print(addresses.first.lat);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => LiveTracking(
                                      destination: LatLng(
                                          double.parse(addresses.first.lat),
                                          double.parse(addresses.first.lon)),
                                    )));
                      })
                ],
              ),
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Color.fromRGBO(0, 211, 225, 1), width: 1)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Order Id",
                                style: GoogleFonts.poppins(color: Colors.black),
                              ),
                              Text(
                                widget.snapshot.get('booking').toString(),
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Date of Booking",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400)),
                              Text.rich(TextSpan(
                                  text:
                                      '${format.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data?['booking']))}   ',
                                  style: GoogleFonts.poppins(),
                                  children: [
                                    TextSpan(
                                      text:
                                          '${time.format(DateTime.fromMicrosecondsSinceEpoch(snapshot.data?['booking']))}',
                                    )
                                  ]))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Status",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400)),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                ),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xff32CC34).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(4),
                                    child: Text(
                                      '${snapshot.data?['status']}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Color(0xff32CC34),
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("Shipping Address",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("${widget.snapshot.get('address')}",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade400)),
                          ),
                          trailing: Icon(Icons.local_shipping_outlined,
                              size: 40, color: Colors.green),
                        ),
                        ListTile(
                            title: Text("${widget.snapshot.get('name')}",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.black)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text("${widget.snapshot.get('phone')}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400)),
                            ),
                            trailing: IconButton(
                                icon: Icon(Icons.phone, color: Colors.green),
                                onPressed: () {})),
                        Divider(),
                        StreamBuilder<QuerySnapshot>(
                            stream: dataProvider.orderItems(widget.snapshot.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map<String, dynamic> data =
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;
                                    // return Text("Full Name: ${data['image']} ");
                                    return ItemsDetails(
                                      data: data,
                                    );
                                    // return Container(
                                    //   color: Colors.white,
                                    //   padding: EdgeInsets.only(bottom: 2),
                                    //   child: Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.start,
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: <Widget>[
                                    //         Expanded(
                                    //           flex: 4,
                                    //           child: Container(
                                    //             height: MediaQuery.of(context)
                                    //                     .size
                                    //                     .height *
                                    //                 0.18,
                                    //             width: MediaQuery.of(context)
                                    //                     .size
                                    //                     .width *
                                    //                 0.3,
                                    //             child: Stack(
                                    //               children: [
                                    //                 Positioned(
                                    //                     top: 0,
                                    //                     child: Padding(
                                    //                       padding:
                                    //                           const EdgeInsets
                                    //                               .all(8.0),
                                    //                       child: snapshot.data?.docs[index]['image'] != null &&
                                    //                               snapshot
                                    //                                   .data
                                    //                                   ?.docs[index][
                                    //                                       'image']
                                    //                                   .isNotEmpty
                                    //                           ? CachedNetworkImage(
                                    //                               imageUrl: snapshot.data?.docs[index]
                                    //                                   ['image'],
                                    //                               height: MediaQuery.of(context)
                                    //                                       .size
                                    //                                       .height *
                                    //                                   0.18,
                                    //                               width: MediaQuery.of(context)
                                    //                                       .size
                                    //                                       .width *
                                    //                                   0.3,
                                    //                               fit: BoxFit
                                    //                                   .contain)
                                    //                           : Container(
                                    //                               alignment: Alignment.center,
                                    //                               height: MediaQuery.of(context).size.height * 0.18,
                                    //                               width: MediaQuery.of(context).size.width * 0.3,
                                    //                               child: Icon(Icons.photo_size_select_actual_outlined)),
                                    //                     )),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         Expanded(
                                    //             flex: 6,
                                    //             child: Column(
                                    //               children: [
                                    //                 ListTile(
                                    //                   title: Text(
                                    //                     '${snapshot.data?.docs[index]['name']}',
                                    //                     style:
                                    //                         GoogleFonts.poppins(
                                    //                             fontSize: 18.0,
                                    //                             color: Colors
                                    //                                 .black,
                                    //                             fontWeight:
                                    //                                 FontWeight
                                    //                                     .w500,
                                    //                             letterSpacing:
                                    //                                 0.5),
                                    //                   ),
                                    //                   subtitle: Text(
                                    //                     snapshot.data?.docs[
                                    //                                 index][
                                    //                             'description'] ??
                                    //                         'Price for ${snapshot.data?.docs[index]['quantity']}',
                                    //                     style:
                                    //                         GoogleFonts.poppins(
                                    //                             fontSize: 14.0),
                                    //                   ),
                                    //                 ),
                                    //                 Padding(
                                    //                   padding:
                                    //                       const EdgeInsets.all(
                                    //                           8.0),
                                    //                   child: Container(
                                    //                     width: MediaQuery.of(
                                    //                             context)
                                    //                         .size
                                    //                         .width,
                                    //                     decoration: BoxDecoration(
                                    //                         border: Border.all(
                                    //                             color: Colors
                                    //                                 .grey
                                    //                                 .shade300),
                                    //                         borderRadius:
                                    //                             BorderRadius
                                    //                                 .circular(
                                    //                                     4)),
                                    //                     padding:
                                    //                         EdgeInsets.all(6),
                                    //                     child: Text(
                                    //                       '${snapshot.data?.docs[index]['quantity']}',
                                    //                       style: GoogleFonts
                                    //                           .poppins(),
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //                 Padding(
                                    //                   padding:
                                    //                       const EdgeInsets.only(
                                    //                           left: 8,
                                    //                           right: 8,
                                    //                           top: 4),
                                    //                   child: Row(
                                    //                     children: [
                                    //                       Text(
                                    //                           '₹${snapshot.data?.docs[index]['price']}X${snapshot.data?.docs[index]['pieces']} = ',
                                    //                           style: GoogleFonts.poppins(
                                    //                               fontSize: 18,
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .normal,
                                    //                               color: Colors
                                    //                                   .black)),
                                    //                       Text(
                                    //                           '₹${snapshot.data?.docs[index]['total']}',
                                    //                           style: GoogleFonts.poppins(
                                    //                               fontSize: 18,
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold,
                                    //                               color: Colors
                                    //                                   .green)),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //                 SizedBox(
                                    //                   height: 4,
                                    //                 )
                                    //               ],
                                    //             ))
                                    //       ]),
                                    // );
                                  },
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            }),
                        CustomTile(
                            title: 'Items Total',
                            tail: '₹${widget.snapshot.get('sub')}',
                            titlestyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 16),
                            tailstyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 16)),
                        CustomTile(
                            title: 'Delivery Charge',
                            tail: '₹${widget.snapshot.get('delivery')}',
                            titlestyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 16),
                            tailstyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 16)),
                        CustomTile(
                            title: 'Sub Total',
                            tail:
                                '₹${widget.snapshot.get('sub') + widget.snapshot.get('delivery')}',
                            titlestyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 16),
                            tailstyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 16)),
                        CustomTile(
                            title: 'Total Saving',
                            tail: '- ₹${widget.snapshot.get('saving')}',
                            titlestyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 16),
                            tailstyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                                fontSize: 16)),
                        CustomTile(
                            title: 'Discount',
                            tail:
                                '${((widget.snapshot.get('saving') / widget.snapshot.get('sub')) * 100).floor()}% OFF',
                            titlestyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                fontSize: 16),
                            tailstyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                                fontSize: 16)),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Total:',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    'including all taxes',
                                    style: GoogleFonts.poppins(
                                      color: Color.fromRGBO(112, 112, 112, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "₹${widget.snapshot.get('total')}",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        snapshot.data?['status'] == 'Order PickedUp'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  height: 50.0,
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: ElevatedButton(
                                    // elevation: 0,
                                    onPressed: () async {
                                      CollectionReference reference =
                                          FirebaseFirestore.instance
                                              .collection('Orders');
                                      try {
                                        await reference
                                            .doc(widget.snapshot.id)
                                            .set(
                                          {'status': 'Order Completed'},
                                          // merge: true
                                        );
                                      } catch (e) {}
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Colors.green
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(80.0)),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Complete Order",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  height: 50.0,
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: ElevatedButton(
                                    onPressed: () async {},
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                          Colors.green.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${snapshot.data?['status']}",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }
}

class CustomTile extends StatelessWidget {
  final String title;
  final String tail;
  final TextStyle titlestyle;
  final TextStyle tailstyle;
  CustomTile(
      {required this.title,
      required this.tail,
      required this.titlestyle,
      required this.tailstyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Row(
        children: [
          Expanded(
            child: Align(
              child: Text(
                '$title',
                style: titlestyle,
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: Align(
              child: Text(
                '$tail',
                style: tailstyle,
              ),
              alignment: Alignment.centerRight,
            ),
          )
        ],
      ),
    );
  }
}
