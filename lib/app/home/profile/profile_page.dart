import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/app/home/profile/settings_page.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
import 'package:projet_flutter/utils/authUtils.dart';
import 'package:projet_flutter/utils/cloudStorageUtils.dart';
import 'package:projet_flutter/utils/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget{
  final String profilePictureUrl;

  const ProfilePage(this.profilePictureUrl, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();

  Future<void> onProfilePictureTap(Userinfo uinfo) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      CloudStorage.uploadUserProfilePicture(File(image.path), uinfo);
    }
  }

  Future<void> onPseudoEditingComplete(TextEditingController pseudoController, Userinfo uinfo) async {
    if(uinfo.displayName != pseudoController.value.text){
      await uinfo.updateDisplayName(pseudoController.value.text);
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

}

class _ProfilePageState extends State<ProfilePage>{

  TextEditingController pseudoController = TextEditingController();
  bool _buttonPressed = false;
  bool _loopActive = false;
  final int _maxCounter = 40;
  double _dynamicPadding = 0;
  int _counter = 0;

  void _increaseCounterWhilePressed() async {

    if (_loopActive) return;// check if loop is active

    _loopActive = true;

    while (_buttonPressed) {
      if (_counter >= _maxCounter){
        await AuthUtils.Logout();
      }
      else{
        setState(() {
          _counter++;
          _dynamicPadding = 40;
        });
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
    if (_counter < _maxCounter){
      setState(() {
        _counter = 0;
        _dynamicPadding = 0;
      });
      _counter = 0;
      _loopActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //String networkImgUrl = await FirebaseStorage.instance.ref(CloudStorage.profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png").getDownloadURL();
    return StreamBuilder<DocumentSnapshot>(
        stream: Userinfo.getUserDocumentStream(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
        if(snapshot.data == null){
          return const Text("Loading...");
        }
        Userinfo uinfo = snapshot.data!.data()! as Userinfo;
        pseudoController.text = uinfo.displayName;
        return GestureDetector(
          onTap: () => widget.onPseudoEditingComplete(pseudoController, uinfo),
          child: Scaffold(
            backgroundColor: ColorConstants.background,
            body: Padding(
              padding: const EdgeInsets.fromLTRB(40,20,40,40),
              child: Column(
                children:  [
                    Column(
                        children: [
                          GestureDetector(
                            onTap: () => {
                              widget.onProfilePictureTap(uinfo)
                            },
                            child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage('assets/images/default-profile-picture.png'),
                                  foregroundImage: NetworkImage(
                                      uinfo.imgUrl),
                                  radius: 100,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: TextFormField(
                              style: TextConstants.defaultPrimary,
                              maxLength: 20,
                              controller: pseudoController,
                              onEditingComplete: () => widget.onPseudoEditingComplete(pseudoController, uinfo),
                              decoration: InputDecorationBuilder().addLabel("Pseudo").setBorderRadius(BorderRadius.circular(20)).build(),
                              cursorColor: ColorConstants.primaryHighlight,
                            ),
                          ),

                        ]
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
                            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage())); },
                            child: const Text("Settings", style: TextConstants.defaultSecondary)),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Listener(
                          onPointerDown: (details) {
                            _buttonPressed = true;
                            _increaseCounterWhilePressed();
                          },
                          onPointerUp: (details) {
                            _buttonPressed = false;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorConstants.backgroundHighlight,
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                style: BorderStyle.none,
                              ),
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: const [
                                      Text(
                                          'Logout',
                                          textAlign: TextAlign.center,
                                          style: TextConstants.defaultSecondary
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: _dynamicPadding,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Visibility(
                                        child: SizedBox(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                            value: _counter / _maxCounter,
                                          ),
                                          height: 20.0,
                                          width: 20.0,
                                        ),
                                        visible: _dynamicPadding!=0,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

}