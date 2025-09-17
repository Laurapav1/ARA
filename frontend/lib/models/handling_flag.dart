import 'package:flutter/material.dart';

enum HandlingFlag {
  doubleLeash,
  muzzle,
  experiencedHandler,
  noPark,
  quarantine,
}

extension HandlingFlagUi on HandlingFlag {
  String get label {
    switch (this) {
      case HandlingFlag.doubleLeash:
        return 'Double leash';
      case HandlingFlag.muzzle:
        return 'Muzzle';
      case HandlingFlag.experiencedHandler:
        return 'Experienced handler';
      case HandlingFlag.noPark:
        return 'No park';
      case HandlingFlag.quarantine:
        return 'Quarantine';
    }
  }

  IconData get icon {
    switch (this) {
      case HandlingFlag.doubleLeash:
        return Icons.link; // “leash/chain”
      case HandlingFlag.muzzle:
        return Icons.masks; // use masks; works everywhere
      case HandlingFlag.experiencedHandler:
        return Icons.verified_user; // supervision
      case HandlingFlag.noPark:
        return Icons.block; // restriction
      case HandlingFlag.quarantine:
        return Icons.sick_outlined;
    }
  }

  Color get color {
    switch (this) {
      case HandlingFlag.doubleLeash:
        return Colors.blue;
      case HandlingFlag.muzzle:
        return Colors.orange;
      case HandlingFlag.experiencedHandler:
        return Colors.purple;
      case HandlingFlag.noPark:
        return Colors.brown;
      case HandlingFlag.quarantine:
        return Colors.red;
    }
  }
}
