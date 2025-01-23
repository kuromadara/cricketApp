import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cricket/ui/ui.dart';
import 'package:cricket/routes/routes.dart';

class EmptyDataWidget extends StatefulWidget {
  const EmptyDataWidget({super.key});

  @override
  State<EmptyDataWidget> createState() => _EmptyDataWidgetState();
}

class _EmptyDataWidgetState extends State<EmptyDataWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCustomSnackBar(context, "No Data Found", false);
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
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/lottie/no_data.json'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No data found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      // bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 0),
    );
  }
}
