import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_son_emlak/Sayfalar/takipEdilenler.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/model/Mesajlar.dart';
import 'package:flutter_son_emlak/model/Sohbet.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'AnaSayfa.dart';
import 'GirisEkran.dart';
import 'MesajlasmaSayfasi.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key, required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final ScrollController listScrollController = ScrollController();
  final ScrollController controller = ScrollController();
  TextEditingController? textDuzenlemeKontrol;
  Stream<QuerySnapshot>? futureAramaSonuclari;
  int? tEdilenSayisi = 0;
  List<Sohbet>? sohbetEdilenler = [];
  bool tikladi = false;
  List<Kullanici>? userList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String id = anlikKullanici!.id;
  String groupChatId = "";
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    getUsers();
    registerNotification();
    configLocalNotification();
    textDuzenlemeKontrol = TextEditingController();
    listScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    textDuzenlemeKontrol!.dispose();
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      kullaniciRef.doc(anlikKullanici!.id).update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {});
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.sametdemirtop.emlakcim',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  aramaYeriTemizleme() {
    textDuzenlemeKontrol!.clear();
    setState(() {
      textDuzenlemeKontrol!.text.isEmpty == true;
    });
  }

  getUsers() async {
    QuerySnapshot qs = await kullaniciRef.get();
    List<Kullanici> kullaniciress =
        qs.docs.map((doc) => Kullanici.fromDocument(doc)).toList();
    setState(() {
      this.userList = kullaniciress;
    });
  }

  buildSuggestions(String query) {
    final List<Kullanici> suggestionList = query.isEmpty
        ? []
        : userList != null
            ? userList!.where((Kullanici user) {
                String _getUsername = user.username.toLowerCase();
                String _query = query.toLowerCase();
                String _getName = user.profileName.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                bool matchesName = _getName.contains(_query);

                return (matchesUsername || matchesName);
              }).toList()
            : [];

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      controller: controller,
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        Kullanici searchedUser = Kullanici(
            id: suggestionList[index].id,
            url: suggestionList[index].url,
            profileName: suggestionList[index].profileName,
            username: suggestionList[index].username,
            chattingWith: suggestionList[index].chattingWith,
            pushToken: suggestionList[index].pushToken,
            biography: suggestionList[index].biography,
            email: suggestionList[index].email,
            isWriting: false,
            isEnteredApp: false);

        return KullaniciSonucMessage(searchedUser);
      }),
    );
  }

  aramaCubugu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(top: 5),
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(35.0),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: textDuzenlemeKontrol,
                      decoration: InputDecoration(
                          hintText: "Ara",
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          border: InputBorder.none),
                      onChanged: (val) {
                        setState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                  textDuzenlemeKontrol!.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.black45),
                          onPressed: aramaYeriTemizleme,
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  tEdilenleriGetirme() {
    return StreamBuilder<QuerySnapshot>(
      stream: takipEdilenRef
          .doc(anlikKullanici!.id)
          .collection("takipEdilenler")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                buildItem(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  sohbetttgetir() {
    return StreamBuilder<QuerySnapshot>(
      stream: sohbetRef
          .doc(anlikKullanici!.id)
          .collection("sohbetEdilenler")
          .where("field")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(20.0),
            itemBuilder: (context, index) =>
                buildItem2(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  takipcileriGetirme() {
    return StreamBuilder<QuerySnapshot>(
      stream: takipciRef
          .doc(anlikKullanici!.id)
          .collection("takipciler")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                buildItem(context, snapshot.data?.docs[index]),
            itemCount: snapshot.data?.docs.length,
            controller: listScrollController,
          );
        } else {
          return Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          );
        }
      },
    );
  }

  void onItemMenuPress(Choice choice) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GirisEkran()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Mesajlar",
          style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 23,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: textDuzenlemeKontrol!.text.isEmpty
              ? ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: aramaCubugu(context),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    sohbetttgetir(),
                  ],
                )
              : Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: ListView(
                    children: [
                      aramaCubugu(context),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: buildSuggestions(query),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      tEdilen userChat = tEdilen.fromDocument(document);
      if (id.hashCode <= userChat.id.hashCode) {
        groupChatId = '$id-${userChat.id}';
      } else {
        groupChatId = '${userChat.id}-$id';
      }
      if (userChat.id == anlikKullanici!.id) {
        return Container(
          color: Colors.white,
        );
      } else {
        return Container(
          child: TextButton(
            child: ListTile(
              dense: true,
              leading: Container(
                height: 50,
                width: 50,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 6,
                            color: Colors.grey.shade300)
                      ],
                      image: DecorationImage(
                          fit: BoxFit.cover, image: NetworkImage(userChat.url)),
                    ),
                  ),
                ),
              ),
              title: Text(
                userChat.profileName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                userChat.username,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
              trailing: Icon(
                Icons.message,
                size: 35,
                color: Colors.deepOrange[100],
              ),
            ),
            onPressed: () async {
              QuerySnapshot snapshot1 = await messageRef
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .where("idFrom", isEqualTo: userChat.id)
                  .get();
              List<Mesajlar> kullaniciress = snapshot1.docs
                  .map((doc) => Mesajlar.fromDocument(doc))
                  .toList();
              for (var doc in kullaniciress) {
                if (doc.idFrom == userChat.id) {
                  var documentReference = FirebaseFirestore.instance
                      .collection('messages')
                      .doc(groupChatId)
                      .collection(groupChatId)
                      .doc(doc.messageID);

                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    transaction.update(
                      documentReference,
                      {
                        'isRead': true,
                      },
                    );
                  });
                  sohbetRef
                      .doc(doc.idFrom)
                      .collection("sohbetEdilenler")
                      .doc(doc.idTo)
                      .update({
                    "isEntered": true,
                  });
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(
                    controller: controller,
                    receiverUsername: userChat.username,
                    receiverId: userChat.id,
                    receiverAvatar: userChat.url,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Future<bool> checkOnline() async {
    Future<QuerySnapshot<Map<String, dynamic>>> document = kullaniciRef.get();
    Sohbet userChat =
        Sohbet.fromDocument(document as DocumentSnapshot<Object?>);
    DocumentSnapshot ds = await sohbetRef
        .doc(userChat.id)
        .collection("sohbetEdilenler")
        .doc(anlikKullanici!.id)
        .get();
    return ds.get("isEntered");
  }

  Widget buildItem2(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      Sohbet userChat = Sohbet.fromDocument(document);

      if (id.hashCode <= userChat.id.hashCode) {
        groupChatId = '$id-${userChat.id}';
      } else {
        groupChatId = '${userChat.id}-$id';
      }
      DateTime dateTime = document.get('timestamp').toDate();
      return StreamBuilder<QuerySnapshot>(
        stream: messageRef
            .doc(groupChatId)
            .collection(groupChatId)
            .where("idFrom", isEqualTo: userChat.id)
            .where("isRead", isEqualTo: false)
            .snapshots(),
        builder: (context, snp) {
          if (!snp.hasData) {
            return circularProgress();
          } else {
            return Container(
              decoration: BoxDecoration(color: Colors.white),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          child: Container(
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(userChat.url),
                              ),
                            ),
                          ),
                        ),
                        snp.data!.docs.length == 0
                            ? new Container(
                                height: 30,
                                width: 30,
                              )
                            : Positioned(
                                top: 28,
                                left: 0,
                                child: Container(
                                  height: 19,
                                  width: 19,
                                  child: Center(
                                    child: Text(
                                      snp.data!.docs.length.toString(),
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle),
                                ),
                              ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                userChat.profileName,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              StreamBuilder<DocumentSnapshot>(
                                  stream:
                                      kullaniciRef.doc(userChat.id).snapshots(),
                                  builder: (context, snp1) {
                                    if (!snp1.hasData) {
                                      return circularProgress();
                                    } else {
                                      return snp1.data!.get("isEnteredApp") ==
                                              true
                                          ? Icon(
                                              Icons.radio_button_on,
                                              color: Colors.green,
                                              size: 15,
                                            )
                                          : Icon(
                                              Icons.radio_button_on,
                                              color: Colors.red,
                                              size: 15,
                                            );
                                    }
                                  })
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          document.get("idFrom") != userChat.id
                              ? Text(
                                  "sen : ${userChat.lastContent.length > 100 ? "gönderi" : userChat.lastContent}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.0,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600),
                                )
                              : Text(
                                  "${userChat.username} : ${userChat.lastContent.length > 100 ? "gönderi" : userChat.lastContent}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.0,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600),
                                ),
                        ],
                      ),
                    ),
                    Text(
                      "${DateFormat('dd MMM kk:mm').format(dateTime)}",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                onPressed: () async {
                  DocumentSnapshot ds =
                      await kullaniciRef.doc(anlikKullanici!.id).get();
                  Kullanici k1 = Kullanici.fromDocument(ds);
                  DocumentSnapshot ds1 =
                      await kullaniciRef.doc(k1.chattingWith).get();
                  Kullanici k2 = Kullanici.fromDocument(ds1);
                  sohbetRef
                      .doc(k2.id)
                      .collection("sohbetEdilenler")
                      .doc(anlikKullanici!.id)
                      .update({
                    "isEntered": true,
                  });
                  QuerySnapshot snapshot1 = await messageRef
                      .doc(groupChatId)
                      .collection(groupChatId)
                      .where("idFrom", isEqualTo: userChat.id)
                      .get();
                  List<Mesajlar> kullaniciress = snapshot1.docs
                      .map((doc) => Mesajlar.fromDocument(doc))
                      .toList();
                  for (var doc in kullaniciress) {
                    if (doc.idFrom == userChat.id) {
                      var documentReference = FirebaseFirestore.instance
                          .collection('messages')
                          .doc(groupChatId)
                          .collection(groupChatId)
                          .doc(doc.messageID);

                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
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
                        receiverUsername: userChat.username,
                        receiverId: userChat.id,
                        receiverAvatar: userChat.url,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
            );
          }
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

@immutable
class KullaniciSonucMessage extends StatelessWidget {
  final Kullanici? herbirKullanici;

  ScrollController controller = ScrollController();
  KullaniciSonucMessage(this.herbirKullanici);
  String id = anlikKullanici!.id;
  String groupChatId = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                sendUserToChatPage(context, kullaniciProfil: herbirKullanici),
            child: ListTile(
              leading: Container(
                height: 50,
                width: 50,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 10,
                            color: Colors.grey)
                      ],
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(herbirKullanici!.url)),
                    ),
                  ),
                ),
              ),
              title: Text(
                herbirKullanici!.profileName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                herbirKullanici!.username,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  sendUserToChatPage(
    context, {
    required Kullanici? kullaniciProfil,
  }) async {
    if (id.hashCode <= kullaniciProfil!.id.hashCode) {
      groupChatId = '$id-${kullaniciProfil.id}';
    } else {
      groupChatId = '${kullaniciProfil.id}-$id';
    }
    await kullaniciRef
        .doc(anlikKullanici!.id)
        .update({"chattingWith": kullaniciProfil.id});
    DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
    Kullanici k1 = Kullanici.fromDocument(ds);
    DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
    Kullanici k2 = Kullanici.fromDocument(ds1);
    sohbetRef
        .doc(k2.id)
        .collection("sohbetEdilenler")
        .doc(anlikKullanici!.id)
        .update({
      "isEntered": true,
    });

    QuerySnapshot snapshot1 = await messageRef
        .doc(groupChatId)
        .collection(groupChatId)
        .where("idFrom", isEqualTo: kullaniciProfil.id)
        .get();
    List<Mesajlar> kullaniciress =
        snapshot1.docs.map((doc) => Mesajlar.fromDocument(doc)).toList();
    for (var doc in kullaniciress) {
      if (doc.idFrom == kullaniciProfil.id) {
        var documentReference = FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .doc(doc.messageID);

        FirebaseFirestore.instance.runTransaction((transaction) async {
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
                  receiverUsername: kullaniciProfil.username,
                  receiverId: kullaniciProfil.id,
                  receiverAvatar: kullaniciProfil.url,
                )));
  }
}
