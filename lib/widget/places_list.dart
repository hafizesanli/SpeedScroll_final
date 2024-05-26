import 'package:flutter/material.dart';
import 'package:speed_scroll/models/place.dart';
import 'package:speed_scroll/screens/place_detail.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({Key? key, required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Center(
        child: Text(
          'No places added yet. Ready to add some?',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (ctx, index) => ListTile(
          leading: Image.network(
            places[index].imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ), // Display image from URL
          title: Text(
            places[index].title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PlaceDetailScreen(place: places[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
