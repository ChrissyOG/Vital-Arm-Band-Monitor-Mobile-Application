import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_theme.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';
import 'utano_3d_html.dart';

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

class _Band3dScreenState extends State<Band3dScreen> {
  late final WebViewController _webViewController;
  bool _isWebViewReady = false;

  BandViewMode _viewMode = BandViewMode.exploded;
  bool _isAutoSpin = false;
  bool _isStudioLight = false;
  int _selectedLayerIndex = -1;

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
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF04070E))
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            final action = data['action'] as String?;
            if (action == 'preset') {
              final mode = data['mode'] as String?;
              BandViewMode? targetMode;
              if (mode == 'docked') targetMode = BandViewMode.worn;
              if (mode == 'split') targetMode = BandViewMode.split;
              if (mode == 'sensors') targetMode = BandViewMode.sensors;
              if (mode == 'inside') targetMode = BandViewMode.exploded;
              if (targetMode != null && mounted) {
                setState(() {
                  _viewMode = targetMode!;
                  if (targetMode != BandViewMode.exploded) {
                    _selectedLayerIndex = -1;
                  }
                });
              }
            } else if (action == 'layer') {
              final idx = data['index'] as int?;
              if (idx != null && mounted) {
                setState(() {
                  _selectedLayerIndex = idx;
                  _viewMode = BandViewMode.exploded;
                });
              }
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isWebViewReady = true);
              _webViewController.runJavaScript("if (window.setPreset) window.setPreset('inside');");
            }
          },
        ),
      )
      ..loadHtmlString(kUtano3dWebGLHtml);
  }

  void _setViewMode(BandViewMode mode) {
    setState(() {
      _viewMode = mode;
      if (mode != BandViewMode.exploded) {
        _selectedLayerIndex = -1;
      }

      String jsPreset;
      switch (mode) {
        case BandViewMode.worn:
          jsPreset = 'docked';
          break;
        case BandViewMode.split:
          jsPreset = 'split';
          break;
        case BandViewMode.sensors:
          jsPreset = 'sensors';
          break;
        case BandViewMode.exploded:
          jsPreset = 'inside';
          break;
      }
      _webViewController.runJavaScript("if (window.setPreset) window.setPreset('$jsPreset');");
    });
  }

  void _toggleAutoSpin() {
    setState(() {
      _isAutoSpin = !_isAutoSpin;
      _webViewController.runJavaScript("if (window.toggleSpin) window.toggleSpin();");
    });
  }

  void _toggleStudioLight() {
    setState(() {
      _isStudioLight = !_isStudioLight;
      _webViewController.runJavaScript("if (window.toggleBg) window.toggleBg();");
    });
  }

  void _selectLayer(int index) {
    setState(() {
      if (_viewMode != BandViewMode.exploded) {
        _setViewMode(BandViewMode.exploded);
      }
      _selectedLayerIndex = (_selectedLayerIndex == index) ? -1 : index;
      _webViewController.runJavaScript("if (window.selectLayer) window.selectLayer($_selectedLayerIndex);");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !_isStudioLight;
    final bgColor = isDark ? const Color(0xFF070B14) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF101726) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide >= 600;
    final stageHeight = (screenSize.height * (isTablet ? 0.48 : 0.42))
      .clamp(isTablet ? 380.0 : 280.0, isTablet ? 580.0 : 400.0)
      .toDouble();

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
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    ),
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
                      'Hardware WebGL 3D • 1:1 with PC',
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
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${snapshot.heartRate} BPM',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: _isStudioLight ? 'Starlink Dark HUD' : 'Studio White',
                icon: Icon(
                  _isStudioLight
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: textColor,
                ),
                onPressed: _toggleStudioLight,
              ),
              IconButton(
                tooltip: _isAutoSpin ? 'Pause Turntable' : 'Auto Turntable',
                icon: Icon(
                  _isAutoSpin
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                  color: _isAutoSpin ? const Color(0xFF38BDF8) : textColor,
                ),
                onPressed: _toggleAutoSpin,
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 3D Viewport Stage Card (Running True Hardware WebGL GPU Engine!)
                Container(
                  height: stageHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF04070E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.12),
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
                        WebViewWidget(controller: _webViewController),
                        if (!_isWebViewReady)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 4 Clean View Angle Presets Row (1..4)
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
                              onTap: () => _selectLayer(-1),
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
                          onTap: () => _selectLayer(part.index),
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

                // Fabric Care & Sensor Highlights Card (From Reference Poster)
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
                            'Fabric Care & Sensor Specifications',
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
                        title: 'Sensor Area Sits Against Skin',
                        desc:
                            'Recessed optical sensor window with dual glowing green PPG optical LEDs (| : |) sitting flush against the skin through the inner sleeve cutout.',
                        badge: 'Direct Skin Contact',
                        badgeColor: const Color(0xFF10B981),
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
