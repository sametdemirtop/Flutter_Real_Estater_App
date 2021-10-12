import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';

import 'AnaSayfa.dart';

class kaydedilenKartlar extends StatefulWidget {
  final String? kullaniciID;
  kaydedilenKartlar({
    required this.kullaniciID,
  });
  @override
  _kaydedilenKartlarState createState() => _kaydedilenKartlarState();
}

class _kaydedilenKartlarState extends State<kaydedilenKartlar> {
  List<Kaydetme> tumIlan = [];

  @override
  void initState() {
    super.initState();
    kaydetmeGetir();
  }

  kaydetmeGetir() async {
    QuerySnapshot<Map<String, dynamic>> snapshot1 = await kaydetmeRef
        .doc(widget.kullaniciID)
        .collection("Kaydedilen İlanlar")
        .get();
    List<Kaydetme> kullanicires =
        snapshot1.docs.map((doc) => Kaydetme.fromDocument(doc.data())).toList();
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
              title: Text("Kaydedilenler",
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

class Kaydetme {
  final String ilanID;
  final String ownerID;
  final String username;

  Kaydetme({
    required this.ilanID,
    required this.username,
    required this.ownerID,
  });

  factory Kaydetme.fromDocument(Map<String, dynamic> doc) {
    return Kaydetme(
      ilanID: doc['ilanID'],
      ownerID: doc['ownerID'],
      username: doc['username'],
    );
  }
}
