import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as ImD;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'AnaSayfa.dart';
import 'GirisEkran.dart';

// ignore: camel_case_types
class yuklemeSayfasi extends StatefulWidget {
  final Kullanici? kullanici;
  final File? dosya;
  yuklemeSayfasi({this.kullanici, this.dosya});

  @override
  _yuklemeSayfasiState createState() => _yuklemeSayfasiState(dosya: this.dosya);
}

// ignore: camel_case_types
class _yuklemeSayfasiState extends State<yuklemeSayfasi> {
  File? dosya;
  bool yukleniyor = false;
  String gonderiID = Uuid().v4();
  TextEditingController textDuzenlemeKontrol = TextEditingController();
  TextEditingController konumDuzenlemeKontrol = TextEditingController();
  PageController? sayfaKontrol;

  _yuklemeSayfasiState({this.dosya});
  gonderiBilgisiTemizleme() async {
    konumDuzenlemeKontrol.clear();
    textDuzenlemeKontrol.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => GirisEkran()));
  }

  getUserCurrentLocation() async {
    Position pozisyon = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //List<Placemark> yerIsaretleri = await placemarkFromCoordinates(pozisyon.latitude, pozisyon.longitude);
    //Placemark yerIsareti = yerIsaretleri[0];
    //String belirliAdres = '${yerIsareti.locality} ${yerIsareti.country}';
    //konumDuzenlemeKontrol.text = belirliAdres;
  }

  fotografiBicimlendirme() async {
    final dizin = await getTemporaryDirectory();
    final yol = dizin.path;
    ImD.Image? fotografDosyasi = ImD.decodeImage(dosya!.readAsBytesSync());
    var bicimlenenGonderiDosyasi = File("$yol/img_$gonderiID.jpg")
      ..writeAsBytesSync(ImD.encodeJpg(fotografDosyasi!, quality: 90));
    setState(() {
      dosya = bicimlenenGonderiDosyasi;
    });
  }

  Future<String> fotografYukleme(File dosya) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("Gonderi Fotoğrafları")
        .child("post_$gonderiID.jpg")
        .putFile(dosya);
    String urlIndirme = await (await uploadTask).ref.getDownloadURL();
    return urlIndirme;
  }

  yuklemeveKaydetmeKontrolu() async {
    setState(() {
      yukleniyor = true;
    });
    await fotografiBicimlendirme();
    String urlIndirme = await fotografYukleme(dosya!);
    gonderiFireStoreKaydetme(
        urlIndirme, konumDuzenlemeKontrol.text, textDuzenlemeKontrol.text);
    konumDuzenlemeKontrol.clear();
    textDuzenlemeKontrol.clear();
    setState(() {
      dosya = dosya!.delete(recursive: true) as File;
      gonderiID = Uuid().v4();
    });
  }

  gonderiFireStoreKaydetme(String urlIndirme, String konum, String aciklama) {
    gonderiRef
        .doc(widget.kullanici!.id)
        .collection("kullaniciGonderi")
        .doc(gonderiID)
        .set({
      "ilanID": gonderiID,
      "ownerID": widget.kullanici!.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "kaydedilenler": {},
      "username": widget.kullanici!.username,
      "description": aciklama,
      "location": konum,
      "url": urlIndirme,
    });
    akisRef.doc(gonderiID).set({
      "ilanID": gonderiID,
      "ownerID": widget.kullanici!.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.kullanici!.username,
      "description": aciklama,
      "location": konum,
      "url": urlIndirme,
      "kaydedilenler": {},
    });
  }

  ekranFormunuGoruntule<Widget>() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: gonderiBilgisiTemizleme,
        ),
        title: Text(
          "Yeni Gönderi",
          style: TextStyle(
              fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: yukleniyor
                ? null
                : () {
                    yuklemeveKaydetmeKontrolu();
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  },
            child: Text(
              "Paylaş",
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(25),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Color(0x54000000),
                  spreadRadius: 4,
                  blurRadius: 5,
                ),
              ], borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: Column(
                children: [
                  yukleniyor ? linearProgress() : Text(""),
                  Container(
                    height: 450.0,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(dosya!), fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(widget.kullanici!.url),
                    ),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: textDuzenlemeKontrol,
                        decoration: InputDecoration(
                          hintText: "Açıklama yaz",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 36.0,
                    ),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: konumDuzenlemeKontrol,
                        decoration: InputDecoration(
                          hintText: "Konum gir",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          primary: Colors.white70,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: getUserCurrentLocation,
                        icon: Icon(
                          Icons.location_on_rounded,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Anlık Konumu Al",
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (dosya != null)
        ? ekranFormunuGoruntule<Widget>()
        : Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AnaSayfa(
                      girdimi: true,
                    )));
  }
}
