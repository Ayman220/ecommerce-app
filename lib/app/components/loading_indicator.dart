import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.size = 36.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = color ?? Get.theme.colorScheme.primary;
    
    return SpinKitFadingCircle(
      color: indicatorColor,
      size: size,
    );
  }
}