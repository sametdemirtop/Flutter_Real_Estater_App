import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'AnaSayfa.dart';

// ignore: must_be_immutable, camel_case_types
class yorumSayfasi extends StatefulWidget {
  final String? ilanID;
  final String? postOwnerID;
  final String? postUrl;
  yorumSayfasi({this.ilanID, this.postOwnerID, this.postUrl});

  TextEditingController yorumduzeltmeKontrolu = TextEditingController();
  yorumlariGoster() => createState().yorumlariGoster();

  @override
  _yorumSayfasiState createState() => _yorumSayfasiState(
      ilanID: ilanID, postOwnerID: postOwnerID, postUrl: postUrl);
}

// ignore: camel_case_types
class _yorumSayfasiState extends State<yorumSayfasi> {
  final String? ilanID;
  final String? postOwnerID;
  final String? postUrl;
  _yorumSayfasiState({this.ilanID, this.postOwnerID, this.postUrl});

  var formKey = GlobalKey<FormState>();

  // ignore: missing_return
  yorumlariGoster() {
    return StreamBuilder<QuerySnapshot>(
        stream: yorumRef
            .doc(ilanID)
            .collection("yorumlar")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<yorum> yorumlar = [];
          snapshot.data!.docs.forEach((document) {
            yorumlar.add(yorum.fromDocument(document));
          });
          return Container(
            color: Colors.grey.shade100,
            child: ListView(
              children: yorumlar,
            ),
          );
        });
  }

  yorumlariKaydet() {
    yorumRef.doc(ilanID).collection("yorumlar").add({
      "username": anlikKullanici!.username,
      "comment": widget.yorumduzeltmeKontrolu.text,
      "timestamp": DateTime.now(),
      "url": anlikKullanici!.url,
      "userID": anlikKullanici!.id,
    });
    bool isNotPostOwner = postOwnerID != anlikKullanici!.id;
    if (isNotPostOwner) {
      bildirimRef.doc(postOwnerID).collection("bildirimler").add({
        "type": "comment",
        "commentData": widget.yorumduzeltmeKontrolu.text,
        "ilanID": ilanID,
        "userID": anlikKullanici!.id,
        "username": anlikKullanici!.username,
        "userProfileImg": anlikKullanici!.url,
        "url": postUrl,
        "timestamp": timestamp,
        "ownerID": postOwnerID,
      });
    }
    widget.yorumduzeltmeKontrolu.clear();
    setState(() {
      StreamBuilder<QuerySnapshot>(
          stream: yorumRef
              .doc(ilanID)
              .collection("yorumlar")
              .orderBy("timestamp", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<yorum> yorumlar = [];
            snapshot.data!.docs.forEach((document) {
              yorumlar.add(yorum.fromDocument(document));
            });
            return Container(
              color: Colors.white,
              child: ListView(
                children: yorumlar,
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Yorumlar",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: yorumlariGoster(),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
              ], borderRadius: BorderRadius.circular(30), color: Colors.black),
              height: 50.0,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 3),
                    // Button send image
                    Padding(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(anlikKullanici!.url),
                      ),
                      padding: EdgeInsets.only(top: 0),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    // Edit text
                    Flexible(
                      child: Container(
                        child: TextFormField(
                          key: formKey,
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                          controller: widget.yorumduzeltmeKontrolu,
                          decoration: InputDecoration.collapsed(
                            hintText: "Yorum yaz..",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                    // Button send message
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        yorumlariKaydet();
                      },
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildInputPadding() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 65,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 1,
                color: Colors.grey.shade400)
          ], borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: ListTile(
            title: Row(
              children: [
                Padding(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(anlikKullanici!.url),
                  ),
                  padding: EdgeInsets.only(top: 0),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: widget.yorumduzeltmeKontrolu,
                        decoration: InputDecoration.collapsed(
                          hintText: "Yorum yaz",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(color: Colors.black),
                        validator: (girilenDeger) {},
                        onSaved: (kaydedilecekDeger) {
                          widget.yorumduzeltmeKontrolu.text =
                              kaydedilecekDeger!;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  size: 30,
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    yorumlariKaydet();
                  }
                },
                color: Colors.green.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class yorum extends StatefulWidget {
  final String username;
  final String userID;
  final String url;
  final String comment;
  final Timestamp timestamp;
  yorum({
    required this.username,
    required this.userID,
    required this.url,
    required this.comment,
    required this.timestamp,
  });
  factory yorum.fromDocument(DocumentSnapshot doc) {
    return yorum(
      username: doc['username'],
      userID: doc['userID'],
      url: doc['url'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  _yorumState createState() => _yorumState();
}

// ignore: camel_case_types
class _yorumState extends State<yorum> {
  var formKey = GlobalKey<FormState>();
  bool onay = false;

  yorumSil() async {
    List<Ilanlar> gonderis = [];
    QuerySnapshot ss = await akisRef.get();
    ss.docs.forEach((document) {
      gonderis.add(Ilanlar.fromDocument(document));
    });
    for (var doc in gonderis) {
      QuerySnapshot commentquerySnapshot = await yorumRef
          .doc(doc.ilanID)
          .collection("yorumlar")
          .where("comment", isEqualTo: widget.comment)
          .get();
      commentquerySnapshot.docs.forEach((document) async {
        yorum yorums = yorum.fromDocument(document);
        if (anlikKullanici!.id == yorums.userID) {
          if (document.exists) {
            document.reference.delete();
            SnackBar snackBar = SnackBar(
              content: Text("Yorum Silindi.."),
              duration: Duration(seconds: 0, milliseconds: 500),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          QuerySnapshot<Map<String, dynamic>> qs = await bildirimRef
              .doc(doc.ownerID)
              .collection("bildirimler")
              .where("commentData", isEqualTo: widget.comment)
              .get();
          qs.docs.forEach((document) {
            if (document.exists) {
              document.reference.delete();
            }
          });
        } else {
          SnackBar snackBar =
              SnackBar(content: Text("Başkasının yorumu silinemez"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            StreamBuilder<QuerySnapshot>(
                stream: yorumRef
                    .doc(doc.ilanID)
                    .collection("yorumlar")
                    .orderBy("timestamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return circularProgress();
                  }
                  List<yorum> yorumlar = [];
                  snapshot.data!.docs.forEach((document) {
                    yorumlar.add(yorum.fromDocument(document));
                  });
                  return Container(
                    color: Colors.white,
                    child: ListView(
                      children: yorumlar,
                    ),
                  );
                });
          });
        }
      });
    }
  }

  TextSpan newTextSpan() {
    return TextSpan(
      children: [
        TextSpan(
            text: widget.username + " ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15)),
        TextSpan(
            text: widget.comment,
            style: TextStyle(color: Colors.black, fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [
          Dismissible(
            onDismissed: (direct) async {
              yorumSil();
            },
            key: Key(UniqueKey().toString()),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: RichText(
                text: newTextSpan(),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.url),
              ),
              subtitle: Text(
                timeago.format(widget.timestamp.toDate()),
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
