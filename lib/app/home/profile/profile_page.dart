import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter/modele/UserInfo.dart';
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
    print("test");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      CloudStorage.uploadUserProfilePicture(File(image.path), uinfo);
    }
  }

}

class _ProfilePageState extends State<ProfilePage>{
  @override
  Widget build(BuildContext context) {
    //String networkImgUrl = await FirebaseStorage.instance.ref(CloudStorage.profilePicturePath+FirebaseAuth.instance.currentUser!.uid+".png").getDownloadURL();
    String uid = (FirebaseAuth.instance.currentUser!.uid);
    print(uid);
    return Scaffold(
      backgroundColor: ColorConstants.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: Userinfo.getUserDocumentStream(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          Userinfo uinfo = snapshot.data!.data()! as Userinfo;

          return Column(
            children:  [
              Expanded(
                child: Center(
                  child: Expanded(
                    child: GestureDetector(
                      onTap: () => {
                        widget.onProfilePictureTap(uinfo)
                      },
                      child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('assets/images/default-profile-picture.png'),
                            foregroundImage: NetworkImage(uinfo.imgUrl),
                            radius: 100,
                          ),
                    ),
                  ),
                ),
              ),

            ],
          );
        }
      ),
    );
  }

}