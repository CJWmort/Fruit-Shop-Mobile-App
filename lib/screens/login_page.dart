import 'package:flutter/material.dart';
import 'package:flutter_project/model/config.dart';
import 'package:flutter_project/screens/drawer_page.dart';
import 'package:flutter_project/screens/loading_page.dart';
import 'package:flutter_project/screens/product_page.dart';
import 'package:flutter_project/screens/register_page.dart';
import 'package:flutter_project/screens/search_page.dart';
import 'package:flutter_project/services/firebaseauth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget{
  @override 
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  bool _isLoading = false;
  bool _obscurepwText = true; //Initially password is obscure
  void _togglePw(){ //Toggle password visibility
    setState(() { 
      //if _toggle() function called, _obscureText will be false so when icon pressed,
      //password obscuretext function will be false
      _obscurepwText = !_obscurepwText;
    });
  }
  //Controllers for textfields.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Widget build(BuildContext context){
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
              title: Text("LOGIN", style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold)),
              bottom: PreferredSize(
                child: Container(
                  color: Colors.brown[700],
                  height: 8,
                ),
                preferredSize: Size.fromHeight(4.0)
              ),
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
                    Icons.search_rounded, 
                    color: Colors.brown[700],
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.push(context, PageTransition(child: SearchPage(), type: PageTransitionType.fade));
                  },
                ),               
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image(
                    image: AssetImage('images/logo.png'),
                  ),
                  SizedBox(height: 30,),
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
                  SizedBox(height: 20),
                  RaisedButton( //Sign In Button
                    color: Colors.brown[400],
                    textColor: Colors.white,
                    elevation: 5.0,
                    onPressed: () async{
                      if(emailController.text.isEmpty || passwordController.text.isEmpty){
                        Fluttertoast.showToast(msg: "Please ensure that the fields required are filled up.", gravity: ToastGravity.TOP); return null; //Prevent form submission if fields are empty
                      }
                      setState(() { _isLoading = true; });
                      var reguser = await FirebaseAuthService().signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      if(reguser != null){
                        closeDrawer();
                        //Direct user to product page when login
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => ProductPage()),
                          (Route<dynamic> route) => false
                        );
                      }
                      setState(() { _isLoading = false; });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text('LOGIN'),
                    ),
                  ),
                  //Sign up / Sign in toggler
                  RaisedButton(
                    onPressed: (){      
                      closeDrawer();  
                      Navigator.push(context, PageTransition(child: RegisterPage(), type: PageTransitionType.fade));
                    },
                    textColor: Colors.white,
                    color: Colors.blue,
                    child: Text("Create an account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
    );
  }
}