import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Question model
// ─────────────────────────────────────────────────────────────────────────────

class _MathQuestion {
  final int a;
  final int b;
  final bool isAddition;

  const _MathQuestion({
    required this.a,
    required this.b,
    required this.isAddition,
  });

  int get answer => isAddition ? a + b : a - b;

  String get text => isAddition ? '$a + $b = ?' : '$a − $b = ?';

  List<int> _distractors() {
    final correct = answer;
    final candidates = <int>{};
    for (final delta in [1, 2, 3, -1, -2, -3]) {
      final v = correct + delta;
      if (v > 0 && v != correct) candidates.add(v);
    }
    // Ensure we have at least 3 distractors.
    var extra = 4;
    while (candidates.length < 3) {
      final v = correct + extra;
      if (v != correct) candidates.add(v);
      extra++;
    }
    final list = candidates.take(3).toList();
    return list;
  }

  List<int> get options {
    final list = [answer, ..._distractors()];
    list.shuffle(Random());
    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class SpeedMathPage extends StatefulWidget {
  const SpeedMathPage({super.key});

  @override
  State<SpeedMathPage> createState() => _SpeedMathPageState();
}

class _SpeedMathPageState extends State<SpeedMathPage> {
  late List<_MathQuestion> _questions;
  late List<int> _options;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _showSuccess = false;
  bool _sessionDone = false;

  static const int _total = 10;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    final rng = Random();
    final questions = <_MathQuestion>[];

    // 5 addition + 5 subtraction, then shuffle
    for (var i = 0; i < 5; i++) {
      final a = rng.nextInt(20) + 1;
      final b = rng.nextInt(20) + 1;
      questions.add(_MathQuestion(a: a, b: b, isAddition: true));
    }
    for (var i = 0; i < 5; i++) {
      int a = rng.nextInt(20) + 1;
      int b = rng.nextInt(20) + 1;
      if (a < b) {
        final tmp = a;
        a = b;
        b = tmp;
      }
      questions.add(_MathQuestion(a: a, b: b, isAddition: false));
    }
    questions.shuffle(rng);
    setState(() {
      _questions = questions;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _showSuccess = false;
      _sessionDone = false;
      _options = questions[0].options;
    });
  }

  void _resetSession() => _generateQuestions();

  Future<void> _onOptionTap(int value) async {
    if (_showSuccess || _selectedAnswer != null) return;
    final question = _questions[_currentIndex];

    if (value == question.answer) {
      setState(() {
        _selectedAnswer = value;
        _showSuccess = true;
        _score++;
      });
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      if (_currentIndex + 1 >= _total) {
        setState(() => _sessionDone = true);
      } else {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _showSuccess = false;
          _options = _questions[_currentIndex].options;
        });
      }
    } else {
      // Wrong answer — show red briefly then auto-advance to next question
      setState(() => _selectedAnswer = value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite! Moving on 💪'),
          duration: Duration(milliseconds: 700),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (_currentIndex + 1 >= _total) {
        setState(() => _sessionDone = true);
      } else {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _showSuccess = false;
          _options = _questions[_currentIndex].options;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionDone) return _buildScoreScreen(context);

    final question = _questions[_currentIndex];
    final progress = _currentIndex / _total;

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildProgress(_currentIndex + 1, progress),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildQuestionCard(question),
                  const SizedBox(height: 16),
                  _buildSparkyCard(question),
                  const SizedBox(height: 16),
                  _buildTipCard(question),
                  const SizedBox(height: 20),
                  _buildSkipButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textSecondary),
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
                const Icon(Icons.star_rounded,
                    color: Color(0xFF3B82F6), size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_score',
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

  // ── Progress bar ──────────────────────────────────────────────────────────

  Widget _buildProgress(int questionNum, double progress) {
    final pct = (progress * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $questionNum of $_total',
                style: AppTypography.kidsBodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$pct% Complete',
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
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.info),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Question card ─────────────────────────────────────────────────────────

  Widget _buildQuestionCard(_MathQuestion question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _showSuccess
            ? Border.all(color: Colors.green, width: 3)
            : Border.all(color: Colors.transparent, width: 3),
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
          if (_showSuccess)
            const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 36),
          Text(
            question.text,
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.orange900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.isAddition
                ? 'Count them up to find the magic number!'
                : 'Take them away to find the answer!',
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
            children: _options
                .map((opt) => _buildOptionButton(opt, question.answer))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int number, int correctAnswer) {
    final isSelected = _selectedAnswer == number;
    final isCorrect = isSelected && number == correctAnswer;
    final isWrong = isSelected && number != correctAnswer;

    Color bgColor;
    Color borderColor;
    if (isCorrect) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = Colors.green;
    } else if (isWrong) {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = Colors.red;
    } else {
      bgColor = const Color(0xFFF8F9FC);
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () => _onOptionTap(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: AppTypography.kidsHeadlineLg.copyWith(
            fontSize: 22,
            color: isCorrect
                ? Colors.green
                : isWrong
                    ? Colors.red
                    : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  // ── Sparky hint ───────────────────────────────────────────────────────────

  Widget _buildSparkyCard(_MathQuestion question) {
    final hint = question.isAddition
        ? '"You can do it! Think about your fingers!"'
        : '"Take the smaller number away from the bigger one!"';
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
            child:
                Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
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
            hint,
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

  // ── Tip card ──────────────────────────────────────────────────────────────

  Widget _buildTipCard(_MathQuestion question) {
    final tip = question.isAddition
        ? 'Try counting from the larger number!'
        : 'Count back from the first number!';
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
          const Icon(Icons.lightbulb_rounded,
              color: AppColors.info, size: 20),
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
                  tip,
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

  // ── Skip button ───────────────────────────────────────────────────────────

  Widget _buildSkipButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.skip_next_rounded,
          color: AppColors.textSecondary, size: 18),
      label: Text(
        'Exit',
        style: AppTypography.kidsBodyMd.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── Score screen ──────────────────────────────────────────────────────────

  Widget _buildScoreScreen(BuildContext context) {
    final stars = _score >= 9
        ? '🌟🌟🌟'
        : _score >= 7
            ? '⭐⭐⭐'
            : _score >= 5
                ? '⭐⭐'
                : '⭐';

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'Session Complete!',
                  style: AppTypography.kidsHeadlineLg.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored $_score / $_total',
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(stars, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                // Star row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_total, (i) {
                    return Icon(
                      i < _score
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < _score
                          ? const Color(0xFFFBBF24)
                          : Colors.grey,
                      size: 22,
                    );
                  }),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _resetSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange500,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Play Again 🎮',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.orange500, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.orange900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
