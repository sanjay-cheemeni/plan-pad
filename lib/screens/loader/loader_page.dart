import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';

class LoaderPage extends StatelessWidget {
  const LoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const SizedBox(
              width: 50,
              height: 22,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
            )));
  }
}
