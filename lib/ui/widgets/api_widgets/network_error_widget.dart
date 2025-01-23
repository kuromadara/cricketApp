import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cricket/routes/routes.dart';
import 'package:cricket/ui/ui.dart';

class NetworkErrorWidget extends StatefulWidget {
  const NetworkErrorWidget({super.key});

  @override
  State<NetworkErrorWidget> createState() => _NetworkErrorWidgetState();
}

class _NetworkErrorWidgetState extends State<NetworkErrorWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(context, "No Internet", false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
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
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/lottie/no_internet.json'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Network Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        // bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 0),
      ),
    );
  }
}
