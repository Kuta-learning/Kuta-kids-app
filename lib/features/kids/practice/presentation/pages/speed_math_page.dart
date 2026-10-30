import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

class SpeedMathPage extends StatefulWidget {
  const SpeedMathPage({super.key});

  @override
  State<SpeedMathPage> createState() => _SpeedMathPageState();
}

class _SpeedMathPageState extends State<SpeedMathPage> {
  static const _correctAnswer = 8;
  int? _selectedAnswer;

  void _checkAnswer() {
    final selectedAnswer = _selectedAnswer;
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose an answer first!')));
      return;
    }

    final isCorrect = selectedAnswer == _correctAnswer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Amazing! You found the magic number!'
              : 'Almost! Try counting again.',
        ),
        backgroundColor: isCorrect ? AppColors.success : AppColors.orange900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProgress(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildQuestionCard(),
                  const SizedBox(height: 16),
                  _buildSparkyCard(),
                  const SizedBox(height: 16),
                  _buildTipCard(),
                  const SizedBox(height: 20),
                  _buildActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            tooltip: 'Close speed math',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.borderVariant,
              padding: const EdgeInsets.all(6),
            ),
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            'Math Magic Practice',
            style: AppTypography.kidsBodyMd.copyWith(
              color: AppColors.orange900,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2ECF8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '125',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question 3 of 10',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '30% Complete',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.3,
              backgroundColor: AppColors.borderVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'What is 5 + 3?',
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.orange900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Count them up to find the magic number!',
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              7,
              8,
              9,
              10,
            ].map((number) => _buildOptionButton(number)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int number) {
    final isSelected = _selectedAnswer == number;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswer = number),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: AppTypography.kidsHeadlineLg.copyWith(
            fontSize: 22,
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildSparkyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF3B82F6),
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Sparky says:',
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '"You can do it! Think about your fingers!"',
            textAlign: TextAlign.center,
            style: AppTypography.kidsBodyMd.copyWith(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF475569),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Try counting from the larger number!',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.skip_next_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
          label: Text(
            'Skip',
            style: AppTypography.kidsBodyMd.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                elevation: 4,
                shadowColor: AppColors.orange500.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Check Answer',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
