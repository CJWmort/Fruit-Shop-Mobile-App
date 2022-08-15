import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/model/order.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class OrderPage extends StatefulWidget{
  @override 
  _OrderPageState createState() => _OrderPageState();
}

const OrderTextStyle = TextStyle( //Order text styling
  fontWeight: FontWeight.bold,
  color: Colors.blue,
  fontSize: 16,
);

const OrderSubTextStyle = TextStyle( //Order sub text styling
  fontWeight: FontWeight.bold,
  fontSize: 15,
);

class _OrderPageState extends State<OrderPage>{
  String arrivalDate;
  String year;
  String month;
  String date;
  int diffInMin;
  int diffInSec;

  void _refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //Perform a refresh when page loads because cart is emptied when order is made 
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    setState(() {});
  }
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
              title: Text("My Orders", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
            body: FutureBuilder<List<Order>>(
              future: FirestoreService().readOrderData(),
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
                            Icons.local_shipping_outlined,
                            size: 130,
                            color: Colors.brown[700],
                          ),
                          Text(
                            "No Order History",
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
                              "you have not placed any orders",
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
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        reverse: false,
                        padding: EdgeInsets.only(bottom: bottom),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
                                  child: Text("Latest Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black54)),                               
                                ), 
                                Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: RaisedButton(
                                    onPressed: (){setState(() { });},
                                    child: Icon(Icons.refresh, color: Colors.white),
                                    color: Colors.blue,
                                  )
                                )
                              ],
                            ),                    
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, index){       
                                DateTime now = DateTime.now(); 
                                //Convert DateTime.now() to SG time zone's DateTime.now();
                                DateTime dateTimeNowSG = DateTime(now.year, now.month, now.day, now.hour +8, now.minute, now.second);

                                arrivalDate = snapshot.data[index].date;
                                year = arrivalDate.substring(6, 10);
                                month = arrivalDate.substring(3, 5);
                                date = arrivalDate.substring(0, 2);
                                                               
                                //Convert AM & PM to 24 hour format
                                var arrivalTime = snapshot.data[index].time;
                                DateTime time = DateFormat.jm().parse(arrivalTime);
                                String newArrivalTime = DateFormat("HH:mm").format(time);
                                String formatArrivalTime = "$year-$month-$date $newArrivalTime:00";
                                //Find the DateTime format of the arrival date and arrival time combined
                                DateTime arrivalDateTime = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(formatArrivalTime);

                                //Find the difference in arrivalDateTime and dateTimeNowSG                             
                                diffInMin = arrivalDateTime.difference(dateTimeNowSG).inMinutes;
                                diffInSec = arrivalDateTime.difference(dateTimeNowSG).inSeconds;
                                //if difference is less than 0 then just stop at 0
                                diffInSec = diffInSec > 0 ? diffInSec : 0; 
                               
                                //Find the duration in days, hours, minutes & seconds using the difference in seconds
                                var d = (diffInSec / (3600*24)).floor();
                                var h = (diffInSec % (3600*24) / 3600).floor();
                                var m = (diffInSec % 3600 / 60).floor();
                                var s = (diffInSec % 60).floor();
                                var dDisplay = d > 0 ? d.toString() + (d == 1 ? " day, " : " days, ") : " 0 days, ";
                                var hDisplay = h > 0 ? h.toString() + (h == 1 ? " hour, " : " hours, ") : " 0 hours, ";
                                var mDisplay = m > 0 ? m.toString() + (m == 1 ? " min, " : " mins, ") : " 0 mins, ";
                                var sDisplay = s > 0 ? s.toString() + (s == 1 ? " sec " : " secs") : " 0 secs "; 
                                
                                if(dateTimeNowSG.compareTo(arrivalDateTime) > 0 && snapshot.data[index].status != 'Reached'){
                                  //Update status to "Reached" current sg time is after arrival date time
                                  FirestoreService().updateOrderData(snapshot.data[index].uid, 'Reached');
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.local_shipping, color: Colors.brown, size: 35),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Ordered at: ' + snapshot.data[index].startDate,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 18,
                                                      color: Colors.brown
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //Only show cancel button if status is delivering
                                              if(snapshot.data[index].status == 'Delivering')
                                              RaisedButton(
                                                //Disable the cancel button if status is not delivering
                                                //Disable the cancel button if order is arriving in 3 days from now (4320 min)
                                                onPressed: snapshot.data[index].status != 'Delivering' || diffInMin < 4320
                                                ? null : (){ 
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('Cancel Order?'),
                                                        content: Text(
                                                          "You are about to cancel this order.\nThis action cannot be undone.\nAre You Sure?"
                                                        ),
                                                        actions: [
                                                          Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextButton(
                                                                  child: Text('NO'),
                                                                  onPressed: () { 
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                                RaisedButton(
                                                                  onPressed: (){
                                                                    //Cancel the order if more than 3 days before arrival
                                                                    FirestoreService().updateOrderData(snapshot.data[index].uid, 'Cancelled');
                                                                    Navigator.of(context).pop();
                                                                    setState(() {}); //Refresh the state to see the changes
                                                                  },
                                                                  textColor: Colors.white,
                                                                  color: Colors.red,
                                                                  child: Text("YES"),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );                                                
                                                },
                                                color: Colors.red[300],
                                                textColor: Colors.white,
                                                child: Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              )
                                            ],
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              style: DefaultTextStyle.of(context).style,
                                              children:[
                                                TextSpan(text: "Address: ", style: OrderTextStyle),
                                                TextSpan(text: snapshot.data[index].address, style: OrderSubTextStyle),
                                              ],
                                            ),
                                          ),                                        
                                          Row(
                                            children: [
                                              Text("Arrival date & time: ", style: OrderTextStyle),
                                              Text(snapshot.data[index].date + ', ' + snapshot.data[index].time, style: OrderSubTextStyle)
                                            ],
                                          ),                                  
                                          Row(
                                            children: [
                                              Text("Total paid: ", style: OrderTextStyle),
                                              Text('\$' + snapshot.data[index].totalPaid, style: OrderSubTextStyle)
                                            ],
                                          ),  
                                          Row(
                                            children: [
                                              Text("Payment type: ", style: OrderTextStyle),
                                              Text(snapshot.data[index].paymentType.toUpperCase(), style: OrderSubTextStyle)
                                            ],
                                          ),  
                                          if(snapshot.data[index].status == 'Delivering')
                                          Row(
                                            children: [
                                              Text("Status: ", style: OrderTextStyle),
                                              Text(snapshot.data[index].status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange))
                                            ],
                                          ),     
                                          if(snapshot.data[index].status == 'Reached')
                                          Row(
                                            children: [
                                              Text("Status: ", style: OrderTextStyle),
                                              Text(snapshot.data[index].status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green))
                                            ],
                                          ),   
                                          if(snapshot.data[index].status == 'Cancelled')
                                          Row(
                                            children: [
                                              Text("Status: ", style: OrderTextStyle),
                                              Text(snapshot.data[index].status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red))
                                            ],
                                          ),                                      
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time, color: Colors.blue),
                                                  SizedBox(width: 5),
                                                  Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                                                ],
                                              ),
                                              snapshot.data[index].status == 'Cancelled' 
                                              ? Text(
                                                "0 days, 0 hours, 0 mins, 0 secs",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black45
                                                ),
                                              )
                                              : Text(
                                                dDisplay + hDisplay + mDisplay + sDisplay,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: diffInSec > 0 ? Colors.blue : Colors.black45
                                                ),
                                              ),
                                            ],
                                          ),                                         
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),      
                          ],
                        ),
                      ),
                    );         
                  }
                }                 
              }
            ),            
          ),     
        ),   
      ],
    );
  }
}