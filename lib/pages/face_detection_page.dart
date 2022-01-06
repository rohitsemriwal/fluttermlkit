import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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

  Future<void> detectFaces() async {
    // Empty the existing list and show loading (in case of a reload)
    setState(() {
      foundFaces = [];
      isLoading = true;
    });

    // Create the Input Image
    InputImage inputImage = InputImage.fromFile(widget.image);

    // Define the Detector
    FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
      enableContours: true,
      enableTracking: true,
      enableClassification: true,
      enableLandmarks: true,
      mode: FaceDetectorMode.accurate
    ));

    // Get the list of faces from the image
    List<Face> faces = await faceDetector.processImage(inputImage);
    
    // Adding all the faces to the list
    for(Face face in faces) {
      Map<String, dynamic> detailMap = {
        "face_bounding_box": face.boundingBox,
        "angleY": face.headEulerAngleY,
        "angleZ": face.headEulerAngleZ,
        "contour": face.getContour(FaceContourType.face),
        "smiling_probability": face.smilingProbability,
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
      appBar: AppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await detectFaces();
          },
          child: ListView(
            children: [

              Hero(
                tag: "main_image",
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: FileImage(widget.image),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20,),

              (isLoading == false) ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),

                    Text("Total Faces: ${foundFaces.length}", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),),

                    SizedBox(height: 10,),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: foundFaces.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> currentFace = foundFaces[index];
                        return ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: CircleAvatar(
                            child: Text((index + 1).toString()),
                          ),
                          title: Text("Angle Y: ${ currentFace['angleY'].toStringAsFixed(2) }, Angle Z: ${ currentFace['angleZ'].toStringAsFixed(2) }"),
                          subtitle: Text("Smiling Probability: " + (currentFace['smiling_probability'] * 100).toStringAsFixed(2)),
                        );
                      },
                    ),
                  ],
                ),
              ) : Center(
                child: CupertinoActivityIndicator(),
              ),

            ],
          ),
        ),
      ),
    );
  }

}