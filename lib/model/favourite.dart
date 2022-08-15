class Favourite{ //Favourites subcollection will be in the users collection
  
  String fruitid; //uid of the fruit that is favourited
  String userid; //uid of the user that favourited the fruit
  String name; //name of the favourited fruit
  String image; //image of the favourited fruit

  Favourite({this.fruitid, this.userid, this.name, this.image});

  Favourite.fromMap(Map<String, dynamic> data){
    fruitid = data['fruitid'];
    userid = data['userid'];
    name = data['name'];
    image = data['image'];
  }
}
