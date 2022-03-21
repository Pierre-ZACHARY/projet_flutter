import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projet_flutter/page/home.dart';
import 'page/connexion.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) => ref.watch(firebaseAuthProvider).userChanges());


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      return MyHomePage(context, user, title: "Home Page");
    }
    // sinon
    return ConnexionPage(context, title: 'Connexion');
  }
}
