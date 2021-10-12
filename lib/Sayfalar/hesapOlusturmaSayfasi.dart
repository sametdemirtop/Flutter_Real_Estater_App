import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/widgets/baslik.dart';

class HesapOlusturmaSayfasi extends StatefulWidget {
  @override
  _HesapOlusturmaSayfasiState createState() => _HesapOlusturmaSayfasiState();
}

class _HesapOlusturmaSayfasiState extends State<HesapOlusturmaSayfasi> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String? username;
  kullaniciadiOlusturma() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      form.save();

      SnackBar snackbar =
          SnackBar(content: Text("Hoşgeldin" + " " + username!));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar:
          baslik(context, strBaslik: "Hesap Oluşturma", geriButonuYokSay: true),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 26.0),
            child: Text(
              "Kullanıcı Adı gir",
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(17.0),
            child: Container(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  validator: (val) {
                    if (val!.trim().length < 5 || val.isEmpty) {
                      return "Kullanıcı adı çok kısa";
                    } else if (val.trim().length > 15) {
                      return "Kullanıcı adı çok uzun";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (val) => username = val,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: OutlineInputBorder(),
                      labelText: "Username",
                      labelStyle: TextStyle(fontSize: 16.0),
                      hintText: "En az 5 karakter olmalı",
                      hintStyle: TextStyle(color: Colors.black12)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: kullaniciadiOlusturma,
            child: Container(
              height: 55.0,
              width: 360.0,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  "İlerle",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
