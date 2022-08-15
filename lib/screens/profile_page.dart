import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/cart_page.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/favourite_page.dart';
import 'package:flutter_project/screens/loading_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firebaseauth_service.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:flutter_project/services/storage_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget{
  @override 
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{
  final RegExp phoneRegex = new RegExp(r'^(6|8|9)');
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldpwController = TextEditingController();
  final TextEditingController newpwController = TextEditingController();
  final TextEditingController cfmnewpwController = TextEditingController();

  bool isChangeAccount = true; //Initially edit Name, Phone Number & Email fields shown only
  bool _isLoading = false;
  bool _obscurepwText = true; //Initially password is obscure
  String imageUrl;
  void _togglePw(){ //Toggle password visibility
    setState(() { 
      //if _toggle() function called, _obscureText will be false so when icon pressed,
      //password obscuretext function will be false
      _obscurepwText = !_obscurepwText;
    });
  }
  @override 
  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final Storage storage = Storage(); //create Storage object
    final FirebaseAuth _fbAuth = FirebaseAuth.instance;
    return _isLoading 
    ? LoadingScreen()
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
              title: Text("PROFILE", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,               
                    children: [
                      SizedBox(height: 20),
                      Stack(
                        children: [      
                          _fbAuth.currentUser.photoURL != null   
                          ? CircleAvatar(
                            radius: 85,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: NetworkImage(_fbAuth.currentUser.photoURL) ,
                            )                            
                          )
                          : CircleAvatar(
                            radius: 85,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.blue.shade100,
                              child: Image(
                                image: AssetImage('images/guest.png'),
                                height: 75,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 25,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Center(
                                    child: IconButton( 
                                      tooltip: "Edit Profile Picture",
                                      icon: Icon(Icons.edit, color: Colors.white, size: 25),
                                      //Allow user to change his/her profile picture
                                      onPressed: () async {   
                                        final results = await FilePicker.platform.pickFiles(
                                        allowMultiple: false, //Only can select 1 file
                                        type: FileType.custom,
                                        allowedExtensions: ['png', 'jpg'],
                                      );
                                      if(results == null){
                                        Fluttertoast.showToast(msg: "No file selected", gravity: ToastGravity.TOP);
                                        return null;
                                      }

                                      setState(() { _isLoading = true; });
                                      final path = results.files.single.path;
                                      final fileName = results.files.single.name;
                                      storage.uploadFile(path, fileName).then((value) => print('File Uploaded!'));

                                      //Allow time for file to upload to storage before proceeding
                                      await Future.delayed(const Duration(seconds: 2), (){});   

                                      Reference ref = FirebaseStorage.instance.ref().child(fileName);
                                      var url = await ref.getDownloadURL();
                                      //Update user's profile picture & user's document
                                      await FirebaseAuth.instance.currentUser.updateProfile(photoURL: url);   
                                      var user = _fbAuth.currentUser;
                                      DocumentSnapshot documentSnapshot;
                                      await FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((value) {
                                        documentSnapshot = value;
                                      });      
                                      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                        'name': documentSnapshot['name'],
                                        'email': documentSnapshot['email'],
                                        'phone': documentSnapshot['phone'],
                                        'photoUrl': url,
                                        'password': documentSnapshot['password'],
                                        'uid': _fbAuth.currentUser.uid,
                                      });

                                      setState(() { _isLoading = false; });      
                                      return Fluttertoast.showToast(msg: "Profile Picture Updated Successfully!", gravity: ToastGravity.TOP);            
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(_fbAuth.currentUser != null ? "Welcome, " + _fbAuth.currentUser.displayName
                            : 'Loading...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.brown[700]
                        ),
                      ),
                      SizedBox(height: 10),
                      isChangeAccount //Display Edit Account Fields / Edit Password Fields
                      ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                labelText: _fbAuth.currentUser != null ? "Current Name: " + _fbAuth.currentUser.displayName
                                          : 'Loading...',
                                hintText: 'Enter New Name',
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
                          FutureBuilder<DocumentSnapshot>(
                            future: FirestoreService().userCollection.doc(_fbAuth.currentUser.uid).get(),
                            builder: (context, snapshot){
                              if(!snapshot.hasData){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              else{
                                return Padding(
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
                                      labelText: "Current Phone No.: " + snapshot.data['phone'],
                                      hintText: 'Enter New Phone No.',
                                      counterText: "",
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
                                );
                              }
                            }
                          ),                        
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              controller: emailController,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                labelText: _fbAuth.currentUser != null ? "Current Email: " + _fbAuth.currentUser.email
                                            : 'Loading...',
                                hintText: 'Enter New Email',
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
                        ],
                      )
                      : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              controller: oldpwController,
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
                                labelText: 'Enter Current Password',
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
                              controller: newpwController,
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
                                labelText: 'Enter New Password',
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
                              controller: cfmnewpwController,
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
                                labelText: 'Confirm New Password',
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
                        ],
                      ),
                      isChangeAccount
                      ? RaisedButton(
                        color: Colors.brown[400],
                        textColor: Colors.white,
                        elevation: 5.0,
                        onPressed: () async{
                          if(emailController.text.isEmpty || phoneController.text.isEmpty || nameController.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please ensure that the fields required are filled up.", gravity: ToastGravity.TOP); return null; //Prevent form submission if fields are empty
                          }
                          else if(phoneController.text.length != 8){
                            Fluttertoast.showToast(msg: "Phone Number has to be 8 Digits", gravity: ToastGravity.TOP); return null; //Check if phone number is 8 digits
                          }
                          else if(!phoneController.text.startsWith(phoneRegex)){
                            Fluttertoast.showToast(msg: "Please ensure Phone Number is local (Singapore)", gravity: ToastGravity.TOP); return null; //Check if phone number belongs locally in sg 
                          }    
                          setState(() { _isLoading = true; });            
                          var upduser = await FirebaseAuthService().updateAccount(
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                          );
                          if(upduser != null){
                            setState(() {});
                            Fluttertoast.showToast(msg: "Account Updated Successfully!\nWelcome, ${_fbAuth.currentUser.displayName}", gravity: ToastGravity.TOP);
                          }
                          setState(() { _isLoading = false; });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Text('SAVE'),
                        ),
                      )
                      : RaisedButton(
                        color: Colors.brown[400],
                        textColor: Colors.white,
                        elevation: 5.0,
                        onPressed: () async{
                          if(oldpwController.text.isEmpty || newpwController.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please ensure that the fields required are filled up.", gravity: ToastGravity.TOP); return null; //Prevent form submission if fields are empty
                          }
                          else if(newpwController.text != cfmnewpwController.text){
                            Fluttertoast.showToast(msg: "New Password and Confirm New Password fields has to be the same.", gravity: ToastGravity.TOP); return null; //Check if password = confirm password
                          }
                          setState(() { _isLoading = true; });            
                          var upduser = await FirebaseAuthService().changePassword(
                            currentPassword: oldpwController.text.trim(),
                            newPassword : newpwController.text.trim(),
                          );
                          if(upduser == true){
                            setState(() {});
                            Fluttertoast.showToast(msg: "Password Updated Successfully!\nWelcome, ${_fbAuth.currentUser.displayName}", gravity: ToastGravity.TOP);
                          }
                          setState(() { _isLoading = false; });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Text('SAVE'),
                        ),
                      ),
                      //Update Account / Update Password toggler
                      RaisedButton(
                        onPressed: (){          
                          setState(() { isChangeAccount = !isChangeAccount; });
                        },
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: isChangeAccount 
                          ? Text("Change Password")
                          : Text("Edit Account"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}