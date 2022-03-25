import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projet_flutter/app/register_page.dart';
import 'package:projet_flutter/utils/authUtils.dart';
import 'package:projet_flutter/utils/constant.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage(BuildContext context, {Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {

  // TODO Ajouter State Register, ajouter Google / apple Sign In, Ajouter retour d'actions ( spinner ou barre de chargement ... ), gérer les erreurs retourner par login /register
  // voir https://medium.com/flutter-community/make-progress-button-in-flutter-d4e2d27bd1d7 pour le chargement du bouton login par ex

  bool rememberMe = false;
  String email = "", password = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  Future<void> Login(String email, String password) async {
    AuthUtils.Login(email, password);
  }

  Future<void> Register(String email, String password) async {
    AuthUtils.Register(email, password);
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

  Checkbox makeRememberCheckBox(){
    return Checkbox(
      value: rememberMe,
      checkColor: Colors.green,
      activeColor: Colors.white,
      onChanged: (value) {
        setState(() {
          rememberMe = value!;
        });
      },
    );
  }

  ElevatedButton makeLogInButton(){
    return ElevatedButton(
      onPressed: () => Login(emailController.text, passwordController.text),
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
        "Log-in",
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

  Column makeSignInText(){
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
            "Sign in with",
            style: kLabelStyle)
      ],
    );
  }

  GestureDetector makeSignInWithGoogleButton(){
    return GestureDetector(
      onTap: () => print("Login with Google"),
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
    // Register("nicolas.loison45@gmail.com", "password", displayName: "Ouais la team");
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
                          "Sign-In",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "OpenSans",
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        makeEmailEntry(),
                        const SizedBox(height: 20.0),
                        makePasswordEntry(),
                        makePasswordForgotButton(),
                        Row(
                          children: <Widget>[
                            Theme(
                                data: ThemeData(unselectedWidgetColor: Colors.white),
                                child: makeRememberCheckBox()
                            ),
                            const Text(
                              "Remember me",
                              style: kLabelStyle,
                            ),
                          ],
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            width: double.infinity,
                            child: makeLogInButton()
                        ),
                        makeSignInText(),
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
                          onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const RegisterPage(title: "Register"))),
                          child: RichText(
                              text: const TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "No account ? ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                    TextSpan(
                                        text: "Sign-Up",
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
