//import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_classification/bounding_box.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'object_detection.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  double _imageHeight = 416;
  double _imageWidth = 416;
  late tfl.Interpreter interpreter;
  late Uint8List OutputTensorData;
  late File image;
  late List<ObjectDetection> _detections;
  late List _results = [];
  late File _image;
  bool imageSelect = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/best-int8.tflite');
    interpreter.allocateTensors();
    print(interpreter.getInputTensors());
    print(interpreter.getOutputTensors());
  }

  Future imageClassification(File image1) async {
// Load an image
    var image = img.decodeImage(await image1.readAsBytes());

// Define the desired input dimensions
    int inputWidth = 416;
    int inputHeight = 416;
    int numChannels = 3;

// Resize the image to the desired dimensions
    final resizedImage =
        img.copyResize(image!, width: inputWidth, height: inputHeight);

// Create a 4D list with the shape [1, 416, 416, 3]
    List<List<List<List<int>>>> inputTensorData =
        List.generate(1, (batchIndex) {
      return List.generate(inputHeight, (y) {
        return List.generate(inputWidth, (x) {
          return List.generate(numChannels, (channel) {
            final pixel = resizedImage.getPixel(x, y);
            int normalizedValue;
            if (channel == 0) {
              normalizedValue = pixel.r.toInt();
            } else if (channel == 1) {
              normalizedValue = pixel.r.toInt();
            } else {
              normalizedValue = pixel.b.toInt();
            }
            return normalizedValue;
          });
        });
      });
    });

// Now, 'inputTensorData' contains the preprocessed image data in the desired shape [1, 416, 416, 3] as doubles with normalization
    print(inputTensorData);

// Now, 'inputTensorData' contains the preprocessed image data in the desired shape [1, 416, 416, 3] as doubles with normalization

// Now, 'inputTensorData' contains the preprocessed image data in the desired shape [1, 416, 416, 3]

    // Define the shape of the output tensor
    int outputBatchSize = 1;
    int outputWidth = 10647;
    int outputChannels = 6;

// Calculate the total size of the output tensor
    int outputSize = outputBatchSize * outputWidth * outputChannels;

// Create an output tensor filled with zeros
    List<List<List<int>>> outputTensor = List.generate(outputBatchSize, (i) {
      return List.generate(outputWidth, (j) {
        return List.generate(outputChannels, (k) {
          return 0; // Fill with zeros
        });
      });
    });
    print(outputTensor.shape);
    interpreter.run(inputTensorData, outputTensor);
    print(outputTensor); // Your UINT8 output tensor

// Define image dimensions
    int imageWidth = 416; // Replace with your image dimensions
    int imageHeight = 416;

// Extract bounding box coordinates (x, y, width, height) within [0, 1] range

    var detections = decodeOutputTensor(outputTensor, ["penguin"]);

    /*while (i < a) {
      print(detections[i].x);
      print(detections[i].y);
      print(detections[i].width);
      print(detections[i].height);
      print(detections[i].confidence);
      print(detections[i].classId);
      i++;
    }*/
    setState(() {
      _detections = detections;
      _image = image1;
      print(_image);
      imageSelect = true;
    });

// Now 'outputTensor' is a 3D list with the desired shape [1, 1000, 6] filled with zeros

// Reshape the data to match the desired shape [1, 416, 416, 3]
// Now 'reshapedInputTensorData' contains the preprocessed image data with the desired shape

    //interpreter.(inputTensorIndex, inputTensorData);

    /*File compressedFile = await FlutterNativeImage.compressImage(
      image.path,
      quality: 100,
      targetWidth: 416,
      targetHeight: 416,
    );
    var recognitions = await Tflite.detectObjectOnImage(
        path: compressedFile.path, // required
        model: "YOLO",
        imageMean: 0.0,
        imageStd: 255.0,
        threshold: 0.3, // defaults to 0.1
        numResultsPerClass: 2, // defaults to 5
        blockSize: 32, // defaults to 32
        numBoxesPerBlock: 5, // defaults to 5
        asynch: true // defaults to true
        );
    print(recognitions);

    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          if (imageSelect)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: CustomPaint(
                    painter: BoundingBoxPainter(_detections, 416.0, 416.0),
                    child: Image.asset('assets/image1.jpg'),
                  ), // Image first
                ),
              ],
            )
          else
            Container(
              margin: const EdgeInsets.all(10),
              child: const Opacity(
                opacity: 0.8,
                child: Center(
                  child: Text(
                    "No image selected",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Center(
        child: Container(
          margin: const EdgeInsets.all(50),
          child: ElevatedButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.image),
            label: const Text("pick image"),
          ),
        ),
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
