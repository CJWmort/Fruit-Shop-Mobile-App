class Address{ //Address subcollection will be in the users collection
  
  String uid; //unique id of the address
  String name; //name of the address
  String address; //address of the user

  Address({this.uid, this.name, this.address});

  Address.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    name = data['name'];
    address = data['address'];
  }
}
