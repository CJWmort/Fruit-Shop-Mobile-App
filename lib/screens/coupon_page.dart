import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/model/coupon.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:page_transition/page_transition.dart';

class CouponPage extends StatefulWidget{
  @override 
  _CouponPageState createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage>{
  @override  
  Widget build(BuildContext context){
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
              title: Text("MY COUPONS", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
            body: FutureBuilder<List<Coupon>>(
              future: FirestoreService().readUserCouponData(),
              builder: (context, snapshot){             
                if(!snapshot.hasData){ //Display loading animation while fetching data       
                  return Center(
                    child: CircularProgressIndicator(),
                  );                                            
                } else{
                  if(snapshot.data.isEmpty){
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 130,
                            color: Colors.brown[700],
                          ),
                          Text(
                            "No Coupons Available",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 270,
                            child: Text(
                              "spend up to \$50 on a single order to earn a coupon",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.brown[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else{                       
                    return Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, index){ 
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 35),
                              title: Text(
                                snapshot.data[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white
                                ),
                              ),
                              subtitle: Text(
                                snapshot.data[index].desc,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white
                                ),
                              ),
                              tileColor: Colors.brown,                             
                            ),
                          );
                        }
                      ),      
                    );         
                  }
                }                 
              }
            ),     
            floatingActionButton: FloatingActionButton(
              splashColor: Colors.orangeAccent,
              child: Icon(Icons.info_outline),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("How To Earn Coupons?"),
                      content: Text("- Spend up to \$50 on a single order to earn a coupon.\n- Maximum of one coupon earned per order."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), 
                          child: Text("OK")
                        )
                      ],
                    );
                  },
                );
              },
            ), 
          ),
        ),   
      ],
    );
  }
}