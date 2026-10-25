import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';

/// Authentic hospital cardiac oscilloscope monitor with sweep cursor.
class EcgOscilloscope extends StatefulWidget {
  const EcgOscilloscope({
    required this.bpm,
    this.color = const Color(0xFF00FF66),
    this.height = 70,
    super.key,
  });

  final int bpm;
  final Color color;
  final double height;

  @override
  State<EcgOscilloscope> createState() => _EcgOscilloscopeState();
}

class _EcgOscilloscopeState extends State<EcgOscilloscope>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1814),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E382B)),
      ),
      child: AnimatedBuilder(
        animation: _sweepController,
        builder: (context, _) {
          return CustomPaint(
            painter: _EcgPainter(
              progress: _sweepController.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  const _EcgPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle medical oscilloscope grid
    final gridPaint = Paint()
      ..color = const Color(0xFF162D22)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Generate repeating ECG P-Q-R-S-T cardiac waveform
    final path = Path();
    final midY = size.height / 2;
    final sweepX = size.width * progress;

    double computeEcgY(double x) {
      final cycleWidth = size.width / 3.0;
      final t = (x % cycleWidth) / cycleWidth;

      if (t > 0.15 && t < 0.22) {
        // P wave
        return midY - (sin((t - 0.15) / 0.07 * pi) * 6);
      } else if (t >= 0.25 && t < 0.28) {
        // Q dip
        return midY + 4;
      } else if (t >= 0.28 && t < 0.32) {
        // Sharp high R spike
        final spikeT = (t - 0.28) / 0.04;
        return midY - (sin(spikeT * pi) * (size.height * 0.42));
      } else if (t >= 0.32 && t < 0.36) {
        // S dip
        return midY + 8;
      } else if (t >= 0.42 && t < 0.52) {
        // T wave
        return midY - (sin((t - 0.42) / 0.10 * pi) * 9);
      }
      return midY;
    }

    bool first = true;
    for (double x = 0; x < size.width; x += 1.5) {
      final y = computeEcgY(x);
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw main waveform
    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, wavePaint);

    // Glowing phosphor sweep cursor
    final cursorY = computeEcgY(sweepX);
    final cursorPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(sweepX, cursorY), 3.0, cursorPaint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(sweepX, cursorY), 7.0, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Smooth counting numerical animation widget.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.value,
    this.unit = '',
    this.style,
    this.unitStyle,
    super.key,
  });

  final double value;
  final String unit;
  final TextStyle? style;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(formatted, style: style),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(unit, style: unitStyle),
            ],
          ],
        );
      },
    );
  }
}

/// Dynamic Pulsing Heartbeat icon synced to real BPM.
class PulsingHeartIcon extends StatefulWidget {
  const PulsingHeartIcon({
    required this.bpm,
    this.color = coral,
    this.size = 20,
    super.key,
  });

  final int bpm;
  final Color color;
  final double size;

  @override
  State<PulsingHeartIcon> createState() => _PulsingHeartIconState();
}

class _PulsingHeartIconState extends State<PulsingHeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _calculateDuration(widget.bpm),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.32).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant PulsingHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _controller.duration = _calculateDuration(widget.bpm);
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  Duration _calculateDuration(int bpm) {
    final safeBpm = bpm.clamp(40, 200);
    return Duration(milliseconds: (30000 / safeBpm).round());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        Icons.favorite_rounded,
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}

/// Blinking/glowing live radar dot indicating active sensor streaming.
class LiveRadarDot extends StatefulWidget {
  const LiveRadarDot({
    this.color = lime,
    this.label = 'LIVE',
    super.key,
  });

  final Color color;
  final String label;

  @override
  State<LiveRadarDot> createState() => _LiveRadarDotState();
}

class _LiveRadarDotState extends State<LiveRadarDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 14 + (progress * 10),
                  height: 14 + (progress * 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: (1.0 - progress) * 0.45),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Map GPS pin with expanding radar ripple rings.
class RadarMapPin extends StatefulWidget {
  const RadarMapPin({
    this.compact = false,
    this.color = forest,
    super.key,
  });

  final bool compact;
  final Color color;

  @override
  State<RadarMapPin> createState() => _RadarMapPinState();
}

class _RadarMapPinState extends State<RadarMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 28.0 : 36.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final rippleSize = size + (progress * 38);
        final opacity = (1.0 - progress).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: rippleSize,
              height: rippleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: opacity * 0.6),
                  width: 2.0,
                ),
                color: widget.color.withValues(alpha: opacity * 0.15),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: widget.compact ? 13 : 16,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Heads-Up Notification Banner when vital spikes occur with 2-minute countdown timer.
class VitalSpikeNotificationBanner extends StatelessWidget {
  const VitalSpikeNotificationBanner({
    required this.snapshot,
    super.key,
  });

