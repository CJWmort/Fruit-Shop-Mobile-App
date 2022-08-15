class Cards{ //Card subcollection will be in the users collection
  
  String uid; //unique id of the card
  String name; //name of the card holder
  String number; //card number
  String cvv; //cvv of the card
  String expiry; //expiry of the card

  Cards({this.uid, this.name, this.number, this.cvv, this.expiry});

  Cards.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    name = data['name'];
    number = data['number'];
    cvv = data['cvv'];
    expiry = data['expiry'];
  }
}
