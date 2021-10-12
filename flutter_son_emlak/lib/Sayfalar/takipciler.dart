import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/widgets/baslik.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';

import 'AnaSayfa.dart';
import 'aramaSayfasi.dart';

// ignore: camel_case_types
class takipciler extends StatefulWidget {
  final String? kullaniciprofilID;
  final String? anlikKullaniciID;
  takipciler({this.kullaniciprofilID, this.anlikKullaniciID});
  @override
  _takipcilerState createState() => _takipcilerState();
}

// ignore: camel_case_types
class _takipcilerState extends State<takipciler> {
  List<takipci>? tumTakipciler = [];
  void initState() {
    super.initState();
    profilKontrol();
  }

  profilKontrol() {
    bool kendiProfilimi = widget.anlikKullaniciID == widget.kullaniciprofilID;
    if (kendiProfilimi) {
      return takipcileriGetirAnlik();
    } else {
      return takipcileriGetirKullanici();
    }
  }

  takipcileriGetirAnlik() async {
    QuerySnapshot snapshot = await takipciRef
        .doc(widget.anlikKullaniciID)
        .collection("takipciler")
        .get();

    List<takipci>? kullanicires1 =
        snapshot.docs.map((doc) => takipci.fromDocument(doc)).toList();
    setState(() {
      this.tumTakipciler = kullanicires1;
    });
  }

  takipcileriGetirKullanici() async {
    QuerySnapshot snapshot = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .get();

    List<takipci>? kullanicires1 =
        snapshot.docs.map((doc) => takipci.fromDocument(doc)).toList();
    setState(() {
      this.tumTakipciler = kullanicires1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: kullaniciRef.snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<KullaniciSonuc>? kullaniciAramaSonucu = [];
          dataSnapshot.data!.docs.forEach((documents) {
            Kullanici? herbirKullanici = Kullanici.fromDocument(documents);
            for (var doc in tumTakipciler!) {
              if (doc.id == herbirKullanici.id) {
                KullaniciSonuc? userResult = KullaniciSonuc(herbirKullanici);
                kullaniciAramaSonucu.add(userResult);
              }
            }
          });
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: baslik(context, strBaslik: "Takipçiler"),
            body: RefreshIndicator(
              color: Colors.black,
              child: ListView(
                children: kullaniciAramaSonucu,
              ),
              onRefresh: () {
                return profilKontrol();
              },
            ),
          );
        });
  }
}

// ignore: camel_case_types
class takipci {
  final String id;
  final String username;
  final String url;
  final String profileName;

  takipci(
      {required this.id,
      required this.username,
      required this.url,
      required this.profileName});

  factory takipci.fromDocument(DocumentSnapshot doc) {
    return takipci(
      id: doc['id'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
    );
  }
}
