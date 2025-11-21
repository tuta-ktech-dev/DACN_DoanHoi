import 'package:flutter/material.dart';

class BaseError extends StatelessWidget {
  const BaseError(
      {super.key, required this.errorMessage, required this.onTryAgain});

  final String errorMessage;
  final Function() onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        const Icon(Icons.error),
        Text(errorMessage),
        TextButton(onPressed: onTryAgain, child: const Text('Try again')),
      ],
    );
  }
}
