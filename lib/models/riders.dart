


import 'controller.dart';

class Rider extends Controller{
  String riderKey,password,deviceID,fullname,stationID;

  bool isLogin;


  Rider(
      {
        required this.riderKey,
        required this.password,
        required this.deviceID,
        required this.fullname,
        required this.isLogin,
        required this.stationID,

      }):super(collectionName: 'riders',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'riderKey':riderKey,
      'password':password,
      'deviceID':deviceID,
      'fullname':fullname,
      'isLogin':isLogin,
      'stationID':stationID,
    };
  }

  static Rider toObject({required Map<String, dynamic> object}){
    Rider rider =  Rider(
      riderKey:object['riderKey'],
      password:object['password'],
      deviceID:object['deviceID'],
      fullname:object['fullname'],
      isLogin:object['isLogin'] ,
      stationID:object['stationID'] ,
    );
    rider.id = object['id'];
    return rider;
  }

  Future<void> logout()async {
    deviceID = "";
    isLogin = false;
    return upsert();
  }

}