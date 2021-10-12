import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/AnaSayfa.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/realestate/myAppMap.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: camel_case_types
class anaAkisSayfasi extends StatefulWidget {
  final Kullanici? gAnlikKullanici;
  anaAkisSayfasi({
    required this.gAnlikKullanici,
  });

  @override
  _anaAkisSayfasiState createState() => _anaAkisSayfasiState();
}

// ignore: camel_case_types
class _anaAkisSayfasiState extends State<anaAkisSayfasi>
    with AutomaticKeepAliveClientMixin<anaAkisSayfasi> {
  List<Ilanlar>? tumIlanlarList = [];
  final ScrollController controller = ScrollController();
  LatLng? currentPostion;
  @override
  void initState() {
    super.initState();
    tumIlanlar();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: buildRefreshIndicator(),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(right: 10),
            icon: Icon(
              Icons.map,
              color: Colors.deepPurple[400],
            ),
            onPressed: () {
              haritayiAc();
            },
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "İlanlar",
          style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  RefreshIndicator buildRefreshIndicator() {
    return RefreshIndicator(
      color: Colors.indigo,
      child: ListView(
        shrinkWrap: true,
        children: tumIlanlarList!,
      ),
      onRefresh: () => tumIlanlar(),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });
  }

  tumIlanlar() async {
    QuerySnapshot snapshot = await ilanRef.get();

    List<Ilanlar>? kullanicires1 =
        snapshot.docs.map((doc) => Ilanlar.fromDocument(doc)).toList();
    setState(() {
      this.tumIlanlarList = kullanicires1;
    });
  }

  void haritayiAc() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => myAppMap(currentPostion: currentPostion)));
  }
}
