import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:speed_scroll/models/place.dart';
import 'package:speed_scroll/screens/home.dart';
import 'package:speed_scroll/screens/image_location.dart'; // Update import to the correct path
import 'package:speed_scroll/models/place.dart';
class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

  final Place place;
  Future<void> _deletePlace(BuildContext context) async {
    try {
      //delete the image from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(place.imageUrl);
      await storageRef.delete();

      //delete the document from Firestore
      await FirebaseFirestore.instance.collection('places').doc(place.id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place deleted successfully')),
      );
      Navigator.of(context).pop(); //
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete place: $e')),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Place'),
        content: const Text('Are you sure you want to delete this place?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deletePlace(context); //delete operation
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              place.imageUrl,
              width: 380,
              height: 380,
            ),

            Text(
              place.title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.deepPurpleAccent, fontSize: 25
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                icon: const Icon(Icons.location_pin, size: 30, color: Colors.red),
                label: const Text("Send Me There"),

            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confirmDelete(context),
        backgroundColor: Colors.white,
        child: const Icon(Icons.delete),
      ),
    );
  }
}
