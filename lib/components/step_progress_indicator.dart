import 'package:flutter/cupertino.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color selectedColor;
  final Color unselectedColor;

  StepProgressIndicator({
    required this.totalSteps,
    required this.currentStep,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: index < currentStep ? selectedColor : unselectedColor,
            ),
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            height: 3.0,
          ),
        );
      }),
    );
  }
}
