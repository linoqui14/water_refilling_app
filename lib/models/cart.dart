




import 'package:water_refilling_app/models/controller.dart';

class CartItem extends Controller{
  String userID,productID,status,orderID,stationID;
  int totalCartItemQuantity,totalCartItemValue;

  CartItem({required this.userID,required this.productID,required this.status,this.totalCartItemQuantity = 0,this.totalCartItemValue = 0,this.orderID="",required this.stationID}):super(collectionName: 'cart_items',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'userID':userID,
      'productID':productID,
      'status':status,
      'totalCartItemQuantity':totalCartItemQuantity,
      'totalCartItemValue':totalCartItemValue,
      'orderID':orderID,
      'stationID':stationID,

    };
  }
  static CartItem toObject({required Map<String, dynamic> object}){
    CartItem cart =  CartItem(
      userID: object['userID'],
      productID: object['productID'],
      status: object['status'],
      totalCartItemQuantity: object['totalCartItemQuantity'],
      totalCartItemValue: object['totalCartItemValue'],
      orderID: object['orderID'],
      stationID: object['stationID'],
    );
    cart.id = object['id'];
    return cart;
  }

}