import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_son_emlak/Sayfalar/profilSayfasi.dart';
import 'package:flutter_son_emlak/model/Kullanici.dart';

import 'AnaSayfa.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Kullanici>? userList;
  String query = "";
  TextEditingController searchController = TextEditingController();
  ScrollController? controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    QuerySnapshot qs = await kullaniciRef.get();
    List<Kullanici> kullaniciress =
        qs.docs.map((doc) => Kullanici.fromDocument(doc)).toList();
    setState(() {
      this.userList = kullaniciress;
    });
  }

  PreferredSize aramaSayfasiBasligi(BuildContext context) {
    return PreferredSize(
        child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Container(
              padding: EdgeInsets.only(top: 5),
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35.0),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 10),
                              blurRadius: 10,
                              color: Colors.grey)
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.person_search,
                                color: Colors.black45,
                              ),
                              onPressed: () {}),
                          Expanded(
                            child: TextFormField(
                              controller: searchController,
                              decoration: InputDecoration(
                                  hintText: "Ara",
                                  hintStyle: TextStyle(color: Colors.black26),
                                  border: InputBorder.none),
                              onChanged: (val) {
                                setState(() {
                                  query = val;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.black45),
                            onPressed: () {
                              WidgetsBinding.instance!.addPostFrameCallback(
                                  (_) => searchController.clear());
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
            )),
        preferredSize: Size.fromHeight(80));
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
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        Kullanici searchedUser = Kullanici(
            id: suggestionList[index].id,
            url: suggestionList[index].url,
            profileName: suggestionList[index].profileName,
            username: suggestionList[index].username,
            chattingWith: '',
            pushToken: '',
            biography: '',
            email: '',
            isWriting: false,
            isEnteredApp: false);

        return KullaniciSonuc(searchedUser);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: aramaSayfasiBasligi(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}

class KullaniciSonuc extends StatelessWidget {
  final Kullanici? herbirKullanici;
  KullaniciSonuc(this.herbirKullanici);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              kullaniciProfiliGoster(
                context,
                kullaniciProfilID: herbirKullanici!.id,
                kullaniciUsername: herbirKullanici!.username,
                kullaniciUrl: herbirKullanici!.url,
              );
            },
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

  kullaniciProfiliGoster(
    context, {
    required String kullaniciProfilID,
    required String kullaniciUsername,
    required String kullaniciUrl,
  }) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => profilSayfasi(
                  kullaniciUsername: kullaniciUsername,
                  kullaniciUrl: kullaniciUrl,
                  kullaniciprofilID: kullaniciProfilID,
                )));
  }
}
