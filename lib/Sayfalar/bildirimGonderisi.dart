import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/widgets/baslik.dart';
import 'package:flutter_son_emlak/widgets/ilanlar.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';

import 'AnaSayfa.dart';

class bildirimGonderisi extends StatelessWidget {
  final String? gonderiID;
  final String? kullaniciID;
  bildirimGonderisi({required this.kullaniciID, required this.gonderiID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: gonderiRef
            .doc(anlikKullanici!.id)
            .collection("kullaniciGonderi")
            .doc(gonderiID)
            .snapshots(),
        builder: (context, ds) {
          if (!ds.hasData) {
            return circularProgress();
          }
          Ilanlar ilanlar = Ilanlar.fromDocument(ds.data!);
          return Center(
            child: Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: baslik(context, strBaslik: ""),
              body: SingleChildScrollView(child: ilanlar),
            ),
          );
        });
  }
}
