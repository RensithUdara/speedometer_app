import 'package:flutter/material.dart';
import 'package:speedometer/meter_painter.dart';

class Speedometer extends StatefulWidget {
  const Speedometer({super.key});

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  bool isPressing = false;
  double maxSpeed = 0;
  double totalSpeed = 0;
  int speedCount = 0;
  final double speedLimit = 80; // Set your speed limit here

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    animation = Tween<double>(begin: 0, end: 100).animate(controller)
      ..addListener(() {
        if (controller.isAnimating) {
          double currentSpeed = animation.value;
          setState(() {
            totalSpeed += currentSpeed;
            speedCount++;
            if (currentSpeed > maxSpeed) {
              maxSpeed = currentSpeed;
            }
          });
        }
      });

    super.initState();
  }

  double get averageSpeed => speedCount > 0 ? totalSpeed / speedCount : 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 400,
                width: MediaQuery.sizeOf(context).width,
                child: AnimatedBuilder(
                  builder: (context, child) {
                    return CustomPaint(
                      painter: MeterPainter(percentage: animation.value),
                    );
                  },
                  animation: controller,
                ),
              ),
              if (animation.value > speedLimit)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Speed Limit Exceeded!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    isPressing = true;
                  });
                  controller.forward();
                },
                onLongPressEnd: (details) async {
                  setState(() {
                    isPressing = false;
                  });
                  await Future.delayed(
                    const Duration(milliseconds: 400),
                  );
                  controller.animateBack(0,
                      duration: const Duration(seconds: 12));
                },
                child: Container(
                  height: 55,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isPressing ? Colors.green[200] : Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Accelerator',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Average Speed: ${averageSpeed.toStringAsFixed(1)} KM/H',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Max Speed: ${maxSpeed.toStringAsFixed(1)} KM/H',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
