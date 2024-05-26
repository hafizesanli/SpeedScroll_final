import 'package:speed_scroll/models/place.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPlacesNotifier extends ChangeNotifier {
  List<Place> _places = [];

  List<Place> get places => _places;

  void addPlace(String title) {
    final newPlace = Place(title: title, imageUrl: '', id: '');
    _places.add(newPlace);
    notifyListeners();
  }
}
