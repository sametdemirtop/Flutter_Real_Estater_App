import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_son_emlak/Sayfalar/AnaSayfa.dart';
import 'package:flutter_son_emlak/Sayfalar/FullImageWidget.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:uuid/uuid.dart';

import 'ilanPhotos.dart';

class ilanSayfasi extends StatefulWidget {
  final List? items;
  final List? items2;
  final List? items3;
  final List? tip;
  final List? cat;
  ilanSayfasi(
      {required this.items,
      required this.items2,
      required this.items3,
      required this.tip,
      required this.cat});

  @override
  _ilanSayfasiState createState() => _ilanSayfasiState(
      items: items, items2: items2, items3: items3, tip: tip, cat: cat);
}

class _ilanSayfasiState extends State<ilanSayfasi> {
  String? _chosenID;
  String? _chosenID2;
  String? _chosenID3;
  String? _chosenCatID;
  String? _chosenTipID;
  String? _chosenYayinID;

  String? _chosenName;
  String? _chosenCatName;
  String? _chosenTipName;
  String? _chosenYayinName;
  String? _chosenName2;
  String? _chosenName3;
  bool? isVisible;
  bool? isVisible2;
  bool? isVisible3;
  bool? isVisibleCat;
  bool? isVisibleTip;
  bool? isVisibleYayin;
  bool? isClosing;
  String? next;
  String? previous;

  List<String> ekOzellikler = [
    "Arka cephe",
    "Caddeye yakın",
    "Denize sıfır",
    "Havaalanına yakın",
    "Boğaz manzarası",
    "Göl manzarası",
    "Metroya yakın",
    "Asansör",
    "Fitness",
    "Güvenlik",
    "Otobana yakın",
    "Ön cephe",
    "Jeneratör",
    "Kapıcı",
    "Toplu ulaşıma yakın",
    "Tramwaya yakın",
    "Marmaraya yakın",
    "Tenis kortu",
    "Yüzme Havuzu",
    "Yangın Merdiveni",
    "Oyun parkı",
    "Otopark",
    "TEM'e yakın",
    "Avrasya tüneline yakın",
  ];
  List<String> userChecked = [];
  final ScrollController listScrollController = ScrollController();
  final ScrollController listScrollController2 = ScrollController();
  final ScrollController controller = ScrollController();

  List<String> cat1 = ["SATILIK", "KİRALIK", "GÜNLÜK KİRALIK"];
  List<String> other = ["SATILIK", "KİRALIK"];
  List? items;
  List<Ilanlar>? gonderiListesi = [];
  List? items2;
  List? items3;
  List? cat;
  List? tip;
  int currentStep = 0;
  int? _currentPage;
  String? krediValue;
  String? isinmaValue;
  String? kullanimValue;
  String? yapiValue;
  final List<String> kredi = ["Evet", "Hayır"];
  final List<String> isinma = [
    "Güneş Enerjisi",
    "Kombi",
    "Klima",
    "Merkezi",
    "Kat Kaloriferi",
    "Soba",
    "Jeotermal Isıtma",
    "Yok"
  ];
  final List<String> kullanim = [
    "Boş",
    "Kiracı Oturuyor",
    "Ev sahibi Oturuyor",
  ];
  final List<String> yapi = [
    "Sıfır",
    "İkinci El",
    "Yapım Aşamasında",
  ];

  bool? validator;

  bool? validator2;
  Stream<QuerySnapshot>? futureAramaSonuclari;

  bool? imageCheck;
  bool? baslikCheck;
  bool? aciklamaCheck;

  _ilanSayfasiState({this.items, this.items2, this.items3, this.cat, this.tip});
  @override
  initState() {
    super.initState();
    imageCheck = false;
    baslikCheck = false;
    aciklamaCheck = false;
    validator = false;
    validator2 = false;
    krediValue = kredi.first;
    isinmaValue = isinma.first;
    kullanimValue = kullanim.first;
    yapiValue = yapi.first;
    _currentPage = 0;
    _chosenID = "0";
    _chosenID2 = "0";
    _chosenID3 = "0";
    _chosenCatID = "0";
    _chosenTipID = "0";
    _chosenYayinID = "0";
    _chosenCatName = "Kategori Seçiniz";
    _chosenTipName = "İlan Tipi Seçiniz";
    _chosenYayinName = "Yayınlama Tipi Seçiniz";
    _chosenName = "İl Seçiniz";
    _chosenName2 = "İlçe Seçiniz";
    _chosenName3 = "Mahalle Seçiniz";
    next = "Next";
    previous = "";
    isVisible = false;
    isVisible2 = false;
    isVisible3 = false;
    isVisibleCat = false;
    isVisibleTip = false;
    isVisibleYayin = false;
    isClosing = false;
    _pageController = PageController(initialPage: 0);
    ilanID = Uuid().v4();
  }

