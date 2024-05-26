import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _image;


  void _disposeImagePicker() {
    setState(() {
      _image = null; // Reset the selected image
    });
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _savePlace() async {
    final enteredTitle = _titleController.text;
    Position position = await Geolocator.getCurrentPosition();
    double latitude = position.latitude;
    double longitude = position.longitude;

    if (enteredTitle.isEmpty || _image == null) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final placesCollection =
            FirebaseFirestore.instance.collection('places');
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('place_images')
            .child('${DateTime.now()}.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();
        await placesCollection.add({
          'title': enteredTitle,
          'userId': user.uid,
          'imageUrl': imageUrl,
          'latitude': latitude,
          'longitude': longitude,
        });
        Navigator.of(context).pop();
      } else {
        print('User is not logged in.');
      }
    } catch (error) {
      print('Error saving place: $error');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _disposeImagePicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (_image != null) ...[
              Image.file(_image!),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _getImage,
              icon: const Icon(Icons.camera),
              label: const Text('Take Picture'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
