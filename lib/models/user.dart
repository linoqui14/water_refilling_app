


import 'controller.dart';
class UserType {
  static const CUSTOMER = 'CUSTOMER';
  static const RIDER = 'RIDER';
  static const List<String> USERTYPES = [CUSTOMER,RIDER];
}
class User extends Controller{
  String username,password,email,firstname,lastname,birthday,deviceID,userType;
  bool isLogin;

  User(
      {
        this.userType = UserType.CUSTOMER,
        this.isLogin = false,
        required this.username,
        required this.password,
        required this.email,
        required this.firstname,
        required this.lastname,
        required this.birthday,
        required this.deviceID
      }) : super(collectionName: 'users',id:Controller.genID(11));

  @override
  Map<String, dynamic> toJson() {

    return {
      'id':super.id,
      'username':username,
      'password':password,
      'email':email,
      'firstname':firstname,
      'birthday':birthday,
      'lastname':lastname,
      'isLogin':isLogin,
      'deviceID':deviceID,
      'userType':userType,

    };
  }

  static User toObject({required Map<String, dynamic> object}){
    User user =  User(
      username: object['username'],
      password: object['password'],
      email: object['email'],
      firstname: object['firstname'],
      lastname: object['lastname'],
      birthday: object['birthday'],
      deviceID: object['deviceID'],
      isLogin: object['isLogin'],
      userType: object['userType'],
    );
    user.id = object['id'];
    return user;
  }
  Future<bool> isAvailable() async{
    var collections = await getThisCollection();
    var usernames = await collections.where('username',isEqualTo: username).get();
    var emails = await collections.where('emails',isEqualTo: email).get();
    if(usernames.docs.isNotEmpty)return false;
    if(emails.docs.isNotEmpty)return false;
    // print(username);
    return true;

  }
  Future<void> logout()async {
    deviceID = "";
    isLogin = false;
    return upsert();
  }




}