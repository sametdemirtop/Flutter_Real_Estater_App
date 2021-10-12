import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IlanPhotos extends StatefulWidget {
  final String? postID;
  final String? ownerID;
  final String? username;
  final String? location;
  final String? url;
  final String? ilanID;
  final Timestamp? timestamp;

  IlanPhotos({
    this.ilanID,
    this.ownerID,
    this.username,
    this.timestamp,
    this.location,
    this.url,
    this.postID,
  });
  factory IlanPhotos.fromDocument(DocumentSnapshot doc) {
    return IlanPhotos(
      ilanID: doc['ilanID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
      timestamp: doc['timestamp'],
      location: doc['location'],
      url: doc['url'],
      postID: doc['postID'],
    );
  }

  @override
  _IlanPhotosState createState() => _IlanPhotosState(
        ilanID: this.ilanID!,
        ownerID: this.ownerID!,
        username: this.username!,
        timestamp: this.timestamp!,
        location: this.location!,
        url: this.url!,
        postID: this.postID!,
      );
}

class _IlanPhotosState extends State<IlanPhotos> {
  final String? ilanID;
  final String? ownerID;
  final String? username;
  final String? location;
  final String? url;
  final String? postID;
  final Timestamp? timestamp;

  _IlanPhotosState({
    this.ilanID,
    this.ownerID,
    this.username,
    this.location,
    this.url,
    this.postID,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover),
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }
}