  PageController? _pageController;
  List<Marker> myMarker = [];
  GoogleMapController? mapController;

  String? searchAdd;
  double lati = 0;
  double longti = 0;
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  Set<Polygon> _polygons = HashSet<Polygon>();
  bool isPolygon = true;
  List<LatLng> polygonLatLng = [];
  int _polygonIdCounter = 1;
  double? radius;
  TextEditingController ilanBaslikController = TextEditingController();
  TextEditingController ilanAciklamaController = TextEditingController();
  TextEditingController ilanFiyatController = TextEditingController();
  TextEditingController ilanMetreKareController = TextEditingController();
  TextEditingController ilanOdaSayisiController = TextEditingController();
  TextEditingController ilanSalonSayisiController = TextEditingController();
  TextEditingController ilanBanyoSayisiController = TextEditingController();
  TextEditingController ilanKatSayisiController = TextEditingController();
  TextEditingController ilanBinaYasiController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey5 = GlobalKey<FormState>();
  final formKey6 = GlobalKey<FormState>();
  final formKey7 = GlobalKey<FormState>();
  final formKey8 = GlobalKey<FormState>();
  final formKey9 = GlobalKey<FormState>();
  bool yukleniyor = false;
  final imagePicker = ImagePicker();
  File? imageFile;
  String gonderiID = Uuid().v4();
  String ilanID = Uuid().v4();
  String imageUrl = "";
  String front = "";

  bool checkValues() {
    if (ilanBaslikController.text.isEmpty == false &&
        userChecked.isEmpty == false &&
        imageUrl != "" &&
        ilanAciklamaController.text.isEmpty == false &&
        ilanFiyatController.text.isEmpty == false &&
        ilanMetreKareController.text.isEmpty == false &&
        ilanOdaSayisiController.text.isEmpty == false &&
        ilanSalonSayisiController.text.isEmpty == false &&
        ilanBanyoSayisiController.text.isEmpty == false &&
        ilanKatSayisiController.text.isEmpty == false &&
        ilanBinaYasiController.text.isEmpty == false) {
      return true;
    } else {
      return false;
    }
  }

  /*Set<Polygon> myPolygon() {
    List<LatLng> polygonCoords = [];

    polygonCoords.add(LatLng(lati, longti));
    polygonCoords.add(LatLng(8.9486, 125.5364));
    polygonCoords.add(LatLng(8.9303, 125.5384));
    polygonCoords.add(LatLng(8.9442, 125.5321));
    Set<Polygon> polygonSet = new Set();
    polygonSet.add(Polygon(
        polygonId: PolygonId('test'),
        points: polygonCoords,
        strokeColor: Colors.red)); //color of the border
    return polygonSet;
  }*/

  /*void setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygons.add(
      Polygon(
          polygonId: PolygonId(polygonIdVal),
          points: polygonLatLng,
          strokeWidth: 2,
          strokeColor: Colors.yellow,
          fillColor: Colors.yellow.shade200),
    );
  }*/

  ilanFotoCekme() {
    Stream<QuerySnapshot> tumFotolar = ilanPhotoRef
        .doc(anlikKullanici!.id)
        .collection("ilanGonderi")
        .doc(ilanID)
        .collection("Gonderi")
        .snapshots();
    setState(() {
      futureAramaSonuclari = tumFotolar;
      futureAramaSonuclari!.map((event) {
        setState(() {
          front = event.docs.first.get("url");
        });
      });
    });
  }

  ilanFireStoreKaydetme() {
    ilanRef.doc(ilanID).set({
      "ilanID": ilanID,
      "ownerID": anlikKullanici!.id,
      "timestamp": DateTime.now(),
      "username": anlikKullanici!.username,
      "kategoriName": _chosenCatName,
      "tipName": _chosenTipName,
      "yayinName": _chosenYayinName,
      "il": _chosenName,
      "ilçe": _chosenName2,
      "mahalle": _chosenName3,
      "latitude": lati,
      "longitude": longti,
      "ilanBaslik": ilanBaslikController.text,
      "ilanAciklama": ilanAciklamaController.text,
      "ilanFiyat": ilanFiyatController.text,
      "ilanMetreKare": ilanMetreKareController.text,
      "ilanOdaSayısı": ilanOdaSayisiController.text,
      "ilanSalonSayısı": ilanSalonSayisiController.text,
      "ilanBanyoSayısı": ilanBanyoSayisiController.text,
      "ilanKatSayısı": ilanKatSayisiController.text,
      "ilanBinaYaşı": ilanBinaYasiController.text,
      "ilanKredi": krediValue,
      "ilanIsınma": isinmaValue,
      "ilanKullanım": kullanimValue,
      "ilanYapı": yapiValue,
      "ekOzellikler": userChecked,
      "ownerUrl": anlikKullanici!.url,
      "likes": {},
      "kaydedilenler": {},
      "frontUrl": front,
      "ownerBiography": anlikKullanici!.biography,
      "ownerProfileName": anlikKullanici!.profileName,
    });
  }

