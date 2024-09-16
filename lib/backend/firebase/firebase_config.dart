import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCsWiUpW5lvFfBb79DwZhC00OEYET8QZvM",
            authDomain: "shiv-physiotherapy-ir2bhp.firebaseapp.com",
            projectId: "shiv-physiotherapy-ir2bhp",
            storageBucket: "shiv-physiotherapy-ir2bhp.appspot.com",
            messagingSenderId: "59392940131",
            appId: "1:59392940131:web:d941eeccc9254c87714056"));
  } else {
    await Firebase.initializeApp();
  }
}
