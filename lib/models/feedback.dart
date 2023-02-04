


import 'controller.dart';

class FeedBack extends Controller{
  String comment,userID,stationID,date;
  int star;
  bool nameVisible;

  FeedBack(
      {
        required this.comment,
        required this.userID,
        required this.stationID,
        required this.date,
        required this.star,
        required this.nameVisible
      }):super(collectionName: 'feedbacks',id: Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'comment':comment,
      'userID':userID,
      'stationID':stationID,
      'date':date,
      'star':star,
      'nameVisible':nameVisible,
    };
  }

  static FeedBack toObject({required Map<String, dynamic> object}){
    FeedBack feedback =  FeedBack(
        comment: object['comment'],
        userID: object['userID'],
        date: object['date'],
        stationID: object['stationID'],
        star: object['star'],
        nameVisible: object['nameVisible']
    );
    feedback.id = object['id'];
    return feedback;
  }
}