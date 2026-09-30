import 'package:flutter/material.dart';

class KazinLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;

  const KazinLogo({
    super.key,
    this.height = 36,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/kazin_logo.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "KAZIN",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              "GUIDE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        );
      },
    );
  }
}
