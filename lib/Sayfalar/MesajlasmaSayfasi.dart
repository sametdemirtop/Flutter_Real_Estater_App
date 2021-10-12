import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';
import 'package:flutter_son_emlak/model/Mesajlar.dart';
import 'package:flutter_son_emlak/model/Sohbet.dart';
import 'package:flutter_son_emlak/widgets/progress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

import 'AnaSayfa.dart';
import 'FullImageWidget.dart';
import 'VideoFlutterPlayer.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverUsername;
  final String receiverAvatar;
  final ScrollController controller;

  Chat(
      {required this.receiverId,
      required this.receiverAvatar,
      required this.receiverUsername,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: ChatScreen(
        controller: controller,
        receiverId: receiverId,
        receiverUsername: receiverUsername,
        receiverAvatar: receiverAvatar,
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: StreamBuilder<DocumentSnapshot>(
        stream: sohbetRef
            .doc(anlikKullanici!.id)
            .collection("sohbetEdilenler")
            .doc(receiverId)
            .snapshots(),
        builder: (context, snp) {
          if (!snp.hasData) {
            return circularProgress();
          } else {
            return AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
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
                    "isEntered": false,
                  });

                  Navigator.pop(context);
                },
              ),
              title: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(receiverAvatar),
                ),
                title: Text(
                  receiverUsername,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: StreamBuilder<DocumentSnapshot>(
                    stream: kullaniciRef.doc(receiverId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return circularProgress();
                      } else {
                        return Row(
                          children: [
                            snp.data!.get("isEntered") == true
                                ? Text(
                                    "Mesajını görebilir",
                                    style: TextStyle(fontSize: 13),
                                  )
                                : snapshot.data!.get("isWriting") == true
                                    ? Text(
                                        "Yazıyor..",
                                        style: TextStyle(fontSize: 13),
                                      )
                                    : snapshot.data!.get("isEnteredApp") == true
                                        ? Text(
                                            "Online",
                                            style: TextStyle(fontSize: 13),
                                          )
                                        : snapshot.data!.get("isEnteredApp") ==
                                                    true &&
                                                snp.data!.get("isEntered") ==
                                                    true
                                            ? Text(
                                                "Mesajını görebilir",
                                                style: TextStyle(fontSize: 13),
                                              )
                                            : Text(
                                                "Çevrimdışı",
                                                style: TextStyle(fontSize: 13),
                                              ),
                            SizedBox(
                              width: 5,
                            ),
                            snp.data!.get("isEntered") == true
                                ? Container(
                                    height: 13,
                                    width: 26,
                                    color: Colors.red,
                                    child: Center(
                                      child: Text("LIVE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                : Container(),
                          ],
                        );
                      }
                    }),
                trailing: StreamBuilder<DocumentSnapshot>(
                    stream: kullaniciRef.doc(receiverId).snapshots(),
                    builder: (context, snp1) {
                      if (!snp1.hasData) {
                        return circularProgress();
                      } else {
                        return snp1.data!.get("isEnteredApp") == true
                            ? Icon(
                                Icons.radio_button_on,
                                color: Colors.green,
                                size: 17,
                              )
                            : Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: 17,
                              );
                      }
                    }),
              ),
              centerTitle: true,
            );
          }
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverUsername;
  final ScrollController controller;

  ChatScreen(
      {required this.receiverId,
      required this.receiverAvatar,
      required this.receiverUsername,
      required this.controller});

  @override
  State createState() => ChatScreenState(
        receiverId: receiverId,
        receiverAvatar: receiverAvatar,
        receiverUsername: receiverUsername,
        controller: controller,
      );
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatScreenState({
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverUsername,
    required this.controller,
  });

  String receiverId;

  String receiverAvatar;
  String receiverUsername;
  String? id = anlikKullanici!.id;

  String? messageID;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  File? videoFile;
  bool isLoading = false;
  bool isDissmis = false;

  String imageUrl = "";
  String videoUrl = "";
  String voiceUrl = "";
  String lastTime = "";
  List<Reference>? references;
  DateTime? before;
  DateTime? after;
  bool isFabVisible = true;

  final TextEditingController textEditingController = TextEditingController();

  ScrollController? controller = ScrollController();
  ScrollController? sccontroller = ScrollController();
  var formKey = GlobalKey<FormState>();
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  bool? _isUploading;
  bool? _isRecorded;
  bool? _isRecording;
  int timeProgress = 0;
  int audioDuration = 0;
  int dur = 0;
  bool? isPlaying;
  int? selectedIndex;
  String? _filePath;
  FlutterAudioRecorder2? _audioRecorder;
  AudioPlayer? audioPlayer;
  bool? isVisible;

  /// Optional
  slider(int index) {
    return Container(
      width: 300.0,
      child: Slider.adaptive(
          autofocus: true,
          activeColor: Colors.white,
          value: timeProgress.toDouble(),
          max: audioDuration.toDouble(),
          onChanged: (value) {
            if (selectedIndex == index) {
              seekToSec(value.toInt());
            }
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    //listScrollController.addListener(_scrollListener);
    WidgetsBinding.instance!.addObserver(this);
    readLocal();
    isVisible = false;
    _isUploading = false;
    _isRecorded = false;
    _isRecording = false;
    selectedIndex = -1;
    audioPlayer = AudioPlayer(
      mode: PlayerMode.MEDIA_PLAYER,
    );
    audioPlayer!.onPlayerCompletion.listen((duration) {
      setState(() {
        selectedIndex = -1;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer!.release();
    audioPlayer!.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('state = $state');
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
      DocumentSnapshot rf = await sohbetRef
          .doc(anlikKullanici!.id)
          .collection("sohbetEdilenler")
          .doc(k2.id)
          .get();
      Sohbet userChat = Sohbet.fromDocument(rf);
      QuerySnapshot snapshot1 = await messageRef
          .doc(groupChatId)
          .collection(groupChatId)
          .where("idFrom", isEqualTo: userChat.id)
          .get();
      List<Mesajlar> kullaniciress =
          snapshot1.docs.map((doc) => Mesajlar.fromDocument(doc)).toList();
      for (var doc in kullaniciress) {
        if (doc.idFrom == userChat.id) {
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
    } else {
      DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
      Kullanici k1 = Kullanici.fromDocument(ds);
      DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
      Kullanici k2 = Kullanici.fromDocument(ds1);
      sohbetRef
          .doc(k2.id)
          .collection("sohbetEdilenler")
          .doc(anlikKullanici!.id)
          .update({
        "isEntered": false,
      });
    }
  }

  playMusic(String urlfirebase, int index) async {
    setState(() {
      selectedIndex = index;
      isPlaying = true;
    });
    await audioPlayer!.play(urlfirebase, isLocal: false);

    audioPlayer!.onDurationChanged.listen((Duration duration) async {
      setState(() {
        audioDuration = duration.inSeconds;
      });
    });
    audioPlayer!.onAudioPositionChanged.listen((Duration position) async {
      setState(() {
        timeProgress = position.inSeconds;
      });
    });
  }

  /// Compulsory
  pauseMusic(int index) async {
    setState(() {
      selectedIndex = index;
      isPlaying = false;
    });
    await audioPlayer!.pause();
  }

  /// Optional
  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    audioPlayer!
        .seek(newPos); // Jumps to the given position within the audio file
  }

  /// Optional
  String getTimeString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString'; // Returns a string with the format mm:ss
  }

  readLocal() async {
    if (id.hashCode <= receiverId.hashCode) {
      groupChatId = '$id-$receiverId';
    } else {
      groupChatId = '$receiverId-$id';
    }

    kullaniciRef.doc(id).update({'chattingWith': receiverId});
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future getVideo() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      videoFile = File(pickedFile.path);
      if (videoFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadVideoFile();
      }
    }
  }

  Future<void> onSendMessage(
    String content,
    int type,
    String s,
  ) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
      Kullanici k1 = Kullanici.fromDocument(ds);
      DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
      Kullanici k2 = Kullanici.fromDocument(ds1);

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(time);

      sohbetRef
          .doc(id)
          .collection("sohbetEdilenler")
          .doc(k2.id)
          .get()
          .then((value1) async {
        sohbetRef
            .doc(k2.id)
            .collection("sohbetEdilenler")
            .doc(id)
            .get()
            .then((value2) {
          if (value1.exists == true && value2.exists == true) {
            if (value1.get("isEntered") == false &&
                value2.get("isEntered") == true) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': false,
                    'length': s,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
            } else if (value1.get("isEntered") == true &&
                value2.get("isEntered") == false) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': false,
                    'length': s,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
            } else if (value1.get("isEntered") == true &&
                value2.get("isEntered") == true) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.set(
                  documentReference,
                  {
                    'messageID': time,
                    'idFrom': id,
                    'idTo': receiverId,
                    'timestamp': DateTime.now(),
                    'content': content,
                    'type': type,
                    'isRead': true,
                    'length': s,
                  },
                );
              });
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": true,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
            } else if (value1.get("isEntered") == false &&
                value2.get("isEntered") == false) {
              kullaniciRef.doc(id).update({'chattingWith': k2.id});
              kullaniciRef.doc(k2.id).update({'chattingWith': id});
              sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                "id": k2.id,
                "url": k2.url,
                "username": k2.username,
                "profileName": k2.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
              sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                "id": id,
                "url": anlikKullanici!.url,
                "username": anlikKullanici!.username,
                "profileName": anlikKullanici!.profileName,
                "lastContent": content,
                "timestamp": DateTime.now(),
                "isEntered": false,
                "messageID": time,
                "idFrom": id,
                "isWriting": false
              });
            }
          } else {
            FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.set(
                documentReference,
                {
                  'messageID': time,
                  'idFrom': id,
                  'idTo': receiverId,
                  'timestamp': DateTime.now(),
                  'content': content,
                  'type': type,
                  'isRead': false,
                  'length': s,
                },
              );
            }).then((value) {
              if (k2.id == receiverId) {
                sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                  "id": k2.id,
                  "url": k2.url,
                  "username": k2.username,
                  "profileName": k2.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": false,
                  "messageID": time,
                  "idFrom": id,
                  "isWriting": false
                });
                sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                  "id": id,
                  "url": anlikKullanici!.url,
                  "username": anlikKullanici!.username,
                  "profileName": anlikKullanici!.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": true,
                  "messageID": time,
                  "idFrom": id,
                  "isWriting": false
                });
              } else {
                sohbetRef.doc(id).collection("sohbetEdilenler").doc(k2.id).set({
                  "id": k2.id,
                  "url": k2.url,
                  "username": k2.username,
                  "profileName": k2.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": true,
                  "messageID": time,
                  "idFrom": id,
                  "isWriting": false
                });
                sohbetRef.doc(k2.id).collection("sohbetEdilenler").doc(id).set({
                  "id": id,
                  "url": anlikKullanici!.url,
                  "username": anlikKullanici!.username,
                  "profileName": anlikKullanici!.profileName,
                  "lastContent": content,
                  "timestamp": DateTime.now(),
                  "isEntered": false,
                  "messageID": time,
                  "idFrom": id,
                  "isWriting": false
                });
              }
            });
          }
        });
      });
      controller!.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.bounceIn);
      if (isFabVisible == false) {
        setState(() {
          isFabVisible = true;
        });
      }
    } else {
      Fluttertoast.showToast(
          timeInSecForIosWeb: 0,
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      DateTime dateTime = document.get('timestamp').toDate();
      if (document.get('idFrom') == id) {
        return Column(
          children: [
            Row(
              children: <Widget>[
                document.get('type') == 0
                    // Text
                    ? Container(
                        child: Text(
                          document.get('content'),
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.indigo[400],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
                    : document.get('type') == 1
                        // Image
                        ? Container(
                            child: OutlinedButton(
                              child: Material(
                                child: Image.network(
                                  document.get("content"),
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                      url: document.get('content'),
                                    ),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(0))),
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.indigoAccent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          )
                        // Sticker
                        : document.get('type') == 2
                            ? Container(
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                iconSize: 50,
                                                onPressed: () {
                                                  selectedIndex == index &&
                                                          isPlaying == true
                                                      ? pauseMusic(index)
                                                      : playMusic(
                                                          document
                                                              .get("content"),
                                                          index);
                                                },
                                                icon: Icon(
                                                  selectedIndex == index &&
                                                          isPlaying == true
                                                      ? Icons.pause_rounded
                                                      : Icons
                                                          .play_arrow_rounded,
                                                  color: Colors.white,
                                                )),
                                            selectedIndex == index
                                                ? Container(
                                                    width: 150,
                                                    child: slider(index))
                                                : Container(
                                                    width: 150,
                                                    child: Slider.adaptive(
                                                        activeColor:
                                                            Colors.white,
                                                        value: 0.0,
                                                        max: audioDuration
                                                            .toDouble(),
                                                        onChanged: (value) {}),
                                                  ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 100),
                                              child: Text(
                                                selectedIndex == index
                                                    ? getTimeString(
                                                        timeProgress)
                                                    : "00.00",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              document.get("length"),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                width: 250.0,
                                decoration: BoxDecoration(
                                    color: Colors.indigo[400],
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              )
                            : document.get('type') == 3
                                ? Container(
                                    height: 200,
                                    width: 200,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoFlutterPlayer(
                                                      url: document
                                                          .get("content"),
                                                      floatingActionButtonLocation:
                                                          FloatingActionButtonLocation
                                                              .miniStartFloat,
                                                    )));
                                      },
                                      child: VideoFlutterPlayer(
                                          url: document.get("content"),
                                          floatingActionButtonLocation:
                                              FloatingActionButtonLocation
                                                  .miniStartFloat),
                                    ),
                                    margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 0.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[400],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  )
                                : Container(
                                    child: Image.asset(
                                      'images/${document.get('content')}.gif',
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: isLastMessageRight(index)
                                            ? 20.0
                                            : 10.0,
                                        right: 10.0),
                                  ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            Row(
              children: [
                isLastMessageRight(index)
                    ? Container(
                        child: Text(
                          DateFormat('dd MMM kk:mm').format(dateTime),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                        margin: EdgeInsets.only(left: 240, bottom: 10.0),
                      )
                    : Container(
                        child: Text(
                          DateFormat('dd MMM kk:mm').format(dateTime),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                        margin: EdgeInsets.only(left: 240, bottom: 5.0),
                      ),
                SizedBox(
                  width: 10,
                ),
                document.get('isRead') == true
                    ? Container(
                        child: Icon(
                          Icons.done_all,
                          color: Colors.greenAccent,
                        ),
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      )
                    : Container(
                        child: Icon(
                          Icons.done_all,
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      ),
              ],
            ),
          ],
        );
      } else {
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            receiverAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(
                          width: 35,
                          height: 35,
                        ),
                  document.get('type') == 0
                      ? buildContainer(document)
                      : document.get('type') == 1
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    document.get('content'),
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null &&
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullPhoto(
                                              url: document.get('content'))));
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(0))),
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            )
                          : document.get('type') == 2
                              ? Container(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                iconSize: 50,
                                                onPressed: () {
                                                  selectedIndex == index &&
                                                          isPlaying == true
                                                      ? pauseMusic(index)
                                                      : playMusic(
                                                          document
                                                              .get("content"),
                                                          index);
                                                },
                                                icon: Icon(selectedIndex ==
                                                            index &&
                                                        isPlaying == true
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded),
                                                color: Colors.white,
                                              ),
                                              selectedIndex == index
                                                  ? Container(
                                                      width: 150,
                                                      child: slider(index))
                                                  : Container(
                                                      width: 150,
                                                      child: Slider.adaptive(
                                                          activeColor:
                                                              Colors.white,
                                                          value: 0.0,
                                                          max: audioDuration
                                                              .toDouble(),
                                                          onChanged:
                                                              (value) {}),
                                                    ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 100),
                                                child: Text(
                                                  selectedIndex == index
                                                      ? getTimeString(
                                                          timeProgress)
                                                      : "00.00",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Text(
                                                document.get("length"),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                      15.0, 10.0, 15.0, 10.0),
                                  margin: EdgeInsets.only(left: 10.0),
                                )
                              : document.get('type') == 3
                                  ? Container(
                                      height: 200,
                                      width: 200,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      VideoFlutterPlayer(
                                                        url: document
                                                            .get("content"),
                                                        floatingActionButtonLocation:
                                                            FloatingActionButtonLocation
                                                                .miniEndFloat,
                                                      )));
                                        },
                                        child: VideoFlutterPlayer(
                                          url: document.get("content"),
                                          floatingActionButtonLocation:
                                              FloatingActionButtonLocation
                                                  .miniEndFloat,
                                        ),
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 0,
                                          bottom: isLastMessageRight(index)
                                              ? 20.0
                                              : 10.0,
                                          right: 0.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ))
                                  : Container(
                                      child: Image.asset(
                                        'images/${document.get('content')}.gif',
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: isLastMessageRight(index)
                                              ? 20.0
                                              : 10.0,
                                          right: 10.0),
                                    ),
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(dateTime),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 11.0, bottom: 5.0),
                    )
                  : Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(dateTime),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 11.0, bottom: 5.0),
                    ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Container buildContainer(DocumentSnapshot<Object?> document) {
    return Container(
      child: Text(
        document.get('content'),
        style: TextStyle(color: Colors.white),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      width: 200.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(left: 10.0),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() async {
    kullaniciRef.doc(id).update({'chattingWith': ""});
    /*DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
    Kullanici k1 = Kullanici.fromDocument(ds);
    DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
    Kullanici k2 = Kullanici.fromDocument(ds1);
    sohbetRef
        .doc(k2.id)
        .collection("sohbetEdilenler")
        .doc(anlikKullanici!.id)
        .update({
      "isEntered": false,
    });*/
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {},
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              buildListMessage(),
              Container(
                padding: EdgeInsets.only(left: 15),
                alignment: Alignment.bottomLeft,
                child: Visibility(
                  visible: isVisible!,
                  child: Container(
                    width: 300,
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.indigo[400],
                      elevation: 5,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  child: IconButton(
                                      iconSize: 27,
                                      icon: Icon(Icons.camera),
                                      onPressed: getImage,
                                      color: Colors.white),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Fotoğraf",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  child: IconButton(
                                    iconSize: 27,
                                    icon: Icon(Icons.video_collection),
                                    onPressed: getVideo,
                                    color: Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Video",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  child: IconButton(
                                    iconSize: 27,
                                    icon: Icon(Icons.multitrack_audio_outlined),
                                    onPressed: getVideo,
                                    color: Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Ses",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
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
            ],
          ),
          floatingActionButton: isFabVisible != true
              ? FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.arrow_downward, color: Colors.white),
                  onPressed: scrollDown,
                )
              : Container(),
          bottomNavigationBar: buildInput(),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? const CircularProgressIndicator(
              backgroundColor: Colors.white,
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              top: 15,
              bottom: 15,
              right: 0,
            ),
            child: _isRecorded != true
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.deepPurple[400]),
                    height: 50.0,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              if (isVisible == true) {
                                setState(() {
                                  isVisible = false;
                                });
                              } else {
                                setState(() {
                                  isVisible = true;
                                });
                              }
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          // Edit text
                          Flexible(
                            child: Container(
                              child: TextFormField(
                                key: formKey,
                                onChanged: (String value) async {
                                  if (value.isNotEmpty) {
                                    kullaniciRef
                                        .doc(anlikKullanici!.id)
                                        .update({"isWriting": true});
                                  } else {
                                    kullaniciRef
                                        .doc(anlikKullanici!.id)
                                        .update({"isWriting": false});
                                  }
                                },
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                                controller: textEditingController,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.deepPurple[400]),
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _onRecordAgainButtonPressed();
                                _isRecorded = false;
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.multitrack_audio,
                              color: Colors.white,
                              size: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                lastTime,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _onFileUploadButtonPressed();
                                _onRecordAgainButtonPressed();
                                _isRecorded = false;
                                Fluttertoast.showToast(msg: 'Yükleniyor..');
                              });
                            },
                            icon: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30,
                            )),
                      ],
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 15, bottom: 15, top: 15, left: 5),
          child: Container(
            child: StreamBuilder<DocumentSnapshot>(
              stream: kullaniciRef.doc(anlikKullanici!.id).snapshots(),
              builder: (context, snp) {
                if (!snp.hasData) {
                  return circularProgress();
                } else {
                  return Container(
                    child: snp.data!.get("isWriting") == true
                        ? GestureDetector(
                            onTap: () {
                              onSendMessage(
                                      textEditingController.text, 0, "00.00")
                                  .then((value) {
                                kullaniciRef
                                    .doc(anlikKullanici!.id)
                                    .update({"isWriting": false});
                              });
                            },
                            child: Container(
                              height: 55,
                              width: 53,
                              child: Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple[400],
                                  shape: BoxShape.circle),
                            ),
                          )
                        : GestureDetector(
                            onLongPress: () async {
                              await pressStart();
                            },
                            onLongPressUp: () async {
                              await pressUp();
                              Future.delayed(Duration(milliseconds: 100), () {
                                Duration durations = after!.difference(before!);
                                String minuteString =
                                    '${(durations.inSeconds / 60).floor() < 10 ? 0 : ''}${(durations.inSeconds / 60).floor()}';
                                String secondString =
                                    '${durations.inSeconds % 60 < 10 ? 0 : ''}${durations.inSeconds % 60}';
                                setState(() {
                                  lastTime = '$minuteString:$secondString';
                                });
                              });
                            },
                            child: _isRecording != true
                                ? Container(
                                    height: 55,
                                    width: 53,
                                    child: Center(
                                      child: Icon(
                                        Icons.mic,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple[400],
                                        shape: BoxShape.circle),
                                  )
                                : RippleAnimation(
                                    repeat: true,
                                    color: Colors.deepPurple[200]!,
                                    minRadius: 100,
                                    ripplesCount: 6,
                                    child: Container(
                                      height: 80,
                                      width: 78,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurple[400],
                                              shape: BoxShape.circle),
                                          child: Icon(
                                            Icons.pause_circle_filled,
                                            size: 54,
                                            color: Colors.indigoAccent,
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple[400],
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                          ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onRecordAgainButtonPressed() {
    //anlasildi
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _startRecording() async {
    //anlasildi
    final bool? hasRecordingPermission =
        await FlutterAudioRecorder2.hasPermissions;
    if (hasRecordingPermission!) {
      Directory directory = await getApplicationDocumentsDirectory();
      String filepath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      _audioRecorder =
          FlutterAudioRecorder2(filepath, audioFormat: AudioFormat.AAC);
      await _audioRecorder!.initialized;
      _audioRecorder!.start();
      _filePath = filepath;
      setState(() {});
    } else {
      SnackBar snackBar = SnackBar(
        content: Text('Please enable recording permission'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> pressStart() async {
    //anlasildi
    _isRecorded = false;
    _isRecording = true;
    before = DateTime.now();
    await _startRecording();
  }

  Future<void> pressUp() async {
    //anlasildi
    _audioRecorder!.stop().then((value) => after = DateTime.now());
    setState(() {
      _isRecording = false;
      _isRecorded = true;
      //Fluttertoast.showToast(msg: 'Yükleniyor..');
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Fluttertoast.showToast(msg: 'Yükleniyor..');
    Reference reference =
        FirebaseStorage.instance.ref().child("Chat Images").child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1, "00.00");
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future uploadVideoFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Fluttertoast.showToast(msg: 'Yükleniyor..');
    Reference reference =
        FirebaseStorage.instance.ref().child("Chat Videos").child(fileName);
    UploadTask uploadTask = reference.putFile(videoFile!);
    try {
      TaskSnapshot snapshot = await uploadTask;
      videoUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(videoUrl, 3, "00.00");
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<void> _onFileUploadButtonPressed() async {
    setState(() {
      _isUploading = true;
    });
    UploadTask reference = firebaseStorage
        .ref('upload-voice-firebase')
        .child(_filePath!
            .substring(_filePath!.lastIndexOf('/'), _filePath!.length))
        .putFile(File(_filePath!));
    try {
      TaskSnapshot snapshot = await reference;
      voiceUrl = await snapshot.ref.getDownloadURL();
      Duration durations = after!.difference(before!);
      String minuteString =
          '${(durations.inSeconds / 60).floor() < 10 ? 0 : ''}${(durations.inSeconds / 60).floor()}';
      String secondString =
          '${durations.inSeconds % 60 < 10 ? 0 : ''}${durations.inSeconds % 60}';
      String lasttime = '$minuteString:$secondString';
      setState(() {
        onSendMessage(voiceUrl, 2, lasttime);
      });
    } catch (error) {
      print('Error occured while uplaoding to Firebase ${error.toString()}');
      SnackBar snackBar = SnackBar(
        content: Text('Error occured while uplaoding'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  buildListMessage() {
    return NotificationListener<UserScrollNotification>(
      child: ListView(
        scrollDirection: Axis.vertical,
        controller: controller,
        reverse: true,
        children: [
          /*Container(
          height: 35,
          child: StreamBuilder<DocumentSnapshot>(
              stream: kullaniciRef.doc(receiverId).snapshots(),
              builder: (context, snp) {
                if (!snp.hasData) {
                  return circularProgress();
                } else {
                  if (snp.data!.get("isWriting") == true) {
                    return Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Material(
                            child: Image.network(
                              receiverAvatar,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    value: loadingProgress.expectedTotalBytes !=
                                                null &&
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Icon(
                                  Icons.account_circle,
                                  size: 35,
                                  color: Colors.grey,
                                );
                              },
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          child: Center(
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  WavyAnimatedText('...'),
                                  WavyAnimatedText('...'),
                                ],
                                isRepeatingAnimation: true,
                                onTap: () {
                                  print("Tap Event");
                                },
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black,
                              shape: BoxShape.rectangle),
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      child: Text(
                        "",
                        style: TextStyle(color: Colors.black),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0)),
                      margin: EdgeInsets.only(left: 10.0),
                    );
                  }
                }
              }),
        ),*/
          Container(
            child: groupChatId.isNotEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .doc(groupChatId)
                        .collection(groupChatId)
                        .orderBy('timestamp', descending: true)
                        .limit(_limit)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        listMessage.addAll(snapshot.data!.docs);
                        return ListView.builder(
                          dragStartBehavior: DragStartBehavior.down,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding:
                              EdgeInsets.only(left: 10.0, right: 10, top: 50),
                          itemBuilder: (context, index) =>
                              buildItem(index, snapshot.data?.docs[index]),
                          itemCount: snapshot.data?.docs.length,
                          reverse: true,
                          controller: sccontroller,
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
          ),
        ],
      ),
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.forward) {
          setState(() {
            isFabVisible = true;
          });
        } else if (notification.direction == ScrollDirection.reverse) {
          setState(() {
            isFabVisible = false;
          });
        }
        return true;
      },
    );
  }

  void scrollDown() {
    //final double end = controller!.position.maxScrollExtent;
    //controller!.animateTo(end, duration: Duration(seconds: 1), curve: Curves.easeIn);
    final double start = 0;
    controller!.animateTo(start,
        duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
    if (isFabVisible == false) {
      setState(() {
        isFabVisible = true;
      });
    }
  }

  Future<bool> onWillPop() async {
    DocumentSnapshot ds = await kullaniciRef.doc(anlikKullanici!.id).get();
    Kullanici k1 = Kullanici.fromDocument(ds);
    DocumentSnapshot ds1 = await kullaniciRef.doc(k1.chattingWith).get();
    Kullanici k2 = Kullanici.fromDocument(ds1);
    sohbetRef
        .doc(k2.id)
        .collection("sohbetEdilenler")
        .doc(anlikKullanici!.id)
        .update({
      "isEntered": false,
    });

    Navigator.pop(context);
    return true;
  }
}
