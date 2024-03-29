import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:water_refilling_app/main.dart';
import 'package:water_refilling_app/models/station.dart';
import 'package:water_refilling_app/my_widgets/custom_text_button.dart';
import 'package:water_refilling_app/my_widgets/custom_textfield.dart';
import 'package:lottie/lottie.dart' as lot;
import 'package:water_refilling_app/pages/station.dart';
import '../models/cart.dart';
import '../models/controller.dart';
import '../models/order_detail.dart';
import '../models/product.dart';
import '../models/stock.dart';
import '../models/user.dart';
import '../models/user_address.dart';
import '../tools/variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.user});
  final User user;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  TextEditingController search = TextEditingController();
  int backCounter = 0;
  late TabController tabController;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late NotificationDetails platformChannelSpecifics;
  late Function(Function()) _updateNavigation;


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }



  @override
  void initState() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'findable',
      'findable-tag',
      importance: Importance.max,
      priority: Priority.high,

    );
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,

    );
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (value){
          _updateNavigation((){
            tabController.index=2;
          });
        }
    );

    tabController = new TabController(length: 4, vsync: this);
    Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'userID', value: widget.user.id).listen((event) {
      int count = 0;
      for(var orderd in event.docs){
        OrderDetail order = OrderDetail.toObject(object: orderd.data());
        switch(order.status){
          case OrderStatus.ACCEPTED:
            Controller.getCollectionWhere(collectionName: 'stations', field: 'id', value: order.stationID).then((value) {
              Station station = Station.toObject(object:value.docs.first.data());
              flutterLocalNotificationsPlugin.show(count, "Water Refiling Station", "${station.name} just accepted your order", platformChannelSpecifics);
              _updateNavigation((){
                tabController.index=2;
              });

            });
            break;
          case OrderStatus.DELIVERING:
            Controller.getCollectionWhere(collectionName: 'stations', field: 'id', value: order.stationID).then((value) {
              Station station = Station.toObject(object:value.docs.first.data());
              flutterLocalNotificationsPlugin.show(count, "Water Refiling Station", "${station.name} is delivering your order", platformChannelSpecifics);
              _updateNavigation((){
                tabController.index=2;
              });

            });

            break;
          case OrderStatus.DELIVERED:
            if(!order.isNotified){
              Controller.getCollectionWhere(collectionName: 'stations', field: 'id', value: order.stationID).then((value) {
                Station station = Station.toObject(object:value.docs.first.data());
                flutterLocalNotificationsPlugin.show(count, "Water Refiling Station", "${station.name} just delivered your order", platformChannelSpecifics);
                order.isNotified = true;

                order.upsert();
                _updateNavigation((){
                  tabController.index=2;
                });

              });
            }


            break;
        }
        count++;
      }
    });



    super.initState();
  }
  Future<bool> onBack(){

    if(backCounter==2){
      double slideValue = 0;
      Tools.statefulDialog(
          context: context,
          builder: (context,onUpdate){
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Tools.radiusSize)
                ),

                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Slide to confirm.',style:GoogleFonts.comfortaa(fontWeight: FontWeight.bold ,)),
                    SliderTheme(
                      data: SliderThemeData(

                        activeTrackColor: Colors.black54,
                        inactiveTrackColor: Colors.black,
                        thumbColor: Color(0xff333333),
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 20),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                        trackHeight: 38,
                        trackShape: RoundedRectSliderTrackShape(),
                        rangeTrackShape: RoundedRectRangeSliderTrackShape(),
                        rangeThumbShape: RoundRangeSliderThumbShape(),


                      ),

                      child: Slider(
                          label: 'Slide to confirm.',
                          // activeColor: Colors.black54,
                          // inactiveColor: Colors.black,
                          onChangeStart: (value){
                            print(value);
                          },
                          onChangeEnd: (value){
                            if(value == 1.0){
                              widget.user.logout().whenComplete((){
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Login()),
                                        (route) => false
                                );
                              });

                            }
                            else{
                              onUpdate((){
                                slideValue = 0;
                              });
                            }
                          },
                          value: slideValue,
                          onChanged: (value){
                            onUpdate((){
                              slideValue = value;
                            });
                          }
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          onPop: ()async=>true
      );
      backCounter = 0;
    }
    if(backCounter==1){
      Fluttertoast.showToast(
          msg: "Press one last more to logout",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 12
      );
    }
    backCounter++;

    return Future.value(false);
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onBack,
      child: Scaffold(
        backgroundColor:  Color(0xffF5F5F5),
        body: SafeArea(
          child: Container(
            height: Tools.getDeviceHeight(context),
            width: Tools.getDeviceWidth(context),

            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 35,
                            height: 35,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.09),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                    offset: Offset(1, 3), // changes position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(13))
                            ),
                            child: Text(widget.user.firstname[0].toUpperCase()+widget.user.firstname[1].toLowerCase()),
                          ),
                          onTap: (){
                            TextEditingController passwordr = TextEditingController(text: widget.user.password);
                            TextEditingController usernamer = TextEditingController(text: widget.user.username);
                            TextEditingController firstname = TextEditingController(text: widget.user.firstname);
                            TextEditingController lastname = TextEditingController(text: widget.user.lastname);
                            TextEditingController email = TextEditingController(text: widget.user.email);
                            TextEditingController address = TextEditingController(text: widget.user.email);

                            Tools.statefulDialog(
                                onPop: ()async=>true,
                                context: context,
                                builder: (context,registerState){
                                  return Dialog(
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      width:Tools.getDeviceWidth(context) ,
                                      height: Tools.getDeviceHeight(context)*.75,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                      child: Scrollbar(

                                        thickness: 10, //width of scrollbar
                                        radius: Radius.circular(20),
                                        // thumbVisibility: true, //always show scrollbar
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Your Account",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                              Container(
                                                margin: EdgeInsets.symmetric(vertical: 10),
                                                alignment: Alignment.bottomLeft,

                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Account",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.blue)),
                                                    Divider(thickness: 0.5,color: Colors.blue,),
                                                    CustomTextField(
                                                        enableFloat: true,
                                                        onChange: (value){

                                                        },
                                                        icon: Icons.email_rounded,
                                                        padding: EdgeInsets.only(top: 10),
                                                        color: Colors.blue,
                                                        hint: 'email',
                                                        controller: email
                                                    ),
                                                    CustomTextField(
                                                        enableFloat: true,
                                                        onChange: (value){

                                                        },
                                                        icon: Icons.person,
                                                        padding: EdgeInsets.only(top: 10),
                                                        color: Colors.blue,
                                                        hint: 'Username',
                                                        controller: usernamer
                                                    ),
                                                    CustomTextField(
                                                        enableFloat: true,
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
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: CustomTextField(
                                                              enableFloat: true,
                                                              onChange: (value){

                                                              },
                                                              icon: Icons.person,
                                                              padding: EdgeInsets.only(top: 10),
                                                              color: Colors.blue,
                                                              hint: 'Firstname',
                                                              controller: firstname
                                                          ),
                                                        ),
                                                        Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                                                        Expanded(
                                                          child: CustomTextField(
                                                              enableFloat: true,
                                                              onChange: (value){

                                                              },
                                                              icon: Icons.person,
                                                              padding: EdgeInsets.only(top: 10),
                                                              color: Colors.blue,
                                                              hint: 'Lastname',
                                                              controller: lastname
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    StreamBuilder(
                                                        stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: widget.user.id),
                                                        builder: (context, snapshot) {
                                                          if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                                          if(snapshot.data!.docs.isEmpty){
                                                            _determinePosition().then((value) {
                                                              http.get(Uri.parse("https://geocode.maps.co/reverse?lat=${value.latitude}&lon=${value.longitude}")).then((response) {
                                                                var json = jsonDecode(response.body);
                                                                address.text = json['display_name'];
                                                                UserAddress useAddress = UserAddress(address: address.text, userID: widget.user.id, lat: value.latitude, long: value.longitude);
                                                                useAddress.upsert();
                                                              });
                                                            });
                                                          }
                                                          UserAddress useAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());
                                                          address.text = useAddress.address;
                                                          return CustomTextField(
                                                            style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.black54,fontSize: 8,height: 1),
                                                            minLines: 3,
                                                            padding: EdgeInsets.only(top: 10),
                                                            readonly: true,
                                                            enableFloat: true,
                                                            icon: Icons.map_outlined,
                                                            color: Colors.blue,
                                                            hint: "Address",
                                                            controller: address,
                                                            suffix:  CustomTextButton(
                                                              onPressed: (){

                                                                LatLng selectedLocation = LatLng(useAddress.lat,  useAddress.long);
                                                                MapController map = MapController();

                                                                Tools.statefulDialog(
                                                                    context: context,
                                                                    builder: (context,updateMap){
                                                                      if(address.text.isNotEmpty&&address.text.isEmpty){
                                                                        address.text = address.text;
                                                                        http.get(Uri.parse("https://geocode.maps.co/search?q=${address.text}")).then((value) {
                                                                          var json = jsonDecode(value.body);
                                                                          // 1128 kauswagan cagayan de Oro city
                                                                          double lat = double.parse(json.first['lat']);
                                                                          double long = double.parse(json.first['lon']);
                                                                          updateMap((){
                                                                            selectedLocation = LatLng(lat, long);
                                                                            map.move(selectedLocation, 18);
                                                                          });

                                                                        });
                                                                      }
                                                                      return Dialog(
                                                                        insetPadding: EdgeInsets.zero,
                                                                        backgroundColor: Colors.transparent,
                                                                        child: Container(
                                                                          padding: EdgeInsets.all(20),
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.all(Radius.circular(30))
                                                                          ),
                                                                          height: 600,
                                                                          width: 500,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text("Click on location to select address.",style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 15,height: 1),),
                                                                              Padding(padding: EdgeInsets.only(bottom: 20)),
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                                                                child: SizedBox(
                                                                                  width: 500,
                                                                                  height: 300,
                                                                                  child: FlutterMap(
                                                                                    mapController: map,
                                                                                    options: MapOptions(
                                                                                      scrollWheelVelocity: 0.0,
                                                                                      keepAlive: true,
                                                                                      onTap: (tap,latlong){
                                                                                        http.get(Uri.parse("https://geocode.maps.co/reverse?lat=${latlong.latitude}&lon=${latlong.longitude}")).then((value) {
                                                                                          var json = jsonDecode(value.body);
                                                                                          updateMap((){
                                                                                            selectedLocation = latlong;
                                                                                            map.move(selectedLocation, 18);
                                                                                            address.text = json['display_name'];
                                                                                          });

                                                                                        });
                                                                                      },
                                                                                      center: selectedLocation,
                                                                                      zoom: 15,
                                                                                    ),
                                                                                    // nonRotatedChildren: [
                                                                                    //   AttributionWidget.defaultWidget(
                                                                                    //     source: 'OpenStreetMap contributors',
                                                                                    //     onSourceTapped: null,
                                                                                    //   ),
                                                                                    // ],
                                                                                    children: [

                                                                                      TileLayer(

                                                                                        urlTemplate: 'https://api.mapbox.com/styles/v1/linoqui14/cldkeehky000001og36ot0c67/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsMnRsaG1ndTA1aGsza25vMDRocjE5YXoifQ.RyE1w-7zHamlAuYrOSwO0Q',
                                                                                        additionalOptions: {
                                                                                          'accessToken':'sk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsZGw3MG5zODI4b3IzcHFwamhjbjZ2NzAifQ.Y_8z_gTuWOYp2Xyf5whNMw',
                                                                                          'id': 'mapbox.mapbox-streets-v8'
                                                                                        },
                                                                                        // userAgentPackageName: 'com.example.app',
                                                                                      ),
                                                                                      MarkerLayer(
                                                                                        markers: [
                                                                                          Marker(
                                                                                            point: selectedLocation,
                                                                                            width: 15,
                                                                                            height: 15,
                                                                                            builder: (context) => Icon(Icons.place_rounded,color: Colors.blue,),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(padding: EdgeInsets.only(top: 10)),
                                                                              Center(child: Text("or",style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 15,height: 1),)),
                                                                              Padding(padding: EdgeInsets.only(top: 10)),
                                                                              CustomTextField(

                                                                                icon: Icons.place_outlined,
                                                                                enableFloat: false,
                                                                                color: Colors.blue,
                                                                                hint: "Type address",
                                                                                controller: address,
                                                                                suffix: CustomTextButton(
                                                                                  style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.blue,fontSize: 15,height: 1),
                                                                                  color: Colors.transparent,
                                                                                  onPressed: (){
                                                                                    http.get(Uri.parse("https://geocode.maps.co/search?q=${address.text}")).then((value) {
                                                                                      var json = jsonDecode(value.body);
                                                                                      // 1128 kauswagan cagayan de Oro city
                                                                                      double lat = double.parse(json.first['lat']);
                                                                                      double long = double.parse(json.first['lon']);
                                                                                      selectedLocation = LatLng(lat, long);
                                                                                      useAddress.lat = lat;
                                                                                      useAddress.long = long;
                                                                                      updateMap((){
                                                                                        selectedLocation = LatLng(lat, long);
                                                                                        map.move(selectedLocation, 18);
                                                                                      });

                                                                                    });
                                                                                  },
                                                                                  rTopLeft: 0,
                                                                                  rBottomLeft: 0,
                                                                                  height: 50,
                                                                                  width: 50,
                                                                                  text: "Find",
                                                                                ),
                                                                              ),
                                                                              Padding(padding: EdgeInsets.only(top: 10)),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  CustomTextButton(
                                                                                    onPressed: (){
                                                                                      if(address.text.isEmpty)return;
                                                                                      setState(() {
                                                                                        address.text = address.text.toTitleCase();
                                                                                        useAddress.address = address.text;

                                                                                        useAddress.upsert();
                                                                                        Navigator.pop(context);
                                                                                      });
                                                                                    },
                                                                                    color: Colors.blue,
                                                                                    text: "Confirm",
                                                                                  ),
                                                                                  CustomTextButton(
                                                                                    padding: EdgeInsets.zero,
                                                                                    style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 15,height: 1),
                                                                                    onPressed: (){
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    color: Colors.transparent,
                                                                                    text: "Cancel",
                                                                                  ),
                                                                                ],
                                                                              )

                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    onPop: ()async=>true
                                                                );
                                                              },
                                                              style: GoogleFonts.notoSansNKo(fontSize: 10,height: 1,color: Colors.blue),
                                                              color: Colors.transparent,
                                                              height: 50,
                                                              width: 130,
                                                              rTopLeft: 0,
                                                              rBottomLeft: 0,
                                                              icon: Icon(Icons.place_rounded,color: Colors.blue,),
                                                              text: "Pin Location",
                                                            ),
                                                          );
                                                        }
                                                    ),

                                                    CustomTextButton(

                                                      text: "Update",
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
                                                          widget.user.password = passwordr.text;
                                                          widget.user.username = usernamer.text;
                                                          widget.user.firstname = firstname.text;
                                                          widget.user.lastname = lastname.text;
                                                          widget.user.email = email.text;
                                                          widget.user.upsert().then((value) {
                                                            Fluttertoast.showToast(
                                                                msg: "Successfully updated",
                                                                toastLength: Toast.LENGTH_SHORT,
                                                                gravity: ToastGravity.CENTER,
                                                                timeInSecForIosWeb: 1,
                                                                backgroundColor: Colors.blue,
                                                                textColor: Colors.white,
                                                                fontSize: 16.0
                                                            );
                                                          });
                                                          // User user = User(username: usernamer.text,password: passwordr.text,firstname: firstname.text,lastname: lastname.text,birthday: "", email: email.text,deviceID: "");

                                                        }
                                                        catch(e){
                                                          print("ERROR");
                                                        }



                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.only(top: 0)),

                                              // CustomTextField(
                                              //     hint: "",
                                              //     controller: controller)
                                              // Builder(
                                              //     builder: (context) {
                                              //       TextEditingController address = TextEditingController();
                                              //       LatLng selectedLocation = LatLng(8.499010,  124.629230);
                                              //       MapController map = MapController();
                                              //       late Function(Function()) _updateMapOnly;
                                              //       return StatefulBuilder(
                                              //           builder: (context,updateMap) {
                                              //             return StreamBuilder(
                                              //                 stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: widget.user.id),
                                              //                 builder: (context, snapshot) {
                                              //                   if(!snapshot.hasData)return Center();
                                              //                   if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                              //                   late UserAddress userAddress;
                                              //                   if(snapshot.data!.docs.isEmpty){
                                              //
                                              //                     _determinePosition().then((value) {
                                              //                       LatLng latlong = LatLng(value.latitude, value.longitude);
                                              //                       http.get(Uri.parse("https://geocode.maps.co/reverse?lat=${latlong.latitude}&lon=${latlong.longitude}")).then((value) {
                                              //                         var json = jsonDecode(value.body);
                                              //                         userAddress = UserAddress(address: json['display_name'], userID: widget.user.id, lat: latlong.latitude, long: latlong.longitude);
                                              //                         userAddress.upsert().then((value) {
                                              //                           updateMap((){
                                              //                             selectedLocation = latlong;
                                              //                             map.move(selectedLocation, 18);
                                              //                             address.text = json['display_name'];
                                              //                           });
                                              //                         });
                                              //
                                              //
                                              //                       });
                                              //                     });
                                              //                   }
                                              //                   else{
                                              //                     userAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());
                                              //                     address.text = userAddress.address;
                                              //                   }
                                              //
                                              //                   return Container(
                                              //                     // padding: EdgeInsets.all(20),
                                              //                     decoration: BoxDecoration(
                                              //                         color: Colors.white,
                                              //                         borderRadius: BorderRadius.all(Radius.circular(10))
                                              //                     ),
                                              //                     height: 400,
                                              //                     width: double.infinity,
                                              //                     child: Column(
                                              //                       crossAxisAlignment: CrossAxisAlignment.start,
                                              //                       children: [
                                              //                         Text("Click on location to select address.",style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 10,height: 1),),
                                              //                         // Padding(padding: EdgeInsets.only(bottom: 20)),
                                              //                         StatefulBuilder(
                                              //                             builder: (context,updateMapOnly) {
                                              //                               _updateMapOnly = updateMapOnly;
                                              //                               return ClipRRect(
                                              //                                 borderRadius: BorderRadius.all(Radius.circular(25)),
                                              //                                 child: SizedBox(
                                              //                                   width: 500,
                                              //                                   height: 200,
                                              //                                   child: FlutterMap(
                                              //
                                              //                                     mapController: map,
                                              //                                     options: MapOptions(
                                              //                                       onMapReady: (){
                                              //                                         _updateMapOnly((){
                                              //                                           selectedLocation = LatLng(userAddress.lat, userAddress.long);
                                              //                                           map.move(LatLng(userAddress.lat, userAddress.long), 18);
                                              //                                         });
                                              //
                                              //                                       },
                                              //                                       scrollWheelVelocity: 0.0001,
                                              //                                       keepAlive: true,
                                              //                                       onTap: (tap,latlong){
                                              //                                         http.get(Uri.parse("https://geocode.maps.co/reverse?lat=${latlong.latitude}&lon=${latlong.longitude}")).then((value) {
                                              //                                           var json = jsonDecode(value.body);
                                              //                                           _updateMapOnly((){
                                              //                                             selectedLocation = latlong;
                                              //                                             map.move(selectedLocation, 18);
                                              //                                             address.text = json['display_name'];
                                              //                                           });
                                              //
                                              //                                         });
                                              //                                       },
                                              //                                       center: selectedLocation,
                                              //                                       zoom: 15,
                                              //                                     ),
                                              //                                     // nonRotatedChildren: [
                                              //                                     //   AttributionWidget.defaultWidget(
                                              //                                     //     source: 'OpenStreetMap contributors',
                                              //                                     //     onSourceTapped: null,
                                              //                                     //   ),
                                              //                                     // ],
                                              //                                     children: [
                                              //
                                              //                                       TileLayer(
                                              //
                                              //                                         urlTemplate: "https://api.mapbox.com/styles/v1/linoqui14/cldl76aim002v01o4pkskyxyd/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsMnRsaG1ndTA1aGsza25vMDRocjE5YXoifQ.RyE1w-7zHamlAuYrOSwO0Q",
                                              //                                         additionalOptions: {
                                              //                                           'accessToken':'sk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsZGw3MG5zODI4b3IzcHFwamhjbjZ2NzAifQ.Y_8z_gTuWOYp2Xyf5whNMw',
                                              //                                           'id': 'mapbox.mapbox-streets-v8'
                                              //                                         },
                                              //                                         // userAgentPackageName: 'com.example.app',
                                              //                                       ),
                                              //                                       MarkerLayer(
                                              //                                         markers: [
                                              //                                           Marker(
                                              //                                             point: selectedLocation,
                                              //                                             width: 15,
                                              //                                             height: 15,
                                              //                                             builder: (context) => Icon(Icons.place_rounded,color: Colors.blue,),
                                              //                                           ),
                                              //                                         ],
                                              //                                       ),
                                              //                                     ],
                                              //                                   ),
                                              //                                 ),
                                              //                               );
                                              //                             }
                                              //                         ),
                                              //                         Padding(padding: EdgeInsets.only(top: 10)),
                                              //                         // Center(child: Text("or",style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 15,height: 1),)),
                                              //                         Padding(padding: EdgeInsets.only(top: 10)),
                                              //                         CustomTextField(
                                              //
                                              //                           icon: Icons.place_outlined,
                                              //                           enableFloat: false,
                                              //                           color: Colors.blue,
                                              //                           hint: "Type address",
                                              //                           controller: address,
                                              //                           suffix: CustomTextButton(
                                              //                             style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.blue,fontSize: 15,height: 1),
                                              //                             color: Colors.transparent,
                                              //                             onPressed: (){
                                              //                               http.get(Uri.parse("https://geocode.maps.co/search?q=${address.text}")).then((value) {
                                              //                                 var json = jsonDecode(value.body);
                                              //                                 // 1128 kauswagan cagayan de Oro city
                                              //                                 double lat = double.parse(json.first['lat']);
                                              //                                 double long = double.parse(json.first['lon']);
                                              //                                 selectedLocation = LatLng(lat, long);
                                              //                                 _updateMapOnly((){
                                              //                                   selectedLocation = LatLng(lat, long);
                                              //                                   map.move(selectedLocation, 18);
                                              //                                 });
                                              //
                                              //                               });
                                              //                             },
                                              //                             rTopLeft: 0,
                                              //                             rBottomLeft: 0,
                                              //                             height: 50,
                                              //                             width: 50,
                                              //                             text: "Find",
                                              //                           ),
                                              //                         ),
                                              //                         Row(
                                              //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //                           children: [
                                              //                             CustomTextButton(
                                              //                               width:120,
                                              //                               onPressed: (){
                                              //                                 if(address.text.isEmpty)return;
                                              //
                                              //                                 userAddress.address = address.text;
                                              //                                 userAddress.lat = selectedLocation.latitude;
                                              //                                 userAddress.long = selectedLocation.longitude;
                                              //
                                              //                                 userAddress.upsert().then((value) {
                                              //                                   Fluttertoast.showToast(
                                              //                                       msg: "Location update successfully!",
                                              //                                       toastLength: Toast.LENGTH_SHORT,
                                              //                                       gravity: ToastGravity.CENTER,
                                              //                                       timeInSecForIosWeb: 1,
                                              //                                       backgroundColor: Colors.blue,
                                              //                                       textColor: Colors.white,
                                              //                                       fontSize: 16.0
                                              //                                   );
                                              //                                   _updateMapOnly((){
                                              //
                                              //                                   });
                                              //                                 });
                                              //
                                              //                                 // setState(() {
                                              //                                 //   stationAddress.text = address.text.toTitleCase();
                                              //                                 //   Navigator.pop(context);
                                              //                                 // });
                                              //                               },
                                              //                               color: Colors.blue,
                                              //                               text: "Save Location",
                                              //                             ),
                                              //                             CustomTextButton(
                                              //                               padding: EdgeInsets.zero,
                                              //                               style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 15,height: 1),
                                              //                               onPressed: (){
                                              //                                 // Navigator.pop(context);
                                              //                               },
                                              //                               color: Colors.transparent,
                                              //                               text: "",
                                              //                             ),
                                              //                           ],
                                              //                         )
                                              //
                                              //                       ],
                                              //                     ),
                                              //                   );
                                              //                 }
                                              //             );
                                              //           }
                                              //       );
                                              //     }
                                              // ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Tools.getDeviceHeight(context)*0.78,
                    child: TabBarView(
                        controller: tabController,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Select",style: GoogleFonts.quicksand(fontWeight: FontWeight.w100,fontSize: 25),),
                                    Text("Station",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                width: Tools.getDeviceWidth(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(

                                        icon: Ionicons.search,
                                        filled: true,
                                        filledColor: Color(0xffC3EBFF).withAlpha(50),
                                        padding: EdgeInsets.zero,
                                        rAll: 15,
                                        borderWidth: 0,
                                        hint: 'Search Station',
                                        controller: search,
                                        color: Colors.blue,

                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.09),
                                              spreadRadius: 3,
                                              blurRadius: 6,
                                              offset: Offset(1, 3), // changes position of shadow
                                            ),
                                          ],
                                          color: Colors.white,
                                          // shape: BoxShape.circle,
                                          borderRadius: BorderRadius.all(Radius.circular(13))

                                      ),
                                      child: CustomTextButton(
                                        onPressed: (){
                                          setState(() {

                                          });
                                        },
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black87),
                                        color: Colors.white,
                                        rAll: 18,
                                        padding: EdgeInsets.zero,
                                        width: 20,
                                        height: 20,
                                        text: "Go",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  stream: Controller.getCollectionStream(collectionName: 'stations'),
                                  builder: (context,snapshot){
                                    if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                    if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                    List<Station> stations = [];

                                    for(var query in snapshot.data!.docs){
                                      Station station = Station.toObject(object: query.data());
                                      if(search.text.isNotEmpty){
                                        if(station.name.toLowerCase().contains(search.text.toLowerCase())||station.address.toLowerCase().contains(search.text.toLowerCase())){
                                          stations.add(station);
                                        }
                                      }
                                      else{
                                        stations.add(station);
                                      }

                                    }

                                    return CarouselSlider(
                                      options: CarouselOptions(
                                        enableInfiniteScroll: stations.length>1,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        height: 400.0,
                                        viewportFraction: 0.8,
                                        enlargeCenterPage: true,
                                        autoPlay: true,
                                      ),
                                      items: stations.map((station) {
                                        return GestureDetector(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>StationPage(station: station,user: widget.user,)));
                                          },
                                          child: Builder(
                                            builder: (BuildContext context) {
                                              bool isOpen = station.status=='open'?true:false;
                                              return Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height:MediaQuery.of(context).size.height ,
                                                  // margin: EdgeInsets.symmetric(horizontal: .5),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                                      // border: Border.all(
                                                      //   color: isOpen?Colors.blue:Colors.deepOrange,
                                                      //   width: 1
                                                      // ),
                                                      color: Colors.white
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text('${station.name}', style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue ,),),
                                                              Container(
                                                                alignment: Alignment.center,
                                                                width: 30,
                                                                height: 20,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                                                    color: isOpen?Colors.green:Colors.deepOrange
                                                                ),
                                                                child: Text(station.status,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.white ,),),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Text('${station.address}', style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),maxLines: 3,)
                                                          ),
                                                        ],
                                                      ),

                                                      Expanded(
                                                        child: StreamBuilder(
                                                            stream: Controller.getCollectionStreamWhere(collectionName: 'products', field: 'stationID', value: station.id) ,
                                                            builder: (context,snapshot){
                                                              if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                                              if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                                              if(snapshot.data!.docs.isEmpty) {
                                                                return Container(

                                                                    alignment: Alignment.center,

                                                                    child:SingleChildScrollView(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          lot.Lottie.network("https://assets1.lottiefiles.com/packages/lf20_L9pDkC.json",width: 200),
                                                                          Text("This station has no products",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                                        ],
                                                                      ),
                                                                    )
                                                                );
                                                              }

                                                              List<Product> products = [];
                                                              for(var query in snapshot.data!.docs){
                                                                Product product = Product.toObject(object: query.data());
                                                                products.add(product);
                                                                // print(query.data());
                                                              }
                                                              Product firstProduct = products.first;

                                                              return Container(
                                                                margin: EdgeInsets.only(top: 20),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Image.network(firstProduct.imgURL,fit: BoxFit.fitHeight,height: 200,alignment: Alignment.center,),
                                                                    Expanded(
                                                                      child: Container(
                                                                        child: SingleChildScrollView(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [

                                                                              Text("Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,color:Colors.blue,fontSize: 10,height: 1),),
                                                                              Text("Php${firstProduct.price}.00",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,color:Colors.orange,fontSize: 20,height: 1),),
                                                                              Text(firstProduct.name,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,color:Colors.grey,fontSize: 10),),
                                                                              Padding(padding: EdgeInsets.only(top: 20)),
                                                                              Text("Top Selling Product",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,color:Colors.orange,fontSize: 10,height: 1),),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }
                              )
                            ],
                          ),
                          Builder(
                              builder: (context) {
                                // late Function(Function()) _updateCart;


                                return Column(
                                  children: [
                                    Container(
                                      color:  Color(0xffF5F5F5),
                                      padding: EdgeInsets.all(10),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Your",style: GoogleFonts.quicksand(fontWeight: FontWeight.w100,fontSize: 25),),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Cart",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),
                                              StreamBuilder(
                                                  stream: Controller.getCollectionStreamWhere(collectionName: 'cart_items', field: 'userID', value: widget.user.id),
                                                  builder:  (context,snapshot){
                                                    if(!snapshot.hasData)return Center();
                                                    if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                    List<CartItem> carts = [];
                                                    for(var query in snapshot.data!.docs){
                                                      CartItem cart = CartItem.toObject(object: query.data());
                                                      if(cart.status!='oncart')continue;
                                                      carts.add(cart);
                                                      // print(query.data());
                                                    }
                                                    return Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text("Total Items:",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,)),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8),
                                                          child: Text(carts.length.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 15,height: 1,color: Colors.blue ,)),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color:  Color(0xffF5F5F5),
                                      height: Tools.getDeviceHeight(context)*.635,
                                      width: Tools.getDeviceWidth(context),
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Scaffold(
                                        backgroundColor:  Color(0xffF5F5F5),
                                        body: FutureBuilder(
                                          future: Controller.getCollectionWhere(collectionName: 'cart_items', field: 'userID', value: widget.user.id),
                                          builder: (context,snapshot){
                                            if(!snapshot.hasData)return Center();
                                            if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                            if(snapshot.data!.docs.isEmpty) {
                                              return Container(
                                                  alignment: Alignment.center,
                                                  child:SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        lot.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
                                                        Text("You don't have item on your cart!",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                      ],
                                                    ),
                                                  )
                                              );
                                            }
                                            List<CartItem> carts = [];
                                            for(var query in snapshot.data!.docs){
                                              CartItem cart = CartItem.toObject(object: query.data());
                                              if(cart.status!='oncart')continue;
                                              carts.add(cart);
                                              // print(query.data());
                                            }
                                            if(carts.isEmpty){
                                              return Container(
                                                  alignment: Alignment.center,
                                                  child:SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        lot.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
                                                        Text("You don't have item on your cart!",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                      ],
                                                    ),
                                                  )
                                              );
                                            }
                                            return ListView(
                                              children: carts.map((cart){
                                                return StreamBuilder(
                                                    stream: Controller.getCollectionStreamWhere(collectionName: 'products', field: 'id', value: cart.productID),
                                                    builder: (context,snapshot){
                                                      if(!snapshot.hasData)return Center();
                                                      if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                      Product product = Product.toObject(object: snapshot.data!.docs.first.data());
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding:EdgeInsets.only(bottom: 2,top: 10,),
                                                            child: StreamBuilder(
                                                                stream: Controller.getCollectionStreamWhere(collectionName: 'stations', field: 'id', value: product.stationID),
                                                                builder: (context, snapshot) {
                                                                  if(!snapshot.hasData)return Center();
                                                                  if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                  if(snapshot.data!.docs.isEmpty)return Center();
                                                                  Station station = Station.toObject(object: snapshot.data!.docs.first.data());
                                                                  return Text(station.name,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,height: 1,color: Colors.grey ,),);
                                                                }
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.centerLeft,

                                                            padding: EdgeInsets.only(left: 0,right: 0,top: 15,bottom: 0),
                                                            height: 165,
                                                            width: double.infinity,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.only(bottomRight:Radius.circular(15),bottomLeft: Radius.circular(15),topRight: Radius.circular(15)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.grey.withOpacity(0.09),
                                                                  spreadRadius: 3,
                                                                  blurRadius: 6,
                                                                  offset: Offset(1, 3), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),

                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Image.network(product.imgURL,width: 50,fit: BoxFit.fitHeight,),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(product.name,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w200,fontSize: 12,height: 1,color: Colors.blue ,),),
                                                                            SizedBox(
                                                                                width: 150,
                                                                                height: 20,
                                                                                child: Text(product.description,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 10,height: 1,color: Colors.grey ,),maxLines: 3,)
                                                                            ),
                                                                            Padding(padding: EdgeInsets.only(top: 13)),
                                                                            Text("Php.${product.price}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 15,height: 1,color: Colors.orange ,),),
                                                                            StreamBuilder(
                                                                                stream: Controller.getCollectionStreamWhere(collectionName: 'stocks', field: 'id', value: product.stockID),
                                                                                builder: (context, snapshot) {
                                                                                  if(!snapshot.hasData)return Center();
                                                                                  if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                                  Stock stock = Stock.toObject(object: snapshot.data!.docs.first.data());
                                                                                  return Text("Stocks Left: ${stock.stock}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),);
                                                                                }
                                                                            )
                                                                          ],
                                                                        )

                                                                      ],
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: (){
                                                                        Controller.getCollection(collectionName: 'cart_items').then((value) {
                                                                          value.doc(cart.id).delete().then((value) {
                                                                            setState(() {

                                                                            });
                                                                            Fluttertoast.showToast(
                                                                                msg: "Item successfully remove to your cart!",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.CENTER,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.blue,
                                                                                textColor: Colors.white,
                                                                                fontSize: 12
                                                                            );
                                                                          });
                                                                        });
                                                                      },
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                        children: [
                                                                          Icon(Icons.close,color: Colors.grey,)
                                                                        ],
                                                                      ),
                                                                    )

                                                                  ],
                                                                ),
                                                                Divider(),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        IconButton(
                                                                            onPressed: (){

                                                                              if(cart.totalCartItemQuantity>0){
                                                                                cart.totalCartItemQuantity--;
                                                                                cart.totalCartItemValue = cart.totalCartItemQuantity*product.price;
                                                                                cart.upsert();
                                                                              }

                                                                            },
                                                                            icon: Icon(Icons.remove)
                                                                        ),
                                                                        Container(
                                                                          alignment: Alignment.center,
                                                                          height: 30,
                                                                          width: 30,
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.09),
                                                                                spreadRadius: 3,
                                                                                blurRadius: 6,
                                                                                offset: Offset(1, 3), // changes position of shadow
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: StreamBuilder(
                                                                              stream: Controller.getCollectionStreamWhere(collectionName: 'cart_items', field: 'id', value: cart.id),
                                                                              builder: (context, snapshot) {
                                                                                if(!snapshot.hasData)return Center();
                                                                                if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                                if(snapshot.data!.docs.isEmpty)return Center();
                                                                                CartItem thisCart = CartItem.toObject(object: snapshot.data!.docs.first.data());
                                                                                return Text(thisCart.totalCartItemQuantity.toString());
                                                                              }
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                            onPressed: (){
                                                                              Controller.getCollectionWhere(collectionName: 'stocks', field: 'id', value: product.stockID).then((value) {

                                                                                Stock stock = Stock.toObject(object: value.docs.first.data());
                                                                                if(cart.totalCartItemQuantity<stock.stock){
                                                                                  cart.totalCartItemQuantity++;
                                                                                  cart.totalCartItemValue = cart.totalCartItemQuantity*product.price;
                                                                                  cart.upsert();
                                                                                }
                                                                              });

                                                                            },
                                                                            icon: Icon(Icons.add)
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    Text("="),
                                                                    Container(
                                                                      margin: EdgeInsets.only(right: 10),
                                                                      alignment: Alignment.center,
                                                                      height: 30,
                                                                      width: 100,
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.grey.withOpacity(0.09),
                                                                            spreadRadius: 3,
                                                                            blurRadius: 6,
                                                                            offset: Offset(1, 3), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: StreamBuilder(
                                                                          stream: Controller.getCollectionStreamWhere(collectionName: 'cart_items', field: 'id', value: cart.id),
                                                                          builder: (context, snapshot) {
                                                                            if(!snapshot.hasData)return Center();
                                                                            if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                            if(snapshot.data!.docs.isEmpty)return Center();
                                                                            CartItem thisCart = CartItem.toObject(object: snapshot.data!.docs.first.data());
                                                                            return Text(thisCart.totalCartItemValue.toString());
                                                                          }
                                                                      ),
                                                                    ),

                                                                  ],
                                                                )

                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              }).toList(),
                                            );
                                          },
                                        ),
                                        bottomNavigationBar: BottomAppBar(
                                          elevation: 0,
                                          child: Container(
                                            color:  Color(0xffF5F5F5),
                                            width: Tools.getDeviceWidth(context),
                                            height: 130,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:8.0),
                                              child: Builder(
                                                  builder: (context) {
                                                    int totalValue = 0;
                                                    bool isPickup = false;
                                                    bool isCOD = false;
                                                    TextEditingController totalPrice = TextEditingController(text: "0");
                                                    String orderType = "";
                                                    String paymentType = "";

                                                    return StatefulBuilder(
                                                        builder: (context,updateCart) {
                                                          // _updateCart = updateCart;
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Text("Order Type",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,)),
                                                                        CustomTextButton(
                                                                          width: double.infinity,
                                                                          color: isPickup?Colors.blue:Colors.orange,
                                                                          text: isPickup?"Pickup":"Delivery",
                                                                          onPressed: (){
                                                                            updateCart((){
                                                                              isPickup = isPickup?false:true;
                                                                              if(isPickup)isCOD=false;
                                                                            });
                                                                          },
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Text("Payment Type",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,)),
                                                                        CustomTextButton(
                                                                          width: double.infinity,
                                                                          color: isCOD?Colors.blue:Colors.orange,
                                                                          text: isCOD?"COD":"At Station",
                                                                          onPressed: isPickup?null:(){
                                                                            updateCart((){
                                                                              isCOD = isCOD?false:true;
                                                                            });
                                                                          },
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              StreamBuilder(
                                                                  stream: Controller.getCollectionStreamWhere(collectionName: 'cart_items', field: 'userID', value: widget.user.id),
                                                                  builder: (context, snapshot) {
                                                                    if(!snapshot.hasData)return Center();
                                                                    if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                    List<CartItem> cartItems = [];
                                                                    int _totalPrice = 0;

                                                                    for(var query in snapshot.data!.docs){
                                                                      CartItem cartItem = CartItem.toObject(object: query.data());
                                                                      if(cartItem.status!='oncart')continue;
                                                                      cartItems.add(cartItem);
                                                                      _totalPrice+=cartItem.totalCartItemValue;
                                                                    }
                                                                    totalPrice.text = _totalPrice.toString();
                                                                    return CustomTextField(
                                                                      color: Colors.orange,
                                                                      enableFloat: true,
                                                                      readonly: true,
                                                                      hint: 'Total Price',
                                                                      controller: totalPrice,
                                                                      suffix: CustomTextButton(
                                                                        icon: Icon(Icons.shopping_cart_checkout_outlined,color:Colors.white),
                                                                        style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 15,height: 1,color: Colors.white ,),
                                                                        color: Colors.orange,
                                                                        rTopLeft: 0,
                                                                        rBottomLeft: 0,
                                                                        height: 50,
                                                                        width: 130,
                                                                        text: "Checkout",
                                                                        onPressed: (){
                                                                          if(cartItems.isEmpty)return;

                                                                          bool isValid = true;
                                                                          List<String> stations = [];
                                                                          for (var cart in cartItems) {
                                                                            if(cart.totalCartItemQuantity<=0){
                                                                              isValid = false;
                                                                              Fluttertoast.showToast(
                                                                                  msg: "Invalid order!",
                                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                                  gravity: ToastGravity.CENTER,
                                                                                  timeInSecForIosWeb: 1,
                                                                                  backgroundColor: Colors.orange,
                                                                                  textColor: Colors.white,
                                                                                  fontSize: 12
                                                                              );
                                                                              continue;
                                                                            }
                                                                            if(!stations.contains(cart.stationID)){
                                                                              stations.add(cart.stationID);
                                                                            }



                                                                          }

                                                                          if(isValid){
                                                                            for(var station in stations){
                                                                              Controller.getCollectionWhere(collectionName: 'user_addresses', field: 'userID', value: widget.user.id).then((value) {
                                                                                UserAddress userAddress = UserAddress.toObject(object: value.docs.first.data());
                                                                                OrderDetail order = OrderDetail(lat: userAddress.lat,long: userAddress.long,userAddress: userAddress.address,stationID: station,orderType: isPickup?OrderType.PICKUP:OrderType.DELIVERY,paymentType: isCOD?PaymentType.COD:PaymentType.ATSTATION, userID: widget.user.id, totalItems: 0, totalPrice: 0, status: OrderStatus.PENDING,riderID: "", timeCheckOut: DateTime.now().toString());
                                                                                int items = 0;
                                                                                int totalValue = 0;
                                                                                for(var cart in cartItems.where((element) => element.stationID==station)){
                                                                                  cart.status = 'checkout';
                                                                                  cart.orderID = order.id;
                                                                                  print(cart.stationID);
                                                                                  cart.upsert();
                                                                                  // print(cart.id);
                                                                                  items+=cart.totalCartItemQuantity;
                                                                                  totalValue+=cart.totalCartItemValue;
                                                                                }
                                                                                // print(items);
                                                                                order.totalItems = items;
                                                                                order.totalPrice = totalValue;
                                                                                order.upsert();
                                                                                Fluttertoast.showToast(
                                                                                    msg: "Order successfully placed!",
                                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                                    gravity: ToastGravity.CENTER,
                                                                                    timeInSecForIosWeb: 1,
                                                                                    backgroundColor: Colors.blue,
                                                                                    textColor: Colors.white,
                                                                                    fontSize: 12
                                                                                );
                                                                                setState(() {

                                                                                });
                                                                              });


                                                                            }

                                                                          }

                                                                        },
                                                                      ),


                                                                    );
                                                                  }
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                    );
                                                  }
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                );


                              }
                          ),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Your",style: GoogleFonts.quicksand(fontWeight: FontWeight.w100,fontSize: 25),),
                                    Text("Orders",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: StreamBuilder(
                                    stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'userID', value: widget.user.id),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData)return Center();
                                      if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                      if(snapshot.data!.docs.isEmpty) {
                                        return Container(
                                            height: 300,
                                            alignment: Alignment.center,

                                            child:SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  lot.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
                                                  Text("You dont have any orders",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                ],
                                              ),
                                            )
                                        );
                                      }
                                      List<OrderDetail> orderDetails = [];
                                      for(var query in snapshot.data!.docs){
                                        OrderDetail orderDetail = OrderDetail.toObject(object: query.data());
                                        if(orderDetail.status==OrderStatus.DELIVERED||orderDetail.status==OrderStatus.COMPLETE)continue;
                                        orderDetails.add(orderDetail);
                                        // print(query.data());
                                      }

                                      if(orderDetails.isEmpty){
                                        return Container(
                                            height: 300,
                                            alignment: Alignment.center,

                                            child:SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  lot.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
                                                  Text("You dont have any orders",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                ],
                                              ),
                                            )
                                        );
                                      }
                                      orderDetails.sort((b,a)=>DateTime.parse(a.timeDelivered).compareTo(DateTime.parse(b.timeDelivered)));
                                      return Container(
                                        height: Tools.getDeviceHeight(context)*.635,
                                        padding: EdgeInsets.all(10),
                                        width: Tools.getDeviceWidth(context),
                                        child: ListView(
                                          children: orderDetails.map((order) {

                                            return Container(
                                              alignment: Alignment.topCenter,
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(10),
                                              width: double.infinity,
                                              height: 460,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.09),
                                                    spreadRadius: 3,
                                                    blurRadius: 6,
                                                    offset: Offset(1, 3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  StreamBuilder(
                                                      stream: Controller.getCollectionStreamWhere(collectionName: 'stations', field: 'id', value: order.stationID),
                                                      builder: (context, snapshot) {
                                                        if(!snapshot.hasData)return Center();
                                                        if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                        if(snapshot.data!.docs.isEmpty)return Center();
                                                        Station station = Station.toObject(object: snapshot.data!.docs.first.data());
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text("Station",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                Text(station.name,style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 20,height: 1,color: Colors.blue ,),),
                                                              ],
                                                            ),
                                                            Column(

                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text("Total Items",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                Text(order.totalItems.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 13,height: 1,color: Colors.grey ,),),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                    height: 60,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey.withAlpha(20),
                                                        borderRadius: BorderRadius.all(Radius.circular(50))

                                                    ),

                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 12 ,left: 10,right: 12),
                                                              child: Divider(thickness: 2,color: Colors.blue,),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.all(5),
                                                                      height:order.status==OrderStatus.PENDING?30:15,
                                                                      width: order.status==OrderStatus.PENDING?30:15,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.blue,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            shape: BoxShape.circle
                                                                        ),

                                                                      ),
                                                                    ),
                                                                    Text("Pending",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                  ],
                                                                ),
                                                                if(order.orderType!=OrderType.PICKUP)
                                                                Expanded(child: Column(
                                                                  children: [
                                                                    Divider(thickness: 3,color: Colors.transparent,),
                                                                    Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                  ],
                                                                )),
                                                                if(order.orderType!=OrderType.PICKUP)
                                                                Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.all(5),
                                                                      height:order.status==OrderStatus.ACCEPTED?30:15,
                                                                      width: order.status==OrderStatus.ACCEPTED?30:15,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.blue,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            shape: BoxShape.circle
                                                                        ),

                                                                      ),
                                                                    ),
                                                                    Text("Accepted",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                  ],
                                                                ),
                                                                if(order.orderType!=OrderType.PICKUP)
                                                                Expanded(child: Column(
                                                                  children: [
                                                                    Divider(thickness: 3,color: Colors.transparent,),
                                                                    Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                  ],
                                                                )),
                                                                if(order.orderType!=OrderType.PICKUP)
                                                                Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.all(5),
                                                                      height:order.status==OrderStatus.DELIVERING?30:15,
                                                                      width: order.status==OrderStatus.DELIVERING?30:15,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.blue,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            shape: BoxShape.circle
                                                                        ),

                                                                      ),
                                                                    ),
                                                                    Text("Delivering",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                  ],
                                                                ),
                                                                Expanded(child: Column(
                                                                  children: [
                                                                    Divider(thickness: 3,color: Colors.transparent,),
                                                                    Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                  ],
                                                                )),
                                                                Column(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.all(5),
                                                                      height:order.status==OrderStatus.DELIVERED||order.status==OrderStatus.COMPLETE?30:15,
                                                                      width: order.status==OrderStatus.DELIVERED||order.status==OrderStatus.COMPLETE?30:15,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.blue,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            shape: BoxShape.circle
                                                                        ),

                                                                      ),
                                                                    ),
                                                                    Text(order.orderType==OrderType.PICKUP?"Complete":"Delivered",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        // Row(
                                                        //   children: [
                                                        //     Text("Pending",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                        //     Expanded(child: Divider(thickness: 3,color: Colors.blue,)),
                                                        //     Text("Accepted",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                        //     Expanded(child: Divider(thickness: 3,color: Colors.blue,)),
                                                        //     Text("Delivering",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                        //     Expanded(child: Divider(thickness: 3,color: Colors.blue,)),
                                                        //     Text("Delivered",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                        //   ],
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  StreamBuilder(
                                                      stream: Controller.getCollectionStreamWhere(collectionName: 'cart_items', field: 'orderID', value: order.id),
                                                      builder: (context, snapshot) {
                                                        if(!snapshot.hasData)return Center();
                                                        if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                        if(snapshot.data!.docs.isEmpty)return Center();
                                                        List<CartItem> items = [];
                                                        for(var query in snapshot.data!.docs){
                                                          CartItem item = CartItem.toObject(object: query.data());
                                                          if(item.status!='checkout')continue;
                                                          items.add(item);
                                                          // print(query.data());
                                                        }
                                                        return Container(
                                                          // padding: EdgeInsets.all(10),
                                                          margin: EdgeInsets.only(top: 10),
                                                          width: double.infinity,
                                                          height: 250,

                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                                            child: Container(
                                                              color: Color(0xffF3F3F3),
                                                              child: Scrollbar(
                                                                child: ListView(
                                                                  children: items.map((item){
                                                                    return StreamBuilder(
                                                                        stream: Controller.getCollectionStreamWhere(collectionName: 'products', field: 'id', value: item.productID),
                                                                        builder: (context,snapshot){
                                                                          if(!snapshot.hasData)return Center();
                                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                          Product product = Product.toObject(object: snapshot.data!.docs.first.data());
                                                                          return Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                                                                alignment: Alignment.centerLeft,
                                                                                padding: EdgeInsets.only(left: 5,right: 10,top: 15,bottom: 0),
                                                                                height: 70,
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Colors.grey.withOpacity(0.09),
                                                                                      spreadRadius: 3,
                                                                                      blurRadius: 6,
                                                                                      offset: Offset(1, 3), // changes position of shadow
                                                                                    ),
                                                                                  ],
                                                                                ),

                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                            width:40,
                                                                                            child: Image.network(product.imgURL,height: 35,fit: BoxFit.fitHeight,)
                                                                                        ),
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(product.name,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w200,fontSize: 12,height: 1,color: Colors.blue ,),),
                                                                                            SizedBox(
                                                                                                width: 150,
                                                                                                height: 20,
                                                                                                child: Text(product.description,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 10,height: 1,color: Colors.grey ,),maxLines: 3,)
                                                                                            ),
                                                                                            Padding(padding: EdgeInsets.only(top: 13)),

                                                                                          ],
                                                                                        ),
                                                                                        Column(
                                                                                          children: [
                                                                                            // Text("Total Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.grey ,),),
                                                                                            Text("Php.${item.totalCartItemValue}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,height: 1,color: Colors.orange ,),),
                                                                                            Text("Quantity: ${item.totalCartItemQuantity}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 10,height: 1,color: Colors.grey ,),)
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),

                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        });
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),

                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Total Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 18,color: Colors.grey ,)),
                                                      Text("Php."+order.totalPrice.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.orange ,)),
                                                    ],
                                                  ),
                                                  if(order.status==OrderStatus.PENDING)
                                                  CustomTextButton(
                                                    width:50,
                                                    padding: EdgeInsets.zero,
                                                    style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 13,color: Colors.grey ,),
                                                    color: Colors.transparent,
                                                    text:'Cancel',
                                                    onPressed: (){
                                                      order.delete();
                                                    },
                                                  ),


                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                ),
                              )
                            ],
                          ),
                          Scaffold(
                            body: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Your",style: GoogleFonts.quicksand(fontWeight: FontWeight.w100,fontSize: 25),),
                                      Text("Complete Orders",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: StreamBuilder(
                                      stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'userID', value: widget.user.id),
                                      builder: (context, snapshot) {
                                        if(!snapshot.hasData)return Center();
                                        if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                        if(snapshot.data!.docs.isEmpty)return Center();
                                        List<OrderDetail> orderDetails = [];
                                        for(var query in snapshot.data!.docs){
                                          OrderDetail orderDetail = OrderDetail.toObject(object: query.data());
                                          if(orderDetail.status==OrderStatus.DELIVERED||orderDetail.status==OrderStatus.COMPLETE){
                                            orderDetails.add(orderDetail);
                                          }

                                          // print(query.data());
                                        }
                                        orderDetails.sort((b,a)=>DateTime.parse(a.timeDelivered).compareTo(DateTime.parse(b.timeDelivered)));
                                        return Container(
                                          height: Tools.getDeviceHeight(context)*.560,
                                          padding: EdgeInsets.all(10),
                                          width: Tools.getDeviceWidth(context),
                                          child: ListView(
                                            children: orderDetails.map((order) {
                                              return Container(
                                                alignment: Alignment.topCenter,
                                                margin: EdgeInsets.all(10),
                                                padding: EdgeInsets.all(10),
                                                width: double.infinity,
                                                height: 180,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.09),
                                                      spreadRadius: 3,
                                                      blurRadius: 6,
                                                      offset: Offset(1, 3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    StreamBuilder(
                                                        stream: Controller.getCollectionStreamWhere(collectionName: 'stations', field: 'id', value: order.stationID),
                                                        builder: (context, snapshot) {
                                                          if(!snapshot.hasData)return Center();
                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                          if(snapshot.data!.docs.isEmpty)return Center();
                                                          Station station = Station.toObject(object: snapshot.data!.docs.first.data());
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text("Station",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                  Text(station.name,style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 20,height: 1,color: Colors.blue ,),),
                                                                ],
                                                              ),
                                                              Column(

                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Text("Total Items",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                  Text(order.totalItems.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 13,height: 1,color: Colors.grey ,),),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                                      height: 60,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey.withAlpha(20),
                                                          borderRadius: BorderRadius.all(Radius.circular(50))

                                                      ),

                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(bottom: 12 ,left: 10,right: 12),
                                                                child: Divider(thickness: 2,color: Colors.blue,),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      Container(
                                                                        padding: EdgeInsets.all(5),
                                                                        height:order.status==OrderStatus.PENDING?30:15,
                                                                        width: order.status==OrderStatus.PENDING?30:15,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.blue,
                                                                            shape: BoxShape.circle
                                                                        ),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              shape: BoxShape.circle
                                                                          ),

                                                                        ),
                                                                      ),
                                                                      Text("Pending",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                    ],
                                                                  ),
                                                                  if(order.orderType!=OrderType.PICKUP)
                                                                    Expanded(child: Column(
                                                                      children: [
                                                                        Divider(thickness: 3,color: Colors.transparent,),
                                                                        Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                      ],
                                                                    )),
                                                                  if(order.orderType!=OrderType.PICKUP)
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.all(5),
                                                                          height:order.status==OrderStatus.ACCEPTED?30:15,
                                                                          width: order.status==OrderStatus.ACCEPTED?30:15,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.blue,
                                                                              shape: BoxShape.circle
                                                                          ),
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                shape: BoxShape.circle
                                                                            ),

                                                                          ),
                                                                        ),
                                                                        Text("Accepted",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                      ],
                                                                    ),
                                                                  if(order.orderType!=OrderType.PICKUP)
                                                                    Expanded(child: Column(
                                                                      children: [
                                                                        Divider(thickness: 3,color: Colors.transparent,),
                                                                        Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                      ],
                                                                    )),
                                                                  if(order.orderType!=OrderType.PICKUP)
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.all(5),
                                                                          height:order.status==OrderStatus.DELIVERING?30:15,
                                                                          width: order.status==OrderStatus.DELIVERING?30:15,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.blue,
                                                                              shape: BoxShape.circle
                                                                          ),
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                shape: BoxShape.circle
                                                                            ),

                                                                          ),
                                                                        ),
                                                                        Text("Delivering",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                      ],
                                                                    ),
                                                                  Expanded(child: Column(
                                                                    children: [
                                                                      Divider(thickness: 3,color: Colors.transparent,),
                                                                      Text("",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.transparent ,)),
                                                                    ],
                                                                  )),
                                                                  Column(
                                                                    children: [
                                                                      Container(
                                                                        padding: EdgeInsets.all(5),
                                                                        height:order.status==OrderStatus.DELIVERED||order.status==OrderStatus.COMPLETE?30:15,
                                                                        width: order.status==OrderStatus.DELIVERED||order.status==OrderStatus.COMPLETE?30:15,
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.blue,
                                                                            shape: BoxShape.circle
                                                                        ),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              shape: BoxShape.circle
                                                                          ),

                                                                        ),
                                                                      ),
                                                                      Text(order.orderType==OrderType.PICKUP?"Complete":"Delivered",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),

                                                        ],
                                                      ),
                                                    ),

                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Total Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 18,color: Colors.grey ,)),
                                                        Text("Php."+order.totalPrice.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.orange ,)),
                                                      ],
                                                    )


                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }
                                  ),
                                )
                              ],
                            ),
                            bottomNavigationBar: BottomAppBar(

                              child: StreamBuilder(
                                  stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'userID', value: widget.user.id),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData)return Center();
                                    if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                    if(snapshot.data!.docs.isEmpty)return Center();
                                    int totalSold = 0;
                                    int totalValueSold = 0;
                                    List<OrderDetail> orderDetails = [];
                                    for(var query in snapshot.data!.docs){
                                      OrderDetail orderDetail = OrderDetail.toObject(object: query.data());
                                      if(orderDetail.status!=OrderStatus.DELIVERED)continue;
                                      if(orderDetail.orderType!=OrderType.DELIVERY)continue;
                                      totalSold+=orderDetail.totalItems;
                                      totalValueSold+=orderDetail.totalPrice;
                                      orderDetails.add(orderDetail);
                                      // print(query.data());
                                    }

                                    return Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(5),
                                      height: 55,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text('Bought Containers',style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 10)),
                                              Text(totalSold.toString(),style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,color:Colors.blue,fontSize: 15)),
                                            ],
                                          ),
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                                          Column(
                                            children: [
                                              Text('Total Value',style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 10)),
                                              Text('Php.${totalValueSold.toString()}',style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,color:Colors.orange,fontSize: 15)),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ),

                        ]
                    ),
                  )


                ],
              ),
            ),
          ),
        ),

        bottomNavigationBar: BottomAppBar(

          elevation: 2,
          color:Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 0,
          child: SizedBox(
            height: 50,
            child: Builder(
                builder: (context) {

                  return StatefulBuilder(
                      builder: (context,updateNavigation) {
                        _updateNavigation = updateNavigation;
                        return TabBar(
                          isScrollable: false,
                          indicatorColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          splashBorderRadius: BorderRadius.zero,
                          onTap: (value){
                            updateNavigation((){
                              tabController.index = value;
                            });

                          },
                          controller: tabController,
                          tabs: [
                            Tab(
                              icon:  Icon(Icons.storefront,color: tabController.index ==0?Colors.blue:Colors.grey,),
                            ),
                            Tab(
                              icon:  Icon(Ionicons.basket_outline,color: tabController.index ==1?Colors.blue:Colors.grey,),
                            ),
                            Tab(
                              icon: Icon(Icons.local_shipping,color: tabController.index ==2?Colors.blue:Colors.grey,),
                            ),
                            Tab(
                              icon: Icon(Icons.receipt_long_outlined,color: tabController.index ==3?Colors.blue:Colors.grey,),
                            ),
                          ],
                        );
                      }
                  );
                }
            ),
          ),
        ),

      ),
    );
  }
}
