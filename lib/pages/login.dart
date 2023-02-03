import 'package:flutter/material.dart';
import 'package:water_refilling_app/models/controller.dart';
import 'package:water_refilling_app/my_widgets/custom_text_button.dart';
import 'package:water_refilling_app/my_widgets/custom_textfield.dart';
import 'package:water_refilling_app/pages/home.dart';
import 'package:water_refilling_app/pages/rider_page.dart';
import 'package:water_refilling_app/tools/variables.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../models/riders.dart';
import '../models/user.dart';



class Login extends StatefulWidget{
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginSate();


}

class _LoginSate extends State<Login>{
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController passwordr = TextEditingController();
  TextEditingController usernamer = TextEditingController();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  @override
  void initState() {
    Controller.getCollection(collectionName: 'riders').then((value) {
      PlatformDeviceId.getDeviceId.then((deviceID) {
        value.where('deviceID',isEqualTo: deviceID!).where('isLogin',isEqualTo: true).get().then((riderd) {
          // print(userd.docs.first.data());
          try{
            Rider rider = Rider.toObject(object: riderd.docs.first.data());
            Navigator.push(context, MaterialPageRoute(builder: (context)=>RiderPage(rider: rider)));
          }catch(e){
            Controller.getCollection(collectionName: 'users').then((value) {
              PlatformDeviceId.getDeviceId.then((deviceID) {
                value.where('deviceID',isEqualTo: deviceID!).where('isLogin',isEqualTo: true).get().then((userd) {
                  // print(userd.docs.first.data());
                  try{
                    User user = User.toObject(object: userd.docs.first.data());
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: user)));
                  }catch(e){
                    print(e);
                  }
                });
              });

            });
          }
        });
      });

    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: WillPopScope(
        onWillPop: () { return Future.value(false); },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery. of(context). size. height,
              alignment: Alignment.center,
              color: Colors.white,
              child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                        alignment: Alignment.bottomCenter,
                        height: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.blue,
                                  Colors.white,
                                  Colors.white,
                                  Colors.white,

                                ],

