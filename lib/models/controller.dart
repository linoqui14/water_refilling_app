

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Controller {
  static final _db = FirebaseFirestore.instance;
  final String collectionName;
  late String id;


  Controller({required this.collectionName,required this.id});

  Map<String,dynamic> toJson();


  Future<void> upsert() async{
    _db.collection(collectionName).doc(id).set(toJson());
  }



  Stream<DocumentSnapshot<Map<String, dynamic>>> getByID({required String id}){
    return _db.collection(collectionName).doc(id).snapshots();
  }
  Future<CollectionReference<Map<String,dynamic>>> getThisCollection() async{
    return _db.collection(collectionName);
  }
  static Future<CollectionReference<Map<String,dynamic>>> getCollection({required String collectionName}) async{
    return _db.collection(collectionName);
  }
  static Future<QuerySnapshot<Map<String, dynamic>>> getCollectionWhere({required String collectionName,required String field,required String value}) async{
    return _db.collection(collectionName).where(field,isEqualTo: value).get();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStreamWhere({required String collectionName,required String field,required String value}){
    return _db.collection(collectionName).where(field,isEqualTo: value).snapshots();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream({required String collectionName}) {
    return _db.collection(collectionName).snapshots();
  }
  static String genID(int lengthOfID){
    final random = Random();
    const allChars='AaBbCcDdlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1EeFfGgHhIiJjKkL234567890';
    // below statement will generate a random string of length using the characters
    // and length provided to it
    final randomString = List.generate(lengthOfID,
            (index) => allChars[random.nextInt(allChars.length)]).join();
    return randomString;    // return the generated string
  }




}