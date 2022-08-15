import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/model/address.dart';
import 'package:flutter_project/model/card.dart';
import 'package:flutter_project/model/cart.dart';
import 'package:flutter_project/model/comment.dart';
import 'package:flutter_project/model/coupon.dart';
import 'package:flutter_project/model/favourite.dart';
import 'package:flutter_project/model/fruit.dart';
import 'dart:math';

import 'package:flutter_project/model/order.dart';

class FirestoreService{
  //Create a CollectionReference that references the firestore collection
  final CollectionReference bookCollection = FirebaseFirestore.instance.collection('books');
  final CollectionReference fruitCollection = FirebaseFirestore.instance.collection('fruits');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final Query fruitQuery = FirebaseFirestore.instance.collection('fruits').where('category', isEqualTo: Fruit.currentCategory.toLowerCase()); //Query to filter based on category field in the fruits collection

  Future<List<Fruit>> readFruitData() async{ //Function to read the fruit collection
    List<Fruit> fruitList = [];
    QuerySnapshot snapshot = await fruitQuery.get(); //This is the default snapshot, to filter based on category.
    
    if(Fruit.currentCategory == 'All'){ 
      //If the selected category is 'ALL' then just get all the fruits in the firebase
      snapshot = await fruitCollection.orderBy('favCount', descending: true).get();
    }
    snapshot.docs.forEach((document){
      Fruit fruit = Fruit.fromMap(document.data());
      fruitList.add(fruit);
    });
    return fruitList;
  }

  Future<List<Favourite>> readFavData() async{ //Function to read the favourites sub-collection in users collection
    final Query favQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('favourites'); //Query to get all the favourite fruits for the user
    List<Favourite> favList = [];
    QuerySnapshot snapshot = await favQuery.get(); //Get all the documents in the favourites sub-collection

    snapshot.docs.forEach((document){
      Favourite favourite = Favourite.fromMap(document.data());
      favList.add(favourite);
    });
    return favList;
  }

  Future<void> addFavData(String fruitId, String userId, String name, String image) async{
    //Add new document to the favourites sub-collection in the users collection
    //The document inserted will include the favourited fruit's ID, Name and Image as well as the current user's ID
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('favourites').doc(fruitId).set({ 
      'fruitid': fruitId,
      'userid': userId,
      'name': name,
      'image': image
    });
  }

  Future<void> removeFavData(String fruitId) async{
    //Find the sub-collection "favourites" in the users collection and then
    //Locate the document with that matching fruitId and delete it from the favourites collection
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('favourites').doc(fruitId).delete();
  }

  Future<List<Cart>> readCartData() async{ //Function to read the cart sub-collection in users collection
    final Query cartQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cart'); //Query to get all the cart fruits for the user
    List<Cart> cartList = [];
    QuerySnapshot snapshot = await cartQuery.get(); //Get all the documents in the cart sub-collection

    snapshot.docs.forEach((document){
      Cart cart = Cart.fromMap(document.data());
      cartList.add(cart);
    });
    return cartList;
  }
  
  Future<void> addCartData(String fruitid, String userid, String name, String image, int quantity, String price) async{ 
    //Add new document to the cart sub-collection in the users collection
    //The document inserted will include the fruit's ID, Name and Image, Quantity, Price, Subtotal as well as the current user's ID
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(fruitid).set({ 
      'fruitid': fruitid,
      'userid': userid,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
    });
  }

  Future<void> removeCartData(String fruitId) async{
    //Find the sub-collection "cart" in the users collection and then
    //Locate the document with that matching fruitId and delete it from the cart collection
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cart').doc(fruitId).delete();
  }

