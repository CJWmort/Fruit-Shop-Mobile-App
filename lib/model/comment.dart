import 'package:cloud_firestore/cloud_firestore.dart';

class Comments{ //Comments subcollection will be in the fruits collection
  
  String uid; //unique id of the comment
  String userid; //id of the user's comment
  String profilepic; //profile pic of the user's comment 
  String name; //name of the user's comment
  Timestamp createdAt; //time where the comment is created at
  String comment; //the comment made by the user

  Comments({this.uid, this.userid, this.profilepic, this.name, this.createdAt, this.comment});

  Comments.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    userid = data['userid'];
    profilepic = data['profilepic'];
    name = data['name'];
    createdAt = data['createdAt'];
    comment = data['comment'];
  }
}
