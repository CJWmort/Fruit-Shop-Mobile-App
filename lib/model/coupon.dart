class Coupon{ //Coupon subcollection will be in the users collection
  
  String uid; //unique id of the coupon
  String name; //name of the coupon
  String desc; //description of the coupon
  int value; //value of the coupon

  Coupon({this.uid, this.name, this.desc, this.value});

  Coupon.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    name = data['name'];
    desc = data['description'];
    value = data['value'];
  }
}
