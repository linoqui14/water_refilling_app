

import 'controller.dart';

class Station extends Controller{
  String name,address,password,key,status;


  Station({required this.name,required this.address,required this.password,required this.key,required this.status}):super(collectionName: 'stations',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'name':name,
      'address':address,
      'password':password,
      'key':key,
      'status':status,
    };
  }

  static Station toObject({required Map<String, dynamic> object}){
    Station station =  Station(
      name: object['name'],
      address: object['address'],
      password: object['password'],
      key: object['key'],
      status: object['status'],
    );
    station.id = object['id'];
    return station;
  }


}