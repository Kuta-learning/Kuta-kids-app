import 'package:flutter/material.dart';

class AdventureData {
  final String title;
  final String emoji;
  final Color color;
  final Color iconColor;
  final int progress;
  final int total;
  final Color progressColor;

  const AdventureData({
    required this.title,
    required this.emoji,
    required this.color,
    required this.iconColor,
    required this.progress,
    required this.total,
    required this.progressColor,
  });
}

class RecommendedData {
  final String title;
  final String level;
  final Color color;
  final bool locked;

  const RecommendedData({
    required this.title,
    required this.level,
    required this.color,
    this.locked = false,
  });
}
