import 'package:flutter/material.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart';

class PracticeQuestionPage extends StatefulWidget {
  const PracticeQuestionPage({super.key});

  @override
  State<PracticeQuestionPage> createState() => _PracticeQuestionPageState();
}

class _PracticeQuestionPageState extends State<PracticeQuestionPage> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;

  // Mock question data (will later come from PracticeBloc / Repository)
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 5 + 3?',
      'options': ['6', '7', '8', '9'],
      'correctAnswerIndex': 2,
      'explanation': '5 plus 3 equals 8! Great job counting up.',
    },
    {
      'question': 'Which shape has 3 sides?',
      'options': ['Square', 'Triangle', 'Circle', 'Rectangle'],
      'correctAnswerIndex': 1,
      'explanation': 'A triangle always has 3 straight sides.',
    },
  ];

  void _selectOption(int index) {
    if (_isAnswerSubmitted) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;
    setState(() {
      _isAnswerSubmitted = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerSubmitted = false;
      } else {
        // TODO: Navigate to Practice Results Screen
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestionIndex];
    final options = currentQ['options'] as List<String>;
    final correctIndex = currentQ['correctAnswerIndex'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice (${_currentQuestionIndex + 1}/${_questions.length})'),
        backgroundColor: AppColors.mainPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey[200],
                color: AppColors.mainPrimary,
              ),
              const SizedBox(height: 24),
              
              // Question text
              Text(
                currentQ['question'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Options list
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedOptionIndex == index;
                    Color borderColor = Colors.grey[300]!;
                    Color bgColor = Colors.white;

                    if (_isAnswerSubmitted) {
                      if (index == correctIndex) {
                        bgColor = Colors.green.withValues(alpha: 0.1);
                        borderColor = Colors.green;
                      } else if (isSelected) {
                        bgColor = Colors.red.withValues(alpha: 0.1);
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      bgColor = AppColors.mainPrimary.withValues(alpha: 0.1);
                      borderColor = AppColors.mainPrimary;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          options[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: () => _selectOption(index),
                      ),
                    );
                  },
                ),
              ),

              // Feedback explanation area if submitted
              if (_isAnswerSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedOptionIndex == correctIndex
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentQ['explanation'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedOptionIndex == null
                    ? null
                    : (_isAnswerSubmitted ? _nextQuestion : _submitAnswer),
                child: Text(
                  _isAnswerSubmitted ? 'Next Question' : 'Submit Answer',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}