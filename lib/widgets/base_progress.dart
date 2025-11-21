import 'package:doan_hoi_app/widgets/base_indicator.dart';
import 'package:flutter/material.dart';

class BaseProgress extends StatelessWidget {
  const BaseProgress({super.key, required this.child, this.isLoading = false});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) const BaseIndicator(),
      ],
    );
  }
}
