import 'package:flutter/material.dart';
import 'package:kuta_learning_app/core/constants/app_colors.dart';
import 'package:kuta_learning_app/features/kids/practice/presentation/pages/practice_question_page.dart';

class PracticeHomePage extends StatelessWidget {
  const PracticeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Practice'),
        backgroundColor: AppColors.mainPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose a Practice Category',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildPracticeCategoryCard(
                      context,
                      title: 'Mathematics Practice',
                      description: 'Addition, subtraction, and word problems',
                      icon: Icons.calculate,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PracticeQuestionPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeCategoryCard(
                      context,
                      title: 'English Vocabulary',
                      description: 'Spelling, matching, and reading comprehension',
                      icon: Icons.menu_book,
                      onTap: () {
                        // TODO: Navigate to question flow
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.mainPrimary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.mainPrimary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}