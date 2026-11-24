import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

/// Locally bundled visual assets used throughout Gather.
abstract final class GatherVisuals {
  static Widget foodMotion({double size = 84}) => SizedBox(
    width: size,
    height: size,
    child: Lottie.asset(
      'assets/animations/food_orbit.json',
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
    ),
  );

  static Widget emptyBasketMotion({double width = 176, double height = 148}) =>
      SizedBox(
        width: width,
        height: height,
        child: Lottie.asset(
          'assets/animations/empty_basket.json',
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
      );

  static Widget heroIllustration({double? width, double? height}) =>
      SvgPicture.asset(
        'assets/images/gather_hero.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: 'Illustration of a fresh meal in a serving bowl',
      );

  static Widget emptyKitchenIllustration({double? width, double? height}) =>
      SvgPicture.asset(
        'assets/images/empty_kitchen.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: 'Illustration of a kitchen basket with fresh ingredients',
      );
}
