import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';

import 'AnaSayfa.dart';

class Favoriler extends StatefulWidget {
  final String? kullaniciID;
  Favoriler({
    required this.kullaniciID,
  });
  @override
  _FavorilerState createState() => _FavorilerState();
}

class _FavorilerState extends State<Favoriler> {
  List<Favori> tumIlan = [];

  @override
  void initState() {
    super.initState();
    kaydetmeGetir();
  }

  kaydetmeGetir() async {
    QuerySnapshot<Map<String, dynamic>> snapshot1 =
        await favoriRef.doc(widget.kullaniciID).collection("Favoriler").get();
    List<Favori> kullanicires =
        snapshot1.docs.map((doc) => Favori.fromDocument(doc.data())).toList();
    setState(() {
      this.tumIlan = kullanicires;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: ilanRef.snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<Ilanlar> tumIlanlar = [];
          dataSnapshot.data!.docs.forEach((element) {
            Ilanlar ilan = Ilanlar.fromDocument(element);
            for (var doc in tumIlan) {
              if (ilan.ilanID == doc.ilanID) {
                tumIlanlar.add(ilan);
              }
            }
          });
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.deepPurple[400]),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
              title: Text("Favoriler",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[400],
                  )),
              backgroundColor: Colors.white,
            ),
            body: RefreshIndicator(
                color: Colors.black,
                child: ListView(
                  children: tumIlanlar,
                ),
                onRefresh: () {
                  return kaydetmeGetir();
                }),
          );
        });
  }

  onUserTap(String userId, String ilanID) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                profilSayfasi(kullaniciprofilID: userId, ilanID: ilanID)));
  }
}

class Favori {
  final String ilanID;
  final String ownerID;
  final String username;

  Favori({
    required this.ilanID,
    required this.username,
    required this.ownerID,
  });

  factory Favori.fromDocument(Map<String, dynamic> doc) {
    return Favori(
      ilanID: doc['ilanID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
    );
  }
}
