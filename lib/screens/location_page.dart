import 'dart:async';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Completer<GoogleMapController> _controller = Completer();

  var location = new Location();
  CameraPosition _myLocation;
  LocationData userLocation; //Store current user's Lat, Lng coordinates
  Future<LocationData> _getLocation() async{
    LocationData currentLocation;
    try{
      currentLocation = await location.getLocation();
    }
    catch(e){
      currentLocation = null;
    }
    return currentLocation;
  }
  @override
  void initState() {
    super.initState();
    _getLocation().then((value){
      setState((){
        userLocation = value;
        _myLocation = CameraPosition(
          target: LatLng(userLocation.latitude, userLocation.longitude),
          zoom: 17,
        );
      });
    }); //get the user's current location when they open location page
  }

  static final Marker _yayapapayaMarker = Marker( //Actual store location
    markerId: MarkerId('_yayapapaya'),
    infoWindow: InfoWindow(title: 'YayaPapaya Fruits'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(1.2857059919945328, 103.77570362024194),
  );

  static final Marker _yayapapayaMarker2 = Marker( //Pretend store location
    markerId: MarkerId('_yayapapaya2'),
    infoWindow: InfoWindow(title: 'YayaPapaya Fruits'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(1.378224, 103.748352),
  );

  static final Marker _yayapapayaMarker3 = Marker( //Pretend store location 
    markerId: MarkerId('_yayapapaya3'),
    infoWindow: InfoWindow(title: 'YayaPapaya Fruits'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(1.347026, 103.866257),
  );

  static final Marker _yayapapayaMarker4 = Marker( //Pretend store location 
    markerId: MarkerId('_yayapapaya4'),
    infoWindow: InfoWindow(title: 'YayaPapaya Fruits'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(1.330585, 103.930581),
  );

  Widget build(BuildContext context) {
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
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text("LOCATION", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
            body: userLocation != null //Wait for location to be retrieved before displaying map
            ? GoogleMap(
              mapType: MapType.normal,
              markers: {
                _yayapapayaMarker, //The actual store location marker
                _yayapapayaMarker2, //First pretend store marker
                _yayapapayaMarker3, //Second pretend store marker
                _yayapapayaMarker4 //Third pretend store marker
              },
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _myLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);              
              },
            )
            : Center(
              child: CircularProgressIndicator(),
            )    
          ),         
        ),
      ]
    );
  }
}
