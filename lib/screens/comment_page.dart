import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/comment.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class CommentPage extends StatefulWidget{
  final String fruitUid;
  CommentPage({Key key, this.fruitUid}) : super(key: key);
  @override
  _CommentPageState createState() => _CommentPageState(fruitUid);
}

const DurationTextStyle = TextStyle( //Duration text styling
  color: Colors.black54, 
  fontSize: 14,fontWeight: 
  FontWeight.bold
);

class _CommentPageState extends State<CommentPage>{
  String fruitUid;
  String firstHalf;
  String secondHalf;
  //bool flag = true;
  _CommentPageState(String fruitUid){
    this.fruitUid = fruitUid;
  }
  @override 
  Widget build(BuildContext context){
    final FirebaseAuth _fbAuth = FirebaseAuth.instance;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.orangeAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent[100],
        elevation: 0,
        title: Text("COMMENTS", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),   
        iconTheme: IconThemeData(
          color: Colors.brown[700]
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
      body: FutureBuilder<List<Comments>>(
        future: FirestoreService().readCommentData(fruitUid),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else{          
            if(snapshot.data.isEmpty){
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.insert_comment_outlined,
                      size: 130,
                      color: Colors.brown[700],
                    ),
                    Text(
                      "No Comments Available",
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
                        "there are no comments made for this fruit yet",
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
            else{
              return Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: SingleChildScrollView(
                  reverse: false,
                  padding: EdgeInsets.only(bottom: bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text("Latest Comment", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, index){ 
                          DateTime sgTime = DateTime.now().add(new Duration(hours: 8)); //SG current DateTime
                          DateTime commentDateTime = snapshot.data[index].createdAt.toDate(); // comment TimeStamp to DateTime
                          //Get duration when user posted the comment and display the duration
                          var diffInSec = sgTime.difference(commentDateTime).inSeconds; 
                          var diffInMin = sgTime.difference(commentDateTime).inMinutes;
                          var diffInHour = sgTime.difference(commentDateTime).inHours;
                          var diffInDay = sgTime.difference(commentDateTime).inDays;
                     
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    snapshot.data[index].profilepic != null
                                    ? CircleAvatar(
                                      radius: 24.0,
                                      backgroundColor: Colors.blue.shade100,
                                      backgroundImage: NetworkImage(snapshot.data[index].profilepic),
                                    )
                                    : CircleAvatar(
                                      radius: 24.0,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Image(                                 
                                        image: AssetImage('images/guest.png'),
                                        height: 26,
                                      )
                                    ), 
                                    SizedBox(width: 10),
                                    Text(
                                      snapshot.data[index].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown[700],
                                        fontSize: 20
                                      ),
                                    ),       
                                    SizedBox(width: 5),
                                    Text("•", style: TextStyle(color: Colors.black, fontSize: 20)),
                                    SizedBox(width: 5),
                                    if(diffInSec <= 60) //Displays seconds ago if below/equal 1 minute (60 secs)
                                    Text(diffInSec.toString() + " secs ago", style: DurationTextStyle)  
                                    else if(diffInSec <= 3600) //Displays minutes ago if below/equal 1 hour (3600 secs)
                                    Text(diffInMin.toString() + " mins ago", style: DurationTextStyle)
                                    else if(diffInMin <= 1440) //Displays hours ago if below/equal 1 day (1440 mins)
                                    Text(diffInHour.toString() + " hrs ago", style: DurationTextStyle)
                                    else if(diffInDay <= 30) //Displays days ago if below/equal 30 days (1 month)
                                    Text(diffInDay.toString() + " days ago", style: DurationTextStyle)
                                    else if(diffInDay <= 360) //Displays months ago if below/equal 365 days (1 year)
                                    Text((diffInDay/30).floor().toString() + " mths ago", style: DurationTextStyle)
                                    else //Displays years ago (highest value) .floor() to ignore the "remainder"
                                    Text((diffInDay/360).floor().toString() + " yrs ago", style: DurationTextStyle),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 60),
                                  child: Text(
                                    snapshot.data[index].comment,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),                         
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                )
              );
            }
          }
        }
      ),
      floatingActionButton: Visibility(
        visible: _fbAuth.currentUser != null ? true : false, //Hide add comment button if user not logged in
        child: FloatingActionButton(
          heroTag: 'commentTag',
          splashColor: Colors.orangeAccent,
          child: Icon(Icons.insert_comment_rounded),
          onPressed: (){
            showDialog(
              context: context,
              builder: (_) {
                var messageController = TextEditingController();
                return AlertDialog(
                  backgroundColor: Colors.orangeAccent[100],
                  title: Text('Leave a Comment', style: TextStyle(color: Colors.brown[700])),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _fbAuth.currentUser.photoURL != null
                              ? CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: NetworkImage(_fbAuth.currentUser.photoURL),
                              )
                              : CircleAvatar( //If user have not set custom profile pic, display default profile pic.
                                radius: 24,
                                backgroundColor: Colors.blue.shade100,
                                child: Image(
                                  image: AssetImage('images/guest.png'),
                                  height: 26,
                                ),
                              ),   
                              SizedBox(width: 10),
                              Text(
                                _fbAuth.currentUser.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.brown[700]
                                ),
                              ),        
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 80,
                          child: TextFormField(
                            controller: messageController,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            autofocus: false,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 2
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 2
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(10),
                              hintText: 'Write your comments here',
                              fillColor: Colors.orange[50],
                              filled: true,
                            ),
                          ),
                        ),                 
                      ],
                    ),
                  ),
                  actions: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          RaisedButton(
                            onPressed: (){
                              if(messageController.text.isEmpty){
                                Fluttertoast.showToast(msg: "Comments cannot be empty", gravity: ToastGravity.TOP);
                              } else{
                                DateTime sgTime = DateTime.now().add(new Duration(hours: 8));
                                Timestamp sgTimeStamp = Timestamp.fromDate(sgTime); //SG DateTime To TimeStamp
                                FirestoreService().addCommentData(fruitUid, _fbAuth.currentUser.uid, _fbAuth.currentUser.displayName, _fbAuth.currentUser.photoURL, messageController.text, sgTimeStamp);
                                Navigator.pop(context);
                                Fluttertoast.showToast(msg: "You have posted a comment", gravity: ToastGravity.TOP);
                                setState(() {});   
                              }                                                    
                            },
                            color: Colors.blue,
                            child: Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
