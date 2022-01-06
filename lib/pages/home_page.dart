import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermlkit/pages/face_detection_page.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? selectedImage;

  void showPhotoOptions() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                  child: Text("Camera"),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                  child: Text("Gallery"),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void pickImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    if(pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: Hero(
                  tag: "main_image",
                  child: Container(
                    height: 200,
                    width: 200,
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: Builder(
                      builder: (context) {
                        if(selectedImage != null) {
                          return Image.file(
                            selectedImage!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          );
                        }
                        else {
                          return Text("Select Image");
                        }
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  if(selectedImage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceDetectionPage(
                          image: selectedImage!,
                        )
                      ),
                    );
                  }
                },
                color: (selectedImage != null) ? Colors.blue : Colors.grey,
                child: Text("Scan Photo")
              ),

            ],
          ),
        ),
      ),
    );
  }
}