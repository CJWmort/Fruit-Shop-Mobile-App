import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/about_page.dart';
import 'package:flutter_project/screens/billing_page.dart';
import 'package:flutter_project/screens/coupon_page.dart';
import 'package:flutter_project/screens/location_page.dart';
import 'package:flutter_project/screens/login_page.dart';
import 'package:flutter_project/screens/order_page.dart';
import 'package:flutter_project/screens/profile_page.dart';
import 'package:flutter_project/screens/register_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/services/firebaseauth_service.dart';
import 'package:page_transition/page_transition.dart';

const ListTileTextStyle = TextStyle( //ListTile styling
  fontWeight: FontWeight.bold,
  fontSize: 18,
  color: Colors.white,
);

class DrawerScreen extends StatelessWidget {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.brown[400],
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 40, 0, 30),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            children: [
              Row(
                children: [
                  _fbAuth.currentUser != null
                  ? CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: _fbAuth.currentUser.photoURL != null 
                    ? CircleAvatar( //If user has set custom profile pic, display it.
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: NetworkImage(_fbAuth.currentUser.photoURL),
                    )
                    : CircleAvatar( //If user have not set custom profile pic, display default profile pic.
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      child: Image(
                        image: AssetImage('images/guest.png'),
                        height: 33,
                      ),
                    )
                  )
                  : CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      child: Image(
                        image: AssetImage('images/guest.png'),
                        height: 33,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fbAuth.currentUser != null ? _fbAuth.currentUser.displayName : 'Guest',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),), 
                      if(_fbAuth.currentUser != null) //Display email if there is user logged in
                      Text(_fbAuth.currentUser.email, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)), 
                    ],
                  ),
                ],
              ),  
              _fbAuth.currentUser != null ? SizedBox(height: 50) : SizedBox(height: 120),
              Column(
                children: [
                  if(_fbAuth.currentUser != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.local_shipping_outlined, color: Colors.white), label: Text('My Orders', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: OrderPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),
                  if(_fbAuth.currentUser != null)  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.card_giftcard_rounded, color: Colors.white), label: Text('Coupons', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: CouponPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),      
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.add_business_outlined, color: Colors.white), label: Text('Our Fruits', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: ProductPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),    
                  if(_fbAuth.currentUser != null)  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.credit_card_rounded, color: Colors.white), label: Text('Billing Info', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: BillingPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),             
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.map_outlined, color: Colors.white), label: Text('Location', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: LocationPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.question_answer_outlined, color: Colors.white), label: Text('About Us', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: AboutPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ), 
                  if(_fbAuth.currentUser != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.account_circle_outlined, color: Colors.white), label: Text('Profile', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.person_add_alt, color: Colors.white), label: Text('Register', style: ListTileTextStyle),
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: RegisterPage(), type: PageTransitionType.fade));
                      }, 
                    ),
                  ),
                ],
              ),
              _fbAuth.currentUser != null ? SizedBox(height: 50) : SizedBox(height: 120),
              _fbAuth.currentUser != null
              ? Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: Icon(Icons.logout, color: Colors.white), label: Text('Logout', style: ListTileTextStyle),
                  onPressed: () async{
                    await FirebaseAuthService().signOut();
                    closeDrawer();
                    //Remove all previous routes to prevent going back to unauthorized pages
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false
                    );
                  }, 
                ),
              )          
              : Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: Icon(Icons.login, color: Colors.white), label: Text('Login', style: ListTileTextStyle),
                  onPressed: (){
                    closeDrawer();
                    Navigator.push(context, PageTransition(child: LoginPage(), type: PageTransitionType.fade));
                  }, 
                ),
              ),       
            ],
          ),
        ),
      ),
    );
  }
}