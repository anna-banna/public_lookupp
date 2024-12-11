import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeaconPage extends StatefulWidget {
  const BeaconPage({super.key});

  @override
  State<BeaconPage> createState() => _BeaconPageState();
}

class _BeaconPageState extends State<BeaconPage>
    with SingleTickerProviderStateMixin {
  bool isBeaconActive = false;
  DateTime? startTime;
  Timer? timer;
  Duration duration = Duration.zero;
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _animationController.repeat();
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void toggleBeacon() async {
    if (!isBeaconActive) {
      setState(() {
        isBeaconActive = true;
        startTime = DateTime.now();
        duration = Duration.zero;
      });
      startTimer();
    } else {
      stopBeacon();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        duration = DateTime.now().difference(startTime!);
      });
    });
  }

  void stopBeacon() async {
    timer?.cancel();
    final points = (duration.inSeconds * .08).round();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.update({'currentPoints': FieldValue.increment(points)});
      await userDoc.update({'totalPoints': FieldValue.increment(points)});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You earned $points ${points == 1 ? 'point' : 'points'}!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      isBeaconActive = false;
      startTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a People Time Zone',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (_, __) {
                return CustomPaint(
                  painter: RipplePainter(
                    _animationController.value,
                    isActive: isBeaconActive,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isBeaconActive ? Colors.blue[700] : Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                    ),
                    onPressed: toggleBeacon,
                    child: Text(
                      isBeaconActive ? 'Stop Beacon' : 'Start Beacon',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (isBeaconActive)
              Text(
                _formatDuration(duration),
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              )
            else
              Text(
                'Start focusing to earn points',
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final bool isActive;

  RipplePainter(this.progress, {required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double radius = (size.width / 2) * progress * 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) => true;
}
