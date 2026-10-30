import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  static const _correctAnswer = '15';
  String? _selectedAnswer;

  void _selectAnswer(String answer) {
    setState(() => _selectedAnswer = answer);
    if (answer == _correctAnswer) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Parent verified!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.borderVariant,
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildGateCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFFFEDD5),
                  child: Icon(
                    Icons.person,
                    color: AppColors.orange500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kuta Learning',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB020),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '125',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.settings,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.orange900, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adults Only!',
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.orange900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please solve this simple math\nproblem to prove you are a\nparent:',
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '7 + 8 = ?',
              textAlign: TextAlign.center,
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 22,
                color: AppColors.orange900,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['12', '15', '18']
                .map(
                  (answer) => _ParentOptionButton(
                    number: answer,
                    isSelected: _selectedAnswer == answer,
                    onTap: () => _selectAnswer(answer),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 14,
              color: Color(0xFF1D4ED8),
            ),
            label: const Text(
              'Go back to play',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentOptionButton extends StatelessWidget {
  const _ParentOptionButton({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  final String number;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.borderVariant : AppColors.surfaceApp,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF94A3B8) : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: AppTypography.kidsBodyMd.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}
