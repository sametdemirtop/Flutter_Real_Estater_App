import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/widgets/baslik.dart';
import 'package:image/image.dart' as ImD;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class HesapOlusturmaSayfasi2 extends StatefulWidget {
  final Kullanici? kullanici;
  String? urlIndirme;
  HesapOlusturmaSayfasi2({this.kullanici, this.urlIndirme});
  @override
  _HesapOlusturmaSayfasi2State createState() => _HesapOlusturmaSayfasi2State();
}

class _HesapOlusturmaSayfasi2State extends State<HesapOlusturmaSayfasi2> {
  final imagePicker = ImagePicker();
  File? dosya;
  String gonderiID = Uuid().v4();
  String urlBaslangic =
      "https://www.seekpng.com/png/detail/1010-10108361_person-icon-circle.png";
  Future galeridenFotograf() async {
    final fotograf = await imagePicker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (fotograf != null) {
        dosya = File(fotograf.path);
      } else {
        print('No image selected.');
      }
    });
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

  yuklemeveKaydetmeKontrol() async {
    await fotografiBicimlendirme();
    widget.urlIndirme = await fotografYukleme(dosya!);
    setState(() {
      urlBaslangic = widget.urlIndirme!;
      gonderiID = Uuid().v4();
    });
    if (dosya != null) {
      SnackBar snackbar = SnackBar(
          content: Text("Bilgileriniz Kaydedildi," + "Giriş Yapınız.. "));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, widget.urlIndirme);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baslik(context,
          strBaslik: "Create Profile Photo", geriButonuYokSay: true),
      body: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 15),
                      blurRadius: 10,
                      color: Colors.white)
                ],
              ),
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: NetworkImage(urlBaslangic),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: galeridenFotograf,
              child: Center(
                  child: Text(
                "Change Profile Photo",
                style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              )),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          TextButton(
            onPressed: () {
              yuklemeveKaydetmeKontrol();
            },
            child: Container(
              width: 200.0,
              height: 50,
              child: Text(
                "Kaydet",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
                ],
                color: Colors.brown[100],
                border: Border.all(color: Colors.orange.shade50),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
