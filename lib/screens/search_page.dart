import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/detail_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}

class Debouncer { //Debouncer to add a delay to search result
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _SearchPageState extends State<SearchPage>{
  final _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController searchController = new TextEditingController();
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
        title: TextField(
          controller: searchController,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          onChanged: (value) {  
            _debouncer.run(() { //Delay the search result when search bar changed
              setState(() {});
            });
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: (){
                searchController.clear();
                setState(() {});
              },
              icon: Icon(
                searchController.text.length > 0 ? Icons.close : null,
                color: Colors.brown[700],
              ),
              tooltip: "Clear",
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.orange[100],
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.orange[100],
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
            hintText: 'Search fruits by name',
            fillColor: Colors.orange[50],
            filled: true,
          ),
        ),             
      ),
      body: StreamBuilder<QuerySnapshot>( //Trying out StreamBuilder instead of FutureBuilder
        stream: FirestoreService().fruitCollection.snapshots().asBroadcastStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){ //If no data retrieved...
            return Center(child: CircularProgressIndicator());
          }
          else{ //If snapshot has data, try to fetch the data.
            if(snapshot.data.docs.where(
              (QueryDocumentSnapshot element) => element['name'] 
              .toString()
              .toLowerCase()
              .contains(searchController.text.toLowerCase().trim())).isEmpty){
              //If no fruit name matches the search result, display message for user.
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 130,
                      color: Colors.brown[700],
                    ),
                    Text(
                      "No Results Found",
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
                        "There are no fruits that matches the search criteria",
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
            }
            else{ //Display the fruits that have names that match with the search query
              return ListView( //Trying to experiment with other widgets other than GridView
                children: [
                  ...snapshot.data.docs.where(
                  (QueryDocumentSnapshot element) => element['name'] 
                    .toString()
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase().trim())).map((QueryDocumentSnapshot data){
                      final String uid = data.get('uid');
                      final String name = data.get('name'); 
                      final String image = data.get('image'); 
                      final String category = data.get('category');
                      final int favCount = data.get('favCount');
                      final String price = data.get('price');
                      
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                        child:  Card(
                          elevation: 5,
                          child: ListTile(                                            
                            leading: Image(
                              image: AssetImage('fruit_images/$image')
                            ),
                            title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              category + '\n${favCount.toString()} likes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            trailing: Text(
                              '\$' + price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),      
                            onTap: (){
                              closeDrawer();
                              Navigator.push(context, PageTransition(child: DetailPage(fruitUid: uid), type: PageTransitionType.fade));
                            },                                        
                          ),
                        ),
                      );
                    }
                  )                  
                ],
              );
            }
          }
        },
      ),  
    );
  }
}
