import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';

class AdventureCard extends StatefulWidget {
  final String courseId;
  final String title;
  final String emoji;
  final Color color;
  final int progress;
  final int total;
  final Color progressColor;
  final List<Color>? cardGradient;
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
    this.cardGradient,
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

  void _onTap() {
    context.go(
      '${RouteNames.kidsLearn}/course',
      extra: {
        'courseId': widget.courseId,
        'courseTitle': widget.title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.total > 0 ? widget.progress / widget.total : 0.0;
    final pctInt = (pct * 100).round();
    final gradient =
        widget.cardGradient ?? const [Color(0xFFFFB347), Color(0xFFFF8C00)];

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
        _onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular thumbnail / emoji badge
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.progressColor, width: 3),
                ),
                child: widget.thumbnailUrl != null &&
                        widget.thumbnailUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Center(
                            child: Text(widget.emoji,
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 40)),
                      ),
              ),
              const SizedBox(height: 14),
              // Course title
              Text(
                widget.title,
                style: AppTypography.kidsBodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              // Progress label row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$pctInt%',
                    style: AppTypography.kidsBodyMd.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.4),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              if (pct >= 1.0) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      'Completed!',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 12,
                        color: Colors.white,
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
