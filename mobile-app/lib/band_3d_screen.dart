import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';

enum BandViewMode {
  split,
  docked,
  sensors,
  band,
}

class Band3dScreen extends StatefulWidget {
  const Band3dScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<Band3dScreen> createState() => _Band3dScreenState();
}

class _Band3dScreenState extends State<Band3dScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _dockController;
  late final AnimationController _pulseController;

  BandViewMode _viewMode = BandViewMode.split;
  bool _isAutoSpin = true;
  bool _isStudioLight = false;

  double _rotX = 0.28;
  double _rotY = -0.25;
  double _zoom = 1.0;
  double _podFlip = 0.0;
  double _sceneOffsetX = 0.0;

  // Target values for smooth animated camera movement
  double _targetRotX = 0.28;
  double _targetRotY = -0.25;
  double _targetZoom = 1.0;
  double _targetPodFlip = 0.0;
  double _targetSceneOffsetX = 0.0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..addListener(() {
        if (_isAutoSpin && mounted) {
          setState(() {
            _targetRotY += 0.007;
            _rotY += (_targetRotY - _rotY) * 0.12;
            _rotX += (_targetRotX - _rotX) * 0.12;
            _zoom += (_targetZoom - _zoom) * 0.12;
            _podFlip += (_targetPodFlip - _podFlip) * 0.12;
            _sceneOffsetX += (_targetSceneOffsetX - _sceneOffsetX) * 0.12;
          });
        }
      });
    _spinController.repeat();

    _dockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1.0, // 1.0 = Detached (Split), 0.0 = Docked
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _dockController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setViewMode(BandViewMode mode) {
    setState(() {
      _viewMode = mode;
      _isAutoSpin = false;

      switch (mode) {
        case BandViewMode.split:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.28;
          _targetRotY = -0.25;
          _targetZoom = 1.0;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.docked:
          _dockController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.30;
          _targetRotY = -0.28;
          _targetZoom = 1.15;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.sensors:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _targetRotX = -0.22;
          _targetRotY = 0.32;
          _targetZoom = 1.35;
          _targetPodFlip = 1.0; // Show underside with green LEDs
          _targetSceneOffsetX = -55.0;
          break;
        case BandViewMode.band:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.32;
          _targetRotY = -0.30;
          _targetZoom = 1.20;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 50.0;
          break;
      }
    });
  }

  void _toggleDock() {
    if (_dockController.value > 0.5) {
      _setViewMode(BandViewMode.docked);
    } else {
      _setViewMode(BandViewMode.split);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !_isStudioLight;
    final bgColor = isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF131A29) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return ListenableBuilder(
      listenable: TelemetryService.instance,
      builder: (context, _) {
        final snapshot = TelemetryService.instance.snapshot;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0B101D) : Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: forest.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: forest.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.view_in_ar_rounded,
                      color: forest, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utano Vital Band 3D',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'AU-001 • Removable Pod & Washable Band',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: _isStudioLight ? 'Starlink Dark HUD' : 'Studio White',
                icon: Icon(
                  _isStudioLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: textColor,
                ),
                onPressed: () => setState(() => _isStudioLight = !_isStudioLight),
              ),
              IconButton(
                tooltip: _isAutoSpin ? 'Pause Rotation' : 'Auto Turntable',
                icon: Icon(
                  _isAutoSpin ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  color: _isAutoSpin ? forest : textColor,
                ),
                onPressed: () {
                  setState(() {
                    _isAutoSpin = !_isAutoSpin;
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 3D Viewport Stage Card
              Container(
                height: 380,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF05080E) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Interactive Gesture 3D Canvas
                      Positioned.fill(
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _isAutoSpin = false;
                              _targetRotY += details.delta.dx * 0.009;
                              _targetRotX -= details.delta.dy * 0.009;
                              _targetRotX = _targetRotX.clamp(-1.45, 1.45);
                              _rotX = _targetRotX;
                              _rotY = _targetRotY;
                            });
                          },
                          onScaleUpdate: (details) {
                            if (details.scale != 1.0) {
                              setState(() {
                                _isAutoSpin = false;
                                _targetZoom = (_targetZoom * details.scale).clamp(0.65, 2.2);
                                _zoom = _targetZoom;
                              });
                            }
                          },
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _dockController,
                              _pulseController,
                            ]),
                            builder: (context, _) {
                              return CustomPaint(
                                painter: UtanoBand3dPainter(
                                  rotX: _rotX,
                                  rotY: _rotY,
                                  zoom: _zoom,
                                  detach: _dockController.value,
                                  podFlip: _podFlip,
                                  sceneOffsetX: _sceneOffsetX,
                                  pulse: _pulseController.value,
                                  isStudioLight: _isStudioLight,
                                  isCritical: snapshot.isCritical,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Top HUD Pill: Status & Battery
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white)
                                    .withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: forest.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: forest,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _dockController.value > 0.5
                                        ? 'Pod Detached (Washable)'
                                        : 'Pod Docked (Monitoring)',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white)
                                    .withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.battery_5_bar_rounded,
                                      color: forest, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${snapshot.batteryPercentage}%',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Floating Control: Dock / Detach Action
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white)
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '360° Drag • Pinch Zoom',
                                style: TextStyle(
                                  color: subColor,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _toggleDock,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                foregroundColor: forest,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: forest.withValues(alpha: 0.5),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                              icon: Icon(
                                _dockController.value > 0.5
                                    ? Icons.system_update_alt_rounded
                                    : Icons.open_in_full_rounded,
                                size: 16,
                              ),
                              label: Text(
                                _dockController.value > 0.5
                                    ? 'Snap Pod In'
                                    : 'Pop Pod Out',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // View Angle Presets Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPresetChip(
                      label: '1. Removable Pod',
                      icon: Icons.splitscreen_rounded,
                      isActive: _viewMode == BandViewMode.split,
                      onTap: () => _setViewMode(BandViewMode.split),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: '2. Secure Fit (Docked)',
                      icon: Icons.check_circle_outline_rounded,
                      isActive: _viewMode == BandViewMode.docked,
                      onTap: () => _setViewMode(BandViewMode.docked),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: '3. Green Optical Sensors',
                      icon: Icons.sensors_rounded,
                      isActive: _viewMode == BandViewMode.sensors,
                      onTap: () => _setViewMode(BandViewMode.sensors),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: '4. Washable Band',
                      icon: Icons.local_laundry_service_outlined,
                      isActive: _viewMode == BandViewMode.band,
                      onTap: () => _setViewMode(BandViewMode.band),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Hardware Architecture & Components Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hardware_rounded,
                            color: forest, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Hardware Anatomy & Wearable Design',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureRow(
                      title: 'Removable Electronics Pod',
                      desc:
                          'Screenless matte-black stadium pebble. Houses ESP32 dual-core MCU, 1000mAh LiPo battery, and emergency SOS hardware interrupter.',
                      badge: 'Easy Wash',
                      badgeColor: Colors.blue,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 20),
                    _buildFeatureRow(
                      title: 'Advanced Optical Biosensors',
                      desc:
                          'Underside optical window with dual 525nm green LEDs (MAX30102) for continuous Heart Rate and SpO2 photoplethysmography + 4 gold contact pads.',
                      badge: 'Dual Green PPG',
                      badgeColor: forest,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 20),
                    _buildFeatureRow(
                      title: 'Washable Fabric Strap & Dock',
                      desc:
                          'Breathable woven neoprene strap with reinforced top/bottom stitching, front Velcro flap, and quick-snap retention cradle with 3 gold pogo pins.',
                      badge: 'Secure Fit',
                      badgeColor: const Color(0xFFF59E0B),
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Live Telemetry Link Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: forest.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: forest.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_sync_rounded,
                          color: forest, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HiveMQ Public Cloud Uplink',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'broker.hivemq.com:1883 • utano/AU-001/telemetry',
                            style: TextStyle(
                              color: subColor,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: forest.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: forest,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildPresetChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? forest
              : (isDark ? const Color(0xFF131A29) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? forest
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: forest.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required Color textColor,
    required Color subColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  color: subColor,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==============================================================================
// 3D CUSTOM PAINTER: Washable Band + Snap-In Cradle + Removable Pod (Exact 1:1)
// ==============================================================================
class UtanoBand3dPainter extends CustomPainter {
  UtanoBand3dPainter({
    required this.rotX,
    required this.rotY,
    required this.zoom,
    required this.detach,
    required this.podFlip,
    required this.sceneOffsetX,
    required this.pulse,
    required this.isStudioLight,
    required this.isCritical,
  });

  final double rotX;
  final double rotY;
  final double zoom;
  final double detach;
  final double podFlip;
  final double sceneOffsetX;
  final double pulse;
  final bool isStudioLight;
  final bool isCritical;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + sceneOffsetX;
    final cy = size.height / 2 + 10;

    // Draw Ground Contact Shadow
    _drawGroundShadow(canvas, cx, cy);

    // List of 3D draw commands to be depth-sorted
    final commands = <_DrawCommand>[];

    // Band Group offset (shifts slightly left when pod is detached)
    final bandShiftX = -45.0 * detach;

    // 1. Fabric Strap Oval Segments
    _generateStrapSegments(commands, cx + bandShiftX, cy);

    // 2. Plastic Strap Buckle (Rear-right)
    _generateStrapBuckle(commands, cx + bandShiftX, cy);

    // 3. Snap-In Cradle Dock (Front of band)
    _generateCradleDock(commands, cx + bandShiftX, cy);

    // 4. Removable Pod (Interpolates between docked and detached)
    final podX = cx + bandShiftX + detach * 115.0;
    final podY = cy - detach * 8.0;
    final podZ = -detach * 20.0;
    _generateRemovablePod(commands, podX, podY, podZ);

    // Sort by depth (back to front: largest depth drawn first)
    commands.sort((a, b) => b.depth.compareTo(a.depth));

    // Execute draw commands
    for (final cmd in commands) {
      cmd.draw(canvas);
    }
  }

  void _drawGroundShadow(Canvas canvas, double cx, double cy) {
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: isStudioLight ? 0.35 : 0.55),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy + 115), radius: 140 * zoom),
      );

    canvas.save();
    canvas.translate(cx, cy + 115);
    canvas.scale(1.0, 0.32);
    canvas.drawCircle(Offset.zero, 140 * zoom, shadowPaint);
    canvas.restore();
  }

  // Project (x, y, z) into 2D Screen Space
  _Pt3 _project(double x, double y, double z, double originX, double originY) {
    // Rotate Y
    final cosY = math.cos(rotY), sinY = math.sin(rotY);
    final x1 = x * cosY + z * sinY;
    final z1 = -x * sinY + z * cosY;

    // Rotate X
    final cosX = math.cos(rotX), sinX = math.sin(rotX);
    final y2 = y * cosX - z1 * sinX;
    final z2 = y * sinX + z1 * cosX;

    const cameraDist = 480.0;
    final scale = (cameraDist / (cameraDist + z2)) * zoom;

    return _Pt3(
      originX + x1 * scale,
      originY + y2 * scale,
      z2,
      scale,
    );
  }

  // 1. Washable Woven Fabric Strap
  void _generateStrapSegments(List<_DrawCommand> list, double ox, double oy) {
    const segments = 36;
    const rx = 100.0;
    const rz = 65.0;
    const strapHeight = 44.0;

    for (int i = 0; i < segments; i++) {
      final t1 = (i / segments) * math.pi * 2;
      final t2 = ((i + 1) / segments) * math.pi * 2;

      final x1 = rx * math.cos(t1), z1 = rz * math.sin(t1);
      final x2 = rx * math.cos(t2), z2 = rz * math.sin(t2);

      final p1Top = _project(x1, -strapHeight / 2, z1, ox, oy);
      final p2Top = _project(x2, -strapHeight / 2, z2, ox, oy);
      final p2Btm = _project(x2, strapHeight / 2, z2, ox, oy);
      final p1Btm = _project(x1, strapHeight / 2, z1, ox, oy);

      final avgZ = (p1Top.z + p2Top.z + p2Btm.z + p1Btm.z) / 4;
      final normalZ = math.sin((t1 + t2) / 2);

      // Shading calculation for dark fabric
      final shade = (24 + normalZ * 18).clamp(14, 46).toInt();
      final color = Color.fromARGB(255, shade, shade + 2, shade + 5);

      // Check if this segment falls on front-left Velcro patch (t between 1.6 and 2.5 rad)
      final isVelcro = t1 > 1.4 && t2 < 2.7;

      list.add(
        _DrawCommand(
          depth: avgZ,
          draw: (canvas) {
            final path = Path()
              ..moveTo(p1Top.x, p1Top.y)
              ..lineTo(p2Top.x, p2Top.y)
              ..lineTo(p2Btm.x, p2Btm.y)
              ..lineTo(p1Btm.x, p1Btm.y)
              ..close();

            canvas.drawPath(
              path,
              Paint()..color = isVelcro ? const Color(0xFF111419) : color,
            );

            // Stitching lines on top and bottom borders
            final stitchPaint = Paint()
              ..color = const Color(0xFF475569).withValues(alpha: 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0;

            canvas.drawLine(
              Offset(p1Top.x, p1Top.y),
              Offset(p2Top.x, p2Top.y),
              stitchPaint,
            );
            canvas.drawLine(
              Offset(p1Btm.x, p1Btm.y),
              Offset(p2Btm.x, p2Btm.y),
              stitchPaint,
            );

            // Velcro boundary border highlight
            if (isVelcro) {
              canvas.drawPath(
                path,
                Paint()
                  ..color = const Color(0xFF334155).withValues(alpha: 0.4)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.5,
              );
            }
          },
        ),
      );
    }
  }

  // 2. Plastic Strap Buckle
  void _generateStrapBuckle(List<_DrawCommand> list, double ox, double oy) {
    const buckleTheta = -0.65;
    const rx = 100.0, rz = 65.0;
    final bx = rx * math.cos(buckleTheta);
    final bz = rz * math.sin(buckleTheta);

    final pTop = _project(bx, -26, bz, ox, oy);
    final pBtm = _project(bx, 26, bz, ox, oy);

    list.add(
      _DrawCommand(
        depth: (pTop.z + pBtm.z) / 2,
        draw: (canvas) {
          final rect = Rect.fromCenter(
            center: Offset((pTop.x + pBtm.x) / 2, (pTop.y + pBtm.y) / 2),
            width: 14 * pTop.scale,
            height: 52 * pTop.scale,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(3)),
            Paint()..color = const Color(0xFF1E242E),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(3)),
            Paint()
              ..color = const Color(0xFF475569)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 * pTop.scale,
          );
        },
      ),
    );
  }

  // 3. Snap-In Cradle Dock (with 3 vertical gold pins)
  void _generateCradleDock(List<_DrawCommand> list, double ox, double oy) {
    const cradleZ = 67.0; // Front of the band
    final cCenter = _project(0, 0, cradleZ, ox, oy);

    list.add(
      _DrawCommand(
        depth: cCenter.z - 2.0,
        draw: (canvas) {
          final s = cCenter.scale;
          // Outer Cradle Rim (Stadium / Pill shape)
          final outerRect = Rect.fromCenter(
            center: Offset(cCenter.x, cCenter.y),
            width: 88 * s,
            height: 52 * s,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(26 * s)),
            Paint()..color = const Color(0xFF141820),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(26 * s)),
            Paint()
              ..color = const Color(0xFF334155)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0 * s,
          );

          // Inner Dock Cavity
          final innerRect = Rect.fromCenter(
            center: Offset(cCenter.x, cCenter.y),
            width: 72 * s,
            height: 38 * s,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(innerRect, Radius.circular(19 * s)),
            Paint()..color = const Color(0xFF090C10),
          );

          // 3 VERTICAL GOLD PINS on the right inner wall
          final pinX = cCenter.x + 28 * s;
          final pinYs = [
            cCenter.y - 8 * s,
            cCenter.y,
            cCenter.y + 8 * s,
          ];

          for (final py in pinYs) {
            canvas.drawCircle(
              Offset(pinX, py),
              2.5 * s,
              Paint()..color = const Color(0xFFFACC15),
            );
            canvas.drawCircle(
              Offset(pinX, py),
              2.5 * s,
              Paint()
                ..color = const Color(0xFF854D0E)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.8 * s,
            );
          }
        },
      ),
    );
  }

  // 4. Removable Pod (Front with Power Button ⏻ or Back with Dual Green LEDs & 4 Gold Pads)
  void _generateRemovablePod(
      List<_DrawCommand> list, double ox, double oy, double oz) {
    // Compute effective pod rotation including flip
    final podCenter = _project(0, 0, oz, ox, oy);

    // Is the back (sensor side) visible?
    final cosView = math.cos(rotY + podFlip * math.pi);
    final isBackVisible = cosView < 0 || podFlip > 0.5;

    list.add(
      _DrawCommand(
        depth: podCenter.z - 8.0,
        draw: (canvas) {
          final s = podCenter.scale;
          final podRect = Rect.fromCenter(
            center: Offset(podCenter.x, podCenter.y),
            width: 78 * s,
            height: 44 * s,
          );

          // Outer Stadium Pebble Body (Matte Black)
          canvas.drawRRect(
            RRect.fromRectAndRadius(podRect, Radius.circular(22 * s)),
            Paint()..color = const Color(0xFF1E222A),
          );

          // Subtle specular highlight gradient across front
          final highlightPaint = Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
              ],
            ).createShader(podRect);

          canvas.drawRRect(
            RRect.fromRectAndRadius(podRect, Radius.circular(22 * s)),
            highlightPaint,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(podRect, Radius.circular(22 * s)),
            Paint()
              ..color = const Color(0xFF334155).withValues(alpha: 0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6 * s,
          );

          if (!isBackVisible) {
            // FRONT FACE: Flush Right-Side Power Button (⏻)
            final btnX = podCenter.x + 22 * s;
            final btnY = podCenter.y;
            final btnRadius = 8.5 * s;

            // Recessed groove around button
            canvas.drawCircle(
              Offset(btnX, btnY),
              btnRadius + 1.5 * s,
              Paint()..color = const Color(0xFF0C0E12),
            );

            // Button face
            canvas.drawCircle(
              Offset(btnX, btnY),
              btnRadius,
              Paint()..color = const Color(0xFF232832),
            );

            // Crisp White Power Symbol (⏻)
            final pSymPaint = Paint()
              ..color = isCritical ? const Color(0xFFEF4444) : Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4 * s
              ..strokeCap = StrokeCap.round;

            // Arc
            canvas.drawArc(
              Rect.fromCircle(center: Offset(btnX, btnY + 0.5 * s), radius: 4.5 * s),
              -math.pi * 0.35,
              math.pi * 1.7,
              false,
              pSymPaint,
            );
            // Vertical bar
            canvas.drawLine(
              Offset(btnX, btnY - 5.5 * s),
              Offset(btnX, btnY - 0.5 * s),
              pSymPaint,
            );
          } else {
            // BACK FACE: Optical Sensor Cavity + Dual Green LEDs + 4 Gold Pads
            final sensorRect = Rect.fromCenter(
              center: Offset(podCenter.x, podCenter.y),
              width: 32 * s,
              height: 22 * s,
            );

            // Recessed dark window
            canvas.drawRRect(
              RRect.fromRectAndRadius(sensorRect, Radius.circular(4 * s)),
              Paint()..color = const Color(0xFF06090D),
            );

            // DUAL GLOWING GREEN OPTICAL LEDS
            final led1X = podCenter.x - 6 * s;
            final led2X = podCenter.x + 6 * s;
            final ledY = podCenter.y;

            final greenGlow = Paint()
              ..color = const Color(0xFF10B981).withValues(alpha: 0.45 + pulse * 0.45)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

            canvas.drawCircle(Offset(led1X, ledY), 6 * s, greenGlow);
            canvas.drawCircle(Offset(led2X, ledY), 6 * s, greenGlow);

            // White-hot emitter die cores
            final corePaint = Paint()..color = const Color(0xFFE6FFFA);
            canvas.drawCircle(Offset(led1X, ledY), 2.2 * s, corePaint);
            canvas.drawCircle(Offset(led2X, ledY), 2.2 * s, corePaint);

            // FOUR GOLD PADS (2 Left, 2 Right)
            final goldPadPaint = Paint()..color = const Color(0xFFFACC15);
            final padCoords = [
              Offset(podCenter.x - 24 * s, podCenter.y - 5 * s),
              Offset(podCenter.x - 24 * s, podCenter.y + 5 * s),
              Offset(podCenter.x + 24 * s, podCenter.y - 5 * s),
              Offset(podCenter.x + 24 * s, podCenter.y + 5 * s),
            ];

            for (final pt in padCoords) {
              canvas.drawCircle(pt, 2.2 * s, goldPadPaint);
            }
          }
        },
      ),
    );
  }

  @override
  bool shouldRepaint(covariant UtanoBand3dPainter oldDelegate) => true;
}

class _Pt3 {
  _Pt3(this.x, this.y, this.z, this.scale);
  final double x;
  final double y;
  final double z;
  final double scale;
}

class _DrawCommand {
  _DrawCommand({required this.depth, required this.draw});
  final double depth;
  final void Function(Canvas canvas) draw;
}
