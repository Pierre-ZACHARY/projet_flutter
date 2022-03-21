import 'package:flutter/material.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage(BuildContext context, {Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0079FF),
                  Color(0xFF090979),
                ],
                stops: [0, 1],
              )
            ),
          ),
          Container(
            height: double.infinity,
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 120.0,
              ),
            ),
          )

        ],
      ),
    );
  }
}
