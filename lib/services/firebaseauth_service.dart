import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAuthService{
  //FirebaseAuth instance
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  String errorMsg;
  
  Future<User> signIn({String email, String password}) async{
    try{
      UserCredential ucred = await _fbAuth.signInWithEmailAndPassword(
        email: email, password: password
      );
      User user = ucred.user;
      Fluttertoast.showToast(msg: "Signed In Successfully!\nWelcome, ${user.displayName}", gravity: ToastGravity.TOP);
      return user;
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.TOP);
      return null;
    } catch (e){
      print(e.message);
      return null;
    }
  }
  Future<User> signUp({String name, String phone, String email, String password}) async{
    try{
      UserCredential ucred = await _fbAuth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      User user = ucred.user;
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': user.photoURL,
        'password': password,
        'uid': user.uid,
      });
      await FirebaseAuth.instance.currentUser.updateProfile(displayName: name);
      FirestoreService().addUserCouponData(); //Generate a random coupon for new users
      return user;
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.TOP);
      return null; 
    } catch (e){
      print(e.message);
      return null;
    }
  }
  Future<User> updateAccount({String name, String phone, String email}) async{  
    try{
      var user = _fbAuth.currentUser;
      DocumentSnapshot documentSnapshot;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((value) {
        documentSnapshot = value;
      });
      final cred = EmailAuthProvider.credential(email: user.email, password: documentSnapshot['password']);
      await user.reauthenticateWithCredential(cred);
      await FirebaseAuth.instance.currentUser.updateProfile(displayName: name);
      await FirebaseAuth.instance.currentUser.updateEmail(email);
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': user.photoURL,
        'password': documentSnapshot['password'],
        'uid': user.uid,
      });
      Fluttertoast.showToast(msg: "Account Updated Successfully!\nWelcome, ${_fbAuth.currentUser.displayName}", gravity: ToastGravity.TOP);
      return _fbAuth.currentUser;
    } on FirebaseAuthException catch (e){
      Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.TOP);
      return null; 
    } catch (e){
      print(e.message);
      return null;
    }
  }
  Future<bool> changePassword({String currentPassword, String newPassword}) async {
    bool success = false;
    var user = _fbAuth.currentUser;
    DocumentSnapshot documentSnapshot;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((value) {
      documentSnapshot = value;
    });
    //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.
    final cred = EmailAuthProvider.credential(email: user.email, password: currentPassword);
    await user.reauthenticateWithCredential(cred).then((value) async {
      await user.updatePassword(newPassword).then((_) {
        success = true; 
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': documentSnapshot['name'],
          'email': documentSnapshot['email'],
          'phone': documentSnapshot['phone'],
          'photoUrl': user.photoURL,
          'password': newPassword,
          'uid': user.uid,
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
      });
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message, gravity: ToastGravity.TOP);
    });
    return success;
  }
  Future<void> signOut() async{
    await _fbAuth.signOut();
    Fluttertoast.showToast(msg: "You have logged out of your account", gravity: ToastGravity.TOP);
  }
}