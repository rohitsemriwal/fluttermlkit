import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectionPage extends StatefulWidget {
  final File image;

  const FaceDetectionPage({ Key? key, required this.image }) : super(key: key);

  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {

  bool isLoading = true;
  List<Map<String, dynamic>> foundFaces = [];

  void detectFaces() async {
    // Create the Input Image
    InputImage inputImage = InputImage.fromFile(widget.image);

    // Define the Detector
    FaceDetector faceDetector = GoogleMlKit.vision.faceDetector();

    // Get the list of faces from the image
    List<Face> faces = await faceDetector.processImage(inputImage);
    
    // Adding all the faces to the list
    for(Face face in faces) {
      Map<String, dynamic> detailMap = {
        "position": face.getContour(FaceContourType.face)!.positionsList[0],
        "smiling_probability": face.smilingProbability.toString()
      };
      
      foundFaces.add(detailMap);
    }

    // Setting loading to false
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    detectFaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (isLoading == false) ? Container(
          child: ListView.builder(
            itemCount: foundFaces.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> currentFace = foundFaces[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(index.toString()),
                ),
                title: Text("Face at x: ${currentFace['position'].x} and y: ${currentFace['position'].y}"),
                subtitle: Text("Smiling Probability: ${currentFace['smiling_probability']}"),
              );
            },
          ),
        ) : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

}