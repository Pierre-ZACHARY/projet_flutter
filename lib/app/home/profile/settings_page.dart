import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget{
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingPageState();

  Future<void> onActiveChange(bool value, Userinfo uinfo) async {
    await uinfo.updateActiveValue(value);
  }
}

class _SettingPageState extends State<SettingPage>{

  bool _activeValue = false;
  bool _notifValue = false;
  SharedPreferences ?_sharedPreferences;

  getSharedPreferences () async
  {
    _sharedPreferences = await SharedPreferences.getInstance();
    final bool? notif = _sharedPreferences?.getBool("notif");
    if (notif!=null){
      _notifValue = notif;
      return;
    }
    _notifValue = false;
  }

  setNotifValue(bool value) async{
    await _sharedPreferences?.setBool("notif", _notifValue);
  }

  @override
  Widget build(BuildContext context) {
    //String networkImgUrl = await FirebaseStorage.instance.ref(CloudStorage.profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png").getDownloadURL();
    getSharedPreferences();
    return StreamBuilder<DocumentSnapshot<Userinfo>>(
        stream: Userinfo.getUserDocumentStream(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if(snapshot.data == null){
            return const Text("Loading...");
          }
          Userinfo uinfo = snapshot.data!.data()!;
          _activeValue = uinfo.active;
          return Scaffold(
            backgroundColor: ColorConstants.background,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(40,20,40,40),
              child: Column(
                children:  [
                  Column(
                      children: const [
                        SizedBox(
                          height: 30
                        ),
                        Text(
                            "Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "OpenSans",
                              fontSize: 30.0
                            )
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                      ]
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          CupertinoSwitch(
                            value: _activeValue,
                            onChanged: (value) {
                              setState(() {
                                _activeValue = value;
                                widget.onActiveChange(_activeValue, uinfo);
                              });
                            },
                          ),
                          const Expanded(
                              child: Text(
                                  "Active (visible in users search)",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "OpenSans"
                                  )
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0,),
                      Row(
                        children: <Widget>[
                          CupertinoSwitch(
                            value: _notifValue,
                            onChanged: (value) {
                              setState(() {
                                _notifValue = value;
                                setNotifValue(_notifValue);
                              });
                            },
                          ),
                          const Expanded(
                              child: Text(
                                  "Push notifications (allow the sending of notifications)",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "OpenSans"
                                  )
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Expanded(
                    child: Text(""),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(ColorConstants.secondary),
                            ),
                            onPressed: () { Navigator.pop(context); },
                            child: const Text("Back", style: TextConstants.defaultSecondary)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );

  }

}