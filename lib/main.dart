import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projet_flutter/utils/notification_service.dart';
import 'app/home/home_page.dart';
import 'app/loggin_page.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projet_flutter/modele/UserInfo.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) => ref.watch(firebaseAuthProvider).userChanges());


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(
    child: MaterialApp(home: MyApp())
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    // sert à changer automatiquement de page quand utilisateur connecté ou non
    return authStateChanges.when(
      data: (user) => _data(context, user),
      loading: () =>
      const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) =>
      const Scaffold(
        body: Text('Something went wrong'),
      ),
    );
  }

  Widget _data(BuildContext context, User? user) {
    if (user != null) {
      // si utilisateur co
      NotificationService.getToken().then((value) {
        Userinfo.saveToken(value, user.uid);
      });
      return MyHomePage(context, user, title: "Home Page");
    }
    // sinon
    return ConnexionPage(context, title: 'Connexion');
  }
}
