import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

class RecommendedCard extends StatefulWidget {
  final String title;
  final String level;
  final Color color;
  final bool locked;

  const RecommendedCard({
    super.key,
    required this.title,
    required this.level,
    required this.color,
    this.locked = false,
  });

  @override
  State<RecommendedCard> createState() => _RecommendedCardState();
}

class _RecommendedCardState extends State<RecommendedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.93,
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
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: widget.locked ? const Color(0xFFF1F5F9) : widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: widget.locked
                            ? const Icon(Icons.lock_rounded,
                                size: 40, color: Colors.black26)
                            : _Placeholder(color: widget.color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.title,
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: widget.locked
                            ? Colors.black38
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.locked ? '🔒 LOCKED' : '📚 ${widget.level}',
                      style: AppTypography.kidsBodyMd.copyWith(
                        fontSize: 10,
                        color: widget.locked
                            ? Colors.black38
                            : const Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.locked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⭐',
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color color;

  const _Placeholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(const Color(0xFFFF6B6B), 10),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(const Color(0xFFFFD166), 14),
                const SizedBox(width: 6),
                _dot(const Color(0xFF06D6A0), 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
