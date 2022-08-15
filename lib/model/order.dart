import 'package:cloud_firestore/cloud_firestore.dart';

class Order{ //Orders subcollection will be in the users collection
  
  String uid; //get the unique id of the order
  String address; //delivery address of the order
  String phone; //person to contact for the order
  String startDate; //the date the order was made
  String date; //arrival date of the order
  String time; //arrival time of the order
  String paymentType; //either cash or card
  String totalPaid; //final total amount paid for the order
  String status; //status of the order, delivering / reached / cancelled
  Timestamp createdAt; //timestamp of when the order is placed

  Order({this.uid, this.address, this.phone, this.startDate, this.date, this.time, this.paymentType, this.totalPaid, this.status, this.createdAt});

  Order.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    address = data['address'];
    phone = data['phone'];
    startDate = data['startDate'];
    date = data['date'];
    time = data['time'];
    paymentType = data['paymentType'];
    totalPaid = data['totalPaid'];
    status = data['status'];
    createdAt = data['createdAt'];
  }
}
