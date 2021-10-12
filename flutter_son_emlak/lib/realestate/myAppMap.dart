import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/AnaSayfa.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

bool? kaydedildimi;

class myAppMap extends StatefulWidget {
  final LatLng? currentPostion;
  myAppMap({
    required this.currentPostion,
  });
  @override
  _myAppMapState createState() => _myAppMapState(
        currentPostion: this.currentPostion,
      );
}

class _myAppMapState extends State<myAppMap> {
  Completer<GoogleMapController> _controller = Completer();
  List<Ilanlar>? tumIlanlarList = [];
  List<Marker> myMarkers = [];
  List<Marker> allMarkers = [];
  double zoomVal = 5.0;
  final LatLng? currentPostion;
  _myAppMapState({
    this.currentPostion,
  });

  @override
  void initState() {
    super.initState();
    tumIlanlar();
  }

  tumIlanlar() async {
    QuerySnapshot snapshot = await ilanRef.get();

    List<Ilanlar>? kullanicires1 =
        snapshot.docs.map((doc) => Ilanlar.fromDocument(doc)).toList();
    setState(() {
      this.tumIlanlarList = kullanicires1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.indigoAccent,
        title: Text("Harita Görünümü", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          /*Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildContainer(tumIlanlarList!),
            ),
          ),*/
        ],
      ),
    );
  }

  buildProperty(Ilanlar ilanlar) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Container(
        width: 75,
        height: 190,
        padding: EdgeInsets.only(top: 20),
        child: GestureDetector(
          child: Card(
            margin: EdgeInsets.only(bottom: 24),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(ilanlar.frontUrl!),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[400],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      width: 50,
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Center(
                        child: Text(
                          ilanlar.yayinName!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 30, bottom: 10),
                                  child: Text(
                                    ilanlar.ilanBaslik!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          ilanlar.mahalle!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                          ilanlar.ilanMetreKare.toString() +
                                              "m2",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10, top: 20),
                                  child: Text(
                                    r"₺" + ilanlar.ilanFiyat!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Row(
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
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: ilanRef
                                                .doc(ilanlar.ilanID)
                                                .snapshots(),
                                            builder: (context, snp) {
                                              if (!snp.hasData) {
                                                return circularProgress();
                                              } else {
                                                int sayac = 0;
                                                if (snp.data!.get("likes") ==
                                                    null) {
                                                  return Text(
                                                    sayac.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }
                                                snp.data!
                                                    .get("likes")
                                                    .values
                                                    .forEach((herbirDeger) {
                                                  if (herbirDeger == true) {
                                                    sayac = sayac + 1;
                                                    return Text(
                                                      sayac.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    );
                                                  }
                                                });
                                                return Text(
                                                  sayac.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
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
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: ilanRef
                                              .doc(ilanlar.ilanID)
                                              .snapshots(),
                                          builder: (context, snp) {
                                            if (!snp.hasData) {
                                              return circularProgress();
                                            } else {
                                              int sayac = 0;
                                              if (snp.data!
                                                      .get("kaydedilenler") ==
                                                  null) {
                                                return Text(
                                                  sayac.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                              snp.data!
                                                  .get("kaydedilenler")
                                                  .values
                                                  .forEach((herbirDeger) {
                                                if (herbirDeger == true) {
                                                  sayac = sayac + 1;
                                                  return Text(
                                                    sayac.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }
                                              });
                                              return Text(
                                                sayac.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              _gotoLocation(ilanlar.latitude!, ilanlar.longitude!);
            });
          },
        ),
      ),
    );
  }

  Widget _buildContainer(List<Ilanlar> list) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: ListView.builder(
            itemCount: tumIlanlarList!.length,
            itemBuilder: (context, index) {
              return buildProperty(tumIlanlarList![index]);
            }));
  }

  Widget _boxes(String _image, double lat, double long, String restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  /*Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(restaurantName),
                    ),
                  ),*/
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(
    BuildContext context,
  ) {
    return FutureBuilder<QuerySnapshot>(
        future: ilanRef.get(),
        builder: (context, snp) {
          if (!snp.hasData) {
            return circularProgress();
          } else {
            for (int i = 0; i < snp.data!.docs.length; i++) {
              allMarkers.add(Marker(
                markerId: MarkerId(snp.data!.docs[i].get("ilanBaslik")),
                position: LatLng(
                  snp.data!.docs[i].get("latitude"),
                  snp.data!.docs[i].get("longitude"),
                ),
                infoWindow:
                    InfoWindow(title: snp.data!.docs[i].get("ilanBaslik")!),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
              ));
            }
            return ListView.builder(
                itemCount: snp.data!.docs.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1.10,
                    child: GoogleMap(
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition:
                          CameraPosition(target: currentPostion!, zoom: 14),
                      markers: Set.from(allMarkers),
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
                  );
                });
          }
        });
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}
