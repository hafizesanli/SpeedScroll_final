import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Place {
  Place({
    required this.id, // id is now a required parameter
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;



  factory Place.fromSnapshot(DocumentSnapshot snapshot) {
    String imageUrl = snapshot['imageUrl'];
    return Place(
      id: snapshot.id, // Set id from the document ID
      title: snapshot['title'] ?? '',
      imageUrl: imageUrl,
    );
  }
}
