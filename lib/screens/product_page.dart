import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/model/fruit.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/detail_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:page_transition/page_transition.dart';

class ProductPage extends StatefulWidget{
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>{
  @override 
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
            appBar: AppBar(
              backgroundColor: Colors.orangeAccent[100],
              elevation: 0,
              title: Text("OUR FRUITS", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),              
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
            body: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 5),
                  color: Colors.orangeAccent[100],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.orangeAccent[100],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < Fruit.categoryList.length; i++)
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                          width: 80,
                          height: 70,
                          child: RaisedButton(
                            onPressed: (){
                              //Change the category selection
                              Fruit.currentCategory = Fruit.categoryList[i];
                              setState(() {}); //Refresh the state to see selected category
                            },
                            elevation: Fruit.categoryList[i] == Fruit.currentCategory ? 8 : 0,
                            color: Fruit.categoryList[i] == Fruit.currentCategory ? Colors.orange[400] : Colors.brown,  
                            textColor: Fruit.categoryList[i] == Fruit.currentCategory ? Colors.black : Colors.white,
                            shape: CircleBorder(side: BorderSide.none),
                            child: Text(
                              Fruit.categoryList[i],
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    reverse: false,
                    padding: EdgeInsets.only(bottom: bottom),
                    child: FutureBuilder<List<Fruit>>(
                      future: FirestoreService().readFruitData(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){                   
                          return Container(
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                            child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                //control width / height of grid item
                                childAspectRatio: MediaQuery.of(context).size.width / 650, 
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, index){
                                var beforeDiscount;
                                if(snapshot.data[index].category == 'deals'){
                                  beforeDiscount = ((double.parse(snapshot.data[index].price) / (100 - snapshot.data[index].discount)) * 100).toStringAsFixed(2); //To display the price before discount
                                }
                                return GestureDetector(
                                  onTap: (){
                                    closeDrawer();
                                    Navigator.push(context, PageTransition(child: DetailPage(fruitUid: snapshot.data[index].uid), type: PageTransitionType.fade));
                                  },
                                  child: Stack(
                                    children: [    
                                      Container(                                       
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: AssetImage('fruit_images/${snapshot.data[index].image}'),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(                                          
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Colors.red[300],
                                              ),
                                              Text(
                                                snapshot.data[index].favCount.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                            color: snapshot.data[index].category != 'deals' ? Colors.orange[400]
                                            : Colors.black.withOpacity(0.6)
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            snapshot.data[index].category != 'deals' ? '\$' + snapshot.data[index].price
                                            : '\$' + beforeDiscount,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              decoration: snapshot.data[index].category != 'deals' 
                                              ? TextDecoration.none : TextDecoration.lineThrough,
                                              decorationThickness: 1.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if(snapshot.data[index].category == 'deals')
                                      Container(
                                        margin: const EdgeInsets.only(top: 45),
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              topLeft: Radius.circular(20),
                                            ),
                                            color: Colors.orange[400]
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: RichText(
                                            text: TextSpan(
                                              style: DefaultTextStyle.of(context).style,
                                              children:[
                                                TextSpan(text: snapshot.data[index].discount.toString() + "% OFF ", 
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(text: "\$" + snapshot.data[index].price, 
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),   
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: 60,
                                          width: 200,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            color: Colors.orange[400],
                                          ),
                                          child: Text(
                                            snapshot.data[index].name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),                                                                                           
                                    ],  
                                  )
                                );
                              },
                            )                         
                          );
                        } else{
                          return Center( //Display loading animation if cannot get data for any reason
                            child: CircularProgressIndicator(),
                          );
                        }
                      }
                    ),
                  ),
                )               
              ],
            ),
          ),
        ),   
      ]
    );
  }
}
