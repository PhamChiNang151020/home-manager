import "package:flutter/material.dart";
import "package:home_manager/features/shared/app_loading.dart";

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(message: message);
  }
}
