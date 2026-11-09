import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';

enum BandViewMode {
  worn,     // 1. How It Looks (Docked in Wide Upper-Arm Sleeve)
  split,    // 2. Removable Pod (Detached for Washing)
  sensors,  // 3. Sensor Area Sits Against Skin (Green LEDs)
  exploded, // 4. What's Inside the Pod (Exploded CAD Architecture)
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
  late final AnimationController _explodeController;
  late final AnimationController _pulseController;

  BandViewMode _viewMode = BandViewMode.worn;
  bool _isAutoSpin = true;
  bool _isStudioLight = false;

  double _rotX = 0.26;
  double _rotY = -0.22;
  double _zoom = 1.05;
  double _podFlip = 0.0;
  double _sceneOffsetX = 0.0;

  // Target values for smooth animated camera movement
  double _targetRotX = 0.26;
  double _targetRotY = -0.22;
  double _targetZoom = 1.05;
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
            _targetRotY += 0.0065;
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
      value: 0.0, // 0.0 = Docked (Worn), 1.0 = Detached (Split)
    );

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 0.0, // 0.0 = Assembled, 1.0 = Exploded Internal Layers
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
    _explodeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setViewMode(BandViewMode mode) {
    setState(() {
      _viewMode = mode;
      _isAutoSpin = false;

      switch (mode) {
        case BandViewMode.worn:
          _dockController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.26;
          _targetRotY = -0.22;
          _targetZoom = 1.12;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.split:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.28;
          _targetRotY = -0.26;
          _targetZoom = 0.98;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.sensors:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = -0.20;
          _targetRotY = 0.35;
          _targetZoom = 1.35;
          _targetPodFlip = 1.0; // Show underside with green LEDs
          _targetSceneOffsetX = -55.0;
          break;
        case BandViewMode.exploded:
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.38;
          _targetRotY = -0.45;
          _targetZoom = 0.92;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = -45.0;
          break;
      }
    });
  }

  void _toggleDock() {
    if (_dockController.value > 0.5) {
      _setViewMode(BandViewMode.worn);
    } else {
      _setViewMode(BandViewMode.split);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !_isStudioLight;
    final bgColor = isDark ? const Color(0xFF070B14) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF101726) : Colors.white;
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
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.view_in_ar_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utano Upper-Arm Band 3D',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Comfortable, Smart Upper-Arm Monitor',
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
                tooltip: _isAutoSpin ? 'Pause Turntable' : 'Auto Turntable',
                icon: Icon(
                  _isAutoSpin ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  color: _isAutoSpin ? const Color(0xFF38BDF8) : textColor,
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
                    color: isDark ? const Color(0xFF04070E) : const Color(0xFFE2E8F0),
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
                                _explodeController,
                                _pulseController,
                              ]),
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: UtanoUpperArmBand3dPainter(
                                    rotX: _rotX,
                                    rotY: _rotY,
                                    zoom: _zoom,
                                    detach: _dockController.value,
                                    explode: _explodeController.value,
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

                        // Top HUD Pill: Status & Active LED
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
                                      .withValues(alpha: 0.90),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF38BDF8),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _explodeController.value > 0.5
                                          ? 'What\'s Inside the Pod (CAD)'
                                          : (_dockController.value > 0.5
                                              ? 'Removable Pod (Water-Resistant)'
                                              : 'Upper-Arm Sleeve (Worn)'),
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
                                      .withValues(alpha: 0.90),
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
                                  foregroundColor: const Color(0xFF38BDF8),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
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
                                      ? 'Insert Into Sleeve'
                                      : 'Remove Pod',
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

                // View Angle Presets Row (Matching the 4 sub-images from the user's poster)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPresetChip(
                        label: '1. How It Looks (Worn)',
                        icon: Icons.check_circle_outline_rounded,
                        isActive: _viewMode == BandViewMode.worn,
                        onTap: () => _setViewMode(BandViewMode.worn),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildPresetChip(
                        label: '2. Removable Pod',
                        icon: Icons.splitscreen_rounded,
                        isActive: _viewMode == BandViewMode.split,
                        onTap: () => _setViewMode(BandViewMode.split),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildPresetChip(
                        label: '3. Skin Sensor Area',
                        icon: Icons.sensors_rounded,
                        isActive: _viewMode == BandViewMode.sensors,
                        onTap: () => _setViewMode(BandViewMode.sensors),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildPresetChip(
                        label: '4. What\'s Inside (CAD)',
                        icon: Icons.layers_outlined,
                        isActive: _viewMode == BandViewMode.exploded,
                        onTap: () => _setViewMode(BandViewMode.exploded),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Key Features Checklist (From User Reference Poster)
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
                          const Icon(Icons.health_and_safety_rounded,
                              color: Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Real-Time Health • Upper-Arm Band',
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
                        title: 'Comfortable, Breathable Fabric Sleeve',
                        desc:
                            'Soft, stretchable, washable nylon-spandex sleeve. Snug upper-arm compression fit that stays firmly in place during daily activity.',
                        badge: 'Machine Washable',
                        badgeColor: Colors.blue,
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const Divider(height: 20),
                      _buildFeatureRow(
                        title: 'Removable Water-Resistant Pod',
                        desc:
                            'Matte-black casing with glowing Heart-ECG emblem & blue status bar. Pops out easily before washing the sleeve.',
                        badge: 'IP67 Splash Proof',
                        badgeColor: forest,
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const Divider(height: 20),
                      _buildFeatureRow(
                        title: 'Sensor Area Sits Against Skin',
                        desc:
                            'Direct optical photoplethysmography window with dual 525nm green LEDs & digital temperature probe for medical-grade vitals.',
                        badge: 'Accurate Readings',
                        badgeColor: const Color(0xFF10B981),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const Divider(height: 20),
                      _buildFeatureRow(
                        title: 'What\'s Inside the Pod',
                        desc:
                            'GPS module (NEO-6M), Cellular LTE & Wi-Fi antennas, Main ESP32 PCB controller, 1000mAh battery, and motion sensors.',
                        badge: 'Dual Connectivity',
                        badgeColor: const Color(0xFFF59E0B),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Live Cloud Telemetry Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.wifi_tethering_rounded,
                            color: Color(0xFF38BDF8), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Upper-Arm Vitals Stream',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Heart rate · SpO₂ · Temperature · Motion',
                              style: TextStyle(
                                color: subColor,
                                fontSize: 11,
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
                          'CONNECTED',
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
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF131A29) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF38BDF8)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
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
// 3D CUSTOM PAINTER: Wide Upper-Arm Sleeve + Heart-ECG Pod + Cyan LED Bar + Exploded Layers
// ==============================================================================
class UtanoUpperArmBand3dPainter extends CustomPainter {
  UtanoUpperArmBand3dPainter({
    required this.rotX,
    required this.rotY,
    required this.zoom,
    required this.detach,
    required this.explode,
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
  final double explode;
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

    final commands = <_DrawCommand>[];

    // Band Group offset (shifts slightly left when pod is detached)
    final bandShiftX = -45.0 * detach;

    // 1. Wide Upper-Arm Fabric Compression Sleeve
    _generateUpperArmSleeve(commands, cx + bandShiftX, cy);

    // 2. Sleeve Integrated Docking Pocket/Bezel
    _generateSleeveDock(commands, cx + bandShiftX, cy);

    // 3. Removable Pod (with Heart-ECG emblem, cyan LED bar, green back sensors, and exploded layers)
    final podX = cx + bandShiftX + detach * 115.0;
    final podY = cy - detach * 8.0;
    final podZ = -detach * 20.0;
    _generatePodAndLayers(commands, podX, podY, podZ);

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
        Rect.fromCircle(center: Offset(cx, cy + 120), radius: 145 * zoom),
      );

    canvas.save();
    canvas.translate(cx, cy + 120);
    canvas.scale(1.0, 0.32);
    canvas.drawCircle(Offset.zero, 145 * zoom, shadowPaint);
    canvas.restore();
  }

  _Pt3 _project(double x, double y, double z, double originX, double originY) {
    final cosY = math.cos(rotY), sinY = math.sin(rotY);
    final x1 = x * cosY + z * sinY;
    final z1 = -x * sinY + z * cosY;

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

  // 1. Wide Upper-Arm Compression Sleeve (Nylon-Spandex Woven Fabric)
  void _generateUpperArmSleeve(List<_DrawCommand> list, double ox, double oy) {
    const segments = 40;
    const rx = 105.0; // Upper arm bicep radius
    const rz = 68.0;
    const sleeveHeight = 76.0; // Wide upper-arm sleeve width

    for (int i = 0; i < segments; i++) {
      final t1 = (i / segments) * math.pi * 2;
      final t2 = ((i + 1) / segments) * math.pi * 2;

      final x1 = rx * math.cos(t1), z1 = rz * math.sin(t1);
      final x2 = rx * math.cos(t2), z2 = rz * math.sin(t2);

      final p1Top = _project(x1, -sleeveHeight / 2, z1, ox, oy);
      final p2Top = _project(x2, -sleeveHeight / 2, z2, ox, oy);
      final p2Btm = _project(x2, sleeveHeight / 2, z2, ox, oy);
      final p1Btm = _project(x1, sleeveHeight / 2, z1, ox, oy);

      final avgZ = (p1Top.z + p2Top.z + p2Btm.z + p1Btm.z) / 4;
      final normalZ = math.sin((t1 + t2) / 2);

      // Dark heather fabric shading with woven depth
      final shade = (26 + normalZ * 22).clamp(16, 52).toInt();
      final fabricColor = Color.fromARGB(255, shade, shade + 2, shade + 6);

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

            canvas.drawPath(path, Paint()..color = fabricColor);

            // Woven elastic knit texture lines
            final threadPaint = Paint()
              ..color = const Color(0xFF475569).withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8;

            canvas.drawLine(
              Offset((p1Top.x + p1Btm.x) / 2, (p1Top.y + p1Btm.y) / 2),
              Offset((p2Top.x + p2Btm.x) / 2, (p2Top.y + p2Btm.y) / 2),
              threadPaint,
            );

            // Reinforced ribbed top and bottom border trims (Piping hems)
            final borderPaint = Paint()
              ..color = const Color(0xFF1E293B)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;

            canvas.drawLine(Offset(p1Top.x, p1Top.y), Offset(p2Top.x, p2Top.y), borderPaint);
            canvas.drawLine(Offset(p1Btm.x, p1Btm.y), Offset(p2Btm.x, p2Btm.y), borderPaint);
          },
        ),
      );
    }
  }

  // 2. Sleeve Integrated Docking Bezel
  void _generateSleeveDock(List<_DrawCommand> list, double ox, double oy) {
    const dockZ = 70.0;
    final center = _project(0, 0, dockZ, ox, oy);

    list.add(
      _DrawCommand(
        depth: center.z - 2.0,
        draw: (canvas) {
          final s = center.scale;
          final outerRect = Rect.fromCenter(
            center: Offset(center.x, center.y),
            width: 86 * s,
            height: 56 * s,
          );

          // Outer molded black dock frame
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(22 * s)),
            Paint()..color = const Color(0xFF141922),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(22 * s)),
            Paint()
              ..color = const Color(0xFF334155)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8 * s,
          );

          // Open inner window through which sensors touch the skin
          final innerRect = Rect.fromCenter(
            center: Offset(center.x, center.y),
            width: 68 * s,
            height: 40 * s,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(innerRect, Radius.circular(16 * s)),
            Paint()..color = const Color(0xFF070A0F),
          );
        },
      ),
    );
  }

  // 3. Removable Pod & Exploded Internal Layers
  void _generatePodAndLayers(
      List<_DrawCommand> list, double ox, double oy, double oz) {
    final exp = explode;
    final podCenter = _project(0, 0, oz, ox, oy);

    final cosView = math.cos(rotY + podFlip * math.pi);
    final isBackVisible = cosView < 0 || podFlip > 0.5;

    if (exp < 0.05) {
      // ASSEMBLED POD
      list.add(
        _DrawCommand(
          depth: podCenter.z - 6.0,
          draw: (canvas) {
            _drawPodMesh(canvas, podCenter, isBackVisible);
          },
        ),
      );
    } else {
      // WHAT'S INSIDE THE POD (EXPLODED CAD LAYERS)
      // Layer 1: Top Shell (with Heart-ECG icon and light bar)
      final p1 = _project(0, -65 * exp, oz, ox, oy);
      list.add(
        _DrawCommand(
          depth: p1.z - 12.0,
          draw: (canvas) {
            _drawPodShell(canvas, p1, '1. Water-Resistant Top Shell');
          },
        ),
      );

      // Layer 2: GPS Module & LTE/Wi-Fi Antenna
      final p2 = _project(0, -32 * exp, oz, ox, oy);
      list.add(
        _DrawCommand(
          depth: p2.z - 8.0,
          draw: (canvas) {
            _drawGpsAntennaLayer(canvas, p2);
          },
        ),
      );

      // Layer 3: Main Controller PCB (ESP32)
      final p3 = _project(0, 0, oz, ox, oy);
      list.add(
        _DrawCommand(
          depth: p3.z - 4.0,
          draw: (canvas) {
            _drawMainPcbLayer(canvas, p3);
          },
        ),
      );

      // Layer 4: 1000mAh Battery Pouch
      final p4 = _project(0, 32 * exp, oz, ox, oy);
      list.add(
        _DrawCommand(
          depth: p4.z,
          draw: (canvas) {
            _drawBatteryLayer(canvas, p4);
          },
        ),
      );

      // Layer 5: Biosensor Bay & Optical Window (Green LEDs)
      final p5 = _project(0, 65 * exp, oz, ox, oy);
      list.add(
        _DrawCommand(
          depth: p5.z + 4.0,
          draw: (canvas) {
            _drawSensorLayer(canvas, p5);
          },
        ),
      );
    }
  }

  // Draw Assembled Pod with Heart-ECG Icon and Cyan Status LED Bar
  void _drawPodMesh(Canvas canvas, _Pt3 center, bool isBackVisible) {
    final s = center.scale;
    final rect = Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: 76 * s,
      height: 48 * s,
    );

    // Matte black stadium pebble shell
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(24 * s)),
      Paint()..color = const Color(0xFF161A22),
    );

    // Specular highlight gradient across top curve
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.4),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(24 * s)),
      highlightPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(24 * s)),
      Paint()
        ..color = const Color(0xFF334155).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s,
    );

    if (!isBackVisible) {
      // ======================================================================
      // FRONT FACE: Heart + ECG Vital Wave Emblem + Horizontal Glowing Cyan Bar
      // ======================================================================
      final iconY = center.y - 4 * s;

      // 1. HEART + ECG WAVE MONOGRAM (White/Cyan Glow)
      final heartPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Heart outline path
      final heartPath = Path();
      const hw = 9.0;
      heartPath.moveTo(center.x, iconY + 5.5 * s);
      heartPath.cubicTo(
        center.x - hw * 1.3 * s, iconY - 3 * s,
        center.x - hw * 0.8 * s, iconY - 9 * s,
        center.x, iconY - 3.5 * s,
      );
      heartPath.cubicTo(
        center.x + hw * 0.8 * s, iconY - 9 * s,
        center.x + hw * 1.3 * s, iconY - 3 * s,
        center.x, iconY + 5.5 * s,
      );
      canvas.drawPath(heartPath, heartPaint);

      // ECG Pulse spike passing through heart
      final ecgPath = Path()
        ..moveTo(center.x - 12 * s, iconY + 0.5 * s)
        ..lineTo(center.x - 4 * s, iconY + 0.5 * s)
        ..lineTo(center.x - 2 * s, iconY - 4 * s)
        ..lineTo(center.x + 1 * s, iconY + 4 * s)
        ..lineTo(center.x + 3 * s, iconY - 1 * s)
        ..lineTo(center.x + 5 * s, iconY + 0.5 * s)
        ..lineTo(center.x + 12 * s, iconY + 0.5 * s);

      final ecgPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(ecgPath, ecgPaint);

      // 2. HORIZONTAL GLOWING CYAN STATUS LED BAR (Below Heart Icon)
      final barY = center.y + 13 * s;
      final barW = 24 * s;
      final barH = 3.5 * s;
      final barRect = Rect.fromCenter(
        center: Offset(center.x, barY),
        width: barW,
        height: barH,
      );

      final ledColor = isCritical
          ? const Color(0xFFEF4444)
          : const Color(0xFF38BDF8);

      // Glow halo
      final glowPaint = Paint()
        ..color = ledColor.withValues(alpha: 0.6 + pulse * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, Radius.circular(barH / 2)), glowPaint);

      // Core bright light bar
      final corePaint = Paint()..color = ledColor;
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, Radius.circular(barH / 2)), corePaint);

      // White hot center
      final centerBar = Rect.fromCenter(
        center: Offset(center.x, barY),
        width: barW * 0.5,
        height: barH * 0.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(centerBar, Radius.circular(barH / 4)),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    } else {
      // ======================================================================
      // BACK FACE: Recessed Optical Sensor Cavity + Dual Green PPG LEDs
      // ======================================================================
      final sensorRect = Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: 32 * s,
        height: 22 * s,
      );

      // Dark glass optical window
      canvas.drawRRect(
        RRect.fromRectAndRadius(sensorRect, Radius.circular(4 * s)),
        Paint()..color = const Color(0xFF06090D),
      );

      // DUAL BRIGHT GLOWING GREEN OPTICAL LEDs
      final led1X = center.x - 6 * s;
      final led2X = center.x + 6 * s;
      final ledY = center.y;

      final greenGlow = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.45 + pulse * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(led1X, ledY), 6 * s, greenGlow);
      canvas.drawCircle(Offset(led2X, ledY), 6 * s, greenGlow);

      // White-hot emitter die cores
      final corePaint = Paint()..color = const Color(0xFFE6FFFA);
      canvas.drawCircle(Offset(led1X, ledY), 2.2 * s, corePaint);
      canvas.drawCircle(Offset(led2X, ledY), 2.2 * s, corePaint);

      // Gold charging contact pads
      final goldPadPaint = Paint()..color = const Color(0xFFFACC15);
      canvas.drawCircle(Offset(center.x - 22 * s, center.y), 2.0 * s, goldPadPaint);
      canvas.drawCircle(Offset(center.x + 22 * s, center.y), 2.0 * s, goldPadPaint);
    }
  }

  // Exploded View Layers:
  void _drawPodShell(Canvas canvas, _Pt3 p, String label) {
    final s = p.scale;
    final rect = Rect.fromCenter(center: Offset(p.x, p.y), width: 72 * s, height: 44 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(22 * s)), Paint()..color = const Color(0xFF1E222A));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(22 * s)), Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 1.5 * s);
    _drawLayerTag(canvas, p, label, const Color(0xFF38BDF8));
  }

  void _drawGpsAntennaLayer(Canvas canvas, _Pt3 p) {
    final s = p.scale;
    final rect = Rect.fromCenter(center: Offset(p.x, p.y), width: 62 * s, height: 34 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8 * s)), Paint()..color = const Color(0xFFB45309));
    // Ceramic GPS Patch
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(p.x - 14 * s, p.y), width: 16 * s, height: 16 * s), Radius.circular(3 * s)), Paint()..color = const Color(0xFFD97706));
    _drawLayerTag(canvas, p, '2. GPS Module & LTE / Wi-Fi Antenna', const Color(0xFFF59E0B));
  }

  void _drawMainPcbLayer(Canvas canvas, _Pt3 p) {
    final s = p.scale;
    final rect = Rect.fromCenter(center: Offset(p.x, p.y), width: 64 * s, height: 36 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8 * s)), Paint()..color = const Color(0xFF047857));
    // Metal ESP32 RF Shield Can
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(p.x, p.y), width: 26 * s, height: 20 * s), Radius.circular(4 * s)), Paint()..color = const Color(0xFF94A3B8));
    _drawLayerTag(canvas, p, '3. Main Controller PCB (ESP32)', const Color(0xFF10B981));
  }

  void _drawBatteryLayer(Canvas canvas, _Pt3 p) {
    final s = p.scale;
    final rect = Rect.fromCenter(center: Offset(p.x, p.y), width: 56 * s, height: 30 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(6 * s)), Paint()..color = const Color(0xFFCA8A04));
    _drawLayerTag(canvas, p, '4. 1000mAh LiPo Battery Pouch', const Color(0xFFEAB308));
  }

  void _drawSensorLayer(Canvas canvas, _Pt3 p) {
    final s = p.scale;
    final rect = Rect.fromCenter(center: Offset(p.x, p.y), width: 70 * s, height: 42 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(20 * s)), Paint()..color = const Color(0xFF0F172A));
    // Green LEDs
    final gPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(p.x - 6 * s, p.y), 3.5 * s, gPaint);
    canvas.drawCircle(Offset(p.x + 6 * s, p.y), 3.5 * s, gPaint);
    _drawLayerTag(canvas, p, '5. Optical Sensors (HR, SpO₂, Temp)', const Color(0xFF34D399));
  }

  void _drawLayerTag(Canvas canvas, _Pt3 p, String text, Color color) {
    final s = p.scale;
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 10 * s, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    final tx = p.x + 46 * s;
    final ty = p.y - 6 * s;

    // Leader line
    canvas.drawLine(
      Offset(p.x + 36 * s, p.y),
      Offset(tx - 4, ty + 7),
      Paint()..color = color.withValues(alpha: 0.6)..strokeWidth = 1.0,
    );

    textPainter.paint(canvas, Offset(tx, ty));
  }

  @override
  bool shouldRepaint(covariant UtanoUpperArmBand3dPainter oldDelegate) => true;
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
