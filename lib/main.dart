import 'dart:convert';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late File imagefile;
  bool hasPicked = false;
  bool hasProcessed = false;
  String? message = "";
  String connectionEndpoint = "https://483c-95-70-145-76.eu.ngrok.io/getClass";
  String? predictedLabel = "";
  String? _base64;

  uploadImage() async{
    final request = http.MultipartRequest("POST",Uri.parse(connectionEndpoint));

    final headers = {
      "Content-type": "multipart/form-data"
    };
    request.files.add(http.MultipartFile('image',
        imagefile.readAsBytes().asStream(),
        imagefile.lengthSync(),
        filename: imagefile.path.split("/").last));

    request.headers.addAll(headers);
    final response = await request.send();

    http.Response res = await http.Response.fromStream(response);
    final resJson = await jsonDecode(res.body);
    var map = Map<String,dynamic>.from(resJson);
    _base64 =  map["hist"];
    message = map['message'];


    if(message == "Success")
      {
        setState(() {
          hasProcessed = true;
          hasPicked = true;
          predictedLabel = map["prediction"];
        });
      }

  }

  Future getImageGallery() async {
    final XFile? _image =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      imagefile = File(_image!.path);
      hasPicked = true;
      hasProcessed = false;
      _base64 = null;
    });
  }

  @override
  void initState() {
    super.initState();

  }

  Future getImageCamera() async {
    final XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imagefile = File(pickedFile.path);
        hasProcessed = false;
        hasPicked = true;
        _base64 = null;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blood Picker Demo'),
        ),
        body: Center(
          child:
          Column(
              children: [
                hasPicked == false
                    ? const Text('No image loaded')
                    : Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                alignment: Alignment.topCenter,
                                child:
                                Image.file(imagefile, height: 350, width: 350),
                              )
                          )
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            uploadImage();
                          },
                          child: const Text('Process')),
                      Text(
                        hasProcessed != false? 'Successfully Predicted As : $predictedLabel' : '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),

                    _base64 == null ? Text(
                      hasProcessed != false
                          ? 'Histogram Of Grayscale:'
                          : 'Waiting for Processing',
                      style: const TextStyle(fontSize: 16),
                    ):
                    Image.memory(base64Decode(_base64!)),
                    ],
                  ),
                )

              ]),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.camera),
              label: 'Capture from camera',
              onTap: () => getImageCamera(),
            ),
            SpeedDialChild(
              child: const Icon(Icons.image),
              label: 'Upload from gallery',
              onTap: () => getImageGallery(),
            )
          ],
        ));
  }
}
