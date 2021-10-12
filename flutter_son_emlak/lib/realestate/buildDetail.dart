import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/AnaSayfa.dart';
import 'package:flutter_son_emlak/Sayfalar/MesajlasmaSayfasi.dart';
import 'package:flutter_son_emlak/model/Mesajlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ilanPhotos.dart';

class BuildDetail extends StatefulWidget {
  final String? ilanID;
  final String? ilanKullanim;
  final String? ownerBiography;
  final String? ownerProfileName;
  final String? il;
  final String? ilce;
  final String? mahalle;
  final String? kategoriName;
  final String? tipName;
  final String? yayinName;
  final double? latitude;
  final double? longitude;
  final String? ilanBaslik;
  final String? ilanFiyat;
  final String? ilanMetreKare;
  final String? ilanOdaSayisi;
  final String? ilanBanyoSayisi;
  final String? ilanKatSayisi;
  final String? ilanBinaYasi;
  final String? ilanKredi;
  final String? ilanIsinma;
  final String? ilanYapi;
  final String? ilanSalonSayisi;
  final List? ekOzellikler;
  final String? ownerID;
  final String? ownerUrl;
  final likes;
  final String? username;
  final String? ilanAciklama;
  final Timestamp? timestamp;
  final String? frontUrl;
  final kaydedilenler;

  BuildDetail({
    this.ownerBiography,
    this.ownerProfileName,
    this.ilanKullanim,
    this.ilanSalonSayisi,
    this.ilanID,
    this.ownerID,
    this.likes,
    this.username,
    this.ilanAciklama,
    this.timestamp,
    this.frontUrl,
    this.kaydedilenler,
    this.ekOzellikler,
    this.longitude,
    this.latitude,
    this.il,
    this.ilanBanyoSayisi,
    this.ilanBaslik,
    this.ilanFiyat,
    this.ilanBinaYasi,
    this.ilanIsinma,
    this.ilanKatSayisi,
    this.ilanKredi,
    this.ilanMetreKare,
    this.ilanOdaSayisi,
    this.ilanYapi,
    this.ilce,
    this.kategoriName,
    this.mahalle,
    this.tipName,
    this.yayinName,
    this.ownerUrl,
  });

  factory BuildDetail.fromDocument(DocumentSnapshot doc) {
    return BuildDetail(
      ownerBiography: doc["ownerBiography"],
      ownerProfileName: doc["ownerProfileName"],
      ilanKullanim: doc["ilanKullanım"],
      ilanID: doc['ilanID'],
      ownerID: doc['ownerID'],
      likes: doc['likes'],
      username: doc['username'],
      ilanAciklama: doc['ilanAciklama'],
      timestamp: doc['timestamp'],
      frontUrl: doc['frontUrl'],
      kaydedilenler: doc['kaydedilenler'],
      ekOzellikler: doc['ekOzellikler'],
      il: doc['il'],
      ilanBanyoSayisi: doc['ilanBanyoSayısı'],
      ilanBaslik: doc['ilanBaslik'],
      ilanFiyat: doc['ilanFiyat'],
      ilanBinaYasi: doc['ilanBinaYaşı'],
      ilanIsinma: doc['ilanIsınma'],
      ilanKatSayisi: doc['ilanKatSayısı'],
      ilanKredi: doc['ilanKredi'],
      ilanMetreKare: doc['ilanMetreKare'],
      ilanOdaSayisi: doc['ilanOdaSayısı'],
      ilanYapi: doc['ilanYapı'],
      ilce: doc['ilçe'],
      kategoriName: doc['kategoriName'],
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      mahalle: doc['mahalle'],
      tipName: doc['tipName'],
      yayinName: doc['yayinName'],
      ownerUrl: doc['ownerUrl'],
      ilanSalonSayisi: doc['ilanSalonSayısı'],
    );
  }

  int toplamBegeniSayisi(likes) {
    if (likes == null) {
      return 0;
    }
    int sayac = 0;
    likes.values.forEach((herbirDeger) {
      if (herbirDeger == true) {
        sayac = sayac + 1;
      }
    });
    return sayac;
  }

  int toplamKaydedilmeSayisi(kaydedilenler) {
    if (kaydedilenler == null) {
      return 0;
    }
    int sayac = 0;
    kaydedilenler.values.forEach((herbirDeger) {
      if (herbirDeger == true) {
        sayac = sayac + 1;
      }
    });
    return sayac;
  }

