



import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:water_refilling_app/models/order_details.dart';
import 'package:water_refilling_app/models/riders.dart';
import 'package:http/http.dart' as http;
import '../models/cart.dart';
import '../models/controller.dart';
import '../models/product.dart';
import '../models/station.dart';
import '../models/stock.dart';
import '../models/user.dart';
import '../models/user_address.dart';
import '../my_widgets/custom_text_button.dart';
import '../my_widgets/custom_textfield.dart';
import '../tools/variables.dart';
import 'login.dart';
class RiderPage extends StatefulWidget{
  const RiderPage({super.key,required this.rider});
  final Rider rider;
  @override
  State<StatefulWidget> createState() => _RiderPageState();
}


class _RiderPageState extends State<RiderPage> with TickerProviderStateMixin{

  TextEditingController search = TextEditingController();
  int backCounter = 0;
  late TabController tabController;
  LatLng? currentRiderLocation;
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
    Geolocator.getPositionStream().listen((event) {
      currentRiderLocation = LatLng(event.latitude, event.longitude);

    });
    tabController = new TabController(length: 3, vsync: this);

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
                              widget.rider.logout().whenComplete((){
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
                            child: Text(widget.rider.fullname[0].toUpperCase()),
                          ),
                          onTap: (){

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
                                    Text("Available",style: GoogleFonts.quicksand(fontWeight: FontWeight.w100,fontSize: 25),),
                                    Text("Orders",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),
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
                                        hint: 'Search Customer Location',
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
                                  stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'stationID',value: widget.rider.stationID),
                                  builder: (context,snapshot){
                                    if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                    if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);

                                    List<OrderDetails> orders = [];
                                    for(var query in snapshot.data!.docs){
                                      OrderDetails order = OrderDetails.toObject(object: query.data());
                                      if(order.status!=OrderStatus.ACCEPTED)continue;
                                      if(order.orderType!=OrderType.DELIVERY)continue;
                                      double distance = 0;
                                      try{
                                        distance = Geolocator.distanceBetween(currentRiderLocation!.latitude, currentRiderLocation!.longitude,order.lat, order.long);
                                      }catch(e){

                                      }

                                      if(search.text.isNotEmpty){
                                        if(order.userAddress.toLowerCase().contains(search.text.toLowerCase())){

                                          orders.add(order);
                                        }
                                        else if(distance<=400){
                                          orders.add(order);
                                        }
                                      }
                                      else{
                                        orders.add(order);
                                      }





                                    }

                                    return CarouselSlider(
                                      options: CarouselOptions(
                                        enableInfiniteScroll: orders.length>1,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        height: 400.0,
                                        viewportFraction: 0.8,
                                        enlargeCenterPage: true,
                                        autoPlay: true,
                                      ),
                                      items: orders.map((order) {
                                        return GestureDetector(
                                          onTap: (){
                                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>StationPage(station: station,user: widget.user,)));
                                          },
                                          child: Builder(
                                            builder: (BuildContext context) {
                                              double distanceValue = 0;
                                              late User customer;
                                              late UserAddress userAddress;
                                              // bool isOpen = station.status=='open'?true:false;
                                              return Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: MediaQuery.of(context).size.height,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                                      color: Colors.white
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    StreamBuilder(
                                                                        stream:  Controller.getCollectionStreamWhere(collectionName: 'users', field: 'id', value:order.userID),
                                                                        builder: (context, snapshot) {
                                                                          if(!snapshot.hasData)return Center();
                                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                          if(snapshot.data!.docs.isEmpty)return Center();
                                                                          User user = User.toObject(object:snapshot.data!.docs.first.data() );
                                                                          customer = user;

                                                                          return Text('${user.firstname}', style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue ,),);
                                                                        }
                                                                    ),
                                                                    FutureBuilder(
                                                                        future: _determinePosition(),
                                                                        builder: (context, snapshot) {
                                                                          if(!snapshot.hasData)return Center();
                                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                          LatLng currentPosition = LatLng(snapshot.data!.latitude,snapshot.data!.longitude);
                                                                          double distance = Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, userAddress.lat, userAddress.long);
                                                                          distanceValue = distance;
                                                                          double distanceInKilometer = distance/1000;
                                                                          return Container(
                                                                            alignment: Alignment.centerRight,

                                                                            height: 50,
                                                                            // decoration: BoxDecoration(
                                                                            //     borderRadius: BorderRadius.all(Radius.circular(50)),
                                                                            //     color: Colors.white
                                                                            // ),
                                                                            child: Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Text(distance.toStringAsFixed(2),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue ,),),
                                                                                Text("m",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                                Text(" or ",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                                Text(distanceInKilometer.toStringAsFixed(2),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue ,),),
                                                                                Text("km",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }
                                                                    )
                                                                  ],
                                                                ),
                                                                StreamBuilder(
                                                                    stream:  Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value:order.userID),
                                                                    builder: (context, snapshot) {
                                                                      if(!snapshot.hasData)return Center();
                                                                      if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                      if(snapshot.data!.docs.isEmpty)return Center();
                                                                      UserAddress userAddressThis = UserAddress.toObject(object:snapshot.data!.docs.first.data() );
                                                                      userAddress = userAddressThis;
                                                                      return Column(
                                                                        children: [
                                                                          // Text('${user.firstname}', style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.blue ,),),
                                                                          Text('${userAddressThis.address}', style:GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,color: Colors.grey ,),maxLines: 3,),
                                                                        ],
                                                                      );
                                                                    }
                                                                )
                                                              ],
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 200,
                                                                width: double.infinity,
                                                                child: FutureBuilder(
                                                                  future: Controller.getCollectionWhere(collectionName: 'cart_items', field: 'orderID', value: order.id),
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
                                                                                lottie.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
                                                                                Text("You don't have item on your cart!",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),
                                                                              ],
                                                                            ),
                                                                          )
                                                                      );
                                                                    }
                                                                    List<CartItem> carts = [];
                                                                    for(var query in snapshot.data!.docs){
                                                                      CartItem cart = CartItem.toObject(object: query.data());
                                                                      if(cart.status!='checkout')continue;
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
                                                                                lottie.Lottie.network("https://assets2.lottiefiles.com/packages/lf20_qh5z2fdq.json",width: 200),
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
                                                                                  Container(
                                                                                    alignment: Alignment.centerLeft,


                                                                                    height: 165,
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
                                                                                            Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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


                                                                                                    },
                                                                                                    icon: Icon(Icons.remove,color: Colors.transparent,)
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


                                                                                                    },
                                                                                                    icon: Icon(Icons.add,color: Colors.transparent)
                                                                                                ),
                                                                                              ],
                                                                                            ),

                                                                                            Text("="),
                                                                                            Container(
                                                                                              margin: EdgeInsets.only(right: 10),
                                                                                              alignment: Alignment.center,
                                                                                              height: 40,
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
                                                                                                    return Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        Text('Total Price',style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 10,height: 1,color: Colors.grey ,)),
                                                                                                        Text(thisCart.totalCartItemValue.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.orange ,)),
                                                                                                      ],
                                                                                                    );
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
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text("Total Items",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,)),
                                                                    Text(order.totalItems.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,height: 1,color: Colors.blue ,)),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text("Total Value",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,)),
                                                                    Text("Php."+order.totalPrice.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,height: 1,color: Colors.orange ,)),
                                                                  ],
                                                                ),

                                                              ],
                                                            )

                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          CustomTextButton(
                                                            color: Colors.blue,
                                                            width: double.infinity,
                                                            text: "Add To Cargo",
                                                            icon: Icon(Icons.local_shipping_outlined,color:Colors.white),
                                                            onHold: (){
                                                              order.status = OrderStatus.DELIVERING;
                                                              order.riderID = widget.rider.id;
                                                              order.upsert();
                                                            },
                                                          ),
                                                          Text("Hold to add to your cargo.",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.grey ,)),
                                                        ],
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
                                              Text("Accepted Orders",style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: StreamBuilder(
                                          stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'riderID', value: widget.rider.id),
                                          builder: (context, snapshot) {
                                            if(!snapshot.hasData)return Center();
                                            if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                            if(snapshot.data!.docs.isEmpty)return Center();
                                            List<OrderDetails> orderDetails = [];
                                            for(var query in snapshot.data!.docs){
                                              OrderDetails orderDetail = OrderDetails.toObject(object: query.data());
                                              if(orderDetail.status!=OrderStatus.DELIVERING)continue;
                                              if(orderDetail.orderType!=OrderType.DELIVERY)continue;
                                              orderDetails.add(orderDetail);
                                              // print(query.data());
                                            }
                                            double distanceFromCustomer = 0;
                                            return Container(
                                              height: Tools.getDeviceHeight(context)*.635,
                                              padding: EdgeInsets.all(10),
                                              width: Tools.getDeviceWidth(context),
                                              child: Scrollbar(
                                                trackVisibility: true,
                                                child: ListView(
                                                  children: orderDetails.map((order) {
                                                    return Container(
                                                      alignment: Alignment.topCenter,
                                                      margin: EdgeInsets.all(10),
                                                      padding: EdgeInsets.all(10),
                                                      width: double.infinity,
                                                      height: 540,
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
                                                              stream: Controller.getCollectionStreamWhere(collectionName: 'users', field: 'id', value: order.userID),
                                                              builder: (context, snapshot) {
                                                                if(!snapshot.hasData)return Center();
                                                                if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                if(snapshot.data!.docs.isEmpty)return Center();
                                                                User user = User.toObject(object: snapshot.data!.docs.first.data());
                                                                return Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              width:Tools.getDeviceWidth(context)*.82,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text("Customer's Name",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                                  Text("Qty.${order.totalItems.toString()}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            StreamBuilder(
                                                                                stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: order.userID),
                                                                                builder: (context, snapshot) {
                                                                                  if(!snapshot.hasData)return Center();
                                                                                  if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                                  if(snapshot.data!.docs.isEmpty)return Center();
                                                                                  UserAddress userAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());

                                                                                  return Container(
                                                                                    width:Tools.getDeviceWidth(context)*.82,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(user.firstname,style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 20,height: 1,color: Colors.blue ,),),
                                                                                            SizedBox(
                                                                                                width:200,
                                                                                                child: Text(userAddress.address,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.grey ,),)),
                                                                                          ],
                                                                                        ),
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            Text("Total Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,)),
                                                                                            Text("Php."+order.totalPrice.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.orange ,)),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                }
                                                                            ),
                                                                          ],
                                                                        ),

                                                                      ],
                                                                    ),

                                                                  ],
                                                                );
                                                              }
                                                          ),
                                                          FutureBuilder(
                                                              future:Geolocator.getCurrentPosition(),
                                                              builder: (context,snapshot){
                                                                if(!snapshot.hasData)return Center();
                                                                if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                latlong.LatLng myLocation  =latlong.LatLng(snapshot.data!.latitude,snapshot.data!.longitude);

                                                                MapController map = MapController();

                                                                return StreamBuilder(
                                                                    stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: order.userID),
                                                                    builder: (context, snapshot) {
                                                                      if(!snapshot.hasData)return Center();
                                                                      if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                      if(snapshot.data!.docs.isEmpty)return Center();
                                                                      UserAddress userAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());
                                                                      double cLat = (userAddress.lat+myLocation.latitude)/2;
                                                                      double cLong = (userAddress.long+myLocation.longitude)/2;
                                                                      LatLng centerPoint = LatLng(cLat, cLong);
                                                                      return ClipRRect(
                                                                        borderRadius: BorderRadius.all(Radius.circular(25)),
                                                                        child: SizedBox(
                                                                          width: 500,
                                                                          height: 200,
                                                                          child: Builder(
                                                                              builder: (context) {
                                                                                return FlutterMap(

                                                                                  mapController: map,
                                                                                  options: MapOptions(
                                                                                    onMapReady: (){
                                                                                      map.move(centerPoint, 17);
                                                                                    },
                                                                                    scrollWheelVelocity: 0.0001,
                                                                                    keepAlive: true,
                                                                                    onTap: (tap,latlong){


                                                                                    },
                                                                                    center: centerPoint,
                                                                                    zoom: 15,
                                                                                  ),

                                                                                  children: [
                                                                                    StreamBuilder(
                                                                                        stream:Geolocator.getPositionStream(),
                                                                                        builder: (context,snapshot){
                                                                                          if(!snapshot.hasData)return Center();
                                                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                                          LatLng currentPos = LatLng(snapshot.data!.latitude,snapshot.data!.longitude);
                                                                                          double distance = Geolocator.distanceBetween(currentPos.latitude, currentPos.longitude, userAddress.lat, userAddress.long);
                                                                                          distanceFromCustomer = distance;
                                                                                          return Stack(
                                                                                            children: [
                                                                                              TileLayer(

                                                                                                urlTemplate: "https://api.mapbox.com/styles/v1/linoqui14/cldl76aim002v01o4pkskyxyd/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsMnRsaG1ndTA1aGsza25vMDRocjE5YXoifQ.RyE1w-7zHamlAuYrOSwO0Q",
                                                                                                additionalOptions: {
                                                                                                  'accessToken':'sk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsZGw3MG5zODI4b3IzcHFwamhjbjZ2NzAifQ.Y_8z_gTuWOYp2Xyf5whNMw',
                                                                                                  'id': 'mapbox.mapbox-streets-v8'
                                                                                                },
                                                                                                // userAgentPackageName: 'com.example.app',
                                                                                              ),
                                                                                              MarkerLayer(
                                                                                                markers: [
                                                                                                  Marker(
                                                                                                    point: currentPos,
                                                                                                    width: 40,
                                                                                                    height: 30,
                                                                                                    builder: (context) => Stack(
                                                                                                      alignment:Alignment.bottomCenter,
                                                                                                      children: [
                                                                                                        Icon(Icons.place_rounded,color: Colors.blue,),
                                                                                                        Text("You",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 8,color: Colors.white ,)),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  Marker(
                                                                                                    point: centerPoint,
                                                                                                    width: 40,
                                                                                                    height: 30,
                                                                                                    builder: (context) => Column(
                                                                                                      // alignment:Alignment.center,
                                                                                                      children: [
                                                                                                        Text('distance',style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 5,color: Colors.white ,height: 1)),
                                                                                                        Text(distance.toStringAsFixed(2)+"m",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 8,color: Colors.white ,height: 1)),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),

                                                                                                  Marker(
                                                                                                    point: LatLng(userAddress.lat,userAddress.long),
                                                                                                    width: 40,
                                                                                                    height: 30,
                                                                                                    builder: (context) => Stack(
                                                                                                      alignment:Alignment.bottomCenter,
                                                                                                      children: [
                                                                                                        Icon(Icons.place_rounded,color: Colors.orange,),
                                                                                                        Text("Customer",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 8,color: Colors.white ,)),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),

                                                                                                ],

                                                                                              ),
                                                                                              FutureBuilder(
                                                                                                  future: http.get(Uri.parse('https://api.mapbox.com/directions/v5/mapbox/driving/${currentPos.longitude}%2C${currentPos.latitude}%3B${userAddress.long}%2C${userAddress.lat}?alternatives=false&geometries=geojson&language=en&overview=simplified&steps=true&access_token=pk.eyJ1IjoibGlub3F1aTE0IiwiYSI6ImNsMnRsaG1ndTA1aGsza25vMDRocjE5YXoifQ.RyE1w-7zHamlAuYrOSwO0Q')),
                                                                                                  builder: (context, snapshot) {
                                                                                                    if(!snapshot.hasData)return Center();
                                                                                                    if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                                                    var json = jsonDecode(snapshot.data!.body);
                                                                                                    var coordinates = json['routes'][0]['geometry']['coordinates'];
                                                                                                    List<LatLng> latlongs = [];
                                                                                                    for(var coordinate in coordinates){
                                                                                                      LatLng latlong = LatLng(coordinate[1],coordinate[0]);
                                                                                                      latlongs.add(latlong);

                                                                                                    }

                                                                                                    return  PolylineLayer(
                                                                                                      polylineCulling: false,
                                                                                                      polylines: [
                                                                                                        Polyline(
                                                                                                          strokeWidth: 2,
                                                                                                          points: latlongs,
                                                                                                          color: Colors.blue,
                                                                                                        ),
                                                                                                      ],
                                                                                                    );


                                                                                                  }
                                                                                              )

                                                                                            ],
                                                                                          );
                                                                                        }
                                                                                    ),



                                                                                  ],
                                                                                );
                                                                              }
                                                                          ),
                                                                        ),
                                                                      );

                                                                    }
                                                                );
                                                              }
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
                                                                  height: 180,

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
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              CustomTextButton(
                                                                color: Colors.blue,
                                                                text: "Drop",
                                                                onHold: (){
                                                                  Controller.getCollectionWhere(collectionName: 'cart_items', field: 'orderID', value:order.id ).then((value) {
                                                                      List<CartItem> carts = [];
                                                                      for(var cartd in value.docs){
                                                                        CartItem cart =  CartItem.toObject(object: cartd.data());
                                                                        carts.add(cart);
                                                                      }
                                                                      for(var cart in carts){
                                                                        Controller.getCollectionWhere(collectionName: 'products', field: 'id', value:cart.productID ).then((prod) {
                                                                          Product product = Product.toObject(object: prod.docs.first.data());
                                                                          Controller.getCollectionWhere(collectionName: 'stocks', field: 'id', value:product.stockID ).then((stok) {
                                                                            Stock stock = Stock.toObject(object: stok.docs.first.data());
                                                                            stock.sold+=cart.totalCartItemQuantity;
                                                                            stock.stock-=cart.totalCartItemQuantity;
                                                                            stock.upsert();
                                                                          });
                                                                        });
                                                                      }
                                                                  });
                                                                  // if(distanceFromCustomer>10){
                                                                  //   Fluttertoast.showToast(
                                                                  //       msg: "Not near enough to drop!",
                                                                  //       toastLength: Toast.LENGTH_SHORT,
                                                                  //       gravity: ToastGravity.CENTER,
                                                                  //       timeInSecForIosWeb: 1,
                                                                  //       backgroundColor: Colors.red,
                                                                  //       textColor: Colors.white,
                                                                  //       fontSize: 12
                                                                  //   );
                                                                  //   return;
                                                                  // }
                                                                  Fluttertoast.showToast(
                                                                      msg: "Drop successfully!",
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                      gravity: ToastGravity.CENTER,
                                                                      timeInSecForIosWeb: 1,
                                                                      backgroundColor: Colors.blue,
                                                                      textColor: Colors.white,
                                                                      fontSize: 12
                                                                  );
                                                                  order.status=OrderStatus.DELIVERED;
                                                                  order.upsert();
                                                                  setState(() {

                                                                  });

                                                                },
                                                              ),
                                                              Expanded(child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                child: Text("Hold to drop, please make sure you are in at least 10 meters near the customer's location.",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 8,height: 1,color: Colors.grey ,)),
                                                              ))
                                                            ],
                                                          )


                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          }
                                      ),
                                    )

                                  ],
                                );


                              }
                          ),
                          Scaffold(
                            body:  Column(
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
                                      stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'riderID', value: widget.rider.id),
                                      builder: (context, snapshot) {
                                        if(!snapshot.hasData)return Center();
                                        if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                        if(snapshot.data!.docs.isEmpty)return Center();
                                        List<OrderDetails> orderDetails = [];
                                        for(var query in snapshot.data!.docs){
                                          OrderDetails orderDetail = OrderDetails.toObject(object: query.data());
                                          if(orderDetail.status!=OrderStatus.DELIVERED)continue;
                                          if(orderDetail.orderType!=OrderType.DELIVERY)continue;
                                          orderDetails.add(orderDetail);
                                          // print(query.data());
                                        }
                                        double distanceFromCustomer = 0;
                                        return Container(
                                          height: Tools.getDeviceHeight(context)*.560,
                                          padding: EdgeInsets.all(10),
                                          width: Tools.getDeviceWidth(context),
                                          child: Scrollbar(
                                            trackVisibility: true,
                                            child: ListView(
                                              children: orderDetails.map((order) {
                                                return Container(
                                                  alignment: Alignment.topCenter,
                                                  margin: EdgeInsets.all(10),
                                                  padding: EdgeInsets.all(10),
                                                  width: double.infinity,
                                                  height: 300,
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
                                                          stream: Controller.getCollectionStreamWhere(collectionName: 'users', field: 'id', value: order.userID),
                                                          builder: (context, snapshot) {
                                                            if(!snapshot.hasData)return Center();
                                                            if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                            if(snapshot.data!.docs.isEmpty)return Center();
                                                            User user = User.toObject(object: snapshot.data!.docs.first.data());
                                                            return Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          width:Tools.getDeviceWidth(context)*.82,
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text("Customer's Name",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                              Text("Qty.${order.totalItems.toString()}",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,),),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        StreamBuilder(
                                                                            stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: order.userID),
                                                                            builder: (context, snapshot) {
                                                                              if(!snapshot.hasData)return Center();
                                                                              if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                                                              if(snapshot.data!.docs.isEmpty)return Center();
                                                                              UserAddress userAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());

                                                                              return Container(
                                                                                width:Tools.getDeviceWidth(context)*.82,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(user.firstname,style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 20,height: 1,color: Colors.blue ,),),
                                                                                        SizedBox(
                                                                                            width:200,
                                                                                            child: Text(userAddress.address,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.grey ,),)),
                                                                                      ],
                                                                                    ),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text("Total Price",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,color: Colors.grey ,)),
                                                                                        Text("Php."+order.totalPrice.toString(),style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.orange ,)),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }
                                                                        ),
                                                                      ],
                                                                    ),

                                                                  ],
                                                                ),

                                                              ],
                                                            );
                                                          }
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
                                                              height: 180,

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
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                )

                              ],
                            ),
                            bottomNavigationBar: BottomAppBar(

                              child: StreamBuilder(
                                  stream: Controller.getCollectionStreamWhere(collectionName: 'orders', field: 'riderID', value: widget.rider.id),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData)return Center();
                                    if(snapshot.connectionState==ConnectionState.waiting)return Center();
                                    if(snapshot.data!.docs.isEmpty)return Center();
                                    int totalSold = 0;
                                    int totalValueSold = 0;
                                    List<OrderDetails> orderDetails = [];
                                    for(var query in snapshot.data!.docs){
                                      OrderDetails orderDetail = OrderDetails.toObject(object: query.data());
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
                                              Text('Sold Container',style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 10)),
                                              Text(totalSold.toString(),style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,color:Colors.blue,fontSize: 15)),
                                            ],
                                          ),
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                                          Column(
                                            children: [
                                              Text('Value Sold',style:  GoogleFonts.notoSansNKo(fontWeight: FontWeight.normal,color:Colors.grey,fontSize: 10)),
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
                  int selectedIndex = 0;
                  return StatefulBuilder(
                      builder: (context,updateNavigation) {
                        return TabBar(
                          isScrollable: false,
                          indicatorColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          splashBorderRadius: BorderRadius.zero,
                          onTap: (value){
                            updateNavigation((){
                              selectedIndex = value;
                            });

                          },
                          controller: tabController,
                          tabs: [
                            Tab(
                              icon:  Icon(Icons.list_alt_outlined,color: selectedIndex==0?Colors.blue:Colors.grey,),
                            ),
                            Tab(
                              icon:  Icon(Icons.assignment_turned_in_outlined,color: selectedIndex==1?Colors.blue:Colors.grey,),
                            ),
                            Tab(
                              icon: Icon(Icons.receipt_long_outlined,color: selectedIndex==2?Colors.blue:Colors.grey,),
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