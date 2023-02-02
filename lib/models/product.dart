

import 'package:cloud_firestore/cloud_firestore.dart';
import 'controller.dart';

class Product extends Controller{
  static final _db = FirebaseFirestore.instance;
  String name,stationID,stockID,description,imgURL;
  int price;

  Product({required this.name,required this.stationID,required this.description,required this.price,required this.stockID,required this.imgURL}): super(collectionName:'products',id:Controller.genID(10)  );

  @override
  Map<String, dynamic> toJson() {

    return {
      'id':super.id,
      'name':name,
      'stationID':stationID,
      'description':description,
      'price':price,
      'stockID':stockID,
      'imgURL':imgURL,
    };
  }

  static Product toObject({required Map<String, dynamic> object}){
    Product product =  Product(
      name: object['name'],
      stationID: object['stationID'],
      price: object['price'],
      description: object['description'],
      stockID: object['stockID'],
      imgURL: object['imgURL'],
    );
    product.id = object['id'];
    return product;
  }


}