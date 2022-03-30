import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projet_flutter/modele/Message.dart';


class CupertinoOptions extends StatefulWidget{
  TextEditingController editingController = TextEditingController();
  bool editing = false;
  bool isCurrentUser = false;
  Widget body;
  Message message;

  CupertinoOptions({Key? key, required this.body, required this.message, required this.isCurrentUser}) : super(key: key);

  
  
  @override
  State<CupertinoOptions> createState() => _CupertinoOptionsState();
}

class _CupertinoOptionsState extends State<CupertinoOptions>{

  late final String path;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _setPath();
    if (!mounted) return;
  }

  void _setPath() async {
    path = (await getExternalStorageDirectory())!.path;
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  _downloadImg(String imgUrl) async {
    // https://github.com/Baseflow/flutter-permission-handler/tree/master/permission_handler
    var serviceStatus = await Permission.photos.status;
    bool isOn = serviceStatus == PermissionStatus.granted;
    if(!isOn){
      if (await Permission.photos.isPermanentlyDenied) {
        openAppSettings();
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
      ].request();
      if((statuses[Permission.photos] != PermissionStatus.granted)){
        _toastInfo('Cancelled');
        return;
      }
    }
    GallerySaver.saveImage(imgUrl).then((bool? success) {
      setState(() {
        if(success ?? false) {
          _toastInfo('Image saved');
        }
        else{
          _toastInfo('Error saving image');
        }
      });
    });
  }

  Widget _buildCupertinoMenu(BuildContext context, Widget body, Message message){
    return CupertinoContextMenu(
        child : body,
        actions: <Widget>[
          widget.isCurrentUser && message.type==0 ? CupertinoContextMenuAction(
            child: CupertinoTextField(
              controller: widget.editingController,
            ),
          ) : Row(),
          widget.isCurrentUser && message.type==0 ? CupertinoContextMenuAction(
            trailingIcon: Icons.edit,
            isDefaultAction: true,
            child: const Text(
              'Confirmer',
              style: TextStyle(
                  color: Colors.green,
                  // fontWeight: FontWeight.bold
                  ),
            ),
            onPressed: () async{
              await message.editMessage(messageContent: widget.editingController.text);
              Navigator.pop(context);
            },
          ) : Row(),
          widget.isCurrentUser ? CupertinoContextMenuAction(
            trailingIcon: Icons.delete,
            isDestructiveAction: true,
            child: const Text(
              'Supprimer',
            ),
            onPressed: () async {
              await message.deleteMessage();
              Navigator.pop(context);
            },
          ) : Row(),
          message.type != 0 ? CupertinoContextMenuAction(
            child: const Text('Enregistrer'),
            onPressed: ()  async {
              await _downloadImg(message.imgUrl!);
              Navigator.pop(context);
            },
          ) : Row(),
        ],
     );
  }

  @override
  Widget build(BuildContext context) {
    //print("Build!");
    // print(widget.editing);
    //print("Modifier: " + (widget.isCurrentUser && !widget.editing).toString());
    //print("Confirmer: " + (widget.isCurrentUser && widget.editing).toString());
    widget.editingController.text = widget.message.messageContent;
    return _buildCupertinoMenu(context, widget.body, widget.message);
  }
}