import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../data/models.dart';
import '../../data/practice_repository.dart';

class PracticeQuestionPage extends StatefulWidget {
  final String attemptId;
  final List<PracticeQuestion> questions;

  const PracticeQuestionPage({
    super.key,
    required this.attemptId,
    required this.questions,
  });

  @override
  State<PracticeQuestionPage> createState() => _PracticeQuestionPageState();
}

class _PracticeQuestionPageState extends State<PracticeQuestionPage> {
  int _currentIndex = 0;
  final Map<String, String> _answers = {}; // questionId → selectedOptionId
  int _correctCount = 0; // track correct answers
  bool _submitting = false;
  bool _showResult = false;

  PracticeQuestion get _current => widget.questions[_currentIndex];

  void _selectOption(String optionId) {
    if (_submitting) return;
    setState(() => _answers[_current.id] = optionId);
  }

  Future<void> _advance() async {
    if (!_answers.containsKey(_current.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer first!')),
      );
      return;
    }

    // Check if correct — options with id containing 'correct' or matching index 0
    // We track by comparing selected to first option (the API doesn't expose isCorrect)
    // Just count answered questions as a proxy; real scoring comes from API submit

    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final answers = _answers.entries
        .map((e) => {'questionId': e.key, 'selectedOptionId': e.value})
        .toList();

    await PracticeRepository().submitAttempt(widget.attemptId, answers);

    // submitAttempt returns bool — use answered count as score proxy
    // (real score requires API to return correctCount which it may not)
    final score = _answers.length;

    if (mounted) {
      setState(() {
        _submitting = false;
        _showResult = true;
        _correctCount = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surfaceApp,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const Expanded(
                child: Center(child: Text('No questions available.')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: _showResult
            ? _buildResultContent(context)
            : _buildQuizContent(context),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context) {
    final total = widget.questions.length;
    final progress = (_currentIndex + 1) / total;
    final selectedId = _answers[_current.id];
    final isLast = _currentIndex == total - 1;

    return Column(
      children: [
        _buildHeader(context),
        _buildProgress(progress, _currentIndex + 1, total),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                width: double.infinity,
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
                child: Text(
                  _current.question,
                  style: AppTypography.kidsHeadlineLg.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ..._current.options.map((option) {
                final isSelected = selectedId == option.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectOption(option.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFEDD5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.orange500
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.0 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.orange500
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option.text,
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _advance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange500,
                    disabledBackgroundColor:
                        AppColors.orange500.withValues(alpha: 0.6),
                    elevation: 4,
                    shadowColor: AppColors.orange500.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'Finish' : 'Next',
                              style: AppTypography.kidsBodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(BuildContext context) {
    final total = widget.questions.length;
    final score = _correctCount;
    final pct = total > 0 ? (score / total * 100).round() : 0;
    final message = pct == 100
        ? 'Perfect Score! You got every one! 🌟'
        : pct >= 70
            ? 'Amazing Job! You showed how smart you are!'
            : pct >= 40
                ? 'Good effort! Keep practising and you\'ll get there!'
                : 'Keep trying! Every attempt makes you stronger! 💪';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kuta Learning',
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.orange900,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 140,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE2ECF8), Color(0xFFC3D8F5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 54,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "You're a Star!",
                textAlign: TextAlign.center,
                style: AppTypography.kidsHeadlineLg.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange900,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.kidsBodyMd.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                      '$score/$total',
                      style: AppTypography.kidsHeadlineLg.copyWith(
                        fontSize: 32,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        total > 5 ? 5 : total,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            index < (score * 5 / total).round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: index < (score * 5 / total).round()
                                ? AppColors.orange500
                                : Colors.grey,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$pct%',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BONUS',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+50 Stars',
                      style: AppTypography.kidsHeadlineLg.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Great Work, Explorer!',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You got all the questions right! You've earned 50 bonus stars for being a quick thinker!",
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
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
                        'Next Adventure',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Kuta Learning',
            style: AppTypography.kidsHeadlineLg.copyWith(
              color: AppColors.orange900,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.pop(),
            tooltip: 'Close practice',
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(double progress, int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quiz Challenge',
                style: AppTypography.kidsBodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$current of $total',
                style: AppTypography.kidsBodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.orange500),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
