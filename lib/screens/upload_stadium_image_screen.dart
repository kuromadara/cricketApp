import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/upload_stadium_image_controller.dart';
import 'package:cricket/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

class UploadStadiumImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UploadStadiumImageController(),
      child: _UploadStadiumImageScreenContent(),
    );
  }
}

class _UploadStadiumImageScreenContent extends StatefulWidget {
  @override
  _UploadStadiumImageScreenContentState createState() => _UploadStadiumImageScreenContentState();
}

class _UploadStadiumImageScreenContentState extends State<_UploadStadiumImageScreenContent> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _stadiumNameController = TextEditingController();
  XFile? _pickedImage;

  @override
  Widget build(BuildContext context) {
    final uploadController = context.watch<UploadStadiumImageController>();

    return Scaffold(
      appBar: AppBar(title: Text('Upload Stadium Image')),  
      body: SingleChildScrollView( // Allow scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Match Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<MatchModel>(
                  decoration: InputDecoration(
                    labelText: 'Select Match',
                    border: InputBorder.none,
                  ),
                  isExpanded: true,
                  value: uploadController.selectedMatch,
                  items: uploadController.matches.map((match) {
                    return DropdownMenuItem(
                      value: match,
                      child: Text('${match.team1.name} vs ${match.team2.name}'),
                    );
                  }).toList(),
                  onChanged: (match) {
                    uploadController.setSelectedMatch(match);
                  },
                ),
              ),
              SizedBox(height: 16),

              // Stadium Name Input
              TextField(
                controller: _stadiumNameController,
                decoration: InputDecoration(
                  labelText: 'Stadium Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Image Preview
              _pickedImage != null
                  ? Image.file(
                      File(_pickedImage!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: Text('No image captured')), 
                    ),
              SizedBox(height: 16),

              // Camera Button
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    // Load the image file
                    final originalImage = File(pickedFile.path);
                    final originalBytes = await originalImage.readAsBytes();

                    // Decode the image
                    img.Image? image = img.decodeImage(originalBytes);

                    // Resize the image to maintain aspect ratio
                    img.Image resizedImage = img.copyResize(image!, width: 800); // Adjust width as needed

                    // Encode the resized image to JPEG format
                    List<int> resizedBytes = img.encodeJpg(resizedImage, quality: 50); // Adjust quality for size

                    // Save the resized image temporarily
                    File resizedFile = await File('${originalImage.parent.path}/resized_${originalImage.uri.pathSegments.last}').writeAsBytes(resizedBytes);

                    setState(() {
                      _pickedImage = XFile(resizedFile.path); // Update the state with the resized image
                    });
                  }
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Stadium Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (uploadController.selectedMatch == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a match')), 
                    );
                    return;
                  }

                  if (_stadiumNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter stadium name')), 
                    );
                    return;
                  }

                  if (_pickedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please capture an image')), 
                    );
                    return;
                  }

                  try {
                    // Create FormData for image upload
                    FormData formData = FormData.fromMap({
                      'image': await MultipartFile.fromFile(
                        _pickedImage!.path,
                        filename: 'stadium_image.jpg',
                      ),
                    });

                    await uploadController.submitStadiumImage(
                      cricketMatchId: uploadController.selectedMatch!.id.toString(),
                      stadiumName: _stadiumNameController.text,
                      imageData: formData,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stadium image uploaded successfully')), 
                    );
                    _stadiumNameController.clear();
                    setState(() {
                      _pickedImage = null;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to upload stadium image: $e')), 
                    );
                  }
                },
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
