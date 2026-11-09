import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';

enum BandViewMode {
  worn,     // 1. How It Looks on the Arm (Docked in Wide Sleeve)
  split,    // 2. Removable Water-Resistant Pod
  sensors,  // 3. Sensor Area Sits Against Skin (| : | Green LEDs)
  exploded, // 4. What's Inside the Pod (Exploded 5-Layer CAD)
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

  BandViewMode _viewMode = BandViewMode.exploded;
  bool _isAutoSpin = false;
  bool _isStudioLight = false;
  int _selectedLayerIndex = -1; // -1 = all layers, 0..4 = highlighted internal layer

  double _rotX = 0.36;
  double _rotY = -0.38;
  double _zoom = 1.05;
  double _podFlip = 0.0;
  double _sceneOffsetX = -38.0;

  // Target values for smooth animated camera movement
  double _targetRotX = 0.36;
  double _targetRotY = -0.38;
  double _targetZoom = 1.05;
  double _targetPodFlip = 0.0;
  double _targetSceneOffsetX = -38.0;

  static const List<_InternalPartSpec> _insideParts = [
    _InternalPartSpec(
      index: 0,
      title: 'Water-resistant casing',
      subtitle: 'Splash & sweat resistant matte polycarbonate shell with illuminated Heart-ECG & cyan status bar.',
      badge: 'IP67 Shell',
      color: Color(0xFF38BDF8),
      icon: Icons.shield_outlined,
    ),
    _InternalPartSpec(
      index: 1,
      title: 'GPS module & Cellular (LTE) / Wi-Fi antenna',
      subtitle: 'Ceramic L1 GPS patch for location & movement speed + LTE/Wi-Fi antenna with automatic fallback.',
      badge: 'GPS + LTE/Wi-Fi',
      color: Color(0xFFF59E0B),
      icon: Icons.satellite_alt_rounded,
    ),
    _InternalPartSpec(
      index: 2,
      title: 'Main PCB (controller)',
      subtitle: 'Multi-layer emerald FR4 circuit board housing the ultra-low-power MCU, RF shield & encrypted memory.',
      badge: 'ESP32 MCU',
      color: Color(0xFF10B981),
      icon: Icons.memory_rounded,
    ),
    _InternalPartSpec(
      index: 3,
      title: 'Battery (1000mAh LiPo)',
      subtitle: 'High-density rechargeable lithium-polymer pouch cell engineered for multi-day continuous monitoring.',
      badge: '1000 mAh',
      color: Color(0xFFEAB308),
      icon: Icons.battery_charging_full_rounded,
    ),
    _InternalPartSpec(
      index: 4,
      title: 'Sensors (HR, SpO₂, Temperature, Motion)',
      subtitle: 'Dual-wavelength green/IR optical PPG array (| : |), clinical skin thermistor & 6-axis accelerometer.',
      badge: '4-in-1 Biosensor',
      color: Color(0xFF34D399),
      icon: Icons.monitor_heart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..addListener(() {
        if (mounted) {
          setState(() {
            if (_isAutoSpin) {
              _targetRotY += 0.0065;
            }
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
      value: 1.0, // Start detached & exploded so user sees "What's Inside the Pod"
    );

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 1.0,
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
      if (mode != BandViewMode.exploded) {
        _selectedLayerIndex = -1;
      }

      switch (mode) {
        case BandViewMode.worn:
          _isAutoSpin = true;
          _dockController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.26;
          _targetRotY = -0.22;
          _targetZoom = 1.12;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.split:
          _isAutoSpin = false;
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.28;
          _targetRotY = -0.26;
          _targetZoom = 0.98;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = 0.0;
          break;
        case BandViewMode.sensors:
          _isAutoSpin = false;
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(0.0, curve: Curves.easeInOutCubic);
          _targetRotX = -0.18;
          _targetRotY = 0.32;
          _targetZoom = 1.35;
          _targetPodFlip = 1.0; // Show underside with | : | green LEDs
          _targetSceneOffsetX = -52.0;
          break;
        case BandViewMode.exploded:
          _isAutoSpin = false;
          _dockController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _explodeController.animateTo(1.0, curve: Curves.easeInOutCubic);
          _targetRotX = 0.36;
          _targetRotY = -0.38;
          _targetZoom = 1.04;
          _targetPodFlip = 0.0;
          _targetSceneOffsetX = -38.0;
          break;
      }
    });
  }

  void _toggleExplodeOrDock() {
    if (_viewMode != BandViewMode.exploded) {
      _setViewMode(BandViewMode.exploded);
    } else {
      _setViewMode(BandViewMode.worn);
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
                    border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
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
                      'Nylon-Spandex Weave • What\'s Inside the Pod',
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
                  _isStudioLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: textColor,
                ),
                onPressed: () =>
                    setState(() => _isStudioLight = !_isStudioLight),
              ),
              IconButton(
                tooltip: _isAutoSpin ? 'Pause Turntable' : 'Auto Turntable',
                icon: Icon(
                  _isAutoSpin
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
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
                  height: 410,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF04070E)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
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
                                  _targetZoom =
                                      (_targetZoom * details.scale).clamp(0.65, 2.2);
                                  _zoom = _targetZoom;
                                });
                              }
                            },
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _spinController,
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
                                    spinPhase: _spinController.value,
                                    isStudioLight: _isStudioLight,
                                    isCritical: snapshot.isCritical,
                                    selectedLayer: _selectedLayerIndex,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Top HUD Pill: Status & Active Mode
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
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.5),
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
                                      _modeBannerText(),
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
                                    const Icon(Icons.favorite_rounded,
                                        color: Color(0xFF10B981), size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${snapshot.heartRate} BPM • ${snapshot.batteryPercentage}%',
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

                        // Bottom Floating Controls: Explode Slider & Quick Action
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white)
                                        .withValues(alpha: 0.90),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.layers_rounded,
                                          color: Color(0xFF38BDF8), size: 15),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Explode:',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 3,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6),
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                    overlayRadius: 12),
                                          ),
                                          child: Slider(
                                            value: _explodeController.value,
                                            activeColor: const Color(0xFF38BDF8),
                                            inactiveColor: subColor
                                                .withValues(alpha: 0.25),
                                            onChanged: (val) {
                                              setState(() {
                                                _explodeController.value = val;
                                                if (val > 0.15) {
                                                  _dockController.value = 1.0;
                                                  _viewMode =
                                                      BandViewMode.exploded;
                                                  _targetSceneOffsetX =
                                                      -38.0 * val;
                                                } else {
                                                  _viewMode = BandViewMode.split;
                                                  _targetSceneOffsetX = 0.0;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _toggleExplodeOrDock,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  foregroundColor: const Color(0xFF38BDF8),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                icon: Icon(
                                  _explodeController.value > 0.5
                                      ? Icons.compress_rounded
                                      : Icons.auto_awesome_motion_rounded,
                                  size: 15,
                                ),
                                label: Text(
                                  _explodeController.value > 0.5
                                      ? 'Assemble'
                                      : 'Inside Pod',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
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

                const SizedBox(height: 12),

                // 6 View Angle Presets Row (Matching Poster Sections + Creative Modes)
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
                        label: '4. What\'s Inside the Pod',
                        icon: Icons.layers_outlined,
                        isActive: _viewMode == BandViewMode.exploded,
                        onTap: () => _setViewMode(BandViewMode.exploded),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Interactive "What's Inside the Pod" Hardware Teardown Explorer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.developer_board_rounded,
                                  color: Color(0xFF38BDF8), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'What\'s Inside the Pod (Tap to Highlight)',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (_selectedLayerIndex != -1)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLayerIndex = -1),
                              child: const Text(
                                'Show All',
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._insideParts.map((part) {
                        final isSelected = _selectedLayerIndex == part.index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_viewMode != BandViewMode.exploded) {
                                _setViewMode(BandViewMode.exploded);
                              }
                              _selectedLayerIndex =
                                  isSelected ? -1 : part.index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? part.color.withValues(alpha: 0.14)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? part.color
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.06)),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: part.color.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(part.icon,
                                      color: part.color, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              part.title,
                                              style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: part.color
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              part.badge,
                                              style: TextStyle(
                                                color: part.color,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        part.subtitle,
                                        style: TextStyle(
                                          color: subColor,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Fabric & Washability Highlights Card (From Poster)
                Container(
                  padding: const EdgeInsets.all(16),
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
                          const Icon(Icons.checkroom_rounded,
                              color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nylon-Spandex Fabric & Care Guide',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        title: 'Soft, Stretchable Nylon-Spandex Fibers',
                        desc:
                            'Interwoven diagonal herringbone stretch fibers with breathable micro-channels that contour comfortably around the upper arm.',
                        badge: 'Breathable Weave',
                        badgeColor: const Color(0xFF38BDF8),
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const Divider(height: 18),
                      _buildFeatureRow(
                        title: 'Machine-Washable Fabric Sleeve',
                        desc:
                            'Remove the electronics pod before washing. The electronics pod is water-resistant (splash and sweat resistant), not fully waterproof.',
                        badge: 'Easy Wash',
                        badgeColor: forest,
                        textColor: textColor,
                        subColor: subColor,
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

  String _modeBannerText() {
    switch (_viewMode) {
      case BandViewMode.worn:
        return '1. Upper-Arm Sleeve (Worn)';
      case BandViewMode.split:
        return '2. Removable Water-Resistant Pod';
      case BandViewMode.sensors:
        return '3. Skin-Contact Optical Sensors';
      case BandViewMode.exploded:
        return '4. What\'s Inside the Pod (CAD)';
    }
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
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
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
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

class _InternalPartSpec {
  const _InternalPartSpec({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.icon,
  });

  final int index;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final IconData icon;
}

// ==============================================================================
// 3D CUSTOM PAINTER: Interwoven Nylon-Spandex Sleeve + Exploded 5-Layer Pod CAD
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
    required this.spinPhase,
    required this.isStudioLight,
    required this.isCritical,
    required this.selectedLayer,
  });

  final double rotX;
  final double rotY;
  final double zoom;
  final double detach;
  final double explode;
  final double podFlip;
  final double sceneOffsetX;
  final double pulse;
  final double spinPhase;
  final bool isStudioLight;
  final bool isCritical;
  final int selectedLayer;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + sceneOffsetX;
    final cy = size.height / 2 + 4;

    // 1. Ground Shadow
    _drawGroundShadow(canvas, cx, cy);

    final commands = <_DrawCommand>[];

    // Band Group shifts left when detached, and further left when exploded
    final bandShiftX = -46.0 * detach - 70.0 * explode;

    // 2. Wide Upper-Arm Compression Sleeve (with Interwoven Herringbone Fibers)
    if (explode < 0.85) {
      _generateUpperArmSleeve(commands, cx + bandShiftX, cy);
      _generateSleeveDock(commands, cx + bandShiftX, cy);
    }

    // 3. Removable Pod & 5 Exploded Internal Hardware Layers
    final podX = cx + (1.0 - explode) * (bandShiftX + detach * 112.0);
    final podY = cy - (1.0 - explode) * detach * 6.0;
    final podZ = -(1.0 - explode) * detach * 18.0;
    _generatePodAndLayers(commands, podX, podY, podZ);

    // Sort back-to-front by Z depth
    commands.sort((a, b) => b.depth.compareTo(a.depth));

    for (final cmd in commands) {
      cmd.draw(canvas);
    }
  }

  void _drawGroundShadow(Canvas canvas, double cx, double cy) {
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: isStudioLight ? 0.30 : 0.50),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy + 130), radius: 145 * zoom),
      );

    canvas.save();
    canvas.translate(cx, cy + 130);
    canvas.scale(1.0, 0.30);
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

  // ===========================================================================
  // 1. UPPER-ARM SLEEVE WITH INTERWOVEN NYLON-SPANDEX HERRINGBONE FIBERS
  // ===========================================================================
  void _generateUpperArmSleeve(List<_DrawCommand> list, double ox, double oy) {
    const segments = 44;
    const rx = 104.0;
    const rz = 68.0;
    const sleeveHeight = 78.0;

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

      // Heather charcoal nylon-spandex base tone
      final shade = (24 + normalZ * 20).clamp(14, 48).toInt();
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

            // Interwoven Diagonal Herringbone Nylon-Spandex Fiber Strands
            final fiberPaint1 = Paint()
              ..color = const Color(0xFF94A3B8).withValues(alpha: 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.85;
            final fiberPaint2 = Paint()
              ..color = const Color(0xFF475569).withValues(alpha: 0.30)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.85;

            for (int r = 1; r <= 5; r++) {
              final fA = r / 6.0;
              final fB = (r + (i.isEven ? 0.65 : -0.65)) / 6.0;
              final ax = p1Top.x + (p1Btm.x - p1Top.x) * fA;
              final ay = p1Top.y + (p1Btm.y - p1Top.y) * fA;
              final bx = p2Top.x + (p2Btm.x - p2Top.x) * fB.clamp(0.08, 0.92);
              final by = p2Top.y + (p2Btm.y - p2Top.y) * fB.clamp(0.08, 0.92);
              canvas.drawLine(
                Offset(ax, ay),
                Offset(bx, by),
                r.isEven ? fiberPaint1 : fiberPaint2,
              );
            }

            // Plush Ribbed Elastic Piping Trim (Top & Bottom Borders)
            final trimPaint = Paint()
              ..color = const Color(0xFF0F1319)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2;
            canvas.drawLine(
                Offset(p1Top.x, p1Top.y), Offset(p2Top.x, p2Top.y), trimPaint);
            canvas.drawLine(
                Offset(p1Btm.x, p1Btm.y), Offset(p2Btm.x, p2Btm.y), trimPaint);

            // Double-stitched lockstitch seam thread along top & bottom hem
            if (i.isEven) {
              final stitchPaint = Paint()
                ..color = const Color(0xFF64748B).withValues(alpha: 0.55)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0;
              final sTop1 = Offset(
                p1Top.x + (p1Btm.x - p1Top.x) * 0.08,
                p1Top.y + (p1Btm.y - p1Top.y) * 0.08,
              );
              final sTop2 = Offset(
                p2Top.x + (p2Btm.x - p2Top.x) * 0.08,
                p2Top.y + (p2Btm.y - p2Top.y) * 0.08,
              );
              final sBtm1 = Offset(
                p1Top.x + (p1Btm.x - p1Top.x) * 0.92,
                p1Top.y + (p1Btm.y - p1Top.y) * 0.92,
              );
              final sBtm2 = Offset(
                p2Top.x + (p2Btm.x - p2Top.x) * 0.92,
                p2Top.y + (p2Btm.y - p2Top.y) * 0.92,
              );
              canvas.drawLine(sTop1, sTop2, stitchPaint);
              canvas.drawLine(sBtm1, sBtm2, stitchPaint);
            }
          },
        ),
      );
    }
  }

  // ===========================================================================
  // 2. SLEEVE CRADLE WITH INNER SKIN-CONTACT SENSOR CUTOUT (| : | GREEN LEDS)
  // ===========================================================================
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
            width: 68 * s,
            height: 76 * s,
          );

          // Molded matte black sleeve pocket bezel
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(22 * s)),
            Paint()..color = const Color(0xFF131720),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(outerRect, Radius.circular(22 * s)),
            Paint()
              ..color = const Color(0xFF334155)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6 * s,
          );

          // Inner optical window cutout (shows | : | green LEDs sitting against skin)
          final innerRect = Rect.fromCenter(
            center: Offset(center.x, center.y),
            width: 44 * s,
            height: 32 * s,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(innerRect, Radius.circular(10 * s)),
            Paint()..color = const Color(0xFF050807),
          );

          // Poster "| : |" green optical bars inside cradle cutout
          final greenGlow = Paint()
            ..color = const Color(0xFF10B981).withValues(alpha: 0.4 + pulse * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(Offset(center.x, center.y), 14 * s, greenGlow);

          final barPaint = Paint()..color = const Color(0xFF00FF66);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(center.x - 10 * s, center.y),
                  width: 3 * s,
                  height: 14 * s),
              Radius.circular(1.5 * s),
            ),
            barPaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(center.x + 10 * s, center.y),
                  width: 3 * s,
                  height: 14 * s),
              Radius.circular(1.5 * s),
            ),
            barPaint,
          );
          canvas.drawCircle(
              Offset(center.x, center.y - 3.5 * s), 1.8 * s, barPaint);
          canvas.drawCircle(
              Offset(center.x, center.y + 3.5 * s), 1.8 * s, barPaint);
        },
      ),
    );
  }

  // ===========================================================================
  // 3. REMOVABLE POD & 5-LAYER EXPLODED "WHAT'S INSIDE THE POD" CAD STACK
  // ===========================================================================
  void _generatePodAndLayers(
      List<_DrawCommand> list, double ox, double oy, double oz) {
    final exp = explode;
    final podCenter = _project(0, 0, oz, ox, oy);
    final cosView = math.cos(rotY + podFlip * math.pi);
    final isBackVisible = cosView < 0 || podFlip > 0.5;

    if (exp < 0.05) {
      // ASSEMBLED POD (Vertical Rounded-Squircle Pebble matching Poster)
      list.add(
        _DrawCommand(
          depth: podCenter.z - 6.0,
          draw: (canvas) {
            _drawAssembledPod(canvas, podCenter, isBackVisible);
          },
        ),
      );
    } else {
      // =======================================================================
      // 5 EXPLODED 3D PERSPECTIVE HARDWARE LAYERS (Matching "What's Inside the Pod")
      // =======================================================================
      final spread = 34.0 * exp;

      // Layer 1 (Top): Water-resistant casing
      _addExplodedSlab(
        list: list,
        layerIdx: 0,
        yCenter: -2.0 * spread,
        width: 66,
        depth: 74,
        thickness: 9,
        ox: ox,
        oy: oy,
        oz: oz,
        topColor: const Color(0xFF1C212B),
        sideColor: const Color(0xFF0F131A),
        borderColor: const Color(0xFF38BDF8),
        label: 'Water-resistant casing',
        subLabel: 'Splash & sweat-proof shell',
        drawDetails: (canvas, c, s) {
          _drawHeartEcgAndBar(canvas, c.x, c.y, s * 0.85);
        },
      );

      // Layer 2: GPS module & Cellular (LTE) / Wi-Fi antenna
      _addExplodedSlab(
        list: list,
        layerIdx: 1,
        yCenter: -1.0 * spread,
        width: 58,
        depth: 64,
        thickness: 5,
        ox: ox,
        oy: oy,
        oz: oz,
        topColor: const Color(0xFF065F46),
        sideColor: const Color(0xFF064E3B),
        borderColor: const Color(0xFFF59E0B),
        label: 'GPS module & LTE/Wi-Fi antenna',
        subLabel: 'Location, speed & auto-fallback',
        drawDetails: (canvas, c, s) {
          // Tan/Gold Ceramic GPS Patch Block
          final patchRect = Rect.fromCenter(
            center: Offset(c.x - 8 * s, c.y - 2 * s),
            width: 18 * s,
            height: 15 * s,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(patchRect, Radius.circular(3 * s)),
            Paint()..color = const Color(0xFFD97706),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                patchRect.deflate(2.5 * s), Radius.circular(2 * s)),
            Paint()..color = const Color(0xFFFEF08A),
          );
          // Gold LTE/Wi-Fi antenna trace
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(c.x + 12 * s, c.y),
                  width: 12 * s,
                  height: 18 * s),
              Radius.circular(2 * s),
            ),
            Paint()
              ..color = const Color(0xFFFBBF24)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6 * s,
          );
        },
      );

      // Layer 3: Main PCB (controller)
      _addExplodedSlab(
        list: list,
        layerIdx: 2,
        yCenter: 0.0,
        width: 60,
        depth: 66,
        thickness: 5,
        ox: ox,
        oy: oy,
        oz: oz,
        topColor: const Color(0xFF047857),
        sideColor: const Color(0xFF065F46),
        borderColor: const Color(0xFF10B981),
        label: 'Main PCB (controller)',
        subLabel: 'ESP32 MCU & copper traces',
        drawDetails: (canvas, c, s) {
          // Silver RF Shield Can
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(c.x - 6 * s, c.y),
                  width: 20 * s,
                  height: 14 * s),
              Radius.circular(3 * s),
            ),
            Paint()..color = const Color(0xFF94A3B8),
          );
          // Silicon MCU Die
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(c.x + 12 * s, c.y + 2 * s),
                  width: 12 * s,
                  height: 12 * s),
              Radius.circular(2 * s),
            ),
            Paint()..color = const Color(0xFF1E293B),
          );
        },
      );

      // Layer 4: Battery (1000mAh LiPo)
      _addExplodedSlab(
        list: list,
        layerIdx: 3,
        yCenter: 1.0 * spread,
        width: 52,
        depth: 58,
        thickness: 9,
        ox: ox,
        oy: oy,
        oz: oz,
        topColor: const Color(0xFFEAB308),
        sideColor: const Color(0xFFCA8A04),
        borderColor: const Color(0xFFFACC15),
        label: 'Battery (1000mAh LiPo)',
        subLabel: 'Rechargeable gold pouch cell',
        drawDetails: (canvas, c, s) {
          // Dark protection terminal strip on left end of battery
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(c.x - 14 * s, c.y),
                  width: 8 * s,
                  height: 16 * s),
              Radius.circular(2 * s),
            ),
            Paint()..color = const Color(0xFF1E293B),
          );
        },
      );

      // Layer 5 (Bottom): Sensors (HR, SpO2, Temperature, Motion)
      _addExplodedSlab(
        list: list,
        layerIdx: 4,
        yCenter: 2.0 * spread,
        width: 66,
        depth: 74,
        thickness: 8,
        ox: ox,
        oy: oy,
        oz: oz,
        topColor: const Color(0xFF111827),
        sideColor: const Color(0xFF090D16),
        borderColor: const Color(0xFF34D399),
        label: 'Sensors (HR, SpO₂, Temp, Motion)',
        subLabel: 'Direct skin optical array (| : |)',
        drawDetails: (canvas, c, s) {
          // Glowing green optical sensor array
          final glow = Paint()
            ..color =
                const Color(0xFF10B981).withValues(alpha: 0.5 + pulse * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(Offset(c.x, c.y), 12 * s, glow);
          final ledPaint = Paint()..color = const Color(0xFF00FF66);
          canvas.drawCircle(Offset(c.x - 6 * s, c.y), 2.5 * s, ledPaint);
          canvas.drawCircle(Offset(c.x + 6 * s, c.y), 2.5 * s, ledPaint);
        },
      );
    }
  }

  // Project and draw a 3D perspective slab for the exploded stack
  void _addExplodedSlab({
    required List<_DrawCommand> list,
    required int layerIdx,
    required double yCenter,
    required double width,
    required double depth,
    required double thickness,
    required double ox,
    required double oy,
    required double oz,
    required Color topColor,
    required Color sideColor,
    required Color borderColor,
    required String label,
    required String subLabel,
    required void Function(Canvas canvas, _Pt3 center, double scale) drawDetails,
  }) {
    final cPt = _project(0, yCenter, oz, ox, oy);
    final rightEdgePt = _project(width * 0.55, yCenter, oz, ox, oy);

    final isHighlighted = selectedLayer == layerIdx;
    final isDimmed = selectedLayer != -1 && !isHighlighted;
    final alpha = isDimmed ? 0.35 : 1.0;

    list.add(
      _DrawCommand(
        depth: cPt.z + yCenter * 0.05,
        draw: (canvas) {
          final s = cPt.scale;
          final w = width * s;
          final h = (depth * 0.48) * s;
          final thick = thickness * s;

          // 3D Extruded Side Thickness
          final sideRect = Rect.fromCenter(
            center: Offset(cPt.x, cPt.y + thick * 0.55),
            width: w,
            height: h,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(sideRect, Radius.circular(14 * s)),
            Paint()..color = sideColor.withValues(alpha: alpha),
          );

          // Top Face of 3D Layer
          final topRect = Rect.fromCenter(
            center: Offset(cPt.x, cPt.y),
            width: w,
            height: h,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(topRect, Radius.circular(14 * s)),
            Paint()..color = topColor.withValues(alpha: alpha),
          );

          // Highlight Halo if Selected
          if (isHighlighted) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(topRect.inflate(3 * s), Radius.circular(16 * s)),
              Paint()
                ..color = borderColor.withValues(alpha: 0.45 + pulse * 0.35)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
            );
          }

          canvas.drawRRect(
            RRect.fromRectAndRadius(topRect, Radius.circular(14 * s)),
            Paint()
              ..color = borderColor.withValues(
                  alpha: isHighlighted ? 1.0 : 0.7 * alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = (isHighlighted ? 2.4 : 1.3) * s,
          );

          if (!isDimmed) {
            drawDetails(canvas, cPt, s);
          }

          // Draw Poster-Style Right Callout Leader Line & Badge
          _drawExplodedCallout(
            canvas: canvas,
            anchor: rightEdgePt,
            label: label,
            subLabel: subLabel,
            color: borderColor,
            alpha: alpha,
            isHighlighted: isHighlighted,
          );
        },
      ),
    );
  }

  void _drawExplodedCallout({
    required Canvas canvas,
    required _Pt3 anchor,
    required String label,
    required String subLabel,
    required Color color,
    required double alpha,
    required bool isHighlighted,
  }) {
    final s = anchor.scale;
    final startX = anchor.x;
    final startY = anchor.y;
    final endX = startX + 26 * s;

    // Glowing anchor dot
    canvas.drawCircle(
      Offset(startX, startY),
      3.0 * s,
      Paint()..color = color.withValues(alpha: alpha),
    );

    // Horizontal leader line
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, startY),
      Paint()
        ..color = color.withValues(alpha: 0.75 * alpha)
        ..strokeWidth = (isHighlighted ? 1.8 : 1.2) * s,
    );

    final titleSpan = TextSpan(
      text: '$label\n',
      style: TextStyle(
        color: (isStudioLight ? const Color(0xFF0F172A) : Colors.white)
            .withValues(alpha: alpha),
        fontSize: (isHighlighted ? 10.5 : 9.5) * s,
        fontWeight: FontWeight.bold,
        height: 1.15,
      ),
      children: [
        TextSpan(
          text: subLabel,
          style: TextStyle(
            color: color.withValues(alpha: 0.9 * alpha),
            fontSize: 8.2 * s,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final tp = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 155 * s);

    final pillRect = Rect.fromLTWH(
      endX + 4 * s,
      startY - tp.height / 2 - 4 * s,
      tp.width + 12 * s,
      tp.height + 8 * s,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(6 * s)),
      Paint()
        ..color = (isStudioLight
                ? Colors.white.withValues(alpha: 0.92 * alpha)
                : const Color(0xFF0F172A).withValues(alpha: 0.88 * alpha)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, Radius.circular(6 * s)),
      Paint()
        ..color = color.withValues(alpha: (isHighlighted ? 0.95 : 0.45) * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isHighlighted ? 1.5 : 1.0) * s,
    );

    tp.paint(canvas, Offset(endX + 10 * s, startY - tp.height / 2));
  }

  // Draw Assembled Pod (Vertical Rounded-Squircle Pebble matching Poster)
  void _drawAssembledPod(Canvas canvas, _Pt3 center, bool isBackVisible) {
    final s = center.scale;
    final rect = Rect.fromCenter(
      center: Offset(center.x, center.y),
      width: 64 * s,
      height: 74 * s,
    );

    // Matte black water-resistant pebble enclosure
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(22 * s)),
      Paint()..color = const Color(0xFF161A22),
    );

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(22 * s)),
      highlightPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(22 * s)),
      Paint()
        ..color = const Color(0xFF334155).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s,
    );

    if (!isBackVisible) {
      _drawHeartEcgAndBar(canvas, center.x, center.y, s);
    } else {
      // BACK FACE: Skin-Contact Sensor Area (| : | Dual Green Optical Bars)
      final sensorRect = Rect.fromCenter(
        center: Offset(center.x, center.y),
        width: 36 * s,
        height: 26 * s,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sensorRect, Radius.circular(6 * s)),
        Paint()..color = const Color(0xFF050807),
      );

      final greenGlow = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.5 + pulse * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
      canvas.drawCircle(Offset(center.x, center.y), 14 * s, greenGlow);

      final ledPaint = Paint()..color = const Color(0xFF00FF66);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(center.x - 9 * s, center.y),
              width: 3.2 * s,
              height: 13 * s),
          Radius.circular(1.5 * s),
        ),
        ledPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(center.x + 9 * s, center.y),
              width: 3.2 * s,
              height: 13 * s),
          Radius.circular(1.5 * s),
        ),
        ledPaint,
      );
      canvas.drawCircle(
          Offset(center.x, center.y - 3.5 * s), 1.8 * s, ledPaint);
      canvas.drawCircle(
          Offset(center.x, center.y + 3.5 * s), 1.8 * s, ledPaint);
    }
  }

  void _drawHeartEcgAndBar(Canvas canvas, double cx, double cy, double s) {
    final iconY = cy - 6 * s;

    // 1. White Heart Outline
    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const hw = 9.5;
    final heartPath = Path()
      ..moveTo(cx, iconY + 6 * s)
      ..cubicTo(
        cx - hw * 1.3 * s,
        iconY - 3 * s,
        cx - hw * 0.8 * s,
        iconY - 9.5 * s,
        cx,
        iconY - 3.5 * s,
      )
      ..cubicTo(
        cx + hw * 0.8 * s,
        iconY - 9.5 * s,
        cx + hw * 1.3 * s,
        iconY - 3 * s,
        cx,
        iconY + 6 * s,
      );
    canvas.drawPath(heartPath, heartPaint);

    // 2. ECG Pulse Line Through Heart
    final ecgPath = Path()
      ..moveTo(cx - 12 * s, iconY + 0.5 * s)
      ..lineTo(cx - 4 * s, iconY + 0.5 * s)
      ..lineTo(cx - 2 * s, iconY - 4.2 * s)
      ..lineTo(cx + 1 * s, iconY + 4.2 * s)
      ..lineTo(cx + 3 * s, iconY - 1.2 * s)
      ..lineTo(cx + 5 * s, iconY + 0.5 * s)
      ..lineTo(cx + 12 * s, iconY + 0.5 * s);

    canvas.drawPath(
      ecgPath,
      Paint()
        ..color = const Color(0xFF7DD3FC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 3. Horizontal Glowing Cyan LED Status Bar (Lower Center)
    final barY = cy + 17 * s;
    final barW = 22 * s;
    final barH = 3.5 * s;
    final barRect =
        Rect.fromCenter(center: Offset(cx, barY), width: barW, height: barH);

    final ledColor =
        isCritical ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(barH / 2)),
      Paint()
        ..color = ledColor.withValues(alpha: 0.65 + pulse * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(barH / 2)),
      Paint()..color = ledColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, barY), width: barW * 0.55, height: barH * 0.5),
        Radius.circular(barH / 4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
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
