import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/gonderiEkranSayfasi.dart';

import 'ilanlar.dart';

// ignore: camel_case_types
class gonderiListeleme extends StatelessWidget {
  final Ilanlar? gonderi;
  gonderiListeleme(this.gonderi);
  tumIlanlariGoster(context, {String? gonderiID, String? kullaniciID}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => gonderiEkranSayfasi(
                gonderiID: gonderiID!, kullaniciID: kullaniciID!)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tumIlanlariGoster(context,
            gonderiID: gonderi!.ilanID, kullaniciID: gonderi!.ownerID);
      },
      child: Image.network(gonderi!.frontUrl as String),
    );
  }
}
