class Fruit{
  String uid;
  String image; //Image of the fruit
  String name; //Name of the fruit
  String country; //Country of origin for the fruit
  String category; //The fruit's category
  String price; //Price of the fruit to 2 decimal places
  int favCount; //Number of users that have added this fruit to favourites
  int discount; //The discount of the deal, if any

  Fruit({this.uid, this.image, this.name, this.country, this.category, this.price, this.favCount, this.discount});

  Fruit.fromMap(Map<String, dynamic> data){
    uid = data['uid'];
    image = data['image'];
    name = data['name'];
    country = data['country'];
    category = data['category'];
    price = data['price'];
    favCount = data['favCount'];
    discount = data['discount'];
  }
  //Store fruit categories in a list
  static List<String> categoryList = ['All', 'Deals', 'Boxes', 'Apple', 'Pear', 'Citrus', 'Berry', 'Melon'];
  static String currentCategory = 'All'; //Keep track of what category the user wants to view 
}