                                begin:Alignment.bottomCenter,
                                end: Alignment.topCenter
                            )
                        ),
                        child: Opacity(child: Image.asset('assets/img/background.jpg'),opacity: 0.5,)
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("WRSA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 100,color: Colors.blue),),
                              Text("Water Refilling Station App",style: TextStyle(fontWeight: FontWeight.w100,fontSize: 15),),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomTextField(
                                  icon: Icons.person,
                                  color: Colors.blue,
                                  hint: "Username",
                                  controller: username
                              ),
                              CustomTextField(
                                  obscureText:true ,
                                  color: Colors.blue,
                                  hint: "password",
                                  controller: password
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: CustomTextButton(
                                  onPressed: (){
                                    PlatformDeviceId.getDeviceId.then((deviceID) {
                                      Controller.getCollection(collectionName: 'users').then((value) {
                                        value.where('username',isEqualTo: username.text).where('password',isEqualTo: password.text).get().then((users){
                                          try{
                                            User user = User.toObject(object: users.docs.first.data());
                                            user.isLogin = true;
                                            user.deviceID = deviceID!;
                                            user.upsert();
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(user: user)));
                                          }catch(e){
                                            //-------------------------------------------------------------------------
                                            Controller.getCollection(collectionName: 'riders').then((value) {
                                              value.where('riderKey',isEqualTo: username.text).where('password',isEqualTo: password.text).get().then((riders){
                                                try{
                                                  Rider rider = Rider.toObject(object: riders.docs.first.data());
                                                  rider.isLogin = true;
                                                  rider.deviceID = deviceID!;
                                                  rider.upsert();
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => RiderPage(rider: rider)));
                                                }catch(e){

                                                  Fluttertoast.showToast(
                                                      msg: "User not found!",
                                                      toastLength: Toast.LENGTH_LONG,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.red,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0
                                                  );
                                                }

                                              });
                                            });
                                            //-------------------------------------------------------------------------
                                          }

                                        });
                                      });
                                    });

                                  },
                                  color: MyColors.darkBlue,
                                  height: 55,
                                  // style: TextStyle(fontWeight: FontWeight.,fontSize: 20,color: Colors.white),
                                  text: "Login",
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account yet?",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 12),),
                              GestureDetector(
                                  onTap: (){
                                    bool isValid = true;
                                    Tools.statefulDialog(
                                        onPop: ()async=>true,
                                        context: context,
                                        builder: (context,registerState){
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              height: Tools.getDeviceHeight(context)*.7,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("REGISTRATION",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 10),
                                                    alignment: Alignment.bottomLeft,

                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Account",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.blue)),
                                                        Divider(thickness: 0.5,color: Colors.blue,),
                                                        CustomTextField(
                                                            onChange: (value){

                                                            },
                                                            icon: Icons.email_rounded,
                                                            padding: EdgeInsets.only(top: 10),
                                                            color: Colors.blue,
                                                            hint: 'email',
                                                            controller: email
                                                        ),
                                                        CustomTextField(
                                                            onChange: (value){

                                                            },
                                                            icon: Icons.person,
                                                            padding: EdgeInsets.only(top: 10),
                                                            color: Colors.blue,
                                                            hint: 'Username',
                                                            controller: usernamer
                                                        ),
                                                        CustomTextField(
                                                            onChange: (value){

                                                            },
                                                            obscureText: true,
                                                            padding: EdgeInsets.only(top: 10),
                                                            color: Colors.blue,
                                                            hint: 'Password',
                                                            controller: passwordr
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(thickness: 2,color: Colors.blue,),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 10,),
                                                    alignment: Alignment.bottomLeft,

                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Personal Information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.blue)),
                                                        Divider(thickness: 0.5,color: Colors.blue,),
                                                        CustomTextField(
                                                            onChange: (value){

                                                            },
                                                            icon: Icons.person,
                                                            padding: EdgeInsets.only(top: 10),
                                                            color: Colors.blue,
                                                            hint: 'Firstname',
                                                            controller: firstname
                                                        ),
                                                        CustomTextField(
                                                            onChange: (value){

                                                            },
                                                            icon: Icons.person,
                                                            padding: EdgeInsets.only(top: 10),
                                                            color: Colors.blue,
                                                            hint: 'Lastname',
                                                            controller: lastname
                                                        ),
                                                        // CustomTextField(
                                                        //     icon: Icons.person,
                                                        //     padding: EdgeInsets.only(top: 10),
                                                        //     color: Colors.blue,
                                                        //     hint: 'Username',
                                                        //     controller: username
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.only(top: 15)),
                                                  CustomTextButton(

                                                    text: "Sign Up",
                                                    color: MyColors.darkBlue,
                                                    width: double.infinity,
                                                    onPressed: (){

                                                      try{
                                                        if(usernamer.text.isEmpty||passwordr.text.isEmpty||firstname.text.isEmpty||lastname.text.isEmpty||email.text.isEmpty)
                                                        {
                                                          Fluttertoast.showToast(
                                                              msg: "Please fill all the required fields.",
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.CENTER,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0
                                                          );
                                                          return;
                                                        }
                                                        User user = User(username: usernamer.text,password: passwordr.text,firstname: firstname.text,lastname: lastname.text,birthday: "", email: email.text,deviceID: "");
                                                        user.isAvailable().then((value) {
                                                          if(value) {
                                                            user.upsert();
                                                            Navigator.pop(context);
                                                            Fluttertoast.showToast(
                                                                msg: "Successfully Registered",
                                                                toastLength: Toast.LENGTH_LONG,
                                                                gravity: ToastGravity.CENTER,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.blue,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0
                                                            );
                                                            return;
                                                          }
                                                          Fluttertoast.showToast(
                                                              msg: "Username or email is already in used.",
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.CENTER,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0
                                                          );

                                                        });
                                                      }
                                                      catch(e){
                                                        print("ERROR");
                                                      }



                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    );
                                  },
                                  child: Text("  SIGN UP",style: TextStyle(fontWeight: FontWeight.bold,color: MyColors.darkBlue,fontSize: 12))
                              )
                            ],
                          ),
                        )

                      ],
                    ),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }

}