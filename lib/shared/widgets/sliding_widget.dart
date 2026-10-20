import 'package:flutter/material.dart';

class SlidingBoxSelector extends StatefulWidget {
  const SlidingBoxSelector({super.key});

  @override
  State<SlidingBoxSelector> createState() =>
      _SlidingBoxSelectorState();
}

class _SlidingBoxSelectorState extends State<SlidingBoxSelector> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 4;

          return Stack(
            children: [
              // Sliding selected box
              AnimatedAlign(
                alignment: Alignment(
                  -1 + (selectedIndex * 2 / 3),
                  0,
                ),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Four selectable boxes
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Center(
                        child:Text('Profile')
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

