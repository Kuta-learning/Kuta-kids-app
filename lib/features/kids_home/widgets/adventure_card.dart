import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

class AdventureCard extends StatefulWidget {
  final String courseId;
  final String title;
  final String emoji;
  final Color color;
  final int progress;
  final int total;
  final Color progressColor;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const AdventureCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.emoji,
    required this.color,
    required this.progress,
    required this.total,
    required this.progressColor,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  State<AdventureCard> createState() => _AdventureCardState();
}

class _AdventureCardState extends State<AdventureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.total > 0 ? widget.progress / widget.total : 0.0;
    final pctInt = (pct * 100).round();

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular thumbnail / emoji badge
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
                child: widget.thumbnailUrl != null &&
                        widget.thumbnailUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Center(
                            child: Text(widget.emoji,
                                style: const TextStyle(fontSize: 38)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 38)),
                      ),
              ),
              const SizedBox(height: 12),
              // Course title
              Text(
                widget.title,
                style: AppTypography.kidsBodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Progress label row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$pctInt%',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.progressColor),
                ),
              ),
              if (pct >= 1.0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      'Completed!',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