  final TelemetrySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.isNotificationActive) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEEC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: coral, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38E77962),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: coral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACUTE VITAL SPIKE DETECTED',
                      style: TextStyle(
                        color: coral,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Stationary patient · Threshold breached',
                      style: TextStyle(color: mutedInk, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              // Live 2-minute countdown badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: coral,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      snapshot.formattedCountdown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pulse: ${snapshot.heartRate} BPM (Tachycardia) · SpO₂: ${snapshot.spo2}% (Hypoxemia)\nAutomated emergency call will dial relative if unacknowledged.',
            style: const TextStyle(
              color: ink,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => TelemetryService.instance.acknowledgeNotification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forest,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('I am checking on patient', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => TelemetryService.instance.fastForwardCountdown(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: coral,
                  elevation: 0,
                  side: const BorderSide(color: coral),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                ),
                child: const Text('⏩ Test Call Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Smart Motion Filter badge: Displays when spike is caused by physical exercise.
class ActivityOptimizationCard extends StatelessWidget {
  const ActivityOptimizationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF5EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3C78B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFFE89635), size: 18),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART ACTIVITY FILTER ACTIVE',
                  style: TextStyle(
                    color: Color(0xFFC7781F),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Elevated heart rate (118 BPM) correlated with gait motion (5.6 km/h). Safe aerobic threshold recognized — emergency relative call suppressed.',
                  style: TextStyle(
                    color: ink,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen Automated Emergency Call Dispatch Screen.
class AutomatedEmergencyCallDialog extends StatefulWidget {
  const AutomatedEmergencyCallDialog({super.key});

  @override
  State<AutomatedEmergencyCallDialog> createState() => _AutomatedEmergencyCallDialogState();
}

class _AutomatedEmergencyCallDialogState extends State<AutomatedEmergencyCallDialog>
    with SingleTickerProviderStateMixin {
  int _callSeconds = 6;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _callSeconds++);
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = _callSeconds ~/ 60;
    final secs = _callSeconds % 60;
    final durationStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF131A18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: coral, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_in_talk_rounded, color: coral, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AUTOMATED EMERGENCY DISPATCH',
                  style: TextStyle(
                    color: coral.withValues(alpha: 0.95),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: coral.withValues(alpha: 0.2),
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: coral,
                  ),
                  child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Dr. T. Bandure (Relative/Caregiver)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              '+263 77 123 4567  ·  Cellular Link Active',
              style: TextStyle(color: Color(0xFF98ACA0), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              'CALL TIME: $durationStr',
              style: const TextStyle(
                color: lime,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),
            // Animated Audio Equalizer Bars
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                final rnd = Random(42);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(14, (i) {
                    final base = 8 + (rnd.nextDouble() * 26);
                    final h = base * (0.6 + (_waveController.value * 0.7));
                    return Container(
                      width: 4,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? lime : const Color(0xFF00FF88),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            // Automated Voice Text Box
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2824),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C3C36)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.volume_up_rounded, color: lime, size: 19),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'AUTOMATED VOICE MESSAGE PLAYING:\n"Critical alert: Patient Miriam Bandure had high heart rate (138 BPM) and low SpO₂ (88%) unacknowledged for 2 minutes. Current location: AI Lab, ICT Building. Please attend immediately."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // End Call Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  TelemetryService.instance.endEmergencyCall();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: coral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.call_end_rounded),
                label: const Text(
                  'Confirm Patient Safe & End Call',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Lecturer Presentation Controls Bar.
class LecturerDemoBar extends StatelessWidget {
  const LecturerDemoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TelemetryService.instance,
      builder: (context, _) {
        final current = TelemetryService.instance.scenario;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.science_rounded, size: 15, color: forest),
                  const SizedBox(width: 6),
                  const Text(
                    'ASSESSMENT DEMO CONTROLS',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: mutedInk,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: forest.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Live hardware simulation',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: forest,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DemoButton(
                      label: 'Normal',
                      sub: '72 bpm',
                      icon: Icons.favorite_border_rounded,
                      activeColor: forest,
                      isActive: current == DemoScenario.normal,
                      onTap: () => TelemetryService.instance.setScenario(DemoScenario.normal),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _DemoButton(
                      label: 'Exercise',
                      sub: '118 bpm (Filtered)',
                      icon: Icons.directions_run_rounded,
                      activeColor: const Color(0xFFE89635),
                      isActive: current == DemoScenario.exercise,
                      onTap: () => TelemetryService.instance.triggerExerciseSpike(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _DemoButton(
                      label: 'Spike (2m Call)',
                      sub: '138 bpm / 88%',
                      icon: Icons.crisis_alert_rounded,
                      activeColor: coral,
                      isActive: current == DemoScenario.emergency,
                      onTap: () => TelemetryService.instance.triggerStationarySpike(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.sub,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String sub;
  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : canvas,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : line,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isActive ? Colors.white : ink,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white.withValues(alpha: 0.9) : mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
