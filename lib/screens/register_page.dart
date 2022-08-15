import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/loading_page.dart';
import 'package:flutter_project/screens/login_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/profile_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firebaseauth_service.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class RegisterPage extends StatefulWidget{
  @override 
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  bool _isLoading = false;
  bool _obscurepwText = true; //Initially password is obscure
  void _togglePw(){ //Toggle password visibility
    setState(() { 
      //if _toggle() function called, _obscureText will be false so when icon pressed,
      //password obscuretext function will be false
      _obscurepwText = !_obscurepwText;
    });
  }
  final RegExp phoneRegex = new RegExp(r'^(6|8|9)');
  //Controllers for textfields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cfmpasswordController = TextEditingController();

  @override  
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final FirebaseAuth _fbAuth = FirebaseAuth.instance;
    return _isLoading
    ? LoadingScreen() //Display loading screen if application is loading
    : Stack(
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
              title: Text("REGISTER", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
            body: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: nameController,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))], 
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.brown,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        maxLength: 8,
                        controller: phoneController,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.brown,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.brown,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: passwordController,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        obscureText: _obscurepwText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: (){
                              _togglePw();
                            },
                            icon: Icon(Icons.visibility),
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.brown,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: cfmpasswordController,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        obscureText: _obscurepwText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: (){
                              _togglePw();
                            },
                            icon: Icon(Icons.visibility),
                          ),
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.brown[600],
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.brown,
                              width: 3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 3,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    RaisedButton( //Sign Up Button
                      color: Colors.brown[400],
                      textColor: Colors.white,
                      elevation: 5.0,
                      onPressed: () async{
                        if(nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty || passwordController.text.isEmpty){
                          Fluttertoast.showToast(msg: "Please ensure that the fields required are filled up.", gravity: ToastGravity.TOP); return null; //Prevent form submission if fields are empty
                        }
                        else if(passwordController.text != cfmpasswordController.text){
                          Fluttertoast.showToast(msg: "Password and Confirm Password fields has to be the same.", gravity: ToastGravity.TOP); return null; //Check if password = confirm password
                        }
                        else if(phoneController.text.length != 8){
                          Fluttertoast.showToast(msg: "Phone Number has to be 8 Digits", gravity: ToastGravity.TOP); return null;
                          //Check if phone number is 8 digits
                        }
                        else if(!phoneController.text.startsWith(phoneRegex)){
                          Fluttertoast.showToast(msg: "Please ensure Phone Number is local (Singapore)", gravity: ToastGravity.TOP); return null; //Check if phone number belongs locally in sg 
                        }
                        setState(() { _isLoading = true; });
                        var newuser = await FirebaseAuthService().signUp(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        if(newuser != null){
                          closeDrawer();
                          Navigator.push(context, PageTransition(child: ProductPage(), type: PageTransitionType.fade));
                          Fluttertoast.showToast(msg: "Signed Up Successfully!\nWelcome, ${_fbAuth.currentUser.displayName}", gravity: ToastGravity.TOP);
                        }
                        setState(() { _isLoading = false; });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Text('REGISTER'),
                      ),
                    ),
                    //Sign up / Sign in toggler for guests
                    if(_fbAuth.currentUser == null)
                    RaisedButton(
                      onPressed: (){
                        closeDrawer();
                        Navigator.push(context, PageTransition(child: LoginPage(), type: PageTransitionType.fade));
                      },
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text("Have an account? Sign In"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}