import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/upload_stadium_image_controller.dart';
import 'package:cricket/models/models.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:cricket/ui/ui.dart';

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
  _UploadStadiumImageScreenContentState createState() =>
      _UploadStadiumImageScreenContentState();
}

class _UploadStadiumImageScreenContentState
    extends State<_UploadStadiumImageScreenContent> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _stadiumNameController = TextEditingController();
  XFile? _pickedImage;

  @override
  Widget build(BuildContext context) {
    final uploadController = context.watch<UploadStadiumImageController>();

    return Scaffold(
      appBar: AppBar(title: Text('Upload Stadium Image')),
      body: ApiHandleUiWidget(
        apiCallStatus: uploadController.apiStatus,
        successWidget: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                        child:
                            Text('${match.team1.name} vs ${match.team2.name}'),
                      );
                    }).toList(),
                    onChanged: (match) {
                      uploadController.setSelectedMatch(match);
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _stadiumNameController,
                  decoration: InputDecoration(
                    labelText: 'Stadium Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      final originalImage = File(pickedFile.path);
                      final originalBytes = await originalImage.readAsBytes();

                      img.Image? image = img.decodeImage(originalBytes);

                      img.Image resizedImage = img.copyResize(image!,
                          width: 800); // Adjust width as needed

                      List<int> resizedBytes = img.encodeJpg(resizedImage,
                          quality: 50); // Adjust quality for size

                      File resizedFile = await File(
                              '${originalImage.parent.path}/resized_${originalImage.uri.pathSegments.last}')
                          .writeAsBytes(resizedBytes);

                      setState(() {
                        _pickedImage = XFile(resizedFile
                            .path); // Update the state with the resized image
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
                      showCustomSnackBar(
                          context, 'Please select a match', false);
                      return;
                    }

                    if (_stadiumNameController.text.isEmpty) {
                      showCustomSnackBar(
                          context, 'Please enter stadium name', false);
                      return;
                    }

                    if (_pickedImage == null) {
                      showCustomSnackBar(
                          context, 'Please capture an image', false);
                      return;
                    }

                    try {
                      FormData formData = FormData.fromMap({
                        'image': await MultipartFile.fromFile(
                          _pickedImage!.path,
                          filename: 'stadium_image.jpg',
                        ),
                      });

                      final result = await uploadController.submitStadiumImage(
                        cricketMatchId:
                            uploadController.selectedMatch!.id.toString(),
                        stadiumName: _stadiumNameController.text,
                        imageData: formData,
                      );

                      if (context.mounted) {
                        showCustomSnackBar(
                            context, result.message, result.success);
                        if (result.success) {
                          _stadiumNameController.clear();
                          setState(() {
                            _pickedImage = null;
                          });
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showCustomSnackBar(context,
                            'Failed to upload stadium image: $e', false);
                      }
                    }
                  },
                  child: Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
