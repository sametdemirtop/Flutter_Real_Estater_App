import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/profilDuzenle.dart';
import 'package:flutter_son_emlak/Sayfalar/takipEdilenler.dart';
import 'package:flutter_son_emlak/Sayfalar/takipciler.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/widgets/gonderiListesi.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';

import 'AnaSayfa.dart';
import 'Favoriler.dart';
import 'MesajlasmaSayfasi.dart';
import 'gonderiEkranSayfasi.dart';
import 'kaydedilenKartlar.dart';

// ignore: camel_case_types
class profilSayfasi extends StatefulWidget {
  final String? kullaniciprofilID;
  final String? kullaniciUrl;
  final String? kullaniciUsername;
  final String? ilanID;
  profilSayfasi(
      {this.kullaniciprofilID,
      this.ilanID,
      this.kullaniciUrl,
      this.kullaniciUsername});

  @override
  _profilSayfasiState createState() => _profilSayfasiState();
}

// ignore: camel_case_types
class _profilSayfasiState extends State<profilSayfasi>
    with AutomaticKeepAliveClientMixin<profilSayfasi> {
  final String? onlineKullaniciID = anlikKullanici!.id;
  final ScrollController controller = ScrollController();
  List<Ilanlar>? gonderiListesi = [];
  // ignore: non_constant_identifier_names
  String? GonderiStili = "grid";
  int? gonderiHesapla = 0;
  int? toplamTakipciHesapla = 0;
  int? toplamTakipEdilenHesapla = 0;
  bool? takip = false;
  bool? yuklenme = false;

  @override
  void initState() {
    super.initState();
    tumProfiliGetir();
    tumTakipedilenleriGetirveHesapla();
    tumTakipcileriGetirveHesapla();
    takipEdiyormu();
  }

  tumTakipedilenleriGetirveHesapla() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await takipEdilenRef
        .doc(widget.kullaniciprofilID)
        .collection("takipEdilenler")
        .get();
    setState(() {
      toplamTakipEdilenHesapla = querySnapshot.docs.length;
    });
  }

  takipEdiyormu() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .get();
    setState(() {
      takip = documentSnapshot.exists;
    });
  }

  tumTakipcileriGetirveHesapla() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .get();
    setState(() {
      toplamTakipciHesapla = querySnapshot.docs.length;
    });
  }

  PreferredSize baslikOlustur() {
    return PreferredSize(
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Profil",
            style: TextStyle(
                color: Colors.deepPurple[400],
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
        ),
        preferredSize: Size.fromHeight(55));
  }

  takipEdilenleriGor() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => takipEdilenler(
                kullaniciprofilID: widget.kullaniciprofilID,
                anlikKullaniciID: onlineKullaniciID)));
  }

  takipcileriGor() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => takipciler(
                kullaniciprofilID: widget.kullaniciprofilID,
                anlikKullaniciID: onlineKullaniciID)));
  }

  profilBasligi() {
    return StreamBuilder<DocumentSnapshot>(
      stream: kullaniciRef.doc(widget.kullaniciprofilID).snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        Kullanici kullanici = Kullanici.fromDocument(dataSnapshot.data!);
        var size = MediaQuery.of(context).size;
        return Container(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: 10,
                        color: Colors.blueGrey.shade50)
                  ],
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Container(
                        width: (size.width - 3) / 3,
                        height: (size.height - 3) / 6,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 6),
                                  blurRadius: 1,
                                  color: Colors.blueGrey.shade50)
                            ],
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: NetworkImage(kullanici.url),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  kullanici.profileName,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Color(0x54000000),
                        spreadRadius: 2,
                        blurRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  kullanici.biography,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              widget.kullaniciprofilID == onlineKullaniciID
                  ? Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 5),
                      child: InkWell(
                        onTap: () {
                          kullaniciProfilDuzenle();
                        },
                        child: Center(
                          child: Text(
                            "Profil Düzenle",
                            style: TextStyle(
                                color: Colors.indigoAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                      ),
                    )
                  : Text(""),
              SizedBox(
                height: 16,
              ),
              Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (widget.kullaniciprofilID == onlineKullaniciID)
                          ? Expanded(
                              child: favorilerButonu(),
                            )
                          : Expanded(
                              child: mesajButonu(),
                            ),
                      (widget.kullaniciprofilID == onlineKullaniciID)
                          ? Expanded(
                              child: kaydedilenlerButonu(),
                            )
                          : Text(""),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: listeVeyaGridGonderiOlustur(),
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ilanRef
                        .where("ownerID", isEqualTo: onlineKullaniciID)
                        .snapshots(),
                    builder: (context, snp) {
                      if (!snp.hasData) {
                        return circularProgress();
                      } else {
                        return Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) =>
                                Ilanlar.fromDocument(snp.data!.docs[index]),
                            itemCount: snp.data?.docs.length,
                            controller: controller,
                          ),
                        );
                      }
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  listeVeyaGridGonderiOlustur() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 10), blurRadius: 10, color: Colors.black12)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.arrow_drop_down,
              color: Colors.black38,
              size: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "İLANLAR",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38),
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.black38, size: 30),
          ],
        ),
      ),
    );
  }

  kaydedilenlerButonu() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => kaydedilenKartlar(
                        kullaniciID: widget.kullaniciprofilID,
                      )));
        },
        child: Container(
          width: 200.0,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark,
                color: Colors.white,
              ),
              SizedBox(width: 5),
              Text(
                "Kaydedilenler",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.black12)
            ],
            color: Colors.deepPurple[400],
            border: Border.all(color: Colors.orange.shade50),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  favorilerButonu() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Favoriler(
                        kullaniciID: widget.kullaniciprofilID,
                      )));
        },
        child: Container(
          width: 200.0,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Favoriler",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.black12)
            ],
            color: Colors.deepPurple[400],
            border: Border.all(color: Colors.orange.shade50),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  mesajButonu() {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                controller: controller,
                receiverUsername: widget.kullaniciUsername!,
                receiverId: widget.kullaniciprofilID!,
                receiverAvatar: widget.kullaniciUrl!,
              ),
            ),
          );
        },
        child: Container(
          width: 200.0,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                color: Colors.white,
                size: 35,
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.black12)
            ],
            color: Colors.deepPurple[400],
            border: Border.all(color: Colors.orange.shade50),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  takiptenCikarmaKontrol() {
    setState(() {
      takip = false;
    });
    takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .get()
        .then((takipci) {
      setState(() {
        if (takipci.exists) {
          takipci.reference.delete();
        }
      });
    });
    takipEdilenRef
        .doc(onlineKullaniciID)
        .collection("takipEdilenler")
        .doc(widget.kullaniciprofilID)
        .get()
        .then((takipedilen) {
      setState(() {
        if (takipedilen.exists) {
          takipedilen.reference.delete();
        }
      });
    });
    bildirimRef
        .doc(widget.kullaniciprofilID)
        .collection("bildirimler")
        .doc(onlineKullaniciID)
        .get()
        .then((bildirim) {
      setState(() {
        if (bildirim.exists) {
          bildirim.reference.delete();
        }
      });
    });
  }

  takipEtmeKontrolu() async {
    setState(() {
      takip = true;
    });
    takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .doc(onlineKullaniciID)
        .set({
      "id": onlineKullaniciID,
      "url": anlikKullanici!.url,
      "username": anlikKullanici!.username,
      "profileName": anlikKullanici!.profileName,
    });
    QuerySnapshot snapshot1 = await kullaniciRef
        .where("id", isEqualTo: widget.kullaniciprofilID)
        .get();
    List<Kullanici> kullaniciress =
        snapshot1.docs.map((doc) => Kullanici.fromDocument(doc)).toList();
    for (var doc in kullaniciress) {
      if (doc.id == widget.kullaniciprofilID) {
        takipEdilenRef
            .doc(onlineKullaniciID)
            .collection("takipEdilenler")
            .doc(widget.kullaniciprofilID)
            .set({
          "id": widget.kullaniciprofilID,
          "url": doc.url,
          "username": doc.username,
          "profileName": doc.profileName,
        });
      }
    }

    bildirimRef
        .doc(widget.kullaniciprofilID)
        .collection("bildirimler")
        .doc(anlikKullanici!.id)
        .set({
      "type": "Follow",
      "commentData": "takip",
      "ownerID": widget.kullaniciprofilID,
      "username": anlikKullanici!.username,
      "timestamp": timestamp,
      "userProfileImg": anlikKullanici!.url,
      "userID": anlikKullanici!.id,
      "url": "",
      "ilanID": "",
    });
  }

  kullaniciProfilDuzenle() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                profilDuzenle(onlineKullaniciID: widget.kullaniciprofilID)));
  }

  Scaffold anaMenu() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: baslikOlustur(),
      body: ListView(
        children: [
          SizedBox(
            height: 12,
          ),
          profilBasligi(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return anaMenu();
  }

  @override
  bool get wantKeepAlive => true;

  profilGonderisiGoster() {
    if (yuklenme!) {
      return circularProgress();
    } else if (gonderiListesi!.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  "Gonderi Yok",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (GonderiStili == "grid") {
      List<gonderiListeleme> gridListesi = [];
      var size = MediaQuery.of(context).size;
      gonderiListesi!.forEach((herbirGonderi) {
        gridListesi.add(gonderiListeleme(herbirGonderi));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 3,
        crossAxisSpacing: 0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(gridListesi.length, (index) {
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                width: (size.width - 3) / 3,
                height: (size.height - 3) / 6,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 6),
                          blurRadius: 2,
                          color: Colors.grey)
                    ],
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: NetworkImage(
                            gridListesi[index].gonderi!.frontUrl as String),
                        fit: BoxFit.cover)),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => gonderiEkranSayfasi(
                          gonderiID:
                              gridListesi[index].gonderi!.ilanID as String,
                          kullaniciID:
                              gridListesi[index].gonderi!.ownerID as String)));
            },
          );
        }),
      );
    } else if (GonderiStili == "list") {
      return Column(
        children: gonderiListesi!,
      );
    }

    return Column(
      children: gonderiListesi!,
    );
  }

  tumProfiliGetir() async {
    setState(() {
      yuklenme = true;
    });

    QuerySnapshot querySnapshot = await gonderiRef
        .doc(widget.kullaniciprofilID)
        .collection("kullaniciGonderi")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      yuklenme = false;
      gonderiHesapla = querySnapshot.docs.length;
      gonderiListesi = querySnapshot.docs
          .map((documentsnapshot) => Ilanlar.fromDocument(documentsnapshot))
          .toList();
    });
    QuerySnapshot querySnapshot1 = await takipEdilenRef
        .doc(widget.kullaniciprofilID)
        .collection("takipEdilenler")
        .get();
    setState(() {
      toplamTakipEdilenHesapla = querySnapshot1.docs.length;
    });
    QuerySnapshot querySnapshot2 = await takipciRef
        .doc(widget.kullaniciprofilID)
        .collection("takipciler")
        .get();
    setState(() {
      toplamTakipciHesapla = querySnapshot2.docs.length;
    });
  }

  Widget bottomGridTile(Map<String, dynamic> data) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          width: (size.width - 3) / 3,
          height: (size.height - 3) / 6,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x540000000),
                  spreadRadius: 1,
                  blurRadius: 0.1,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: NetworkImage(data["url"]), fit: BoxFit.cover)),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => gonderiEkranSayfasi(
                    gonderiID: data["ilanID"], kullaniciID: data["ownerID"])));
      },
    );
  }

  stilVerme(String stil) {
    setState(() {
      this.GonderiStili = stil;
    });
  }
}
