import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/Sayfalar/takipEdilenler.dart';
import 'package:flutter_son_emlak/Sayfalar/yuklemeSayfasi.dart';
import 'package:flutter_son_emlak/realestate/ilanSayfasi.dart';
import 'package:flutter_son_emlak/realestate/search.dart';
import 'package:image_picker/image_picker.dart';

import 'AnaSayfa.dart';
import 'MessageHomePage.dart';
import 'anaAkisSayfasi.dart';
import 'bildirimSayfasi.dart';

class GirisEkran extends StatefulWidget {
  @override
  _GirisEkranState createState() => _GirisEkranState();
}

class _GirisEkranState extends State<GirisEkran>
    with SingleTickerProviderStateMixin {
  List? _items;
  List? _items2;
  List? _items3;
  List? tip;
  List? cat;
  PageController? sayfaKontrol;
  int sayfaSayisi = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Key? key;
  File? dosya;
  final imagePicker = ImagePicker();
  Color favoriRenk = Colors.grey;
  int sayfaNum = 5;
  bool tiklandimi = false;
  AnimationController? animasyonKontrol;
  late Animation<Color?> butonKontrol;
  Animation<double>? animasyonIkonu;
  Animation<double>? butonaCevirme;
  Curve egri = Curves.easeOut;
  double fabYukseklik = 56.0;
  List<tEdilen> takipEdilenKullanicilar = [];

  @override
  void initState() {
    sayfaKontrol = PageController(initialPage: 2);
    sayfaNum = 2;
    animasyonKontrol =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1))
          ..addListener(() {
            setState(() {});
          });
    animasyonIkonu =
        Tween<double>(begin: 0.0, end: 1.0).animate(animasyonKontrol!);
    butonKontrol = ColorTween(begin: Colors.blue, end: Colors.red).animate(
        CurvedAnimation(
            parent: animasyonKontrol!,
            curve: Interval(0.00, 1.00, curve: Curves.linear)));
    butonaCevirme = Tween<double>(begin: fabYukseklik, end: -14.0).animate(
        CurvedAnimation(
            parent: animasyonKontrol!,
            curve: Interval(0.0, 0.75, curve: egri)));
    readJsonIl();
    readJsonIlce();
    readJsonMahalle();
    readJsonKategori();
    readJsonTip();

    super.initState();
  }

  Future<void> readJsonIl() async {
    final String response = await rootBundle.loadString('assets/sehir1.json');
    final data = await json.decode(response);
    setState(() {
      _items = data["iller"];
    });
  }

  Future<void> readJsonIlce() async {
    final String response = await rootBundle.loadString('assets/ilce1.json');
    final data = await json.decode(response);
    setState(() {
      _items2 = data["ilceler"];
    });
  }

  Future<void> readJsonMahalle() async {
    final String response = await rootBundle.loadString('assets/mahalle1.json');
    final data = await json.decode(response);
    setState(() {
      _items3 = data["mahalleler"];
    });
  }

  Future<void> readJsonKategori() async {
    final String response = await rootBundle.loadString('assets/Kategori.json');
    final data = await json.decode(response);
    setState(() {
      cat = data["kategori"];
    });
  }

  Future<void> readJsonTip() async {
    final String response = await rootBundle.loadString('assets/Tip.json');
    final data = await json.decode(response);
    setState(() {
      tip = data["tip"];
    });
  }

  @override
  void dispose() {
    animasyonKontrol!.dispose();
    super.dispose();
  }

  whenPageChanges(int sayfaSayi) {
    setState(() {
      this.sayfaNum = sayfaSayi;
      sayfaKontrol!.jumpToPage(sayfaSayi);
    });
  }

  void animate() {
    if (!tiklandimi) {
      setState(() {
        // ignore: unnecessary_statements
        tiklandimi == true;
      });
      animasyonKontrol!.forward();
    } else {
      animasyonKontrol!.reverse();
    }
    tiklandimi = !tiklandimi;
  }

  Future kameradanFotograf() async {
    final fotograf = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      dosya = File(fotograf!.path);
    });
  }

  Future galeridenFotograf() async {
    final fotograf = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      dosya = File(fotograf!.path);
    });
  }

  Widget butonKamera() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              offset: Offset(0, 10), blurRadius: 90, color: Colors.black26)
        ],
      ),
      child: FloatingActionButton(
        heroTag: "1",
        backgroundColor: Colors.white,
        mini: true,
        onPressed: () {
          print("tapped");
          kameradanFotograf().then((value) {
            // ignore: unnecessary_null_comparison
            if (dosya != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => yuklemeSayfasi(
                            kullanici: anlikKullanici,
                            dosya: dosya,
                          )));
            } else {
              sayfaKontrol!.jumpToPage(0);
            }
          });
        },
        tooltip: "kamera",
        child: Icon(Icons.camera_alt_sharp),
      ),
    );
  }

  Widget butonGaleri() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(offset: Offset(0, 10), blurRadius: 90, color: Colors.black26)
      ]),
      child: FloatingActionButton(
        heroTag: "2",
        mini: true,
        backgroundColor: Colors.white,
        onPressed: () {
          print("tapped");
          galeridenFotograf().then((value) {
            // ignore: unnecessary_null_comparison
            if (dosya != null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => yuklemeSayfasi(
                            kullanici: anlikKullanici,
                            dosya: dosya,
                          )));
            } else {
              sayfaKontrol!.jumpToPage(0);
            }
          });
        },
        tooltip: "galeri",
        child: Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }

  Widget butonEkleme() {
    return Container(
      width: 54,
      height: 54,
      child: FloatingActionButton(
          //BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(45.0))),
          heroTag: "3",
          backgroundColor: Colors.white,
          onPressed: animate,
          tooltip: "ekleme",
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.black,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      key: _scaffoldKey,
      body: PageView(
        children: [
          HomeScreen(
            currentUserId: anlikKullanici!.id,
          ),
          bildirimSayfasi(),
          anaAkisSayfasi(
            gAnlikKullanici: anlikKullanici,
          ),
          Search(),
          profilSayfasi(
            kullaniciprofilID: anlikKullanici!.id,
            ilanID: '',
          ),
        ],
        controller: sayfaKontrol,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        heroTag: "3",
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ilanSayfasi(
                      items: _items,
                      items2: _items2,
                      items3: _items3,
                      tip: tip,
                      cat: cat)));
        },
        tooltip: "ekleme",
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.deepPurple[400],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 8.0,
          left: 20,
          right: 20,
        ),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: Offset(0, 10), blurRadius: 90, color: Colors.black26)
          ]),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            child: BottomAppBar(
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                height: 53,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Icon(
                        Icons.mail,
                        color: sayfaNum == 0 ? Colors.indigoAccent : favoriRenk,
                      ),
                      onPressed: () {
                        whenPageChanges(0);
                      },
                    ),
                    IconButton(
                      padding: EdgeInsets.only(left: 28.0),
                      icon: Icon(
                        Icons.notifications_sharp,
                        color: sayfaNum == 1 ? Colors.indigoAccent : favoriRenk,
                      ),
                      onPressed: () {
                        whenPageChanges(1);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.map,
                        size: 35,
                        color: sayfaNum == 2 ? Colors.indigoAccent : favoriRenk,
                      ),
                      onPressed: () {
                        whenPageChanges(2);
                      },
                    ),
                    IconButton(
                      padding: EdgeInsets.only(right: 28.0),
                      icon: Icon(
                        Icons.search,
                        color: sayfaNum == 3 ? Colors.indigoAccent : favoriRenk,
                      ),
                      onPressed: () {
                        whenPageChanges(3);
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        sayfaKontrol!.jumpToPage(4);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Container(
                            height: 37,
                            width: 37,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[400],
                              borderRadius: BorderRadius.circular(14),
                              // ignore: unnecessary_null_comparison
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(anlikKullanici!.url)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              color: Colors.white.withOpacity(1),
            ),
          ),
        ),
      ),
    );
  }
}
