import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

class PracticeQuestionPage extends StatefulWidget {
  const PracticeQuestionPage({super.key});

  @override
  State<PracticeQuestionPage> createState() => _PracticeQuestionPageState();
}

class _PracticeQuestionPageState extends State<PracticeQuestionPage> {
  static const _targetWord = 'BLUE';
  static const _initialLetters = ['L', 'E', 'B', 'U'];
  static const _tileColors = [
    Color(0xFF93C5FD),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF60A5FA),
  ];

  late final List<String> _availableLetters;
  late List<String?> _placedLetters;
  late List<bool> _usedLetters;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _availableLetters = [..._initialLetters]..shuffle();
    _placedLetters = List<String?>.filled(_targetWord.length, null);
    _usedLetters = List<bool>.filled(_availableLetters.length, false);
  }

  void _onLetterTap(int letterIndex) {
    final slotIndex = _placedLetters.indexOf(null);
    if (slotIndex == -1 || _usedLetters[letterIndex]) return;

    setState(() {
      _placedLetters[slotIndex] = _availableLetters[letterIndex];
      _usedLetters[letterIndex] = true;
    });

    _evaluateAnswer();
  }

  void _onPlacedLetterTap(int slotIndex) {
    final letter = _placedLetters[slotIndex];
    if (letter == null) return;

    final letterIndex = _availableLetters.indexOf(letter);
    setState(() {
      _placedLetters[slotIndex] = null;
      if (letterIndex != -1) _usedLetters[letterIndex] = false;
    });
  }

  void _evaluateAnswer() {
    if (_placedLetters.contains(null)) return;

    final attempt = _placedLetters.join();
    if (attempt == _targetWord) {
      setState(() => _showResult = true);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Almost! Try a different order.',
          style: AppTypography.kidsBodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.orange900,
      ),
    );
  }

  void _resetChallenge() {
    setState(() {
      _availableLetters
        ..clear()
        ..addAll(_initialLetters)
        ..shuffle();
      _placedLetters = List<String?>.filled(_targetWord.length, null);
      _usedLetters = List<bool>.filled(_availableLetters.length, false);
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: SafeArea(
        child: _showResult
            ? _buildResultContent(context)
            : _buildQuestionContent(context),
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildProgress(),
        const SizedBox(height: 24),
        Text(
          'Spell the word!',
          style: AppTypography.kidsHeadlineLg.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap the letters into the boxes below',
          style: AppTypography.kidsBodyMd.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        _buildSlots(),
        const Spacer(),
        _buildLetterTiles(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultContent(BuildContext context) {
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
                  'Amazing Job! You conquered the challenge and showed how smart you are!',
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
                      '5/5',
                      style: AppTypography.kidsHeadlineLg.copyWith(
                        fontSize: 32,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.orange500,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perfect Score!',
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
                  onPressed: _resetChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.replay_rounded,
                        color: Color(0xFF475569),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Play Again',
                        style: AppTypography.kidsBodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Word Challenge',
                style: AppTypography.kidsBodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '3 of 5',
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
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.borderVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange500),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        _placedLetters.length,
        (index) => _buildSlot(index),
      ),
    );
  }

  Widget _buildSlot(int index) {
    final letter = _placedLetters[index];
    final isFilled = letter != null;

    return Semantics(
      button: true,
      label: isFilled ? 'Remove letter $letter' : 'Empty letter slot',
      child: GestureDetector(
        onTap: () => _onPlacedLetterTap(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFFFEF3C7) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.orange500.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            letter ?? '',
            style: AppTypography.kidsHeadlineLg.copyWith(
              fontSize: 22,
              color: AppColors.orange900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterTiles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _availableLetters.length,
          (index) => _buildLetterTile(index),
        ),
      ),
    );
  }

  Widget _buildLetterTile(int index) {
    final used = _usedLetters[index];
    return Semantics(
      button: true,
      label: used
          ? 'Used letter ${_availableLetters[index]}'
          : 'Select letter ${_availableLetters[index]}',
      child: Opacity(
        opacity: used ? 0.3 : 1,
        child: GestureDetector(
          onTap: used ? null : () => _onLetterTap(index),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: _tileColors[index % _tileColors.length],
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _availableLetters[index],
              style: AppTypography.kidsHeadlineLg.copyWith(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
