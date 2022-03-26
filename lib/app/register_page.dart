import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/authUtils.dart';
import '../utils/constant.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

  // TODO Ajouter Google / apple Sign up, Ajouter retour d'actions ( spinner ou barre de chargement ... ), gérer les erreurs retourner par login /register
  // voir https://medium.com/flutter-community/make-progress-button-in-flutter-d4e2d27bd1d7 pour le chargement du bouton login par ex

  String email = "", password = "", username = "";
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register(String email, String password, {String? displayName}) async {
    AuthUtils.Register(email, password, displayName: displayName);
  }

  Column makeEmailEntry(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Email",
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans"),
            decoration: const InputDecoration(
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

  Column makeUsernameEntry(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Username",
          style: kLabelStyle,
        ),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: usernameController,
            keyboardType: TextInputType.name,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans"),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
              hintText: "Enter your username",
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
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: "OpenSans"),
            decoration: const InputDecoration(
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

  ElevatedButton makeRegisterButton(){
    return ElevatedButton(
      onPressed: ()
      {
        register(emailController.text, passwordController.text,
            displayName: usernameController.text);
        Navigator.pop(context);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        padding:  MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(15.0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      child: const Text(
        "Register",
        style: TextStyle(
            color: Color(0xFF154da4),
            letterSpacing: 2.0,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: "OpenSans"
        ),
      ),
    );
  }

  Column makeSignUpText(){
    return Column(
      children: const <Widget>[
        Text(
          "- Or -",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(height: 10.0),
        Text(
            "Sign-Up with",
            style: kLabelStyle)
      ],
    );
  }

  GestureDetector makeSignInWithGoogleButton(){
    return GestureDetector(
      onTap: () async {
        await AuthUtils.googleLogin();
        Navigator.pop(context);
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 6.0
              )
            ],
            image: DecorationImage(
              image: AssetImage("assets/logos/google.jpg"),
            )
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    emailController.text = "";
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
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
              SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 70.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Sign-Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "OpenSans",
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        makeUsernameEntry(),
                        const SizedBox(height: 20.0),
                        makeEmailEntry(),
                        const SizedBox(height: 20.0),
                        makePasswordEntry(),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            width: double.infinity,
                            child: makeRegisterButton()
                        ),
                        makeSignUpText(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              makeSignInWithGoogleButton(),
                              // A modifier avec logo Apple pour la connexion
                              makeSignInWithGoogleButton(),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: RichText(
                              text: const TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "Aleary have an account ? ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                    TextSpan(
                                        text: "Sign-In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        )
                                    )
                                  ]
                              )
                          ),
                        )
                      ],
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}