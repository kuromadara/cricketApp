import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cricket/routes/routes.dart';
import 'package:cricket/ui/ui.dart';

class SomeThingErrorWidget extends StatefulWidget {
  const SomeThingErrorWidget({super.key});

  @override
  State<SomeThingErrorWidget> createState() => _SomeThingErrorWidgetState();
}

class _SomeThingErrorWidgetState extends State<SomeThingErrorWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(context, "Something Went Wrong!", false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie Animation
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/lottie/something.json'),
            ),
          ),

          const SizedBox(height: 20),
          // Text Message
          const Text(
            'Something Went Wrong!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      // bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 0),
    );
  }
}
