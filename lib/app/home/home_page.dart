import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/app/home/chats/chat_page.dart';
import 'package:projet_flutter/app/home/profile/profile_page.dart';
import 'package:projet_flutter/utils/cloudStorageUtils.dart';
import 'package:projet_flutter/utils/constant.dart';
import 'package:projet_flutter/utils/notification_service.dart';

import '/modele/Bandnames.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage(BuildContext context, User user, {Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    ChatPage(),
    ProfilePage("dz")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    NotificationService.initialize();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.backgroundHighlight,
        title: Text(widget.title),
      ),
      backgroundColor: ColorConstants.background,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorConstants.background,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Discussion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: ColorConstants.backgroundHighlight,
        selectedItemColor: ColorConstants.primaryHighlight,
        onTap: _onItemTapped,
      ),
    );
  }
}