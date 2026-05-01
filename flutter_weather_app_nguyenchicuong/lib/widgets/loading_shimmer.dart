import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _block(height: 220),
        const SizedBox(height: 14),
        _block(height: 140),
        const SizedBox(height: 14),
        _block(height: 210),
      ],
    );
  }

  Widget _block({required double height}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.45, end: 0.95),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
}
