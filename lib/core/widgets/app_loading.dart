import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoading({
    super.key,
    this.size = AppSizes.iconLg,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? AppColors.primary,
      size: size,
    );
  }
}

// Full screen loading overlay
class AppFullScreenLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AppFullScreenLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: AppLoading(size: AppSizes.iconXl, color: Colors.white),
            ),
          ),
      ],
    );
  }
}