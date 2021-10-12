import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_son_emlak/Sayfalar/AnaSayfa.dart';
import 'package:flutter_son_emlak/Sayfalar/MesajlasmaSayfasi.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/model/Mesajlar.dart';
import 'package:flutter_son_emlak/model/ilan.dart';
import 'package:flutter_son_emlak/realestate/buildDetail.dart';
import 'package:flutter_son_emlak/realestate/ilanPhotos.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class Ilanlar extends StatefulWidget {
  final String? ilanID;
  final String? ownerBiography;
  final String? ownerProfileName;
  final String? ilanKullanim;
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

  bool yuklenme = false;

  Ilanlar({
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
  factory Ilanlar.fromDocument(DocumentSnapshot doc) {
    return Ilanlar(
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
  _IlanlarState createState() => _IlanlarState(
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

class _IlanlarState extends State<Ilanlar> {
  final String? il;
  final String? ilce;
  final String? ilanKullanim;
  final String? mahalle;
  final String? ownerBiography;
  final String? ownerProfileName;
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
  bool? kaydedildimi;
  bool? isLiked;
  int? activeIndex = 0;

  String? begeni = "0";
  List<IlanPhotos> tumPhotos = [];

  final String? onlineUserID = anlikKullanici!.id;
  final ScrollController controller = ScrollController();
  String id = anlikKullanici!.id;
  String groupChatId = "";

  _IlanlarState(
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
    tumPhotolar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: buildProperty(),
    );
  }

  tumPhotolar() async {
    QuerySnapshot snapshot = await ilanPhotoRef
        .doc(ownerID!)
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

  buildProperty() {
    isLiked = (likes![anlikKullanici!.id.toString()] == true);
    kaydedildimi = (kaydedilenler![anlikKullanici!.id.toString()] == true);
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 10),
      child: Container(
        width: 150,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 10,
                color: Colors.grey.shade300)
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Stack(
          fit: StackFit.loose,
          alignment: Alignment.topCenter,
          children: [
            FutureBuilder<QuerySnapshot>(
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
                  return CarouselSlider.builder(
                    itemCount: snp.data!.docs.length,
                    itemBuilder: (context, index, realIndex) {
                      IlanPhotos ilanPhotos =
                          IlanPhotos.fromDocument(snp.data!.docs[index]);
                      return GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 90),
                          child: Card(
                            margin: EdgeInsets.only(bottom: 90),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: CachedNetworkImage(
                              maxHeightDiskCache: 25,
                              imageUrl: ilanPhotos.url!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      ilanPhotos.url!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(20),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.indigo[400],
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            width: 80,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
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
                                          Container(
                                            child: buildSmooth(ilanPhotos.url!),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.6),
                                                  spreadRadius: 3,
                                                  blurRadius: 15,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: IconButton(
                                                        icon: StreamBuilder<
                                                            DocumentSnapshot>(
                                                          stream: ilanRef
                                                              .doc(ilanID)
                                                              .snapshots(),
                                                          builder:
                                                              (context, snp) {
                                                            if (!snp.hasData) {
                                                              return circularProgress();
                                                            } else {
                                                              Ilan sonIlan = Ilan
                                                                  .fromDocument(
                                                                      snp.data!);
                                                              return Icon(
                                                                sonIlan.likes![anlikKullanici!
                                                                            .id
                                                                            .toString()] ==
                                                                        true
                                                                    ? Icons
                                                                        .favorite
                                                                    : Icons
                                                                        .favorite_border,
                                                                size: 20,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        color:
                                                            Colors.indigo[400],
                                                        onPressed: () async {
                                                          await kullaniciGonderiBegeniKontrolu();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  StreamBuilder<
                                                      DocumentSnapshot>(
                                                    stream: ilanRef
                                                        .doc(ilanID)
                                                        .snapshots(),
                                                    builder: (context, snp) {
                                                      if (!snp.hasData) {
                                                        return circularProgress();
                                                      } else {
                                                        int sayac = 0;
                                                        if (snp.data!
                                                                .get("likes") ==
                                                            null) {
                                                          return Text(
                                                            sayac.toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          );
                                                        }
                                                        snp.data!
                                                            .get("likes")
                                                            .values
                                                            .forEach(
                                                                (herbirDeger) {
                                                          if (herbirDeger ==
                                                              true) {
                                                            sayac = sayac + 1;
                                                            return Text(
                                                              sayac.toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            );
                                                          }
                                                        });
                                                        return Text(
                                                          sayac.toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  right: 5,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: IconButton(
                                                          icon: StreamBuilder<
                                                                  DocumentSnapshot>(
                                                              stream: ilanRef
                                                                  .doc(ilanID)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (snapshot
                                                                        .hasData !=
                                                                    true) {
                                                                  return circularProgress();
                                                                } else {
                                                                  Ilan sonIlan =
                                                                      Ilan.fromDocument(
                                                                          snapshot
                                                                              .data!);
                                                                  return Icon(
                                                                    sonIlan.kaydedilenler![anlikKullanici!.id.toString()] ==
                                                                            true
                                                                        ? Icons
                                                                            .bookmark
                                                                        : Icons
                                                                            .bookmark_outline,
                                                                    color: Colors
                                                                            .indigo[
                                                                        400],
                                                                    size: 21,
                                                                  );
                                                                }
                                                              }),
                                                          onPressed: () async {
                                                            await kullaniciKartKaydetmeKontrolu();
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    StreamBuilder<
                                                        DocumentSnapshot>(
                                                      stream: ilanRef
                                                          .doc(ilanID)
                                                          .snapshots(),
                                                      builder: (context, snp) {
                                                        if (!snp.hasData) {
                                                          return circularProgress();
                                                        } else {
                                                          int sayac = 0;
                                                          if (snp.data!.get(
                                                                  "kaydedilenler") ==
                                                              null) {
                                                            return Text(
                                                              sayac.toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            );
                                                          }
                                                          snp.data!
                                                              .get(
                                                                  "kaydedilenler")
                                                              .values
                                                              .forEach(
                                                                  (herbirDeger) {
                                                            if (herbirDeger ==
                                                                true) {
                                                              sayac = sayac + 1;
                                                              return Text(
                                                                sayac
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              );
                                                            }
                                                          });
                                                          return Text(
                                                            sayac.toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Container(
                                                  width: 225,
                                                  child: Text(
                                                    ilanBaslik!,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          ilanBaslik!.length >
                                                                  30
                                                              ? 16
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 10, top: 10),
                                                child: Text(
                                                  r"₺" + ilanFiyat!,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    mahalle!,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Icon(
                                                    Icons.zoom_out_map,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    ilanMetreKare.toString() +
                                                        "m²",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => circularProgress(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => detaySayfasinaGitme(),
                                ));
                          });
                        },
                      );
                    },
                    options: CarouselOptions(
                        height: 400,
                        viewportFraction: 1,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            activeIndex = index;
                          });
                        }),
                  );
                }
              },
            ),
            Positioned.fill(
              top: 225,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.place,
                              color: Colors.indigo[400],
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              il!,
                              style: TextStyle(fontSize: 10),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 13,
                            ),
                            Text(
                              ilce!,
                              style: TextStyle(fontSize: 10),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 13,
                            ),
                            Text(
                              mahalle!,
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        Text(
                          timeago.format(timestamp!.toDate()),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 20,
                    ),
                    child: Container(
                      height: 55,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: [
                          buildFeature(
                              Icons.roofing, ilanOdaSayisi! + " " + "Oda"),
                          buildFeature(
                              Icons.living, ilanSalonSayisi! + " " + "Salon"),
                          buildFeature(
                              Icons.bathtub, ilanBanyoSayisi! + " " + "Banyo"),
                          buildFeature(
                              Icons.data_usage, ilanYapi! + " " + "Yapı"),
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(ownerUrl!),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ownerProfileName!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      ownerBiography!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        ownerID! == anlikKullanici!.id
                            ? Container(
                                height: 40,
                                width: 40,
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
                                    height: 40,
                                    width: 40,
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
                                    height: 40,
                                    width: 40,
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
                ],
              ),
            ),
          ],
        ),
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

  Widget buildFeature(IconData iconData, String text) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Container(
            height: 30,
            width: 30,
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
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
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

  detaySayfasinaGitme() {
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

  kullaniciProfiliGoster(BuildContext context, {String? kullaniciProfilID}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => profilSayfasi(
                  kullaniciprofilID: kullaniciProfilID,
                  ilanID: '',
                )));
  }

  Widget buildSmooth(String urlImages) {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex!,
      count: tumPhotos.length,
      effect: JumpingDotEffect(
        elevation: 10,
        dotWidth: 5,
        dotHeight: 5,
        activeDotColor: Colors.indigoAccent,
        dotColor: Colors.white.withOpacity(0.9),
      ),
    );
  }
}
