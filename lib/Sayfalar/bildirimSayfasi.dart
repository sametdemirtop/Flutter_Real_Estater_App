import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/realestate/buildDetail.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'AnaSayfa.dart';

// ignore: camel_case_types
class bildirimSayfasi extends StatefulWidget {
  @override
  _bildirimSayfasiState createState() => _bildirimSayfasiState();
}

// ignore: camel_case_types
class _bildirimSayfasiState extends State<bildirimSayfasi>
    with AutomaticKeepAliveClientMixin<bildirimSayfasi> {
  List<Bildirim>? tumBildirimler = [];
  @override
  void initState() {
    bildirimleriGetir();
    super.initState();
  }

  bildirimleriGetir() async {
    QuerySnapshot snapshot = await bildirimRef
        .doc(anlikKullanici!.id)
        .collection("bildirimler")
        .orderBy('timestamp', descending: true)
        .get();
    List<Bildirim> bildirimler = snapshot.docs
        .map((e) =>
            Bildirim.fromDocument(e as DocumentSnapshot<Map<String, dynamic>>?))
        .toList(growable: false);
    setState(() {
      this.tumBildirimler = bildirimler;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Bildirimler",
          style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 23,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: bildirimRef
                .doc(anlikKullanici!.id)
                .collection("bildirimler")
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty == true) {
                  return RefreshIndicator(
                      color: Colors.black,
                      child: Center(
                        child: Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off,
                                    size: 100, color: Colors.blueGrey.shade100),
                                Text(
                                  "Henüz Bildirim yok",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.blueGrey.shade100),
                                )
                              ]),
                        ),
                      ),
                      onRefresh: () {
                        return bildirimleriGetir();
                      });
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      List<Bildirim> bildirimler1 = snapshot.data!.docs
                          .map((e) => Bildirim.fromDocument(
                              e as DocumentSnapshot<Map<String, dynamic>>?))
                          .toList();
                      return ListView(
                        children: bildirimler1,
                      );
                    },
                  );
                }
              } else {
                return circularProgress();
              }
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

String bilidirmAciklamasi = "";
Widget? bildirimSecenek;

class Bildirim extends StatelessWidget {
  final String? username;
  final String? type;
  final String? commentData;
  final String? ilanID;
  final String? userID;
  final String? userProfileImg;
  final String? frontUrl;
  final Timestamp? timestamp;
  final String? ownerID;

  Bildirim(
      {this.username,
      this.type,
      this.commentData,
      this.ilanID,
      this.userID,
      this.userProfileImg,
      this.timestamp,
      this.frontUrl,
      this.ownerID});

  factory Bildirim.fromDocument(DocumentSnapshot<Map<String, dynamic>>? doc) {
    return Bildirim(
      username: doc!['username'],
      type: doc['type'],
      userID: doc['userID'],
      ilanID: doc['ilanID'],
      userProfileImg: doc['userProfileImg'],
      timestamp: doc['timestamp'],
      frontUrl: doc['frontUrl'],
      commentData: doc['commentData'],
      ownerID: doc['ownerID'],
    );
  }
  @override
  Widget build(BuildContext context) {
    bildirimSecenekDuzenle(context);

    return Container(
      child: ListTile(
        title: GestureDetector(
          onTap: () {
            displayUserProfile(context, userProfileID: userID);
          },
          child: RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                      text: username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  TextSpan(
                    text: "$bilidirmAciklamasi",
                  ),
                ]),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            displayUserProfile(context, userProfileID: userID);
          },
          child: Container(
            height: 50,
            width: 50,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 10,
                        color: Colors.grey)
                  ],
                  image: DecorationImage(
                      fit: BoxFit.cover, image: NetworkImage(userProfileImg!)),
                ),
              ),
            ),
          ),
        ),
        subtitle: Text(
          timeago.format(timestamp!.toDate()),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black45),
        ),
        trailing: bildirimSecenek,
      ),
    );
  }

  bildirimSecenekDuzenle(context) {
    if (type == 'like' || type == 'comment' || type == 'kaydetme') {
      bildirimSecenek = InkWell(
        onTap: () {
          gonderiyiGoster(context, ilanID: ilanID, kullaniciID: userID);
        },
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
                ],
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(frontUrl!)),
              ),
            ),
          ),
        ),
      );
    } else {
      bildirimSecenek = Text("");
    }
    if (type == 'Follow') {
      bilidirmAciklamasi = " " + "seni takip etmeye başladı";
    } else if (type == 'comment') {
      bilidirmAciklamasi = " " + "yorum yaptı : " + commentData!;
    } else if (type == 'like') {
      bilidirmAciklamasi = " " + "senin ilanını beğendi";
    } else if (type == 'kaydetme') {
      bilidirmAciklamasi = " " + "senin ilanını kaydetti";
    } else {
      bilidirmAciklamasi = "Error type  $type";
    }
  }
}

gonderiyiGoster(context, {String? ilanID, String? kullaniciID}) {
  return FutureBuilder<DocumentSnapshot>(
      future: ilanRef.doc(ilanID).get(),
      builder: (context, snp) {
        if (!snp.hasData) {
          return circularProgress();
        } else {
          return BuildDetail.fromDocument(snp.data!);
        }
      });
}

displayUserProfile(context, {String? userProfileID}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => profilSayfasi(
                kullaniciprofilID: userProfileID,
                ilanID: '',
              )));
}
