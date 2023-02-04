


import 'package:water_refilling_app/models/controller.dart';
class OrderType{
  static const DELIVERY = "DELIVERY";
  static const PICKUP = "PICKUP";
  static const List<String> ordertTypes = [DELIVERY,PICKUP];
}

class OrderStatus{
  static const ACCEPTED = "ACCEPTED";
  static const PENDING = "PENDING";
  static const DELIVERING = "DELIVERING";
  static const DELIVERED = "DELIVERED";
  static const COMPLETE = "COMPLETE";
}

class PaymentType{
  static const COD = "COD";
  static const ATSTATION = "ATSTATION";
  static const List<String> paymentTypes = [COD,ATSTATION];
}


class OrderDetail extends Controller{
  String orderType,paymentType,userID,status,stationID,riderID,userAddress,timeCheckOut,timeDelivered;
  bool isNotified;
  int totalPrice,totalItems;
  double lat,long;
  OrderDetail(
      {
        required this.orderType,
        required this.paymentType,
        required this.userID,
        required this.totalItems,
        required this.totalPrice,
        required this.status,
        required this.stationID,
        required this.riderID,
        required this.userAddress,
        required this.lat,
        required this.long,
        required this.timeCheckOut,
        this.timeDelivered = "",
        this.isNotified = false,
      }):super(collectionName: 'orders',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'orderType':orderType,
      'paymentType':paymentType,
      'userID':userID,
      'totalItems':totalItems,
      'totalPrice':totalPrice,
      'status':status,
      'stationID':stationID,
      'riderID':riderID,
      'userAddress':userAddress,
      'lat':lat,
      'long':long,
      'timeDelivered':timeDelivered,
      'isNotified':isNotified,
      'timeCheckOut':timeCheckOut,
    };
  }

  static OrderDetail toObject({required Map<String, dynamic> object}){
    OrderDetail order =  OrderDetail(
      userID: object['userID'],
      orderType: object['orderType'],
      paymentType: object['paymentType'],
      totalItems: object['totalItems'],
      totalPrice: object['totalPrice'],
      status: object['status'],
      stationID: object['stationID'],
      riderID: object['riderID'],
      userAddress: object['userAddress'],
      lat: object['lat'],
      long: object['long'],
      isNotified: object['isNotified'],
      timeCheckOut: object['timeCheckOut'],
      timeDelivered: object['timeDelivered'],
    );
    order.id = object['id'];
    return order;
  }


}