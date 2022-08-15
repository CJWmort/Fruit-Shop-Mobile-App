import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/checkout_page.dart';
import 'package:flutter_project/screens/detail_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class CartPage extends StatefulWidget{
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>{
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
            appBar: AppBar(
              backgroundColor: Colors.orangeAccent[100],
              elevation: 0,
              title: Text("MY CART", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),              
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
                IconButton(
                  icon: Icon(
                    Icons.add_business, 
                    color: Colors.brown[700],
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.push(context, PageTransition(child: ProductPage(), type: PageTransitionType.fade));
                  },
                ),              
              ],
            ),
            body: FutureBuilder<List<Cart>>(
              future: FirestoreService().readCartData(),
              builder: (context, snapshot){             
                if(!snapshot.hasData){ //Display loading animation while fetching data       
                  return Center(
                    child: CircularProgressIndicator(),
                  );                                            
                } else{ 
                  if(snapshot.data.isEmpty){ //Display message if cart is empty
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 130,
                            color: Colors.brown[700],
                          ),
                          Text(
                            "No Items In Cart",
                            style: TextStyle(
                              color: Colors.brown[700],
                              fontSize: 28,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            color: Colors.brown,
                            child: TextButton.icon(                  
                              icon: Icon(Icons.add_business_rounded, color: Colors.white, size: 30), 
                              label: Text(
                                'Start Shopping', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18
                                )
                              ),
                              onPressed: (){
                                closeDrawer();
                                Navigator.push(context, PageTransition(child: ProductPage(), type: PageTransitionType.fade));
                              }, 
                            ),
                          ),                        
                        ],
                      ),
                    );
                  } else{  
                    double totalAmount = 0;         
                    for(int i=0; i<snapshot.data.length; i++){
                      totalAmount += snapshot.data[i].quantity * double.parse(snapshot.data[i].price);
                    } 
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, index){   
                                double subtotal = snapshot.data[index].quantity * double.parse(snapshot.data[index].price);
                                //Alert dialog to ask user for confirmation when removing fruit from cart
                                AlertDialog confirmRemove = new AlertDialog( 
                                  title: Text("Remove Fruit"),
                                  content: Text("remove ${snapshot.data[index].name} from the cart?"),
                                  actions: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          FlatButton( //Close the dialog box 
                                            onPressed: () => Navigator.pop(context), 
                                            child: Text("NO", style: TextStyle(fontSize: 16))
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(right: 10),
                                            child: RaisedButton(
                                              onPressed: (){                 
                                                setState((){     
                                                  Fluttertoast.showToast(msg: "Removed from cart", backgroundColor: Colors.black45,timeInSecForIosWeb: 2, gravity: ToastGravity.TOP);  
                                                  FirestoreService().removeCartData(snapshot.data[index].fruitid);
                                                  Navigator.pop(context);
                                                });
                                              },
                                              color: Colors.red,
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );                 
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),	
                                  ),
                                  color: Colors.orange[300],
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [                                        
                                          Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              image: DecorationImage(
                                                image: AssetImage('fruit_images/${snapshot.data[index].image}'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 3,
                                            left: 5,
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.push(context, PageTransition(child: DetailPage(fruitUid: snapshot.data[index].fruitid), type: PageTransitionType.fade));
                                              },
                                              child: Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 30),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        snapshot.data[index].name,
                                                        style: TextStyle(
                                                          color: Colors.brown[700],
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18
                                                        ),
                                                      ),
                                                      Text(
                                                        '\$' + snapshot.data[index].price + ' each',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){ //Ask user for confirmation before removing fruit
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return confirmRemove;
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      margin: const EdgeInsets.only(right: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Colors.red
                                                      ),
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                    )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(snapshot.data[index].quantity - 1 == 0){
                                                            //Show dialog when the user wants to reduce quantity to 0
                                                            showDialog( 
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return confirmRemove;
                                                              },
                                                            );
                                                          } else{ //Decrement the quantity of that fruit by 1 then refresh the state
                                                            setState(() {
                                                              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(snapshot.data[index].fruitid).update({"quantity": FieldValue.increment(-1)});
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: snapshot.data[index].quantity > 1 ? Colors.brown : Colors.grey
                                                          ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                            size: 25,
                                                          ),
                                                        )
                                                      ),
                                                      Container(
                                                        width: 50,
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          snapshot.data[index].quantity.toString(),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: (){
                                                          if(snapshot.data[index].quantity < 99){
                                                            //Increment the quantity of that fruit by 1 then refresh the state
                                                            setState(() {
                                                              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(snapshot.data[index].fruitid).update({"quantity": FieldValue.increment(1)});
                                                            });
                                                          }
                                                          else{
                                                            Fluttertoast.showToast(msg: "Maximum quantity reached", gravity: ToastGravity.TOP); 
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: snapshot.data[index].quantity < 99 ? Colors.brown : Colors.grey
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 25,
                                                          ),
                                                        )
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 5),
                                                    child: Text(
                                                      '\$' + subtotal.toStringAsFixed(2),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 20
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),  
                                    ],
                                  ),                          
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          height: MediaQuery.of(context).size.height*0.25,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.brown[600],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total amount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                  Text(
                                    '\$' + totalAmount.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                ],
                              ),          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "GST (7%)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                  Text(
                                    '+ \$' + (totalAmount * 0.07).toStringAsFixed(2) ,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                ],
                              ),           
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Summary (S\$)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                  Text(
                                    '\$' + (totalAmount + (totalAmount * 0.07)).toStringAsFixed(2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                ],
                              ),                     
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: RaisedButton(
                                  onPressed: (){
                                    closeDrawer();
                                    Navigator.push(context, PageTransition(child: CheckoutPage(totalAmount: totalAmount + (totalAmount * 0.07)), type: PageTransitionType.bottomToTop));
                                  },
                                  color: Colors.green,
                                  child: Text(
                                    "CHECKOUT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.grey[200]
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );      
                  }
                }
              }
            ),      
          ),
        ),   
      ]
    );
  }
}