  Future<void> removeEntireCart() async{ 
    //Clear all the documents in the cart sub collection
    var cartCollection = userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cart');
    var snapshots = await cartCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete(); //Loop through the entire user's cart and delete all document
    }
  }

  Future<List<Cards>> readCardData() async{ //Function to read the card sub-collection in users collection
    final Query cardQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('cards'); //Query to get all the credit card info of the user
    List<Cards> cardList = [];
    QuerySnapshot snapshot = await cardQuery.get(); //Get all the documents in the cards sub-collection

    snapshot.docs.forEach((document){
      Cards card = Cards.fromMap(document.data());
      cardList.add(card);
    });
    return cardList;
  }

  Future<void> addCardData(String name, String number, String cvv, String expiry) async{ 
    var docRef = FirestoreService().userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cards').doc();
    //Add new document to the cards sub-collection in the users collection
    //The document inserted will include the card's Name and Number, CVV and Expiry date
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cards').doc(docRef.id).set({ 
      'uid': docRef.id,
      'name': name,
      'number': number,
      'cvv': cvv,
      'expiry': expiry,
    });
  }

  Future<void> removeCardData(String cardUid) async{
    //Find the sub-collection cards in the users collection and then
    //Locate the document with that matching uid and delete it from the cards collection
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('cards').doc(cardUid).delete();
  }

  Future<List<Coupon>> readUserCouponData() async{ //Function to read the coupons sub-collection in users collection
    final Query couponQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('coupons'); //Query to get all the coupon info of the user
    List<Coupon> couponList = [];
    QuerySnapshot snapshot = await couponQuery.get(); //Get all the documents in the coupons sub-collection

    snapshot.docs.forEach((document){
      Coupon coupon = Coupon.fromMap(document.data());
      couponList.add(coupon);
    });
    return couponList;
  }

  Future<void> addUserCouponData() async{ //Adds a randomly generated coupon for the user
    final Query couponQuery = FirebaseFirestore.instance.collection('coupons');
    var couponList = []; //Store all the current coupons uid
    QuerySnapshot snapshot = await couponQuery.get(); //Get all the documents in the coupons collection
    snapshot.docs.forEach((document){
      Coupon coupon = Coupon.fromMap(document.data());
      couponList.add(coupon.uid);
    });

    // fetch a new Random coupon
    final randomCoupon = new Random();
    var selectedCoupon = couponList[randomCoupon.nextInt(couponList.length)]; 

    final Query randomCouponQuery = FirebaseFirestore.instance.collection('coupons').where('uid', isEqualTo: selectedCoupon);
    QuerySnapshot newSnapshot = await randomCouponQuery.get(); //fetch the random generated coupon from coupons collection
    var docRef = FirestoreService().userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('coupons').doc();

    newSnapshot.docs.forEach((document){
      Coupon coupon = Coupon.fromMap(document.data());
      //Add new document to the coupons sub-collection in the users collection
      //The document inserted will include the coupon's uid, name, description and value
      userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('coupons').doc(docRef.id).set({ 
        'uid': docRef.id,
        'name': coupon.name,
        'description': coupon.desc,
        'value': coupon.value,
      });
    });
  }

  Future<void> removeCouponData(String uid) async{
    //Find the sub-collection "coupons" in the users collection and then
    //Locate the document with that matching uid and delete it from the coupons sub-collection
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('coupons').doc(uid).delete();
  }

  Future<List<Order>> readOrderData() async{ //Function to read the orders sub-collection in users collection
    final Query orderQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('orders').orderBy('createdAt', descending: true).limit(5); //Query to get the 5 latest orders from the user
    List<Order> orderList = [];
    QuerySnapshot snapshot = await orderQuery.get(); //Get all the documents in the orders sub-collection

    snapshot.docs.forEach((document){
      Order order = Order.fromMap(document.data());
      orderList.add(order);
    });
    return orderList;
  }

  Future<void> addOrderData(String address, String phone, String startDate, String date, String time, String paymentType, String totalPaid, String status, Timestamp createdAt) async{ 
    var docRef = FirestoreService().userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('orders').doc();
    //Add new document to the orders sub-collection in the users collection
    //The document inserted will include the order's id, address, contact number, order start date, date and time of arrival, payment type and total amount paid
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('orders').doc(docRef.id).set({ 
      'uid': docRef.id,
      'address': address,
      'phone': phone,
      'startDate': startDate,
      'date': date,
      'time': time,
      'paymentType': paymentType, 
      'totalPaid': totalPaid,
      'status': status,
      'createdAt': createdAt
    });
  }

  Future<void> updateOrderData(String uid, String status) async{
    //Update the order status
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('orders').doc(uid).update({
      'status': status,
    });
  }

  Future<List<Comments>> readCommentData(String fruitid) async{ 
    //Function to read the comments sub-collection in each fruit document
    final Query commentQuery = FirebaseFirestore.instance.collection('fruits').doc(fruitid).collection('comments').orderBy('createdAt', descending: true); //Display the latest comment at the top
    List<Comments> commentList = [];
    QuerySnapshot snapshot = await commentQuery.get(); //Get all the documents in the orders sub-collection

    snapshot.docs.forEach((document){
      Comments comment = Comments.fromMap(document.data());
      commentList.add(comment);
    });
    return commentList;
  }

  Future<void> addCommentData(String fruitid, String userid, String name, String profilepic, String comment, Timestamp createdAt) async{ 
    var docRef = FirestoreService().fruitCollection.doc(fruitid).collection('comments').doc();
    //Add new document to the comments sub-collection in the fruits collection
    //The document inserted will include the user's name, profile pic, comments, and timestamp when they posted the comment
    await fruitCollection.doc(fruitid).collection('comments').doc(docRef.id).set({ 
      'uid': docRef.id,
      'userid': userid,
      'name': name,
      'profilepic': profilepic,
      'comment': comment,
      'createdAt': createdAt 
    });
  }

  Future<List<Address>> readAddressData() async{ //Function to read the address sub-collection in users collection
    final Query addressQuery = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).collection('address'); //Query to get all the billing address info of the user
    List<Address> addressList = [];
    QuerySnapshot snapshot = await addressQuery.get(); //Get all the documents in the cards sub-collection

    snapshot.docs.forEach((document){
      Address address = Address.fromMap(document.data());
      addressList.add(address);
    });
    return addressList;
  }

  Future<void> addAddressData(String userid, String name, String address) async{ 
    var docRef = FirestoreService().userCollection.doc(userid).collection('address').doc();
    //Add new document to the address sub-collection in the users collection
    //The document inserted will include the unique id, name and address
    await userCollection.doc(userid).collection('address').doc(docRef.id).set({ 
      'uid': docRef.id,
      'name': name,
      'address': address
    });
  }

  Future<void> removeAddressData(String addressUid) async{
    //Find the sub-collection address in the users collection and then
    //Locate the document with that matching uid and delete it from the address collection
    await userCollection.doc(FirebaseAuth.instance.currentUser.uid).collection('address').doc(addressUid).delete();
  }
}