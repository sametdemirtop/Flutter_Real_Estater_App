import "package:flutter/material.dart";

PreferredSize baslik(context, {bool uygulamaBasligi = false, required String strBaslik, geriButonuYokSay = false}) {
  return PreferredSize(
      child: AppBar(
        elevation: 10,
        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: geriButonuYokSay ? false : true,
        title: Text(
          uygulamaBasligi ? "FutureBack" : strBaslik,
          style: TextStyle(
            color: Colors.black,
            fontFamily: uygulamaBasligi ? "Signatra" : "",
            fontSize: uygulamaBasligi ? 50.0 : 22.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(50), bottomLeft: Radius.circular(50)),
        ),
      ),
      preferredSize: Size.fromHeight(50));
}
