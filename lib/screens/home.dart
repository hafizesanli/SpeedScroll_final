import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speed_scroll/screens/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:speed_scroll/screens/places.dart';
import 'package:speed_scroll/screens/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _firebase = FirebaseAuth.instance;
  var _isSgignoutLoading = false;

  String? _displayNameGoogle = '';

  @override
  void initState() {
    super.initState();

    //for setting the display name of google if the firebase auth user is null
    if (_firebase.currentUser == null) {
      getGoogleUserInfo();
    }
  }

  Future<void> getGoogleUserInfo() async {
    //.silently() will signIn the previously authenticated google user without the user interaction
    await _googleSignIn.signInSilently();
    setState(() {
      _displayNameGoogle = _googleSignIn.currentUser!.displayName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSgignoutLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const SafeArea(
              child: Stack(
                children: [
                  MapPage(), // Harita widget'ını ekledik
                ],
              ),
            ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.large(
          backgroundColor: const Color.fromARGB(255, 250, 10, 10),
          tooltip: 'Increment',
          onPressed: (){
            showDialog(
            context: context,
            barrierDismissible: false, //boşluğa tıklanınca kapanmasını önlüyor
            builder: (BuildContext context) {
              return const CountdownDialog();
            },
          );

          },
          shape: const CircleBorder(),
          child: const Icon(Icons.sos_rounded, size: 50, color: Colors.white,),
          ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(82, 170, 94, 1.0),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
                }, 
                icon: const Icon(Icons.settings, size: 35, color: Colors.white)
              ),
              IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlacesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite, size: 35, color: Colors.red),
            )
            ],
          )
        ),
    );
  }
}
class CountdownDialog extends StatefulWidget {
  const CountdownDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CountdownDialogState createState() => _CountdownDialogState();
}
class _CountdownDialogState extends State<CountdownDialog> {
  int count = 10;
  late Timer _timer;

  @override
  void initState() {
    startCountdown();
    super.initState();

  }

  // sms metni düzenlendi. home.dart içinde bu fonksiyonu dğiştirmeniz yeterli.
  void _sendSMS() async {
    User? user = FirebaseAuth.instance.currentUser;
    Position position = await Geolocator.getCurrentPosition();
    double latitude = position.latitude;
    double longitude = position.longitude;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // emergencyContact bilgisini alıyo
        Map<String, dynamic> emergencyContact =
        userDoc.data() as Map<String, dynamic>;

        // recipients listesini oluşturuyo
        List<String> recipients = [emergencyContact['emergencyContact']];
        await sendSMS(
            message:
            "This is an emergency, please send help!\nLocation:\nLatitude: ${latitude.toString()}\nLongitude: ${longitude.toString()}",
            recipients: recipients);
      }
    }
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (count > 0) {
        setState(() {
          count--;
        });
      } else {
        _sendSMS();
        _timer.cancel();
        Navigator.of(context).pop();
        
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          "EMERGENCY",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 227, 40, 26)),
        ), 
        ),
      content: SizedBox(width: double.infinity, height: MediaQuery.of(context).size.height / 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
            "At the end of the countdown your emergency contacts will be reached",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20.0),
            ),
            const SizedBox(height: 7),
            Center(
              child: Text("$count", textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          
             )
        ),
        actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 20),
            ))
      ],
      );
      
  }
}
