import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/model/address.dart';
import 'package:flutter_project/model/card.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/model/coupon.dart';
import 'package:flutter_project/screens/billing_page.dart';
import 'package:flutter_project/screens/order_page.dart';
import 'package:flutter_project/screens/profile_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class CheckoutPage extends StatefulWidget{
  final double totalAmount;
  CheckoutPage({Key key, this.totalAmount}) : super(key: key);
  @override
  _CheckoutPageState createState() => _CheckoutPageState(totalAmount);
}

class _CheckoutPageState extends State<CheckoutPage>{
  DateFormat dateFormat = DateFormat("dd-MM-yyyy"); //Format the date into dd-MM-yyyy format
  DateFormat timeFormat = DateFormat("HH:mm"); //Format the time into HH:mm format
  var currentDate = new DateTime.now(); //Current Date
  DateTime selectedDate; //store user selected datetime value
  String selectedTime; //store user selected time for order to arrive
  TimeOfDay initialTime; //store initialTime if not null
  int differenceInDays; //store the difference in days between Now and Selected date
  String paymentMethod = 'cash'; //store the payment method the user is using, default payment method is cash
  String selectedCard; //the last 4 digits of user selected card
  int couponDiscount; //the discount amount from the coupon
  String couponUid; //store the uid of the coupon so we can remove it afterwards
  String address; //store the address selected
  String addressName; //store the address name selected
  
  bool addressValidated = false; //Keep track of validation status of all required fields
  bool dateValidated = false;
  bool timeValidated = false; 

  TextEditingController phoneController = new TextEditingController();
  TextEditingController promoController = new TextEditingController();

  double totalAmount; //The final total amount after GST
  double oldTotalAmount; //store the default total amount before any coupon changes
  _CheckoutPageState(double totalAmount){
    this.totalAmount = totalAmount;
    this.oldTotalAmount = totalAmount; //store the default total amount before any coupon changes
  }

