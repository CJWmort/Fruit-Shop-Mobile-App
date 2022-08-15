class Cart{ //Cart subcollection will be in the users collection
  
  String fruitid; //uid of the fruit in the cart
  String userid; //uid of the user that the cart belongs to
  String name; //name of the fruit in the cart
  String image; //image of the fruit in the cart
  int quantity; //quantity of that specific fruit in the cart
  String price; //price of the fruit

  Cart({this.fruitid, this.userid, this.name, this.image, this.quantity, this.price});

  Cart.fromMap(Map<String, dynamic> data){
    fruitid = data['fruitid'];
    userid = data['userid'];
    name = data['name'];
    image = data['image'];
    quantity = data['quantity'];
    price = data['price'];
  }

  static int cartSize = 0;
}
