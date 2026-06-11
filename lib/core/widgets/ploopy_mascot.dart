import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PloopyMascot extends StatelessWidget {
  final double size;
  final bool withBook;

  const PloopyMascot({super.key, this.size = 120, this.withBook = true});

  @override
  Widget build(BuildContext context) {
    final bodySize = size * 0.68;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * 0.08,
            child: Container(
              width: bodySize,
              height: bodySize,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA23A),
                borderRadius: BorderRadius.circular(bodySize * 0.48),
                border: Border.all(color: const Color(0xFFC65D15), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1FF97316),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size * 0.14,
            right: size * 0.34,
            child: Transform.rotate(
              angle: -0.55,
              child: Container(
                width: size * 0.13,
                height: size * 0.24,
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342),
                  borderRadius: BorderRadius.circular(size * 0.08),
                  border: Border.all(
                    color: const Color(0xFF527C24),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.21,
            right: size * 0.24,
            child: Transform.rotate(
              angle: 0.65,
              child: Container(
                width: size * 0.12,
                height: size * 0.20,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A),
                  borderRadius: BorderRadius.circular(size * 0.08),
                  border: Border.all(
                    color: const Color(0xFF527C24),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.47,
            left: size * 0.35,
            child: _Eye(size: size),
          ),
          Positioned(
            top: size * 0.47,
            right: size * 0.35,
            child: _Eye(size: size),
          ),
          Positioned(
            top: size * 0.57,
            child: Container(
              width: size * 0.18,
              height: size * 0.09,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textMain,
                    width: size * 0.018,
                  ),
                ),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          Positioned(
            top: size * 0.55,
            left: size * 0.23,
            child: _Blush(size: size),
          ),
          Positioned(
            top: size * 0.55,
            right: size * 0.23,
            child: _Blush(size: size),
          ),
          if (withBook)
            Positioned(
              bottom: size * 0.01,
              child: Transform.rotate(
                angle: -0.03,
                child: Container(
                  width: size * 0.7,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(size * 0.04),
                    border: Border.all(
                      color: const Color(0xFFC65D15),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.02,
                      height: size * 0.17,
                      color: AppColors.primaryBorder,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  final double size;

  const _Eye({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.055,
      height: size * 0.08,
      decoration: BoxDecoration(
        color: AppColors.textMain,
        borderRadius: BorderRadius.circular(size * 0.04),
      ),
    );
  }
}

class _Blush extends StatelessWidget {
  final double size;

  const _Blush({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.09,
      height: size * 0.035,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7E7E).withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(size * 0.05),
      ),
    );
  }
}
