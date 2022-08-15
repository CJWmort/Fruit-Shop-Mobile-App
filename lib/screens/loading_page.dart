import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.orangeAccent,
        child: SpinKitPouringHourglass(
          size: 140,
          color: Colors.white,
        ),
      ),
    );
  }
}