

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:water_refilling_app/models/user_address.dart';
import 'package:water_refilling_app/my_widgets/custom_text_button.dart';
import 'package:water_refilling_app/my_widgets/custom_textfield.dart';
import 'package:water_refilling_app/models/feedback.dart' as fd;
import '../models/cart.dart';
import '../models/controller.dart';
import '../models/feedback.dart';
import '../models/product.dart';
import '../models/station.dart';
import '../models/stock.dart';
import '../models/user.dart';
import '../tools/variables.dart';
import 'package:lottie/lottie.dart' as lot;

class StationPage extends StatefulWidget{
  const StationPage({super.key,required this.station,required this.user,});
  final Station station;
  final User user;
  @override
  State<StatefulWidget> createState() => _StationPageState();

}

class _StationPageState extends State<StationPage>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        body: SafeArea(
          child: Container(
            height: Tools.getDeviceHeight(context)*.95,
            width: Tools.getDeviceWidth(context),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: Tools.getDeviceWidth(context)*.8,
                            child: Text(widget.station.name,style: GoogleFonts.lobster(fontWeight: FontWeight.bold,fontSize: 40,color: Colors.blue),maxLines: 3,)
                        ),
                        StreamBuilder(
                            stream: Controller.getCollectionStreamWhere(collectionName: 'stations', field: 'id', value: widget.station.id),
                            builder: (context,snapshot){
                              if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                              if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                              Station station = Station.toObject(object: snapshot.data!.docs.first.data());
                              bool isOpen = station.status=='open'?true:false;
                              return Container(
                                alignment: Alignment.center,
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color: isOpen?Colors.green:Colors.deepOrange
                                ),
                                child: Text(station.status,style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.white ,),),
                              );
                            }
                        )
                      ],
                    ),
                    Text(widget.station.address,style: GoogleFonts.quicksand(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.grey),),
                    FutureBuilder(
                        future:  http.get(Uri.parse("https://geocode.maps.co/search?q=${widget.station.address}")),
                        builder: (context,snapshot) {
                          if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                          if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                          var json = jsonDecode(snapshot.data!.body);
                          double lat = double.parse(json.first['lat']);
                          double long = double.parse(json.first['lon']);
                          MapController map = MapController();
                          LatLng selectedLocation = LatLng(lat, long);

                          // late Function(Function()) _updateMapOnly;
                          // .then((value) {
                          //    var json = jsonDecode(value.body);
                          //    // 1128 kauswagan cagayan de Oro city

                          //    print(lat);
                          //    selectedLocation = LatLng(lat, long);
                          //    _updateMapOnly.
                          //
                          //  });
                          return StreamBuilder(
                              stream: Controller.getCollectionStreamWhere(collectionName: 'user_addresses', field: 'userID', value: widget.user.id),
                              builder: (context, snapshot) {
                                if(!snapshot.hasData)return Center(child: CircularProgressIndicator(),);
                                if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                UserAddress userAddress = UserAddress.toObject(object: snapshot.data!.docs.first.data());
                                double cLat = (userAddress.lat+lat)/2;
                                double cLong = (userAddress.long+long)/2;

                                LatLng centerPoint = LatLng(cLat, cLong);

                                return StatefulBuilder(
                                    builder: (context,updateMapOnly) {
                                      // _updateMapOnly = updateMapOnly;
                                      return ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(25)),
                                        child: SizedBox(
                                          width: 500,
                                          height: 150,
                                          child: FlutterMap(
                                            mapController: map,

                                            options: MapOptions(
                                              interactiveFlags: InteractiveFlag.pinchZoom,
                                              maxZoom: 18,
                                              minZoom: 10,
                                              onMapReady: (){

                                                map.move(centerPoint, 17);


                                              },
                                              scrollWheelVelocity: 0.0001,
                                              keepAlive: true,
                                              center: centerPoint,
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
                                                    point: selectedLocation,
                                                    width: 15,
                                                    height: 15,
                                                    builder: (context) => Icon(Icons.place_rounded,color: Colors.blue,),
                                                  ),
                                                  Marker(
                                                    point: LatLng(userAddress.lat,userAddress.long),
                                                    width: 50,
                                                    height: 50,
                                                    builder: (context) => Column(
                                                      children: [
                                                        Icon(Icons.person_pin,color: Colors.blue,),
                                                        Text("You",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.bold,fontSize: 8,height: 1,color: Colors.white ,),)
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                );
                              }
                          );
                        }
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(
                        width: Tools.getDeviceWidth(context)*.9,
                        child: Text("Products",style: GoogleFonts.quicksand(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black54),maxLines: 3,)
                    ),
                    StreamBuilder(
                        stream: Controller.getCollectionStreamWhere(collectionName: 'products', field: 'stationID', value: widget.station.id),
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
                          return SizedBox(
                            height: Tools.getDeviceHeight(context)*.5,
                            child: ListView(
                              children: products.map((product){
                                return Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10),
                                  height: 100,
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

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Image.network(product.imgURL,width: 80,fit: BoxFit.fitHeight,),
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
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              Controller.getCollectionWhere(collectionName: 'cart_items', field: 'userID', value:widget.user.id).then((value) {

                                                if(value.docs.isEmpty){
                                                  print("Kalungat");
                                                  Fluttertoast.showToast(
                                                      msg: "Successfully added to your cart!",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.blue,
                                                      textColor: Colors.white,
                                                      fontSize: 12
                                                  );
                                                  CartItem cart = CartItem(userID: widget.user.id, productID: product.id, status: 'oncart', stationID: widget.station.id);
                                                  cart.upsert();
                                                  return;
                                                }
                                                if( value.docs.where((element) {
                                                  CartItem cart = CartItem.toObject(object: element.data());
                                                  return cart.productID == product.id&&cart.status!='checkout';
                                                }).isNotEmpty){
                                                  Fluttertoast.showToast(
                                                      msg: "This product is already in your cart!",
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.orange,
                                                      textColor: Colors.white,
                                                      fontSize: 12
                                                  );
                                                  return;
                                                }
                                                Fluttertoast.showToast(
                                                    msg: "Successfully added to your cart!",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.blue,
                                                    textColor: Colors.white,
                                                    fontSize: 12
                                                );
                                                CartItem cart = CartItem(userID: widget.user.id, productID: product.id,status: 'oncart',stationID: widget.station.id);
                                                cart.upsert();

                                              });


                                            },
                                            child: Icon(Icons.add_shopping_cart_outlined,color: Colors.blue),
                                          ),
                                          Text("Add to cart.",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 12,height: 1,color: Colors.grey ,),),

                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          alignment: Alignment.center,
          height: 30,
          width: 70,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(120),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: Offset(1, 3), // changes position of shadow
                ),
              ],
              color: Colors.orange,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              shape: BoxShape.rectangle
          ),
          child: GestureDetector(
            child: Text("Add feedback",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 8,height: 1,color: Colors.white ,),),
            onTap: (){
              int stars = 1;
              TextEditingController comment = TextEditingController();
              bool nameVisible = false;
              Tools.statefulDialog(
                  context: context,
                  builder: (context,updateFeedback){
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.white
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        height: 350,
                        child: Column(

                          children: [
                            Text("Add your thoughts about the service.",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 13,height: 1,color: Colors.grey ,)),
                            CustomTextField(
                              minLines: 5,
                              hint: 'Comments',
                              controller: comment,
                              color: Colors.blue,
                            ),
                            Text("Star Rating",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 13,height: 1,color: Colors.grey ,)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [1,2,3,4,5].map((rate){

                                return IconButton(
                                    onPressed: (){
                                      updateFeedback((){
                                        stars = rate;
                                      });
                                    },
                                    icon: Icon(Icons.star,color:stars<rate?Colors.grey:Colors.yellow),
                                );
                              }).toList(),
                            ),
                            Row(
                              children: [
                                Text("Show your name? ",style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 10,height: 1,color: Colors.grey ,)),
                                Checkbox(value: nameVisible, onChanged: (value){updateFeedback((){
                                  nameVisible= nameVisible?false:true;
                                });}),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextButton(
                                  style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 13,height: 1,color: Colors.white ,),
                                  color: Colors.blue,
                                  text: "Confirm",
                                  onPressed: (){
                                    FeedBack feedback = FeedBack(comment: comment.text,date: DateTime.now().toString(),star: stars,userID: widget.user.id,stationID: widget.station.id,nameVisible: nameVisible);
                                    feedback.upsert();
                                    Navigator.pop(context);
                                  },
                                ),
                                CustomTextButton(
                                  style: GoogleFonts.notoSansNKo(fontWeight: FontWeight.w100,fontSize: 13,height: 1,color: Colors.grey ,),
                                  color: Colors.transparent,
                                  text: "Cancel",
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                )
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
          ),
        )
    );
  }


}