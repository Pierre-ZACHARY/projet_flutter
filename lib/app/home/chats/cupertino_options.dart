import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projet_flutter/modele/Message.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:flowder/flowder.dart';



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
  late DownloaderUtils options;
  late DownloaderCore core;
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

  Widget _buildCupertinoMenu(BuildContext context, Widget body, Message message){
    return CupertinoContextMenu(
        child : body,
        actions: <Widget>[
          widget.isCurrentUser ? CupertinoContextMenuAction(
            child: CupertinoTextField(
              controller: widget.editingController,
            ),
          ) : Row(),
          // widget.isCurrentUser && !widget.editing ? CupertinoContextMenuAction(
          //   trailingIcon: Icons.edit,
          //   child: const Text(
          //     'Modifier',
          //     style: TextStyle(
          //         fontWeight: FontWeight.bold),
          //   ),
          //   onPressed: () {
          //     if (mounted){
          //       setState(() {
          //         widget.editingController.text = message.messageContent;
          //         widget.editing = !widget.editing;
          //       });
          //     }
          //     Navigator.pop(context);
          //   },
          // ) : Row(),
          widget.isCurrentUser ? CupertinoContextMenuAction(
            trailingIcon: Icons.edit,
            isDefaultAction: true,
            child: const Text(
              'Confirmer',
              style: TextStyle(
                  color: Colors.green,
                  // fontWeight: FontWeight.bold
                  ),
            ),
            onPressed: () {
              // TODO Fonction qui met à jour le message d'id msg.messageId
              // if (mounted){
              //   setState(() {
              //     widget.editingController.text = "";
              //     widget.editing = false;
              //   });
              // }
              Navigator.pop(context);
            },
          ) : Row(),
          widget.isCurrentUser ? CupertinoContextMenuAction(
            trailingIcon: Icons.delete,
            isDestructiveAction: true,
            child: const Text(
              'Supprimer',
              // style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ) : Row(),
          message.type != 0 ? CupertinoContextMenuAction(
            child: const Text('Enregistrer'),
            onPressed: ()async {
              options = DownloaderUtils(
                progressCallback: (current, total) {
                  final progress = (current / total) * 100;
                  print('Downloading: $progress');
                },
                file: File(path + "/F.png"),
                progress: ProgressImplementation(),
                onDone: () {
                  print('COMPLETE');
                  print(path);
                },
                deleteOnCancel: true,
              );
              core = await Flowder.download(
                  widget.message.imgUrl!,
                  options);
              Navigator.pop(context);
            },
          ) : Row(),
        ],
     );
  }

  @override
  Widget build(BuildContext context) {
    print("Build!");
    // print(widget.editing);
    print("Modifier: " + (widget.isCurrentUser && !widget.editing).toString());
    print("Confirmer: " + (widget.isCurrentUser && widget.editing).toString());
    widget.editingController.text = widget.message.messageContent;
    return _buildCupertinoMenu(context, widget.body, widget.message);
  }
}