import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/model/address.dart';
import 'package:flutter_project/model/card.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class BillingPage extends StatefulWidget{
  @override 
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage>{
  //Text Controllers for address text fields
  TextEditingController nameController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();

  //Text Controllers for credit card text fields
  TextEditingController cardNameController = new TextEditingController();
  TextEditingController cardNumController = new TextEditingController();
  TextEditingController cvvController = new TextEditingController();
  TextEditingController expDateController = new TextEditingController();

  //Keep track of card's validation
  bool cardNameValidated = false;
  bool cardNumValidated = false;
  bool cvvValidated = false;
  bool expDateValidated = false;
  @override  
  
  Widget build(BuildContext context){
    AlertDialog newAddressDialog = AlertDialog(
      backgroundColor: Colors.orangeAccent[100],
      title: Text("New Billing Address", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              autofocus: false,
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
                hintText: 'Name of address',
                fillColor: Colors.orange[50],
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 80,
              child: TextFormField(
                controller: addressController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                autofocus: false,
                minLines: 3,
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
                  hintText: 'Enter your address here',
                  fillColor: Colors.orange[50],
                  filled: true,
                ),
              ),
            ),
          ]
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
                  if(nameController.text.isEmpty || addressController.text.isEmpty){
                    Fluttertoast.showToast(msg: "Both fields cannot be empty", gravity: ToastGravity.TOP);
                  } else{                 
                    FirestoreService().addAddressData(FirebaseAuth.instance.currentUser.uid, nameController.text, addressController.text);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: "New billing address added", gravity: ToastGravity.TOP);
                    closeDrawer();
                    setState(() {});   
                  }                                                    
                },
                color: Colors.blue,
                child: Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ],
    );
    return Stack(
      children: [
        DrawerScreen(),
        AnimatedContainer(
          //Where you want the screen to move to
          transform: Matrix4.translationValues(DrawerConfig.xOffset, DrawerConfig.yOffset, 0)..scale(DrawerConfig.scaleFactor),
          duration: Duration(milliseconds: 250),
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                  elevation: 0,
                title: Text("BILLING INFO", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
                bottom: TabBar(
                  unselectedLabelColor: Colors.black54,
                  labelColor: Colors.white,
                  indicator: BoxDecoration(
                    color: Colors.brown,
                  ),
                  tabs: [
                    Tab(icon: Icon(Icons.credit_card_rounded) ,text: "My Cards"),
                    Tab(icon: Icon(Icons.add_box), text: "New Card"),
                    Tab(icon: Icon(Icons.location_on), text: "Billing Address"),
                  ],                
                ),
              ),
              body: TabBarView(
                children: [
                  FutureBuilder<List<Cards>>(
                    future: FirestoreService().readCardData(),
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
                                  Icons.credit_card_rounded,
                                  size: 130,
                                  color: Colors.brown[700],
                                ),
                                Text(
                                  "No Cards Saved",
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
                                    "add a new card to enable credit card purchases",
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
                                //Get the card number for each card
                                var cardNumber = snapshot.data[index].number;  
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: Icon(Icons.credit_card_rounded, color: Colors.white),
                                    //Display the last 4 digits of the card only
                                    title: Text(
                                      cardNumber.substring(cardNumber.length - 4),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white
                                      ),
                                    ),
                                    tileColor: Colors.brown,
                                    trailing: RaisedButton(
                                      onPressed: (){
                                        setState(() {
                                          Fluttertoast.showToast(msg: "Card number **** " + cardNumber.substring(cardNumber.length - 4) + " removed", gravity: ToastGravity.TOP);
                                          //Remove the card from the user's cards collection based on it's unique id
                                          FirestoreService().removeCardData(snapshot.data[index].uid);                   
                                        });
                                      },
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      child: Text("REMOVE", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              }
                            ),      
                          );         
                        }
                      }                 
                    }
                  ),     
                  Container(
                    padding: const EdgeInsets.all(10),
                      child: Column(
                      children: [
                        Column(
                          children: [
                            TextField( //Card holder text field
                              controller: cardNameController,                                                             
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))], 
                              style: TextStyle(
                                fontSize: 16,
                              ),                                    
                              decoration: InputDecoration(                                      
                                labelText: "Holder name",                                     
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: cardNameValidated ? Colors.green : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: cardNameValidated ? Colors.green : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(10),
                                fillColor: Colors.grey[200],
                                filled: true,                                    
                              ),
                              onChanged: (value) {
                                setState(() { //toggle card name validation status 
                                  cardNameController.text.isEmpty ? cardNameValidated = false : cardNameValidated = true;
                                });
                              },
                            ),   
                            SizedBox(height: 10), 
                            TextField( //Card number text field
                              controller: cardNumController,                                     
                              style: TextStyle(
                                fontSize: 16,
                              ),           
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), new CustomInputFormatter()],
                              decoration: InputDecoration(  
                                hintText: "XXXX XXXX XXXX XXXX",         
                                labelText: "Card number",                                         
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: cardNumValidated ? Colors.green : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: cardNumValidated ? Colors.green : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(10),
                                fillColor: Colors.grey[200],
                                filled: true,                                     
                              ),
                              onChanged: (value) {
                                setState(() { //toggle card number validation status 
                                  cardNumController.text.length != 19 ? cardNumValidated = false : cardNumValidated = true;
                                });
                              },
                            ),   
                            SizedBox(height: 10),  
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                    child: TextField( //CVV number text field
                                    controller: cvvController,                                     
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),           
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                                    decoration: InputDecoration(          
                                      labelText: "CVV",                                         
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cvvValidated ? Colors.green : Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cvvValidated ? Colors.green : Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(10),    
                                      fillColor: Colors.grey[200],
                                      filled: true,                                 
                                    ),
                                    onChanged: (value) {
                                      setState(() { //toggle cvv number validation status 
                                        cvvController.text.length != 3 ? cvvValidated = false : cvvValidated = true;
                                      });
                                    },
                                  ),   
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 100,
                                    child: TextField( //Expiry date text field
                                    controller: expDateController,                                     
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),           
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), new CustomDateInputFormatter()],
                                    decoration: InputDecoration(          
                                      labelText: "Expiry date",  
                                      hintText: "MM/YY",                                       
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: expDateValidated ? Colors.green : Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: expDateValidated ? Colors.green : Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(10), 
                                      fillColor: Colors.grey[200],
                                      filled: true,                                    
                                    ),
                                    onChanged: (value) {
                                      setState(() { //toggle expiry date validation status 
                                        expDateController.text.length != 5 ? expDateValidated = false : expDateValidated = true;
                                      });
                                    },
                                  ),   
                                ),
                              ],
                            ),            
                          ],
                        ),              
                        SizedBox(height: 20),                       
                        RaisedButton(
                          onPressed: (){
                            closeDrawer();
                            //Check if all fields are validated
                            if (!cardNameValidated || !cardNumValidated || !cvvValidated || !expDateValidated){
                              Fluttertoast.showToast(msg: "Incorrect card information fields. Check and try again.", gravity: ToastGravity.TOP);
                            } else{
                              FirestoreService().addCardData(cardNameController.text, cardNumController.text, cvvController.text, expDateController.text);                          
                              Fluttertoast.showToast(msg: "New card added", gravity: ToastGravity.TOP);
                              setState(() {}); //Refresh the state to see the new card added
                            }
                          },
                          textColor: Colors.white,
                          color: Colors.green,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Add New Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),           
                  ),
                  FutureBuilder<List<Address>>(
                    future: FirestoreService().readAddressData(),
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
                                  Icons.location_on,
                                  size: 130,
                                  color: Colors.brown[700],
                                ),
                                Text(
                                  "No Address Saved",
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
                                    "add a new billing address for us to deliver to",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.brown[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return newAddressDialog;
                                      },
                                    );
                                  },
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: Text('NEW ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          );
                        } else{                       
                          return Column(
                            children: [
                              RaisedButton(
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return newAddressDialog;
                                    },
                                  );
                                },
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Text('NEW ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Container(
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
                                          contentPadding: EdgeInsets.all(10.0),
                                          title: Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              snapshot.data[index].name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white
                                              ),
                                            ),
                                          ),
                                          subtitle: Text(
                                            snapshot.data[index].address,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white70
                                            ),
                                          ),
                                          tileColor: Colors.brown,
                                          trailing: RaisedButton(
                                            onPressed: (){
                                              setState(() {
                                                Fluttertoast.showToast(msg: snapshot.data[index].name + " address removed", gravity: ToastGravity.TOP);
                                                //Remove the address from the user's address collection based on it's unique id
                                                FirestoreService().removeAddressData(snapshot.data[index].uid);                   
                                              });
                                            },
                                            color: Colors.red,
                                            textColor: Colors.white,
                                            child: Text("REMOVE", style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      );
                                    }
                                  ),      
                                ),
                              ),
                            ],
                          );
                        }
                      }                 
                    }
                  ),     
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//create custom text input formatter to add a space after 4 numbers like credit card number
class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Replace this with anything you want to put after each 4 numbers
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length)
    );
  }
}

//create custom text input formatter to add a '/' after 2 numbers like credit card expiry date
class CustomDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/'); // Replace this with anything you want to put after each 4 numbers
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length)
    );
  }
}