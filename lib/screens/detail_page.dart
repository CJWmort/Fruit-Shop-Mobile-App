import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/comment_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class DetailPage extends StatefulWidget{
  final String fruitUid;
  DetailPage({Key key, this.fruitUid}) : super(key: key);
  @override
  _DetailPageState createState() => _DetailPageState(fruitUid);
}

class _DetailPageState extends State<DetailPage>{
  String fruitUid;
  _DetailPageState(String fruitUid){
    this.fruitUid = fruitUid;
  }
  int quantity = 1; //Default quantity will be 1
  bool likesTheFruit;
  bool cartHasFruit; //if user has the selected fruit in cart, return true else false

  @override 
  void initState() {
    super.initState();
    if(FirebaseAuth.instance.currentUser != null){
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('favourites')
      .doc(fruitUid).get().then((value) {
        if(value.exists){
          //Check if the user have this fruit in their favourites collection
          //If user already favourited before, set isLiked value to true
          likesTheFruit = true;
        } else{
          //Else, default value for isLiked will be false
          likesTheFruit = false;
        }
      });    
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart')
      .doc(fruitUid).get().then((value) {
        if(value.exists){
          //Check if the user have this fruit in their cart collection
          cartHasFruit = true;
        } else{
          cartHasFruit = false;
        }
      });
    } else{
      likesTheFruit = false; //If user not logged in, like button will be grey
    }
  }
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final FirebaseAuth _fbAuth = FirebaseAuth.instance;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.brown[700]
        ),    
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: (){
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ProductPage()),
              (Route<dynamic> route) => false
            ); //Go back to product page and then do a refresh to see any changes such as like count.
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirestoreService().fruitCollection.doc(fruitUid).get(),
        builder: (context, snapshot){           
          Future<bool> onLikeButtonTapped(bool isLiked) async{ //Function to handle when the like button is tapped
            //Check if user is valid first 
            if(FirebaseAuth.instance.currentUser != null){
              //Increment the favCount of the fruit by 1 if user "Likes" the fruit
              //Decrement the favCount of the fruit by 1 if the user "Dislikes" the fruit 
              if(!isLiked){
                await FirebaseFirestore.instance.collection('fruits').doc(fruitUid).update({"favCount": FieldValue.increment(1)});
                FirestoreService().addFavData(fruitUid, _fbAuth.currentUser.uid, snapshot.data['name'], snapshot.data['image']);
                Fluttertoast.showToast(msg: "Added to favourites", gravity: ToastGravity.TOP);
              }
              else{
                await FirebaseFirestore.instance.collection('fruits').doc(fruitUid).update({"favCount": FieldValue.increment(-1)});
                FirestoreService().removeFavData(fruitUid); //Remove the fruit from favourites based on the uid of the fruit
                Fluttertoast.showToast(msg: "Removed from favourites", gravity: ToastGravity.TOP); 
              } 
              return !isLiked;
            }
            else{
              Fluttertoast.showToast(msg: "Login account to perform this action", gravity: ToastGravity.TOP);
              return null;
            }
          }
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else{
            var beforeDiscount;
            if(snapshot.data['category'] == 'deals'){
              beforeDiscount = ((double.parse(snapshot.data['price']) / (100 - snapshot.data['discount'])) * 100)
              .toStringAsFixed(2); //To display the price before discount
            } 
            double subtotal = double.parse(snapshot.data['price']) * quantity;
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                children: [   
                  SizedBox(height: 10),                              
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('fruit_images/${snapshot.data['image']}'),
                        fit: BoxFit.contain
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.orangeAccent[100]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                     
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  snapshot.data['category'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                color: snapshot.data['category'] != 'deals' ? Colors.orange[400]
                                : Colors.black45
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                snapshot.data['category'] != 'deals' ? '\$' + snapshot.data['price']
                                : '\$' + beforeDiscount,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: snapshot.data['category'] != 'deals' 
                                  ? TextDecoration.none : TextDecoration.lineThrough,
                                  decorationThickness: 1.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data['country'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'country',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if(beforeDiscount != null)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                color: Colors.orange[400]
                              ),
                              padding: const EdgeInsets.all(10),
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children:[
                                    TextSpan(text: snapshot.data['discount'].toString() + "% OFF  ", 
                                      style: TextStyle(
                                        color: Colors.brown,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    TextSpan(text: "\$" + snapshot.data['price'], 
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),    
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$' + subtotal.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[700],
                                fontSize: 22,
                              ),
                            ),
                            Row(              
                              children: [                         
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      quantity > 1 ? quantity--
                                      : Fluttertoast.showToast(msg: "Minimumn quantity reached", gravity: ToastGravity.TOP);  
                                    });               
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: quantity > 1 ? Colors.brown : Colors.grey
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      quantity < 99 ? quantity++
                                      : Fluttertoast.showToast(msg: "Maximum quantity reached", gravity: ToastGravity.TOP);  
                                    });  
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: quantity < 99 ? Colors.brown : Colors.grey
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: (){
                                    showDialog( //Allow user to pick quantity faster by using the wheel chooser widget
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text('Select Quantity', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        content: Container(
                                          height: 40,
                                          child: WheelChooser.integer(
                                            onValueChanged: (value){
                                              setState(() {
                                                quantity = value;
                                              });
                                            },
                                            listWidth: 30,
                                            maxValue: 99,
                                            minValue: 1,
                                            step: 1,
                                            initValue: quantity, //initial value will be based on quantity value
                                            horizontal: true,
                                            unSelectTextStyle: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        actions: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  child: Text('CLOSE'),
                                                  onPressed: (){
                                                    Navigator.of(context).pop();
                                                  },                                               
                                                )
                                              ],
                                            ),
                                          ),
                                        ],                                                                               
                                      ),
                                    );  
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(4, 20, 4, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.brown,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_upward_rounded, color: Colors.white),
                                        Icon(Icons.arrow_downward_rounded, color: Colors.white),
                                      ],
                                    ),
                                  ), 
                                ),
                              ],
                            ),  
                          ],
                        ),   
                        SizedBox(height: 40),                   
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white
                              ),
                              child: LikeButton(
                                size: 40,
                                //If user likes the fruit before, likesTheFruit will be true else it will be false
                                isLiked:  likesTheFruit,
                                likeCount: snapshot.data['favCount'],                              
                                countPostion: CountPostion.bottom,
                                onTap: onLikeButtonTapped,    
                                countBuilder: (likeCount, isLiked, text) {
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      color: isLiked ? Colors.black : Colors.grey,
                                      fontWeight: FontWeight.bold
                                    ),
                                  );
                                },                                      
                              ),
                            ),
                            SizedBox(
                              width: 250,
                              child: ElevatedButton( //Disable add to cart Button if user not logged in.
                                onPressed: _fbAuth.currentUser != null ? (){ 
                                  //Create new document if user don't have this fruit in cart 
                                  if(!cartHasFruit){ 
                                    FirestoreService().addCartData(fruitUid, _fbAuth.currentUser.uid, snapshot.data['name'], snapshot.data['image'], quantity, snapshot.data['price']);
                                    Fluttertoast.showToast(msg: "Added To Cart", backgroundColor: Colors.black45,timeInSecForIosWeb: 2, gravity: ToastGravity.TOP);
                                    cartHasFruit = true;
                                  } else{ //Increment the fruit if user already have it in their cart
                                    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(fruitUid).update({"quantity": FieldValue.increment(quantity)});
                                  }          
                                  setState(() {}); //Refresh the state to see the badge icon update
                                }
                                : (){ 
                                  Fluttertoast.showToast(msg: "Login account to perform this action", gravity: ToastGravity.TOP);
                                },                               
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(_fbAuth.currentUser != null ? Colors.green : Colors.grey),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    )
                                  )
                                ),
                                //color: _fbAuth.currentUser != null ? Colors.green : Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: Text(
                                    'Add To Cart',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],           
                    ),
                  ),
                ],
              ),
            );
          }
        }
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 30, 340),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 35,
          child: FloatingActionButton(
            heroTag: 'commentTag',
            splashColor: Colors.orangeAccent,
            child: Icon(Icons.insert_comment_rounded),
            onPressed: (){
              Navigator.push(context, PageTransition(child: CommentPage(fruitUid: fruitUid), type: PageTransitionType.fade));
            },
          ),
        ),
      ),
    );
  }
}
