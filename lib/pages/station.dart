

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:water_refilling_app/models/user_address.dart';
import '../models/cart.dart';
import '../models/controller.dart';
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
          height: Tools.getDeviceHeight(context),
          width: Tools.getDeviceWidth(context),
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
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
                            height: Tools.getDeviceHeight(context)*.8,
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
                                                  return cart.productID == product.id;
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
      ),
    );
  }


}