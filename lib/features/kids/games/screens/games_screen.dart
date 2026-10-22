import 'package:flutter/material.dart';

import '../../../../core/constants/app_typography.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Games',
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon!',
              style: AppTypography.kidsBodyMd.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
