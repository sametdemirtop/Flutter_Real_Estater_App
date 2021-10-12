import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'GirisEkran.dart';
import 'HesapOlusturmaSayfasi2.dart';
import 'hesapOlusturmaSayfasi.dart';

Kullanici? anlikKullanici;

final kullaniciRef = FirebaseFirestore.instance.collection("Kullanicilar");
final bildirimRef = FirebaseFirestore.instance.collection("Bildirimler");
final yorumRef = FirebaseFirestore.instance.collection("Yorumlar");
final takipciRef = FirebaseFirestore.instance.collection("Takipçiler");
final takipEdilenRef = FirebaseFirestore.instance.collection("Takip Edilenler");
final gonderiRef = FirebaseFirestore.instance.collection("Gonderilenler");
final akisRef = FirebaseFirestore.instance.collection("Ana Akis");
final kaydetmeRef = FirebaseFirestore.instance.collection("Kaydedilenler");
final favoriRef = FirebaseFirestore.instance.collection("Favoriler");
final messageRef = FirebaseFirestore.instance.collection("messages");
final sohbetRef = FirebaseFirestore.instance.collection("sohbet");
final ilanPhotoRef = FirebaseFirestore.instance.collection("Photos");
final ilanRef = FirebaseFirestore.instance.collection("İlanlar");

final scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final DateTime timestamp = DateTime.now();

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '1234', // id
  'Test Title', // title
  'Test Description.', // description
  importance: Importance.high,
);
final GoogleSignIn? googlegiris = GoogleSignIn();

class AnaSayfa extends StatefulWidget {
  final bool girdimi;

  AnaSayfa({
    required this.girdimi,
  });
  final _AnaSayfaState child = _AnaSayfaState(girdimi: false);
  @override
  _AnaSayfaState createState() {
    _AnaSayfaState(
      girdimi: this.girdimi,
    );
    return child;
  }
}

