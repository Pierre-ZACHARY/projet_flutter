import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_flutter/modele/Discussion.dart';
import 'package:projet_flutter/utils/constant.dart';
import 'package:textfield_search/textfield_search.dart';

import '../../../modele/UserInfo.dart';
import '../../../utils/cloudStorageUtils.dart';

class ChatRoomParam extends StatefulWidget {

  final String discussionId;
  final String? groupPictureUrl;

  const ChatRoomParam({Key? key, required this.discussionId, this.groupPictureUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatRoomParamState();

  Future<void> onGroupPictureTap(Discussion disc) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      CloudStorage.uploadDiscussionPicture(File(image.path), disc);
    }
  }

  Future<void> onGroupNameEditingComplete(TextEditingController groupNameController, Discussion disc) async {
    if(disc.groupTitle != groupNameController.value.text){
      await disc.changeTitle(groupNameController.value.text);
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> onActiveChange(bool value, Discussion disc) async {
    if (value){
      await disc.muteDiscussionForCurrentUser();
    }
    else{
      await disc.unmuteDiscussionForCurrentUser();
    }
  }
}

class UserinfoWrapper{
  late String label;
  late Userinfo value;
  UserinfoWrapper(Userinfo userinfo){
    label = userinfo.displayName;
    value = userinfo;
  }
}

class _ChatRoomParamState extends State<ChatRoomParam>{
  TextEditingController groupNameController = TextEditingController();
  bool _muteDiscussion = false;

  TextEditingController addUserController = TextEditingController();

  @override
  void initState() {
    _getIsMuted();
    super.initState();
  }

  _getIsMuted () async {
    Discussion disc = await Discussion.getDiscussionSnapshotById(widget.discussionId);
    _muteDiscussion = await disc.isDiscussionMutedForCurrentUser();
  }

  // create a Future that returns List
  Future<List> fetchData() async {
    List _list = [];
    String _inputText = addUserController.text;
    Query<Userinfo> query = Userinfo.searchUser(_inputText);
    QuerySnapshot<Userinfo> querySnapshot = await query.limit(10).get();
    for(int i = 0; i < querySnapshot.docs.length; i++){
      QueryDocumentSnapshot<Userinfo> documentSnapshot = querySnapshot.docs[i];
      Userinfo userinfo = documentSnapshot.data();
      _list.add(UserinfoWrapper(userinfo));
    }
    return _list;
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.

    //addUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DocumentSnapshot<Discussion>>(
      stream: Discussion.getDiscussionStream(widget.discussionId),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
          return const Text('Something went wrong', style: TextConstants.titlePrimary);
        }
        Discussion discussion = snapshot.data!.data()!;
        if (discussion.groupTitle != null) {
          groupNameController.text = discussion.groupTitle.toString();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorConstants.backgroundHighlight,
            title: Row(
              children: [
                discussion.getDiscussionCircleAvatar(),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: discussion.getTitleTextWidget(),
                )),
              ],
            ),
          ),
          backgroundColor: ColorConstants.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (discussion.type == 0)
                        discussion.getDiscussionCircleAvatarWithSize(100),
                      if (discussion.type == 1)
                        GestureDetector(
                          onTap: () => {
                            widget.onGroupPictureTap(discussion)
                          },
                          child: discussion.getDiscussionCircleAvatarWithSize(100),
                        ),
                      if (discussion.type == 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: TextFormField(
                            style: TextConstants.defaultPrimary,
                            maxLength: 20,
                            controller: groupNameController,
                            onEditingComplete: () => widget.onGroupNameEditingComplete(groupNameController, discussion),
                            decoration: InputDecorationBuilder().addLabel("Groupe name").setBorderRadius(BorderRadius.circular(20)).build(),
                            cursorColor: ColorConstants.primaryHighlight,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFieldSearch(
                            label: "",
                            textStyle: TextConstants.defaultPrimary,
                            controller: addUserController,
                            decoration: InputDecorationBuilder().addLabel("Add a user").build(),
                            future: () {
                              return fetchData();
                            },
                            getSelectedValue: (UserinfoWrapper value) {
                              discussion.addUser(context, value.value.uid);
                              addUserController.text = "";
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Row(
                          children: [
                            CupertinoSwitch(
                              value: _muteDiscussion,
                              onChanged: (value) {
                                setState(() {
                                  _muteDiscussion = value;
                                  widget.onActiveChange(_muteDiscussion, discussion);
                                  addUserController = TextEditingController();
                                });
                              },
                            ),
                            const Expanded(
                                child: Text(
                                    "Mute discussion",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "OpenSans"
                                    )
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}