import 'package:flutter/animation.dart';

class AdminMotion {
  AdminMotion._();

  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 480);
  static const hero = Duration(milliseconds: 780);

  static const ease = Cubic(0.2, 0.8, 0.2, 1);
  static const emphasized = Cubic(0.16, 1, 0.3, 1);
  static const exit = Cubic(0.4, 0, 1, 1);
}
