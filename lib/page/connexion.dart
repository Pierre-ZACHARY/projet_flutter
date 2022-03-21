import 'package:flutter/material.dart';
import 'package:projet_flutter/utilities/constant.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage(BuildContext context, {Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {

  Column makeEmailEntry(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Email",
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: const TextField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans"),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: "Enter your email address",
              hintStyle: kHintTextStyle,
            ),
          ),
        )
      ],
    );
  }

  Column makePasswordEntry(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Password",
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: const TextField(
            obscureText: true,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans"),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: "Enter your password",
              hintStyle: kHintTextStyle,
            ),
          ),
        )
      ],
    );
  }

  Container makePasswordForgotButton(){
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => print("Forgot password pressed"),
        child: const Text(
          "Forgot Password ?",
          style: kLabelStyle,
        ),
      ),
    );
  }
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
                  Color(0xFF1d9586),
                  Color(0xFF154da4),
                ],
                stops: [0, 1],
              )
            ),
          ),
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 120.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "OpenSans",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  makeEmailEntry(),
                  const SizedBox(height: 30.0),
                  makePasswordEntry(),
                  makePasswordForgotButton(),
                  Container(
                    child: ElevatedButton(
                      onPressed: () => print("Do nothing"),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "OpenSans"
                        ),
                      ),
                    )
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
