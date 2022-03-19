



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Bandnames{
  final int count;
  final String name;
  Bandnames({required this.name, required this.count});

  Bandnames.fromJson(Map<String, Object?> json) : this(name: json['name']! as String, count: json['count']! as int);
  Map<String, Object?> toJson() {
    return {
      'name': name,
      'count': count,
    };
  }
}

class _MyHomePageState extends State<MyHomePage> {

  Widget _buildListItem(BuildContext context, DocumentSnapshot<Bandnames> bnSnapShot){

    Bandnames bn = bnSnapShot.data()!;
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(bn.name)),
          Text(bn.count.toString())
        ],
      ),
      onTap: ()=>{
        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot<Bandnames> freshSnap = await transaction.get(bnSnapShot.reference);
          await transaction.update(freshSnap.reference, {
            'count': freshSnap.data()!.count + 1,
          });
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Bandnames>> _bandnamesStream = FirebaseFirestore.instance.collection('bandnames').withConverter<Bandnames>(
      fromFirestore: (snapshot, _) => Bandnames.fromJson(snapshot.data()!),
      toFirestore: (bandnames, _) => bandnames.toJson(),
    ).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bandnamesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data!.docs[index] as DocumentSnapshot<Bandnames>),
          );
        },

      )
    );
  }
}