  Future<void> _showTimePicker() async { //Show the time picker
    //set initialTime to Singapore time (8 Hours ahead)
    DateTime sgTime = DateTime.now().add(new Duration(hours: 8));
    TimeOfDay sgTimeOfDay = TimeOfDay.fromDateTime(sgTime); //Convert DateTime to TimeOfDay
    //Display previously selected time if any, else just display current time
    final TimeOfDay result = await showTimePicker(context: context, initialTime: initialTime != null ? initialTime : sgTimeOfDay); 
    setState(() {
      if (result != null) {
        timeValidated = true;
        selectedTime = result.format(context);
        initialTime = result;
      } 
    });
  }
  @override 
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    AlertDialog selectCardDialog = AlertDialog( //Alert Dialog for selecting credit card to use
      title: Text("Select a card"),
      content: Container(
        height: 350.0, 
        width: 300.0, 
        child: FutureBuilder<List<Cards>>(
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
                        color: Colors.black54,
                      ),
                      Text(
                        "No Cards Saved",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 270,
                        child: Text(
                          "add a new card to enable credit card purchases",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 160,
                        child: RaisedButton(
                          onPressed: () => Navigator.push(context, PageTransition(child: BillingPage(), type: PageTransitionType.fade)),
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_box),
                              SizedBox(width: 10),
                              Text("ADD CARD"),
                            ],
                          ),
                        )
                      ),
                    ],
                  ),
                );
              } else{    
                return Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                                selectedCard = cardNumber.substring(cardNumber.length - 4);
                                Navigator.pop(context);
                                paymentMethod = 'card';
                              });
                            },
                            color: Colors.green,
                            textColor: Colors.white,
                            child: Text("SELECT", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                onPressed: () => Navigator.pop(context), 
                child: Text("Cancel"),
              ),
              RaisedButton(
                onPressed: (){
                  Navigator.push(context, PageTransition(child: BillingPage(), type: PageTransitionType.fade));
                },
                color: Colors.blue,
                textColor: Colors.white,
                child: Text("ADD NEW CARD", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent[100],
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.brown[700]
        ),
        centerTitle: true,
        title: Text("CHECKOUT", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),    
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
              child: SingleChildScrollView(
                reverse: false,
                padding: EdgeInsets.only(bottom: bottom),
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Deliver to",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("My Billing Address"),
                                          content: Container(
                                            height: 350.0, 
                                            width: 300.0, 
                                            child: FutureBuilder<List<Address>>(
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
                                                        ],
                                                      ),
                                                    );
                                                  } else{                       
                                                    return Container(
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
                                                              contentPadding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                                                              title: Text(
                                                                snapshot.data[index].name,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                  color: Colors.white
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                snapshot.data[index].address,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                  color: Colors.white60
                                                                ),
                                                              ),
                                                              trailing: RaisedButton(
                                                                onPressed: (){
                                                                  address = snapshot.data[index].address;
                                                                  addressName = snapshot.data[index].name;
                                                                  addressValidated = true;
                                                                  setState(() {});
                                                                  Navigator.pop(context);
                                                                },
                                                                color: Colors.green,
                                                                textColor: Colors.white,
                                                                child: Text("SELECT", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          ),
                                          actions: [     
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  FlatButton(
                                                    onPressed: () => Navigator.pop(context), 
                                                    child: Text("Cancel"),
                                                  ),
                                                  RaisedButton(
                                                    onPressed: (){
                                                      Navigator.push(context, PageTransition(child: BillingPage(), type: PageTransitionType.fade));
                                                    },
                                                    color: Colors.blue,
                                                    textColor: Colors.white,
                                                    child: Text("ADD NEW ADDRESS", style: TextStyle(fontWeight: FontWeight.bold)),
                                                  )
                                                ],
                                              ),
                                            ),                                     
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    address != null ? "Change" : "Select",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                ),                             
                              ],
                            ),
                            SizedBox(height: 10),
                            address != null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                  tileColor: Colors.orange[50],
                                  title: Container(
                                    margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                                    child: Text(addressName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                  subtitle: Text(address, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic),
                                ),
                              )
                            )
                            : Text(
                              "no address selected",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontStyle: FontStyle.italic
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,                     
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Contact no.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    closeDrawer();
                                    Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.fade));
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                ),                               
                              ],
                            ),
                            SizedBox(height: 10),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirestoreService().userCollection.doc(FirebaseAuth.instance.currentUser.uid).get(),
                              builder: (context, snapshot){
                                if(!snapshot.hasData){
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                else{
                                  phoneController.text = snapshot.data['phone'];
                                  return TextField( //Current user phone number field
                                    enabled: false,
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.orange[300],
                                          width: 2
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(10),
                                      fillColor: Colors.orange[50],
                                      filled: true,                                                                
                                    ),                       
                                  );
                                }
                              }
                            ),                                                  
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,                     
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pick order arrival date & time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                ),       
                                if(differenceInDays != null && differenceInDays <= 2)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),                                 
                                    Text(
                                      "orders arriving in 3 days or less cannot be cancelled",
                                      style: TextStyle(
                                        color: Colors.blue
                                      ),
                                    ),  
                                  ],
                                ),                                                
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: RaisedButton(
                                    color: Colors.blue,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.date_range_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Select Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: (){                                   
                                      var maxDate = new DateTime(currentDate.year + 5, currentDate.month, currentDate.day);
                                      showDatePicker(
                                        context: context,
                                        //initial date is now date not selected, else initial date will be what the user set before
                                        initialDate: selectedDate == null ? DateTime.now() : selectedDate, 
                                        firstDate: DateTime.now(), //dont allow user to set date as past date
                                        lastDate: maxDate, //dont allow user to set date over 5 years from now
                                      ).then((date){
                                        setState(() {
                                          if(date != null){ //Check if user picked a date
                                            selectedDate = date; 
                                            dateValidated = true;
                                            //Calculate the duration between now and order arrival date
                                            Duration duration = selectedDate.difference(DateTime.now());
                                            differenceInDays = (duration.inDays).floor().toInt();
                                          } else{
                                            dateValidated = false;
                                            return null;
                                          }
                                        });
                                      });
                                    },
                                  ),            
                                ),              
                                selectedDate == null 
                                ? Text('date not selected', style: TextStyle(fontSize: 16, color: Colors.red, fontStyle: FontStyle.italic))  
                                : Text(dateFormat.format(selectedDate), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),      
                            if(selectedDate != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                                
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),       
                                    //Display different messages based on the date the user selected
                                    if(DateFormat('EEE').format(selectedDate) == 'Mon' || DateFormat('EEE').format(selectedDate) == 'Tue' || DateFormat('EEE').format(selectedDate) == 'Wed' || DateFormat('EEE').format(selectedDate) == 'Thu' || DateFormat('EEE').format(selectedDate) == 'Fri')
                                    Text(
                                      " Weekday Selected (Operating hours: 8am - 5pm)\n orders past 5pm will arrive next working day",
                                      style: TextStyle(
                                        color: Colors.blue
                                      ),
                                    ),    
                                    if(DateFormat('EEE').format(selectedDate) == 'Sat') 
                                    Text(
                                      " Saturday Selected (Operating hours: 8am - 1pm)\n orders past 1pm will arrive next working day",
                                      style: TextStyle(
                                        color: Colors.blue
                                      ),
                                    ),  
                                    if(DateFormat('EEE').format(selectedDate) == 'Sun') 
                                    Text(
                                      " Sunday Selected (Operating hours: closed)\n orders will arrive next working day",
                                      style: TextStyle(
                                        color: Colors.blue
                                      ),
                                    ),  
                                  ],
                                ),                                 
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: RaisedButton(
                                    color: Colors.blue,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Select Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: (){      
                                      //Show time picker to allow user to select oder arrival time                             
                                      _showTimePicker();
                                    },
                                  ),  
                                ),                        
                                selectedTime == null 
                                ? Text('time not selected', style: TextStyle(fontSize: 16, color: Colors.red, fontStyle: FontStyle.italic))  
                                : Text(selectedTime, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),                                           
                          ],
                        ),
                      ),
                    ),
                    Card( //Credit card details 
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,                     
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                ),       
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: RaisedButton(
                                            onPressed: (){
                                              setState(() {
                                                paymentMethod = 'cash'; //set payment method to "cash"
                                              });
                                            },
                                            color: Colors.green,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Icon(Icons.money_rounded, color: paymentMethod == 'cash' ? Colors.white : Colors.black54),
                                                Text("Cash", style: TextStyle(color: paymentMethod == 'cash' ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 16))
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          width: 100,
                                          child: RaisedButton(
                                            onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return selectCardDialog;
                                                },
                                              );
                                            },
                                            color: Colors.green,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Icon(Icons.credit_card_rounded, color: paymentMethod == 'card' ? Colors.white : Colors.black54),
                                                Text("Card", style: TextStyle(color: paymentMethod == 'card' ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 16))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    RaisedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("My Coupons"),
                                              content: Container(
                                                height: 350.0, 
                                                width: 300.0, 
                                                child: FutureBuilder<List<Coupon>>(
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
                                                                  leading: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 25),
                                                                  //Display the last 4 digits of the card only
                                                                  title: Text(
                                                                    snapshot.data[index].name,
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: Colors.white
                                                                    ),
                                                                  ),
                                                                  trailing: RaisedButton(
                                                                    onPressed: (){
                                                                      setState(() {                      
                                                                        if(couponDiscount != null){
                                                                          //Revert the coupon changes if there was a coupon picked
                                                                          totalAmount = oldTotalAmount;
                                                                          couponDiscount = null;          
                                                                        }
                                                                        couponUid = snapshot.data[index].uid;
                                                                        couponDiscount = snapshot.data[index].value;
                                                                        totalAmount = totalAmount - couponDiscount;
                                                                        totalAmount < 0 ? totalAmount = 0.00 : totalAmount = totalAmount;
                                                                        Navigator.pop(context);
                                                                      });
                                                                    },
                                                                    color: Colors.green,
                                                                    textColor: Colors.white,
                                                                    child: Text("SELECT", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                              ),
                                              actions: [     
                                                FlatButton(
                                                  onPressed: () => Navigator.pop(context), 
                                                  child: Text("Cancel"),
                                                ),                                      
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      color: Colors.blue,
                                      child: Text("Coupons", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),    
                                if(selectedCard != null && paymentMethod == 'card')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.credit_card_rounded, color: Colors.black54, size: 30),
                                        SizedBox(width: 20),
                                        Text(selectedCard, style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return selectCardDialog;
                                          },
                                        );
                                      },
                                      child: Text(
                                        "Change",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if(couponDiscount != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.card_giftcard_rounded, color: Colors.black54, size: 30),
                                        SizedBox(width: 20),
                                        Text("\$" + couponDiscount.toString() + " Voucher" , style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() { //Revert the coupon changes when user removes coupon
                                          totalAmount = oldTotalAmount;
                                          couponDiscount = null; 
                                          couponUid = null;
                                        });
                                      },
                                      child: Text(
                                        "Remove",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            height: MediaQuery.of(context).size.height*0.15,
            width: MediaQuery.of(context).size.width,
            color: Colors.brown[600],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [                         
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.white
                      ),
                    ),
                    couponDiscount != null
                    ? Row(
                      children: [               
                        Text(
                          '\$' + totalAmount.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '\$' + oldTotalAmount.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.white,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 1.8
                          ),
                        ),
                      ],
                    )
                    : Text(
                      '\$' + oldTotalAmount.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),                   
                Container(               
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    onPressed: (){
                      //Show toast message if any fields are unvalidated
                      if(!addressValidated || !dateValidated || !timeValidated){
                        Fluttertoast.showToast(msg: "Empty / Unselected fields. Check and try again.", gravity: ToastGravity.TOP);
                      }
                      else{
                        FirestoreService().addOrderData(address, phoneController.text, dateFormat.format(DateTime.now()), dateFormat.format(selectedDate), selectedTime, paymentMethod, totalAmount.toStringAsFixed(2), 'Delivering', Timestamp.now());  
                        FirestoreService().removeEntireCart(); //Empty the user's cart upon successful checkout                     
                        if(totalAmount >= 50){ 
                          //generate a random coupon for the user if spent more than or equals to $50
                          FirestoreService().addUserCouponData();
                        }
                        if(couponUid != null){ //Remove the coupon once used by the user
                          FirestoreService().removeCouponData(couponUid);
                        }
                        Navigator.push(context, PageTransition(child: OrderPage(), type: PageTransitionType.fade));   
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              child: AlertDialog(
                                title: Text('Purchase Success!', style: TextStyle(fontWeight: FontWeight.bold)),
                                content: Container(
                                  alignment: Alignment.center,
                                  height: 180,
                                  child: Column(
                                    children: [
                                      Image(
                                        image: AssetImage('images/fruittruck.png'),
                                        height: 150,
                                      ),
                                      SizedBox(height: 10),
                                      Text("Thank You For Your Purchase.", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ),
                                actions: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      child: Text('OK'),
                                      onPressed: () { 
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }                                      
                    },
                    color: addressValidated && dateValidated && timeValidated ? Colors.green : Colors.grey,
                    child: Text(
                      "PLACE ORDER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
