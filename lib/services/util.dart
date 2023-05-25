import 'package:flutter/material.dart';

class UtilFunc {
  static void changeIndex(int value, BuildContext context, int selectedIndex) {
    if (selectedIndex == value) {
      return;
    }

    switch (value) {
      case 0:
        {
          Navigator.pushReplacementNamed(context, '/readIt', arguments: {
            "selectedIndex": 0,
          });
          break;
        }
      case 1:
        {
          Navigator.pushReplacementNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
      case 2:
        {
          Navigator.pushReplacementNamed(context, '/content', arguments: {
            "selectedIndex": 2,
          });
          break;
        }

      case 3:
        {
          Navigator.pushReplacementNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
    }
  }
}
