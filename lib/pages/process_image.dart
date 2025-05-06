import 'dart:convert'; // To use jsonDecode
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Assuming you are using Flutter for the UI

class ProcessImage {
  static Future<void> processImageFile(
      BuildContext context, String imagePath) async {
    print('Processing image at path: $imagePath');
    File imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      try {
        // Build the URL with API key and model ID
        var url = Uri.parse(
            'https://detect.roboflow.com/cornstalk-ec49g/1?api_key=vNVMDi0DQOGjy3GBB6vL');

        // Create the multipart request
        var request = http.MultipartRequest('POST', url);

        // Attach the image file to the request
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));

        // Send the request
        var response = await request.send();

        // Process the response
        if (response.statusCode == 200) {
          print('Image successfully sent and processed.');
          var result = await http.Response.fromStream(response);
          var jsonData = jsonDecode(result.body);

          // Extract predictions
          var predictions = jsonData['predictions'];
          String highestClass = '';
          double highestConfidence = 0.0;

          // Iterate through predictions to find the highest confidence
          predictions.forEach((key, value) {
            double confidence = value['confidence'];
            if (confidence > highestConfidence) {
              highestConfidence = confidence;
              highestClass = key;
            }
          });

          // Format confidence as percentage
          int confidencePercentage = (highestConfidence * 100).toInt();

          // Navigate to display_result.dart and pass the data
          GoRouter.of(context).push(
            '/display_result',
            extra: {
              'imagePath': imagePath,
              'predictedClass': highestClass,
              'confidence': confidencePercentage,
            },
          );
        } else {
          print('Failed to send image. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during processing: $e');
      }
    } else {
      print('Image does not exist at path: $imagePath');
    }
  }
}
