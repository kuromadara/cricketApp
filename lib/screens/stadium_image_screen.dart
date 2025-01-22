import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:dio/dio.dart';

class StadiumImageScreen extends StatefulWidget {
  @override
  _StadiumImageScreenState createState() => _StadiumImageScreenState();
}

class _StadiumImageScreenState extends State<StadiumImageScreen> {
  final StadiumImageController stadiumImageController = StadiumImageController();
  final MatchController matchController = MatchController();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers for text fields
  final TextEditingController _stadiumNameController = TextEditingController();
  
  // To store the picked image
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    // Fetch matches when the screen initializes
    matchController.fetchPendingMatches();
  }

  // Method to open camera and capture image
  Future<void> _openCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  // Method to submit stadium image
  Future<void> _submitStadiumImage() async {
    // Validate inputs
    if (matchController.selectedMatch == null) {
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
          filename: 'stadium_image.jpg'
        ),
      });
      
      // Submit stadium image
      await stadiumImageController.submitStadiumImage(
        cricketMatchId: matchController.selectedMatch!.id,
        stadiumName: _stadiumNameController.text,
        imageData: formData
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stadium image uploaded successfully')),
      );

      // Reset form
      setState(() {
        _pickedImage = null;
        _stadiumNameController.clear();
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload stadium image: $e')),
      );
    }
  }

  // Method to show stadium image upload dialog
  void _showStadiumImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Upload Stadium Image'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Match Dropdown
                    DropdownButtonFormField<MatchModel>(
                      decoration: InputDecoration(
                        labelText: 'Select Match',
                        border: OutlineInputBorder(),
                      ),
                      value: matchController.selectedMatch,
                      items: matchController.matches.map((match) {
                        return DropdownMenuItem(
                          value: match,
                          child: Text('${match.team1.name} vs ${match.team2.name}'),
                        );
                      }).toList(),
                      onChanged: (match) {
                        // Use the method to set selected match
                        matchController.setSelectedMatch(match);
                        // Update the local state in the dialog
                        setState(() {});
                      },
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
                          setState(() {
                            _pickedImage = pickedFile;
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Capture Stadium Image'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitStadiumImage,
                  child: Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stadium Images'),
      ),
      body: Center(
        child: Text('No stadium images yet'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStadiumImageDialog,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _stadiumNameController.dispose();
    super.dispose();
  }
}