  Future galeridenFotograf() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          yukleniyor = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Fluttertoast.showToast(msg: 'Yükleniyor..');
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("İlan Fotoğrafları")
        .child(ilanID)
        .child("post_$gonderiID.jpg");
    UploadTask uploadTask = reference.putFile(imageFile!);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      front = imageUrl;
      setState(() {
        gonderiID = Uuid().v4();
        yukleniyor = false;
        gonderiFireStoreKaydetme(imageUrl);
        ilanFotoCekme();
      });
    } on FirebaseException catch (e) {
      setState(() {
        yukleniyor = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  gonderiFireStoreKaydetme(String urlIndirme) {
    ilanPhotoRef
        .doc(anlikKullanici!.id)
        .collection("ilanGonderi")
        .doc(ilanID)
        .collection("Gonderi")
        .doc(gonderiID)
        .set({
      "ilanID": ilanID,
      "postID": gonderiID,
      "ownerID": anlikKullanici!.id,
      "timestamp": DateTime.now(),
      "username": anlikKullanici!.username,
      "location": "",
      "url": urlIndirme,
    });
  }

  Column kullaniciProfilIsmiAlaniOlusturma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1), blurRadius: 100, color: Colors.white)
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              style: TextStyle(color: Colors.black),
              controller: ilanBaslikController,
              decoration: InputDecoration(
                fillColor: Colors.indigoAccent,
                focusColor: Colors.indigo[400],
                hoverColor: Colors.indigo[400],
                prefixIcon: Icon(Icons.title),
                labelText: "İlan Başlığı",
                hintText: "İlan Başlığını gir",
                enabledBorder: OutlineInputBorder(
                  gapPadding: 0.1,
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.indigo[400]!, width: 3),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 6),
                ),
              ),
              validator: (girilenDeger) {
                if (girilenDeger!.trim().length > 50) {
                  return "İlan Başlığı çok uzun";
                }
                if (girilenDeger.isEmpty == true) {
                  return "İlan Başlığı boş bırakılamaz";
                }
              },
              onSaved: (kaydedilecekDeger) {
                ilanBaslikController.text = kaydedilecekDeger!;
              },
            ),
          ),
        ),
      ],
    );
  }

  Column kullaniciBiographyAlaniOlusturma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1), blurRadius: 100, color: Colors.white)
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLength: 5000,
              maxLines: 7,
              style: TextStyle(color: Colors.black),
              controller: ilanAciklamaController,
              decoration: InputDecoration(
                fillColor: Colors.indigoAccent,
                focusColor: Colors.indigo[400],
                hoverColor: Colors.indigo[400],
                prefixIcon: Icon(Icons.description),
                labelText: "İlan Açıklama",
                hintText: "İlan Açıklamasını Giriniz",
                enabledBorder: OutlineInputBorder(
                  gapPadding: 0.1,
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.indigo[400]!, width: 3),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(width: 6),
                ),
              ),
              validator: (girilenDeger) {
                if (girilenDeger!.trim().length < 150) {
                  return "İlan Açıklama çok kısa";
                } else if (girilenDeger.isEmpty == true) {
                  return "İlan Açıklama boş bırakılamaz";
                } else {
                  return null;
                }
              },
              onSaved: (kaydedilecekDeger) {
                ilanAciklamaController.text = kaydedilecekDeger!;
              },
            ),
          ),
        ),
      ],
    );
  }

  Column ilanFiyatiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 45.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanFiyatController,
                decoration: InputDecoration(
                  suffixText: " ₺ ",
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.money_outlined),
                  labelText: "İlan Fiyatı",
                  hintText: "İlan Fiyatını gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == true) {
                    return "İlan Fiyatı boş bırakılamaz";
                  } else {
                    return null;
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanBaslikController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanMetreKareAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 45.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanMetreKareController,
                decoration: InputDecoration(
                  suffixText: " m² ",
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.square_foot),
                  labelText: "Metrekare",
                  hintText: "Metrekare gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == true) {
                    return "Metrekare boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanMetreKareController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanOdaSayisiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 45.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanOdaSayisiController,
                decoration: InputDecoration(
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.crop_square),
                  labelText: "Oda Sayısı",
                  hintText: "Oda Sayısı gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == true) {
                    return "Oda Sayısı boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanOdaSayisiController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanSalonSayisiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 35.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanSalonSayisiController,
                decoration: InputDecoration(
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.living),
                  labelText: "Salon Sayısı",
                  hintText: "Salon Sayısı gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == true) {
                    return "Salon Sayısı boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanOdaSayisiController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanBanyoSayisiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 30.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanBanyoSayisiController,
                decoration: InputDecoration(
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.bathroom),
                  labelText: "Banyo Sayısı",
                  hintText: "Banyo Sayısı gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == false) {
                    return "Banyo Sayısı boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanBanyoSayisiController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanKatSayisiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanKatSayisiController,
                decoration: InputDecoration(
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.location_city),
                  labelText: "Bina Kat Sayısı",
                  hintText: "Bina Kat Sayısı gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == false) {
                    return "Banyo Sayısı boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanKatSayisiController.text = kaydedilecekDeger!;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column ilanBinaYasiAlma() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 100,
                  color: Colors.grey.shade400.withOpacity(0.1))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 55.0),
            child: Container(
              width: 220,
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: ilanBinaYasiController,
                decoration: InputDecoration(
                  fillColor: Colors.indigoAccent,
                  focusColor: Colors.indigo[400],
                  hoverColor: Colors.indigo[400],
                  prefixIcon: Icon(Icons.apartment),
                  labelText: "Bina Yaşı",
                  hintText: "Bina Yaşı gir",
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0.1,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Colors.indigo[400]!, width: 3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(width: 6),
                  ),
                ),
                validator: (girilenDeger) {
                  if (girilenDeger!.isEmpty == false) {
                    return "Bina Yaşı boş bırakılamaz";
                  }
                },
                onSaved: (kaydedilecekDeger) {
                  ilanBinaYasiController.text = kaydedilecekDeger!;
                  checkValues();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.indigoAccent),
            onPressed: () async {
              print(ilanID.toString());
              var collection = ilanPhotoRef
                  .doc(anlikKullanici!.id)
                  .collection("ilanGonderi")
                  .doc(ilanID)
                  .collection("Gonderi");
              var snapshots = await collection.get();
              for (var doc in snapshots.docs) {
                await doc.reference.delete();
              }
              ListResult result = await FirebaseStorage.instance
                  .ref()
                  .child("İlan Fotoğrafları")
                  .child(ilanID)
                  .listAll();

              result.items.forEach((Reference ref) {
                ref.delete();
              });
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text("İlan Ekleme",
              style: TextStyle(
                fontSize: 24,
                color: Colors.indigoAccent,
              )),
          backgroundColor: Colors.white,
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: <Widget>[
            buildIlanCat(context),
            Container(
              child: GoogleMap(
                polygons: _polygons,
                myLocationEnabled: true,
                onTap: _handleTap,
                markers: Set.from(myMarker),
                initialCameraPosition:
                    CameraPosition(target: LatLng(lati, longti), zoom: 16.5),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListView(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 3,
                    color: Colors.grey,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                      ),
                                      Positioned.fill(
                                        top: 50,
                                        child: Visibility(
                                          visible: imageCheck!,
                                          child: IconButton(
                                            icon: Icon(Icons.error,
                                                size: 25, color: Colors.red),
                                            onPressed: galeridenFotograf,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    padding:
                                        EdgeInsets.only(right: 10, bottom: 10),
                                    icon: Icon(Icons.camera_alt,
                                        size: 50, color: Colors.white),
                                    onPressed: galeridenFotograf,
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigoAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 0),
                            child: StreamBuilder<QuerySnapshot>(
                                stream: ilanPhotoRef
                                    .doc(anlikKullanici!.id)
                                    .collection("ilanGonderi")
                                    .doc(ilanID)
                                    .collection("Gonderi")
                                    .orderBy("timestamp", descending: true)
                                    .snapshots(),
                                builder: (context, snp) {
                                  if (!snp.hasData) {
                                    return circularProgress();
                                  } else {
                                    return Container(
                                      height: 100,
                                      width: 280,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          IlanPhotos ilanPhotos =
                                              IlanPhotos.fromDocument(
                                                  snp.data!.docs[index]);
                                          return Stack(
                                            children: [
                                              GestureDetector(
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 6),
                                                  child: Container(
                                                    width: 100,
                                                    height: 130,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              ilanPhotos.url!),
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullPhoto(
                                                        url: ilanPhotos.url!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 20, right: 10),
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.indigoAccent,
                                                      shape: BoxShape.circle),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await ilanPhotoRef
                                                          .doc(anlikKullanici!
                                                              .id)
                                                          .collection(
                                                              "ilanGonderi")
                                                          .doc(ilanID)
                                                          .collection("Gonderi")
                                                          .doc(ilanPhotos
                                                              .ilanID!)
                                                          .get()
                                                          .then((value) async {
                                                        if (value.exists) {
                                                          value.reference
                                                              .delete();
                                                        }
                                                        setState(() {});
                                                      });
                                                      FirebaseStorage.instance
                                                          .ref()
                                                          .child(
                                                              "İlan Fotoğrafları")
                                                          .child(ilanID)
                                                          .storage
                                                          .refFromURL(
                                                              ilanPhotos.url!)
                                                          .delete();
                                                    },
                                                    child: Center(
                                                      child: Icon(Icons.clear,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        itemCount: snp.data?.docs.length,
                                        controller: controller,
                                      ),
                                    );
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 4,
                    color: Colors.grey,
                  ),
                  Form(
                    key: formKey,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            kullaniciProfilIsmiAlaniOlusturma(),
                            SizedBox(
                              height: 20,
                            ),
                            kullaniciBiographyAlaniOlusturma(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 4,
                    color: Colors.grey,
                  ),
                  Form(
                    key: formKey1,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 30,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "İlan Fiyatı * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanFiyatiAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "MetreKare * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanMetreKareAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "Oda Sayısı * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanOdaSayisiAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "Salon Sayısı * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanSalonSayisiAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "Banyo Sayısı * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanBanyoSayisiAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 30,
                                  ),
                                  child: Text(
                                    "Bina Kat Sayısı * ",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      ilanKatSayisiAlma(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Container(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      top: 30,
                                    ),
                                    child: Text(
                                      "Bina Yaşı * ",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        ilanBinaYasiAlma(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 4,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25,
                                top: 30,
                              ),
                              child: Text(
                                "Krediye Uygun mu * ",
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                                top: 30,
                              ),
                              child: Container(
                                width: 215,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Colors.indigo[400]!, width: 3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton(
                                      items: kredi
                                          .map((value) => DropdownMenuItem(
                                                child: Text(value),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          krediValue = value;
                                        });
                                      },
                                      isExpanded: false,
                                      value: krediValue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25,
                                top: 30,
                              ),
                              child: Text(
                                "Isınma Türü * ",
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 42,
                                top: 30,
                              ),
                              child: Container(
                                width: 215,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Colors.indigo[400]!, width: 3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.thermostat_outlined),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    DropdownButton(
                                      items: isinma
                                          .map((value) => DropdownMenuItem(
                                                child: Text(value),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          isinmaValue = value;
                                        });
                                      },
                                      isExpanded: false,
                                      value: isinmaValue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 25,
                                top: 30,
                              ),
                              child: Text(
                                "Kullanım Durumu * ",
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                                top: 30,
                              ),
                              child: Container(
                                width: 215,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Colors.indigo[400]!, width: 3),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.people_outline_sharp,
                                      size: 22,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    DropdownButton(
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      items: kullanim
                                          .map((value) => DropdownMenuItem(
                                                child: Text(value),
                                                value: value,
                                              ))
                                          .toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          kullanimValue = value;
                                        });
                                      },
                                      isExpanded: false,
                                      value: kullanimValue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 25,
                                  top: 30,
                                ),
                                child: Text(
                                  "Yapı Durumu * ",
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 35,
                                  top: 30,
                                ),
                                child: Container(
                                  width: 215,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Colors.indigo[400]!, width: 3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.data_usage,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      DropdownButton(
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                        items: yapi
                                            .map((value) => DropdownMenuItem(
                                                  child: Text(value),
                                                  value: value,
                                                ))
                                            .toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            yapiValue = value;
                                          });
                                        },
                                        isExpanded: false,
                                        value: yapiValue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 4,
                    color: Colors.grey,
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Ek Özellikler",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black38,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                    controller: listScrollController,
                                    shrinkWrap: true,
                                    itemCount:
                                        ekOzellikler.sublist(0, 11).length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        title: Text(
                                          ekOzellikler.sublist(0, 11)[i],
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        trailing: Checkbox(
                                          side: BorderSide(
                                              color: Colors.indigo[400]!,
                                              width: 2),
                                          activeColor: Colors.indigo[400],
                                          value: userChecked.contains(
                                              ekOzellikler.sublist(0, 11)[i]),
                                          onChanged: (val) {
                                            _onSelected(val!,
                                                ekOzellikler.sublist(0, 11)[i]);
                                          },
                                        ),
                                        //you can use checkboxlistTile too
                                      );
                                    }),
                              ),
                              Expanded(
                                child: ListView.builder(
                                    controller: listScrollController2,
                                    shrinkWrap: true,
                                    itemCount:
                                        ekOzellikler.sublist(12, 23).length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        title: Text(
                                          ekOzellikler.sublist(12, 23)[i],
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        trailing: Checkbox(
                                          side: BorderSide(
                                              color: Colors.indigo[400]!,
                                              width: 2),
                                          activeColor: Colors.indigo[400],
                                          value: userChecked.contains(
                                              ekOzellikler.sublist(12, 23)[i]),
                                          onChanged: (val) {
                                            _onSelected(
                                                val!,
                                                ekOzellikler.sublist(
                                                    12, 23)[i]);
                                          },
                                        ),
                                        //you can use checkboxlistTile too
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.indigoAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: TextButton(
                  onPressed: previousPage,
                  child: Text(
                    previous!,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              next! != "Next"
                  ? Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: TextButton(
                        onPressed: checkValues() == true
                            ? () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                if (!formKey1.currentState!.validate()) {
                                  return;
                                }
                                print("Kaydediliyor.");
                                Fluttertoast.showToast(msg: 'Kaydediliyor.');
                                ilanFireStoreKaydetme();
                                Navigator.pop(context);
                              }
                            : () {
                                Fluttertoast.showToast(
                                    msg: 'Boş Alanları Doldurunuz.');
                                if (imageUrl == "") {
                                  setState(() {
                                    imageCheck = true;
                                  });
                                }
                                if (ilanBaslikController.text.isEmpty == true) {
                                  setState(() {
                                    baslikCheck = true;
                                  });
                                }
                              },
                        child: Text(
                          "Yayınla",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: TextButton(
                        onPressed: validator == true ? nextPage : () {},
                        child: Text(
                          next!,
                          style: TextStyle(
                              color: validator == false
                                  ? Colors.grey
                                  : Colors.white),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Center buildIlanCat(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          Container(
            height: 650,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text("Kategori *"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 75),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.category,
                                size: 28,
                                color: Colors.indigoAccent,
                              ),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenCatName!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisibleCat == false) {
                                      setState(() {
                                        isVisibleCat = true;
                                        modalBottomKategori(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisibleCat = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisibleCat == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisibleCat == false) {
                            setState(() {
                              isVisibleCat = true;
                              modalBottomKategori(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisibleCat = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text("İlan Tipi *"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 80),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 5),
                              Icon(
                                Icons.merge_type,
                                color: Colors.indigoAccent,
                                size: 28,
                              ),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenTipName!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisibleTip == false) {
                                      setState(() {
                                        isVisibleTip = true;
                                        modalBottomIlanTipi(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisibleTip = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisibleTip == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisibleTip == false) {
                            setState(() {
                              isVisibleTip = true;
                              modalBottomIlanTipi(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisibleTip = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 26.0),
                      child: Text("Yayınlama Tipi *"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.playlist_add_sharp,
                                  size: 28, color: Colors.indigoAccent),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenYayinName!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisibleYayin == false) {
                                      setState(() {
                                        isVisibleYayin = true;
                                        modalBottomYayinTipi(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisibleYayin = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisibleYayin == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisibleYayin == false) {
                            setState(() {
                              isVisibleYayin = true;
                              modalBottomYayinTipi(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisibleYayin = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text("İl *"),
                    ),
                    /**/
                    Padding(
                      padding: EdgeInsets.only(left: 115),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                child: Center(
                                  child: Text(
                                    _chosenID!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenName!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisible == false) {
                                      setState(() {
                                        isVisible = true;
                                        modalBottomIl(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisible = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisible == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisible == false) {
                            setState(() {
                              isVisible = true;
                              modalBottomIl(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisible = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text("İlçe *"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 100),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                child: Center(
                                  child: Text(
                                    _chosenID!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenName2!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisible2 == false) {
                                      setState(() {
                                        isVisible2 = true;
                                        modalBottomIlce(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisible2 = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisible2 == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisible2 == false) {
                            setState(() {
                              isVisible2 = true;
                              modalBottomIlce(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisible2 = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text("Mahalle *"),
                    ),
                    /*Icon(Icons.home_sharp, size: 40, color: Colors.indigoAccent),*/
                    Padding(
                      padding: EdgeInsets.only(left: 70),
                      child: InkWell(
                        child: Container(
                          width: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                child: Center(
                                  child: Text(
                                    _chosenID!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    _chosenName3!,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    if (isVisible3 == false) {
                                      setState(() {
                                        isVisible3 = true;
                                        modalBottomMahalle(context);
                                        handleValidator();
                                      });
                                    } else {
                                      setState(() {
                                        isVisible3 = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    isVisible3 == false
                                        ? Icons.arrow_drop_up_sharp
                                        : Icons.arrow_drop_down_sharp,
                                    color: Colors.grey,
                                    size: 30,
                                  )),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onTap: () {
                          if (isVisible3 == false) {
                            setState(() {
                              isVisible3 = true;
                              modalBottomMahalle(context);
                              handleValidator();
                            });
                          } else {
                            setState(() {
                              isVisible3 = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleValidator() {
    if (_chosenCatName == "Kategori Seçiniz" ||
        _chosenTipName == "İlan Tipi Seçiniz" ||
        _chosenYayinName == "Yayınlama Tipi Seçiniz" ||
        _chosenName == "İl Seçiniz" ||
        _chosenName2 == "İlçe Seçiniz") {
      setState(() {
        validator = false;
      });
    } else {
      setState(() {
        validator = true;
      });
    }
  }

  void modalBottomMahalle(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 450,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "MAHALLE SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: items3!
                        .where((e) => e["mahalle_ilcekey"] == _chosenID2)
                        .toList()
                        .length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Container(
                          height: 35,
                          width: 35,
                          child: Center(
                            child: Text(
                              _chosenID!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigoAccent,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 10,
                                  color: Colors.black12)
                            ],
                          ),
                        ),
                        title: Text(
                          items3!
                              .where((e) => e["mahalle_ilcekey"] == _chosenID2)
                              .toList()[index]["mahalle_title"],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenID3 = items3!
                                .where(
                                    (e) => e["mahalle_ilcekey"] == _chosenID2)
                                .toList()[index]["mahalle_ilcekey"];
                            _chosenName3 = items3!
                                .where(
                                    (e) => e["mahalle_ilcekey"] == _chosenID2)
                                .toList()[index]["mahalle_title"];
                          });
                          setState(() {
                            isVisible3 = false;
                            searchAdd = _chosenName3! +
                                " " +
                                _chosenName2! +
                                " " +
                                _chosenName!;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (_chosenName3 == "Mahalle Seçiniz") {
                        setState(() {
                          _chosenName3 = items3!
                              .where((e) => e["mahalle_ilcekey"] == _chosenID2)
                              .toList()
                              .first["mahalle_title"];
                        });
                      }
                      searchAdd = _chosenName3! +
                          " " +
                          _chosenName2! +
                          " " +
                          _chosenName!;
                      isVisible3 = false;

                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void modalBottomIlce(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 450,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "İLÇE SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: items2!
                        .where((e) => e["ilce_sehirkey"] == _chosenID)
                        .toList()
                        .length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Container(
                          height: 35,
                          width: 35,
                          child: Center(
                            child: Text(
                              _chosenID!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigoAccent,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 10,
                                  color: Colors.black12)
                            ],
                          ),
                        ),
                        title: Text(
                          items2!
                              .where((e) => e["ilce_sehirkey"] == _chosenID)
                              .toList()[index]["ilce_title"],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenID2 = items2!
                                .where((e) => e["ilce_sehirkey"] == _chosenID)
                                .toList()[index]["ilce_key"];
                            _chosenName2 = items2!
                                .where((e) => e["ilce_sehirkey"] == _chosenID)
                                .toList()[index]["ilce_title"];
                          });
                          setState(() {
                            isVisible2 = false;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isVisible2 = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void modalBottomIl(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 500,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "İL SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 375,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: items!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Container(
                          height: 35,
                          width: 35,
                          child: Center(
                            child: Text(
                              items![index]["sehir_key"],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigoAccent,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 10,
                                  color: Colors.black12)
                            ],
                          ),
                        ),
                        title: Text(
                          items![index]["sehir_title"],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenID = items![index]["sehir_key"];
                            _chosenName = items![index]["sehir_title"];
                          });
                          setState(() {
                            isVisible = false;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isVisible = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void modalBottomYayinTipi(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 250,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "İLAN TİPİ SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: _chosenCatID == "1" ? cat1.length : other.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Text(
                          _chosenCatID == "1" ? cat1[index] : other[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenYayinName = _chosenCatID == "1"
                                ? cat1[index]
                                : other[index];
                          });
                          setState(() {
                            isVisibleYayin = false;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isVisibleYayin = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void modalBottomIlanTipi(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 400,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "İLAN TİPİ SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: tip!
                        .where((e) => e["tip_key"] == _chosenCatID)
                        .toList()
                        .length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Text(
                          tip!
                              .where((e) => e["tip_key"] == _chosenCatID)
                              .toList()[index]["tip_title"],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenTipID = tip!
                                .where((e) => e["tip_key"] == _chosenCatID)
                                .toList()[index]["tip_key"];
                            _chosenTipName = tip!
                                .where((e) => e["tip_key"] == _chosenCatID)
                                .toList()[index]["tip_title"];
                          });
                          setState(() {
                            isVisibleTip = false;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isVisibleTip = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void modalBottomKategori(BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.indigo[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return Container(
            height: 300,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "İLAN KATEGORİ SEÇİNİZ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 3,
                  color: Colors.grey,
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.indigo[400],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: ListView.builder(
                    itemCount: cat!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        leading: Text(
                          cat![index]["kategori_title"],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _chosenCatID = cat![index]["kategori_id"];
                            _chosenCatName = cat![index]["kategori_title"];
                          });
                          setState(() {
                            isVisibleCat = false;
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isVisibleCat = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: Colors.indigoAccent),
                    child: Center(
                      child: Text(
                        'VAZGEÇ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  nextPage() {
    if (_pageController!.page! == 0) {
      setState(() {
        handleValidator();
        _pageController!.animateToPage(
          _pageController!.page!.toInt() + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        getLocation();
        previous = "Previous";
        next = "Next";
      });
    } else if (_pageController!.page! == 1) {
      setState(() {
        _pageController!.animateToPage(
          _pageController!.page!.toInt() + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        previous = "Previous";
        next = "Yayınla";
      });
    } else if (_pageController!.page! == 2) {
      setState(() {
        previous = "Previous";
        next = "Yayınla";
      });
    }
  }

  void handler() {
    if (formKey.currentState!.validate() == true &&
        formKey1.currentState!.validate() == true &&
        formKey3.currentState!.validate() == true &&
        formKey4.currentState!.validate() == true &&
        formKey5.currentState!.validate() == true &&
        formKey6.currentState!.validate() == true &&
        formKey7.currentState!.validate() == true &&
        formKey8.currentState!.validate() == true &&
        formKey9.currentState!.validate() == true) {
      setState(() {
        formKey.currentState!.save();
        formKey1.currentState!.save();
        formKey3.currentState!.save();
        formKey4.currentState!.save();
        formKey5.currentState!.save();
        formKey6.currentState!.save();
        formKey7.currentState!.save();
        formKey8.currentState!.save();
        formKey9.currentState!.save();
        validator2 = true;
      });
    } else {
      setState(() {
        validator2 = false;
      });
    }
  }

  previousPage() {
    if (_pageController!.page! == 1) {
      setState(() {
        _pageController!.animateToPage(
          _pageController!.page!.toInt() - 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        previous = "Previous";
        next = "Next";
      });
    } else if (_pageController!.page! == 0) {
      setState(() {
        _pageController!.animateToPage(
          _pageController!.page!.toInt(),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        previous = "";
        next = "Next";
      });
    }
  }

  _handleTap(LatLng argument) {
    print(argument);
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(argument.toString()),
          position: argument,
          draggable: true,
          onDragEnd: (dragEndPosition) {
            print(dragEndPosition);
          }));
      if (isPolygon) {
        setState(() {
          polygonLatLng.add(argument);
          // setPolygon();
        });
      }
    });
  }

  void getLocation() async {
    List<Location> locations = await locationFromAddress(searchAdd!);
    setState(() {
      lati = locations[0].latitude;
      longti = locations[0].longitude;
    });
    isPolygon = true;
  }

  void _onSelected(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
    setState(() {
      handler();
    });
  }

  Future<bool> onWillPop() async {
    var collection = ilanPhotoRef
        .doc(anlikKullanici!.id)
        .collection("ilanGonderi")
        .doc(ilanID)
        .collection("Gonderi");
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child("İlan Fotoğrafları")
        .child(ilanID)
        .listAll();

    result.items.forEach((Reference ref) {
      ref.delete();
    });
    return true;
  }
}
