import 'package:local_bazaar_delivery/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogIN extends StatefulWidget {
  const LogIN({Key? key}) : super(key: key);

  @override
  _LogINState createState() => _LogINState();
}

class _LogINState extends State<LogIN> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mail = new TextEditingController();
  TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize
            children: [
              Text("Welcome",
                  style: GoogleFonts.poppins(
                      color: Color(0xff4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 32)),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: 300,
                  child: Image.asset(
                    "assets/login.png",
                    fit: BoxFit.contain,
                  )),
              Padding(
                padding: EdgeInsets.all(8.0)
                    .copyWith(top: 30, bottom: 12, left: 24, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xff4CAF50)),
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: mail,
                    showCursor: true,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: Color(0xff4CAF50),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xff4CAF50),
                      ),
                      hintText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0)
                    .copyWith(bottom: 30, left: 24, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xff4CAF50)),
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: password,
                    showCursor: true,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color(0xff4CAF50),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xff4CAF50),
                      ),
                      hintText: "Password",
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              MaterialButton(
                  elevation: 0,
                  minWidth: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  color: Color(0xff4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text("Login",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  onPressed: () {
                    if (mail.text.length > 8 && password.text.length > 6) {
                      _login();
                    } else {
                      // _scaffoldKey.currentState.showSnackBar(SnackBar(
                      //     content: Text('Please provide a valid information')));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.black,
                        content: Text(
                          'Please provide a valid information',
                          style: TextStyle(
                              color: Colors.redAccent, letterSpacing: 0.5),
                        ),
                      ));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future _login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
        barrierDismissible: false);
    try {
      var user = await auth.signInWithEmailAndPassword(
          email: mail.text.trim(), password: password.text.trim());
      if (user.user != null) {
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Home()));
      }
    } catch (e) {
      Navigator.pop(context);
      // _scaffoldKey.currentState
      //     .showSnackBar(SnackBar(content: Text(e.toString())));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          e.toString(),
          style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
        ),
      ));
    }
  }
}
