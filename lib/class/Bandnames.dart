import 'package:cloud_firestore/cloud_firestore.dart';

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

  static addCount(DocumentReference<Bandnames> ref, int added_count){
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Bandnames> freshSnap = await transaction.get(ref);
      await transaction.update(freshSnap.reference, {
        'count': freshSnap.data()!.count + added_count,
      });
    });
  }
}

final Stream<QuerySnapshot<Bandnames>> bandnamesStream = FirebaseFirestore.instance.collection('bandnames').withConverter<Bandnames>(
  fromFirestore: (snapshot, _) => Bandnames.fromJson(snapshot.data()!),
  toFirestore: (bandnames, _) => bandnames.toJson(),
).snapshots();