  @override
  _BuildDetailState createState() => _BuildDetailState(
        ownerProfileName: this.ownerProfileName,
        ownerBiography: this.ownerBiography,
        ilanID: this.ilanID!,
        ilanKullanim: this.ilanKullanim,
        ownerID: this.ownerID!,
        likes: this.likes,
        username: this.username!,
        ilanAciklama: this.ilanAciklama!,
        timestamp: this.timestamp!,
        frontUrl: this.frontUrl!,
        likeCount: toplamBegeniSayisi(this.likes),
        kaydedilenler: this.kaydedilenler,
        saveCount: toplamKaydedilmeSayisi(this.kaydedilenler),
        ekOzellikler: this.ekOzellikler,
        il: this.il,
        ilanBanyoSayisi: this.ilanBanyoSayisi,
        ilanBaslik: this.ilanBaslik,
        ilanFiyat: this.ilanFiyat,
        ilanBinaYasi: this.ilanBinaYasi,
        ilanIsinma: this.ilanIsinma,
        ilanKatSayisi: this.ilanKatSayisi,
        ilanKredi: this.ilanKredi,
        ilanMetreKare: this.ilanMetreKare,
        ilanOdaSayisi: this.ilanOdaSayisi,
        ilanYapi: this.ilanYapi,
        ilce: this.ilce,
        kategoriName: this.kategoriName,
        latitude: this.latitude,
        longitude: this.longitude,
        mahalle: this.mahalle,
        tipName: this.tipName,
        yayinName: this.yayinName,
        ilanSalonSayisi: this.ilanSalonSayisi,
        ownerUrl: this.ownerUrl,
      );
}

class _BuildDetailState extends State<BuildDetail> {
  final String? il;
  final String? ilce;
  final String? ilanKullanim;
  final String? ownerBiography;
  final String? ownerProfileName;
  final String? mahalle;
  final String? kategoriName;
  final String? tipName;
  final String? yayinName;
  final double? latitude;
  final double? longitude;
  final String? ilanBaslik;
  final String? ilanFiyat;
  final String? ilanMetreKare;
  final String? ilanOdaSayisi;
  final String? ilanBanyoSayisi;
  final String? ilanKatSayisi;
  final String? ilanSalonSayisi;
  final String? ilanBinaYasi;
  final String? ilanKredi;
  final String? ilanIsinma;
  final String? ilanYapi;
  final String? ownerUrl;
  final List? ekOzellikler;
  final String? ilanID;
  final String? ownerID;
  Map? likes;
  final String? username;
  final String? ilanAciklama;
  final Timestamp? timestamp;
  final String? frontUrl;
  int? likeCount;
  int? saveCount;
  Map? kaydedilenler;
  bool? isExpandeded;
  String? url = "";
  List<IlanPhotos> tumPhotos = [];
  bool? kaydedildimi;
  bool? isLiked;

  int? valueSon;

  final String? onlineUserID = anlikKullanici!.id;
  final ScrollController controller = ScrollController();
  String id = anlikKullanici!.id;
  String groupChatId = "";

  _BuildDetailState(
      {this.ownerProfileName,
      this.ownerBiography,
      this.ilanSalonSayisi,
      this.ilanKullanim,
      this.ilanID,
      this.ownerID,
      this.likes,
      this.username,
      this.ilanAciklama,
      this.timestamp,
      this.frontUrl,
      this.likeCount,
      this.kaydedilenler,
      this.saveCount,
      this.yayinName,
      this.tipName,
      this.mahalle,
      this.kategoriName,
      this.ilce,
      this.ilanYapi,
      this.ilanOdaSayisi,
      this.ilanMetreKare,
      this.ilanKredi,
      this.ilanKatSayisi,
      this.ilanIsinma,
      this.ilanBinaYasi,
      this.ilanFiyat,
      this.ilanBaslik,
      this.il,
      this.latitude,
      this.longitude,
      this.ekOzellikler,
      this.ilanBanyoSayisi,
      this.ownerUrl});

  @override
  void initState() {
    super.initState();
    isExpandeded = false;
    url = ownerUrl;
    tumPhotolar();
  }

