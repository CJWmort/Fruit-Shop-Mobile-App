import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/model/favourite.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/detail_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:page_transition/page_transition.dart';

class FavouritePage extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent[100],
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.brown[700]
        ), 
        title: Text("FAVOURITES", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),              
        actions: [
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
      body: FutureBuilder<List<Favourite>>(
        future: FirestoreService().readFavData(),
        builder: (context, snapshot){
          if(!snapshot.hasData){       
            return Center(
              child: CircularProgressIndicator(),
            );                                            
          } else{
            if(snapshot.data.isEmpty){ //Display message if nothing is favourited
              return Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "No Favourite Fruits",
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
                        icon: Icon(Icons.add_business_rounded, color: Colors.white, size: 40), 
                        label: Text(
                          'START SHOPPING', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20
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
              return Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, index){
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Image(
                          image: AssetImage('fruit_images/${snapshot.data[index].image}'),
                        ),
                        title: Text(
                          snapshot.data[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                        trailing: RaisedButton(
                          onPressed: (){
                            closeDrawer();
                            Navigator.push(context, PageTransition(child: DetailPage(fruitUid: snapshot.data[index].fruitid), type: PageTransitionType.fade));
                          },
                          color: Colors.red[400],
                          child: Text(
                            "View",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );      
            }
          }
        }
      ),             
    );
  }
}
