
import 'controller.dart';

class Stock extends Controller{
  int stock,sold;

  Stock({required this.stock,required this.sold}): super(collectionName: 'stocks',id:Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':super.id,
      'stock':stock,
      'sold':sold,
    };
  }

  static Stock toObject({required Map<String, dynamic> object}){
    Stock stock =  Stock(
      stock: object['stock'],
      sold: object['sold'],
    );
    stock.id = object['id'];
    return stock;
  }
}