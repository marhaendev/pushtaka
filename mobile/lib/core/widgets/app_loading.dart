import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final bool isCircular;
  final Color? color;
  const AppLoading({
    super.key,
    this.size = 100,
    this.isCircular = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          'assets/loading.gif',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