  tumPhotolar() async {
    QuerySnapshot snapshot = await ilanPhotoRef
        .doc(anlikKullanici!.id)
        .collection("ilanGonderi")
        .doc(ilanID!)
        .collection("Gonderi")
        .get();
    List<IlanPhotos>? kullanicires1 =
        snapshot.docs.map((doc) => IlanPhotos.fromDocument(doc)).toList();
    setState(() {
      this.tumPhotos = kullanicires1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    isLiked = (likes![anlikKullanici!.id.toString()] == true);
    kaydedildimi = (kaydedilenler![anlikKullanici!.id.toString()] == true);
    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: likeCount!,
            child: Container(
              height: size.height * 0.45,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(frontUrl!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              height: size.height * 0.36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 29),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, likeCount);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      kaydedildimi! == true
                                          ? Icons.bookmark
                                          : Icons.bookmark_outline,
                                      color: Colors.indigo[400],
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      await kullaniciKartKaydetmeKontrolu();
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.bookmark,
                                        color: Colors.indigo[400],
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "${saveCount!} kaydetme",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[400],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      width: 80,
                      height: 30,
                      child: Center(
                        child: Text(
                          yayinName!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Expanded(
                            child: Text(
                              ilanBaslik!,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ilanBaslik!.length > 30 ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          width: 300,
                        ),
                        Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                isLiked! == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                              ),
                              color: Colors.indigo[400],
                              onPressed: () async {
                                await kullaniciGonderiBegeniKontrolu();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 8,
                      bottom: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 29,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  il!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  ilce!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  mahalle!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.zoom_out_map,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              ilanMetreKare! + " " + " m²",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.indigo[400],
                                  size: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${likeCount!} beğenme",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 15),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                controller: controller,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(url!),
                                  fit: BoxFit.cover,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ownerProfileName!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  ownerBiography!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ownerID! == anlikKullanici!.id
                            ? Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[700]!.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: Colors.indigoAccent[700],
                                  ),
                                  onPressed: () {
                                    gonderiSilmeKontrolu(context);
                                  },
                                )),
                              )
                            : Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.indigo[700]!.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.phone,
                                        color: Colors.indigoAccent[700],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.indigo[700]!.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.message,
                                          color: Colors.indigoAccent[700],
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          kullaniciRef
                                              .doc(anlikKullanici!.id)
                                              .update(
                                                  {'chattingWith': ownerID});
                                          kullaniciRef.doc(ownerID).update({
                                            'chattingWith': anlikKullanici!.id
                                          });
                                          if (id.hashCode <= ownerID.hashCode) {
                                            groupChatId = '$id-$ownerID';
                                          } else {
                                            groupChatId = '$ownerID-$id';
                                          }
                                          QuerySnapshot snapshot1 =
                                              await messageRef
                                                  .doc(groupChatId)
                                                  .collection(groupChatId)
                                                  .where("idFrom",
                                                      isEqualTo: ownerID)
                                                  .get();
                                          List<Mesajlar> kullaniciress =
                                              snapshot1.docs
                                                  .map((doc) =>
                                                      Mesajlar.fromDocument(
                                                          doc))
                                                  .toList();
                                          for (var doc in kullaniciress) {
                                            if (doc.idFrom == ownerID) {
                                              var documentReference =
                                                  FirebaseFirestore.instance
                                                      .collection('messages')
                                                      .doc(groupChatId)
                                                      .collection(groupChatId)
                                                      .doc(doc.messageID);

                                              FirebaseFirestore.instance
                                                  .runTransaction(
                                                      (transaction) async {
                                                transaction.update(
                                                  documentReference,
                                                  {
                                                    'isRead': true,
                                                  },
                                                );
                                              });
                                            }
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Chat(
                                                controller: controller,
                                                receiverUsername: username!,
                                                receiverId: ownerID!,
                                                receiverAvatar: ownerUrl!,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildFeature(
                                Icons.roofing, ilanOdaSayisi! + " " + "Oda"),
                            buildFeature(
                                Icons.living, ilanSalonSayisi! + " " + "Salon"),
                            buildFeature(Icons.bathtub,
                                ilanBanyoSayisi! + " " + "Banyo"),
                            buildFeature(
                                Icons.data_usage, ilanYapi! + " " + "Yapı"),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildFeature(
                                Icons.location_city,
                                ilanKatSayisi! +
                                    " " +
                                    "Kat" +
                                    "lı" +
                                    " " +
                                    "Yapı"),
                            buildFeature(Icons.thermostat_outlined,
                                ilanIsinma! + " " + "ile" + " " + "Isınma"),
                            buildFeature(
                                Icons.credit_card,
                                "Krediye Uygun mu" +
                                    " " +
                                    ":" +
                                    " " +
                                    ilanKredi!),
                            buildFeature(Icons.home_rounded, ilanKullanim!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 16,
                    ),
                    child: Text(
                      "Açıklama",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 24,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 10),
                              blurRadius: 100,
                              color: Colors.grey[200]!)
                        ],
                        border: Border.all(
                          color: Colors.indigo[700]!.withOpacity(0.3),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Text(
                        ilanAciklama!,
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 16,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ExpansionPanelList(
                        animationDuration: Duration(milliseconds: 1000),
                        dividerColor: Colors.grey,
                        elevation: 2,
                        children: [
                          ExpansionPanel(
                            body: ListView.builder(
                              padding: EdgeInsets.only(bottom: 30),
                              controller: controller,
                              shrinkWrap: true,
                              itemCount: ekOzellikler!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 5),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                        dense: true,
                                        leading: Icon(
                                          Icons.check_circle,
                                          color: Colors.indigo,
                                        ),
                                        title: Text(ekOzellikler![index]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return InkWell(
                                onTap: () {
                                  if (isExpandeded == false) {
                                    setState(() {
                                      isExpandeded = true;
                                    });
                                  } else {
                                    setState(() {
                                      isExpandeded = false;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "Ek Özellikler",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                            isExpanded: isExpandeded!,
                          )
                        ],
                        expansionCallback: (int item, bool status) {
                          setState(() {
                            isExpandeded = !isExpandeded!;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                      left: 25,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Konum",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.place,
                                color: Colors.indigo[400],
                                size: 32,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(il!),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                              ),
                              Text(ilce!),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                              ),
                              Text(mahalle!),
                            ],
                          ),
                        ),
                        Container(
                          height: 150,
                          width: 360,
                          padding: EdgeInsets.all(3),
                          child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                                target: LatLng(latitude!, longitude!),
                                zoom: 14),
                            markers: {
                              Marker(
                                markerId: MarkerId(ilanBaslik!),
                                position: LatLng(latitude!, longitude!),
                                infoWindow: InfoWindow(title: ilanBaslik!),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueViolet,
                                ),
                              )
                            },
                            gestureRecognizers: Set()
                              ..add(Factory<PanGestureRecognizer>(
                                  () => PanGestureRecognizer()))
                              ..add(
                                Factory<VerticalDragGestureRecognizer>(
                                    () => VerticalDragGestureRecognizer()),
                              )
                              ..add(
                                Factory<HorizontalDragGestureRecognizer>(
                                    () => HorizontalDragGestureRecognizer()),
                              )
                              ..add(
                                Factory<ScaleGestureRecognizer>(
                                    () => ScaleGestureRecognizer()),
                              ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.indigo[400]!, width: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24,
                      left: 24,
                      bottom: 16,
                    ),
                    child: Text(
                      "Fotoğraflar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      bottom: 24,
                    ),
                    child: Container(
                      height: 150,
                      width: 200,
                      child: FutureBuilder<QuerySnapshot>(
                        future: ilanPhotoRef
                            .doc(ownerID!)
                            .collection("ilanGonderi")
                            .doc(ilanID!)
                            .collection("Gonderi")
                            .get(),
                        builder: (context, snp) {
                          if (!snp.hasData) {
                            return circularProgress();
                          } else {
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: snp.data!.docs.length,
                              itemBuilder: (context, index) {
                                IlanPhotos ilanPhotos = IlanPhotos.fromDocument(
                                    snp.data!.docs[index]);
                                return AspectRatio(
                                  aspectRatio: 3 / 2,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(ilanPhotos.url!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  kullaniciGonderiBegeniKontrolu() async {
    var kullaniciID = anlikKullanici!.id.toString();
    bool _liked = (likes![kullaniciID] == true);
    if (_liked) {
      ilanRef.doc(ilanID).update({"likes.$kullaniciID": false});
      favoriRef
          .doc(kullaniciID)
          .collection("Favoriler")
          .doc(ilanID)
          .get()
          .then((favori) => {
                if (favori.exists)
                  {
                    favori.reference.delete(),
                  }
              });
      begeniSil();
      setState(() {
        likeCount = likeCount! - 1;
        isLiked = false;
        likes![kullaniciID] = false;
      });
    } else if (!_liked) {
      await ilanRef.doc(ilanID).update({"likes.$kullaniciID": true});
      begeniEkle();
      favoriEkle();
      setState(() {
        likeCount = likeCount! + 1;
        isLiked = true;
        likes![kullaniciID] = true;
      });
    }
  }

  begeniSil() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(ilanID)
          .get()
          .then((begeni) => {
                if (begeni.exists)
                  {
                    begeni.reference.delete(),
                  }
              });
    }
  }

  begeniEkle() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef.doc(ownerID).collection("bildirimler").doc(ilanID).set({
        "type": 'like',
        "username": anlikKullanici!.username,
        "userID": anlikKullanici!.id,
        "timestamp": timestamp,
        "frontUrl": frontUrl,
        "ilanID": ilanID,
        "userProfileImg": anlikKullanici!.url,
        "commentData": "",
        "ownerID": ownerID,
      });
    }
  }

  Widget buildFeature(IconData iconData, String text) {
    return Expanded(
      child: Column(
        children: [
          SafeArea(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.indigo[700]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: Colors.indigoAccent[700],
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  gonderiSilmeKontrolu(BuildContext mcontext) {
    return showDialog(
        barrierColor: Colors.black54.withOpacity(0.3),
        context: mcontext,
        builder: (context) {
          return SimpleDialog(
            elevation: 20,
            backgroundColor: Colors.white,
            title: Text(
              "Silme İşlemi gerçekleştirilsin mi ?",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            children: [
              SimpleDialogOption(
                child: Text("Sil",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  kullaniciIlanSilme();
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Çık",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  kullaniciIlanSilme() async {
    await ilanRef.doc(ilanID).get().then((value) async {
      if (value.exists) {
        value.reference.delete();
      }
      Navigator.pop(context);
      setState(() {});
    });
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child("İlan Fotoğrafları")
        .child(ilanID!)
        .listAll();

    result.items.forEach((Reference ref) {
      ref.delete();
    });
    QuerySnapshot querySnapshot = await bildirimRef
        .doc(ownerID)
        .collection("bildirimler")
        .where("ilanID", isEqualTo: ilanID)
        .get();
    querySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    /*QuerySnapshot commentquerySnapshot =
        await yorumRef.doc(ilanID).collection("yorumlar").get();
    commentquerySnapshot.docs.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });*/
  }

  kaydetmeSil() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(onlineUserID! + ilanID!)
          .get()
          .then((kaydetme) => {
                if (kaydetme.exists)
                  {
                    kaydetme.reference.delete(),
                  }
              });
    }
  }

  kaydetmeEkle() {
    bool isNotPostOwner = onlineUserID != ownerID;
    if (isNotPostOwner) {
      bildirimRef
          .doc(ownerID)
          .collection("bildirimler")
          .doc(onlineUserID! + ilanID!)
          .set({
        "type": 'kaydetme',
        "username": anlikKullanici!.username,
        "userID": anlikKullanici!.id,
        "timestamp": timestamp,
        "frontUrl": frontUrl,
        "ilanID": ilanID,
        "userProfileImg": anlikKullanici!.url,
        "commentData": "kaydetme",
        "ownerID": ownerID,
      });
    }
  }

  kullaniciKartKaydetmeKontrolu() async {
    var kullaniciID = anlikKullanici!.id;
    bool _kayit = (kaydedilenler![kullaniciID] == true);
    if (_kayit) {
      ilanRef.doc(ilanID).update({"kaydedilenler.$kullaniciID": false});
      kaydetmeRef
          .doc(kullaniciID)
          .collection("Kaydedilen İlanlar")
          .doc(ilanID)
          .get()
          .then((kaydetme) => {
                if (kaydetme.exists)
                  {
                    kaydetme.reference.delete(),
                  }
              });
      kaydetmeSil();
      setState(() {
        saveCount = saveCount! - 1;
        kaydedildimi = false;
        kaydedilenler![kullaniciID] = false;
      });
    } else if (!_kayit) {
      ilanRef.doc(ilanID).update({"kaydedilenler.$kullaniciID": true});
      kaydetmeEkle();
      ilanKaydet();
      setState(() {
        saveCount = saveCount! + 1;
        kaydedildimi = true;
        kaydedilenler![kullaniciID] = true;
      });
    }
  }

  ilanKaydet() async {
    await kaydetmeRef
        .doc(anlikKullanici!.id)
        .collection("Kaydedilen İlanlar")
        .doc(ilanID)
        .set({
      "ilanID": ilanID,
      "ownerID": ownerID,
      "username": username,
    });
  }

  favoriEkle() async {
    await favoriRef
        .doc(anlikKullanici!.id)
        .collection("Favoriler")
        .doc(ilanID)
        .set({
      "ilanID": ilanID,
      "ownerID": ownerID,
      "username": username,
    });
  }
}
