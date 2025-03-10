import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final Function(Color) onFilterSelected;
  const FilterWidget({required this.onFilterSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.transparent, Colors.pinkAccent, Colors.purple, Colors.blueAccent, Colors.lightGreen];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onFilterSelected(color),
          child: CircleAvatar(backgroundColor: color, radius: 25),
        );
      }).toList(),
    );
  }
}
