import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/controllers.dart';
import 'package:cricket/models/models.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/screens/screens.dart';
import 'package:dio/dio.dart';
import 'package:cricket/ui/ui.dart';

class StadiumImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StadiumImageController()),
        ChangeNotifierProvider(create: (context) => MatchController()),
      ],
      child: _StadiumImageScreenContent(),
    );
  }
}

class _StadiumImageScreenContent extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final TextEditingController _stadiumNameController = TextEditingController();

  // To store the picked image
  XFile? _pickedImage;

  @override
  Widget build(BuildContext context) {
    final stadiumImageController = context.watch<StadiumImageController>();
    final matchController = context.watch<MatchController>();

    // Call fetchStadiums after the build is complete only if the API status is not success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stadiumImageController.apiStatus != ApiCallStatus.success) {
        stadiumImageController.fetchStadiums();
      }
    });

    return ApiHandleUiWidget(
      apiCallStatus: stadiumImageController.apiStatus,
      successWidget: Scaffold(
        appBar: AppBar(title: Text('Stadium Images')),  
        body: _StadiumImageGrid(stadiumImageController: stadiumImageController),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => UploadStadiumImageScreen()));
          },
          child: Icon(Icons.add_a_photo),
        ),
      ),
    );
  }
}

class _StadiumImageGrid extends StatelessWidget {
  final StadiumImageController stadiumImageController;

  _StadiumImageGrid({required this.stadiumImageController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: stadiumImageController.stadiums.length,
      itemBuilder: (context, index) {
        final stadium = stadiumImageController.stadiums[index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  stadiumImageController.getStadiumImageUrl(stadium.image),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stadium.stadiumName),
              ),
            ],
          ),
        );
      },
    );
  }
}