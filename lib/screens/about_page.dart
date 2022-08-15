import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget{
  @override 
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>{
  void _contact() async {
    final url = 'mailto:yayapapaya@gmail.com.sg';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final FirebaseAuth _fbAuth = FirebaseAuth.instance;
    return Stack(
      children: [
        DrawerScreen(),
        AnimatedContainer(
          //Where you want the screen to move to
          transform: Matrix4.translationValues(DrawerConfig.xOffset, DrawerConfig.yOffset, 0)..scale(DrawerConfig.scaleFactor),
          duration: Duration(milliseconds: 250),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text("ABOUT US", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
              leading: DrawerConfig.isDrawerOpen ?
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.brown[700], size: 30),
                onPressed: (){
                  setState(() { closeDrawer(); });
                },
              ):
              IconButton(
                icon: Icon(Icons.menu, color: Colors.brown[700]),
                onPressed: (){
                  setState(() { openDrawer(); });
                },
              ),
              actions: [
                if(_fbAuth.currentUser != null) //Only allow logged in users to access the favourites
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.brown[700],
                    size: 25,
                  ),
                  onPressed: () {
                    closeDrawer();
                    Navigator.push(context, PageTransition(child: FavouritePage(), type: PageTransitionType.fade));
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.search_rounded, 
                    color: Colors.brown[700],
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.push(context, PageTransition(child: SearchPage(), type: PageTransitionType.fade));
                  },
                ),
                if(_fbAuth.currentUser != null) //Only allow logged in users to access the cart
                Badge(
                  position: BadgePosition.topStart(),
                  padding: EdgeInsets.all(8),
                  ignorePointer: true,
                  badgeContent: FutureBuilder<List<Cart>>(
                    future: FirestoreService().readCartData(),
                    builder: (context, snapshot){      
                      Cart.cartSize = 0;
                      if(!snapshot.hasData){
                        return Center(child: CircularProgressIndicator());
                      } else{
                        snapshot.data.forEach((element) {
                          Cart.cartSize += element.quantity;
                        });
                        return Text(
                          Cart.cartSize.toString(), 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ); 
                      }
                    } 
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.brown[700],
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.push(context, PageTransition(child: CartPage(), type: PageTransitionType.fade));
                    },
                  ),   
                ),            
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          width: 200,
                          child: Text("Fruit Delivery Singapore - At Yayapapaya, we don't just yaya, we give you more than papaya!", 
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic
                            ),
                          )
                        ),          
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 18, 0, 5),
                        child: Image(
                          height: 150,
                          image: AssetImage('images/fruittruck.png'),
                        ),
                      ),
                    ]
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Text("That's right, we're on a mission to bring Singapore the most exciting and exquisite produce from all around the World.",
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    child: Text("How do we do this? Simple, we're based in Pasir Panjang Wholesale Center, a major produce hub with access to many local and overseas suppliers. With our extensive connections to many wholesalers, importers and overseas growers we can bring in a wide variety of both standard and exotic fruits.",
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 0, 10),
                        child: Image(
                          height: 150,
                          image: AssetImage('images/yayapapaya.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 18, 10),
                        child: Container(
                          width: 200,
                          height: 150,
                          child: Text("Through the YayaPapaya App, we can bring fruits to your doorstep more cost efficiently than before. All it takes is a few taps and your fruits will be on its way!", 
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.3,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          )
                        ),          
                      ),
                    ]
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 0 ,0),
                      child: Text('Our Location:',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ),  
                  ),    
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 60, 0),
                        child: Text('26 Pasir Panjang\nWholesale Centre #01-208\nSingapore 110026',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Image(
                        image: AssetImage('images/location.png'),
                        height: 100,
                      ),           
                    ]
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 0 ,0),
                      child: Text('Our Office Hours:',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ),  
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 20, 0),
                        child: Text('Monday to Friday - 8 am to 5 pm\nSaturday - 8 am to 1 pm\nWe are closed on Sundays\n& Public Holidays',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Image(
                        image: AssetImage('images/clock.png'),
                        height: 100,
                      ),
                    ]
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 0 ,0),
                      child: Text('Contact Information:',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ),  
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 65, 10),
                        child: Text('Call us at: 6774 3387\nEmail us at:\nyayapapaya@gmail.com.sg',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Image(
                        image: AssetImage('images/contact.png'),
                        height: 80,
                      ),
                    ]
                  ),
                  ButtonTheme(
                    minWidth: 300,
                    child: RaisedButton(
                      color: Colors.brown,
                      textColor: Colors.white,
                      onPressed: ()=> launch("tel://67743387"),
                      child: Text('Tap Here To Call Us'),
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 300,
                    child: RaisedButton(
                      color: Colors.brown,
                      textColor: Colors.white,
                      onPressed: (){ _contact(); },
                      child: Text('Tap Here To Send FeedBack'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: ButtonTheme(
                      minWidth: 200,
                      height: 50,
                      child: RaisedButton(
                        color: Colors.brown,
                        textColor: Colors.white,
                        onPressed: (){
                          closeDrawer();
                          Navigator.push(context, PageTransition(child: ProductPage(), type: PageTransitionType.fade));
                        },                       
                        child: Text('START SHOPPING!',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    child: Text(
                      'App Developed By Chin Jun Wen, NYP(DIME) 2022 \u00a9 All Rights Reserved',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
    );
  }
}