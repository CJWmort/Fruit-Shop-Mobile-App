import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/profile_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final heroController = HeroController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){ //Allow user to close keyboard when tap outside of the keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
        //Prevent application from randomly opening keyboard when there is textfield
        FocusManager.instance.primaryFocus.unfocus(); 
      },
      child: MaterialApp(
        navigatorObservers: [heroController],
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.orangeAccent[100],
        ),
        debugShowCheckedModeBanner: false,
        title: 'YayaPapaya App',
        home: Scaffold(
          //User will begin at Product Page if logged in / Login Page if logged out
          body: _fbAuth.currentUser != null ? ProductPage() : LoginPage(),
        ),
      ),
    );
  }
}