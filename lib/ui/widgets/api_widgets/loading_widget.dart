import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cricket/common/common.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(
          radius: loadingRadius,
        ),
      ),
    );
  }
}