class _AnaSayfaState extends State<AnaSayfa>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool girdimi = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final Future<FirebaseApp> _initFirebaseSdk = Firebase.initializeApp();
  bool isToogle = false;

  bool kullaniciOnline = false;

  //String _token = "";

  _AnaSayfaState({
    required this.girdimi,
  });

  /*String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }*/

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('state = $state');
      kullaniciRef.doc(anlikKullanici!.id).update({
        "isEnteredApp": true,
      });
    } else {
      kullaniciRef.doc(anlikKullanici!.id).update({
        "isEnteredApp": false,
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    /* const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _configureDidReceiveLocalNotificationSubject,
    );
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: _configureSelectNotificationSubject);
    messaging.subscribeToTopic("testcribe");*/
    /*messaging.getInitialMessage().then((RemoteMessage message) {
      if (message != null) {
        SnackBar snackBar = SnackBar(
          content: Text("Mesaj boş"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });*/
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
      showNotification(message);
    });
    /*FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      bool isMessage = true;
      showNotification(message);
      if (isMessage) {
        sayfaKontrol.jumpToPage(2);
        Navigator.push(context, MaterialPageRoute(builder: (context) => bildirimSayfasi()));
      } else {
        sayfaKontrol.jumpToPage(1);
        Navigator.push(context, MaterialPageRoute(builder: (context) => profilDuzenle()));
      }
    });*/
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();

    googlegiris!.onCurrentUserChanged.listen((googleHesap) {
      setState(() {
        kullaniciKontrol(googleHesap!);
      });
    }, onError: (gHata) {
      print("Hata Mesaj: " + gHata.toString());
    });

    googlegiris!.isSignedIn().then((isSignedIn) async {
      if (isSignedIn == true) {
        googlegiris!.signInSilently(suppressErrors: false).then((googleHesap2) {
          setState(() {
            kullaniciKontrol(googleHesap2!);
          });
        }).catchError((gHata) {
          print("Hata Mesaj 2: " + gHata.toString());
        });
      }
    });
    firebaseonAuth();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  firebaseonAuth() {
    return FutureBuilder(
        future: _initFirebaseSdk,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print("Hata firebaseonAuth 2: ");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // Assign listener after the SDK is initialized successfully
            FirebaseAuth.instance.authStateChanges().listen((User? user) {
              if (user == null) {
                setState(() {
                  girdimi = false;
                });
              } else {
                setState(() {
                  girdimi = true;
                });
              }
            });
          }

          return circularProgress();
        });
  }

  static void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            '1234', 'Yeni Mesaj', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message.data['title'],
        message.data['message'], platformChannelSpecifics,
        payload: 'item x');
  }

  /*Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        //body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }*/

  kullaniciGiris() {
    setState(() {
      googlegiris!.signIn();
    });
  }

  kullaniciKontrol(GoogleSignInAccount? girisHesap) async {
    if (girisHesap != null) {
      await kullaniciFireStoreKayit();
      setState(() {
        girdimi = true;
      });
    } else {
      setState(() {
        girdimi = false;
      });
    }
  }

  /*Scaffold anaEkrani() {

  }*/

  void toggleScreen() {
    setState(() {
      isToogle = !isToogle;
    });
  }

  Scaffold kayitEkrani() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 75,
            right: 25,
            left: 25,
            bottom: 40,
          ),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
            ], borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Container(
                            width: 220,
                            height: 90,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 10),
                                      blurRadius: 10,
                                      color: Colors.grey)
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(1),
                                      BlendMode.dstATop),
                                  image: AssetImage("assets/images/sscard.png"),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "maCarD",
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 34,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Share your card",
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          toggle(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding toggle() {
    if (isToogle) {
      return Register();
    } else {
      return Login();
    }
  }

  // ignore: non_constant_identifier_names
  Padding Login() {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
        ], borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Sign in to continue",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (val) => val!.isNotEmpty
                          ? null
                          : "Please enter a mail address",
                      decoration: InputDecoration(
                        hintText: "E-mail",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (val) =>
                          val!.length < 6 ? "Enter more than 6 char " : null,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          debugPrint("Email= " + _emailController.text);
                          debugPrint("pass= " + _passwordController.text);
                          signIn(_emailController.text,
                                  _passwordController.text)
                              .then((value) {
                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GirisEkran()));
                            });
                          });
                        }
                      },
                      height: 45,
                      minWidth: double.infinity,
                      color: Colors.deepOrange[200],
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account ?"),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            toggleScreen();
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.deepOrange[200]),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: Text(
                        "OR",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          kullaniciGiris();
                        });
                      },
                      child: Container(
                        width: 270.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/images/google_signin_button1.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Padding Register() {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(offset: Offset(0, 10), blurRadius: 10, color: Colors.grey)
        ], borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Create account to continue",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      validator: (val) => val!.length <= 4
                          ? "Enter 4 char or more than 4 char "
                          : null,
                      decoration: InputDecoration(
                        hintText: "Username",
                        prefixIcon: Icon(Icons.person_pin_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => val!.length <= 3
                          ? "Enter 3 char or more than 3 char "
                          : null,
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (val) => val!.isNotEmpty
                          ? null
                          : "Please enter a mail address",
                      decoration: InputDecoration(
                        hintText: "E-mail",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.deepOrange.shade200, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      validator: (val) =>
                          val!.length < 6 ? "Enter more than 6 char " : null,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          debugPrint("Email= " + _emailController.text);
                          debugPrint("pass= " + _passwordController.text);
                          createPerson(
                                  _emailController.text,
                                  _passwordController.text,
                                  _nameController.text,
                                  _usernameController.text)
                              .then((value) {
                            setState(() {
                              isToogle = false;
                            });
                          });
                        }
                      },
                      height: 45,
                      minWidth: double.infinity,
                      color: Colors.deepOrange[200],
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account ?"),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            toggleScreen();
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.deepOrange[200]),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  kullaniciFireStoreKayit() async {
    final GoogleSignInAccount? gAnlikKullanici = googlegiris!.currentUser;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await kullaniciRef.doc(gAnlikKullanici!.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => HesapOlusturmaSayfasi()));

      kullaniciRef.doc(gAnlikKullanici.id).set({
        "id": gAnlikKullanici.id,
        "profileName": gAnlikKullanici.displayName,
        "username": username,
        "url": gAnlikKullanici.photoUrl,
        "email": gAnlikKullanici.email,
        "biography": "",
        "timestamp": timestamp,
        "chattingWith": "",
        "isWriting": false,
        "pushToken": "",
      });

      documentSnapshot = await kullaniciRef.doc(anlikKullanici!.id).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot);
  }

  Future<User?> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await kullaniciRef.doc(user.user!.uid).get();
    if (!documentSnapshot.exists) {
      documentSnapshot = await kullaniciRef.doc(user.user!.uid).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot);
    return user.user;
  }

  signOut() async {
    return await _auth.signOut();
  }

  // ignore: non_constant_identifier_names
  Future<User?> createPerson(
      String email, String password, String name, String username) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await kullaniciRef.doc(user.user!.uid).get();
    if (!documentSnapshot.exists) {
      final urlIndirme = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HesapOlusturmaSayfasi2(
                    kullanici: anlikKullanici,
                  )));

      kullaniciRef.doc(user.user!.uid).set({
        "id": user.user!.uid,
        "profileName": name,
        "username": username,
        "url": urlIndirme,
        "email": user.user!.email,
        "biography": "",
        "timestamp": timestamp,
        "chattingWith": "",
        "isWriting": false,
        "pushToken": "",
      });
      documentSnapshot = await kullaniciRef.doc(user.user!.uid).get();
    }
    anlikKullanici = Kullanici.fromDocument(documentSnapshot);
    return user.user;
  }

  @override
  Widget build(BuildContext context) {
    if (girdimi == true) {
      return GirisEkran();
    } else {
      return kayitEkrani();
    }
  }

// ignore: missing_return
//Future _configureDidReceiveLocalNotificationSubject(int id, String title, String body, String payload) {}

// ignore: missing_return
/*Future _configureSelectNotificationSubject(String payload) {
    if (payload != null) {
      debugPrint('Notification Payload = ' + payload);
    }
  }
}*/

}
