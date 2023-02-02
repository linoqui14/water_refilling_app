

import 'package:water_refilling_app/models/controller.dart';

class UserAddress extends Controller{
  String address,userID;
  double lat,long;


  UserAddress({required this.address,required this.userID,required this.lat,required this.long}):super(collectionName: 'user_addresses',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'address':address,
      'userID':userID,
      'lat':lat,
      'long':long
    };
  }

  static UserAddress toObject({required Map<String, dynamic> object}){
    UserAddress userAddress =  UserAddress(
      userID: object['userID'],
      address: object['address'],
      lat: object['lat'],
      long: object['long'],
    );
    userAddress.id = object['id'];
    return userAddress;
  }



}