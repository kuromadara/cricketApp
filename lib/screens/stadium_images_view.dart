import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket/controllers/stadium_image_controller.dart';

class StadiumImagesView extends StatelessWidget {
  @override
Widget build(BuildContext context) {
  print('StadiumImagesView build called'); // Debug log
  final controller = Provider.of<StadiumImageController>(context);

  return Scaffold(
    appBar: AppBar(title: Text('Stadium Images')),  
    body: FutureBuilder(
      future: controller.fetchStadiums(), // Ensure this is correct
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (controller.stadiums.isEmpty) {
          return Center(child: Text('No stadium images available.'));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.stadiums.length,
          itemBuilder: (context, index) {
            final stadium = controller.stadiums[index];
            return Card(
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      controller.getStadiumImageUrl(stadium.image),
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
      },
    ),
  );
}
}