import 'package:flutter/material.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayResult extends StatefulWidget {
  const DisplayResult({super.key});

  @override
  _DisplayResultState createState() => _DisplayResultState();
}

class _DisplayResultState extends State<DisplayResult> {
  // Insert data into the database
  Future<void> insertScanResult(String uid, String classification, DateTime scannedAt) async {
    final response = await Supabase.instance.client
        .from('Disease')  // replace with your table name
        .insert({
          'uid': uid,
          'classification': classification,
          'scanned_at': scannedAt.toIso8601String(),
        });

    if (response != null) {
      print('Error inserting data: \${response.error!.message}');
    } else {
      print('Data inserted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed via `extra` using GoRouterState
    final GoRouterState state = GoRouterState.of(context);
    final args = state.extra as Map<String, dynamic>;

    String imagePath = args['imagePath'];
    String predictedClass = args['predictedClass'];
    int confidence = args['confidence'];
    String uid = Supabase.instance.client.auth.currentUser!.id;  // Assuming uid is passed in arguments
    DateTime scannedAt = DateTime.now(); // Current date and time for scanned_at

    // Insert the data when the widget is built
    insertScanResult(uid, predictedClass, scannedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analysis Result'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the image
            Image.file(File(imagePath)),
            const SizedBox(height: 20),
            // Display the prediction result
            Text(
              'Predicted Class: $predictedClass',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Confidence: $confidence% accurate',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
