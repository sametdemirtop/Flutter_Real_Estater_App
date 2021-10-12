import 'package:cloud_firestore/cloud_firestore.dart';

class Ilan {
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

  Ilan({
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

  factory Ilan.fromDocument(DocumentSnapshot doc) {
    return Ilan(
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
}
