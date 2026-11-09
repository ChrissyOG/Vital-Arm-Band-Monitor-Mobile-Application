import 'package:flutter/material.dart';

import 'ai_assistant_screen.dart';
import 'animation_widgets.dart';
import 'app_theme.dart';
import 'band_3d_screen.dart';
import 'mqtt_service.dart';
import 'telemetry_service.dart';
import 'user_profile.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.profile, this.onSignOut, super.key});

  final UserProfile profile;
  final VoidCallback? onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _isCallModalShown = false;

  @override
  void initState() {
    super.initState();
    MqttService.instance.connect();
    TelemetryService.instance.addListener(_handleTelemetryChange);
  }

  @override
  void dispose() {
    TelemetryService.instance.removeListener(_handleTelemetryChange);
    super.dispose();
  }

  void _handleTelemetryChange() {
    final snapshot = TelemetryService.instance.snapshot;
    if (snapshot.isEmergencyCallActive && !_isCallModalShown && mounted) {
      _isCallModalShown = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AutomatedEmergencyCallDialog(),
      ).then((_) {
        _isCallModalShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.profile.role;
    final names = role.monitorsSomeone
        ? const ['Overview', '3D Band', 'AI Assistant', 'History', 'Alerts']
        : const ['Overview', '3D Band', 'AI Assistant', 'Activity', 'Alerts'];
    final pages = role.monitorsSomeone
        ? <Widget>[
            OverviewScreen(
              profile: widget.profile,
              onSignOut: widget.onSignOut,
              onOpenAiChat: () => setState(() => _index = 2),
              onOpen3dBand: () => setState(() => _index = 1),
            ),
            Band3dScreen(profile: widget.profile),
            AiAssistantScreen(profile: widget.profile),
            HistoryScreen(name: widget.profile.monitoredName),
            AlertsScreen(name: widget.profile.monitoredName),
          ]
        : <Widget>[
            OverviewScreen(
              profile: widget.profile,
              onSignOut: widget.onSignOut,
              onOpenAiChat: () => setState(() => _index = 2),
              onOpen3dBand: () => setState(() => _index = 1),
            ),
            Band3dScreen(profile: widget.profile),
            AiAssistantScreen(profile: widget.profile),
            ActivityScreen(name: widget.profile.name),
            AlertsScreen(name: widget.profile.name),
          ];
    final icons = role.monitorsSomeone
        ? const [
            Icons.grid_view_rounded,
            Icons.view_in_ar_rounded,
            Icons.auto_awesome_rounded,
            Icons.show_chart_rounded,
            Icons.notifications_none_rounded,
          ]
        : const [
            Icons.grid_view_rounded,
            Icons.view_in_ar_rounded,
            Icons.auto_awesome_rounded,
            Icons.directions_run_rounded,
            Icons.notifications_none_rounded,
          ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: List.generate(
          names.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            selectedIcon: Icon(icons[index]),
            label: names[index],
          ),
        ),
      ),
    );
  }
}

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({
    required this.profile,
    this.onSignOut,
    this.onOpenAiChat,
    this.onOpen3dBand,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback? onSignOut;
  final VoidCallback? onOpenAiChat;
  final VoidCallback? onOpen3dBand;

  @override
  Widget build(BuildContext context) {
    final role = profile.role;
    final subject = role.monitorsSomeone ? profile.monitoredName : profile.name;
    final isFitness = role == UserRole.fitness;

    return ListenableBuilder(
      listenable: TelemetryService.instance,
      builder: (context, _) {
        final snapshot = TelemetryService.instance.snapshot;

        return DashboardPage(
          title: 'Good morning, ${profile.name.split(' ').first}',
          subtitle: isFitness
              ? 'Your body, in the moment.'
              : 'Here is the latest from $subject.',
          trailing: NotificationButton(onSignOut: onSignOut, profile: profile),
          children: [
            VitalSpikeNotificationBanner(snapshot: snapshot),
            if (snapshot.isActivityCorrelated)
              const ActivityOptimizationCard(),
            const LecturerDemoBar(),
            const SizedBox(height: 14),
            DeviceStatusBanner(
              name: subject,
              isCritical: snapshot.isCritical,
              battery: snapshot.batteryPercentage,
              onTap: onOpen3dBand,
            ),
            const SizedBox(height: 14),
            Utano3dHardwareCard(
              onOpen3d: onOpen3dBand,
              battery: snapshot.batteryPercentage,
            ),
            const SizedBox(height: 14),
            UtanoAiOverviewCard(
              snapshot: snapshot,
              patientName: subject,
              onOpenAiChat: onOpenAiChat,
            ),
            if (!isFitness && role.monitorsSomeone) ...[
              const SizedBox(height: 16),
              AlertSummary(snapshot: snapshot),
            ],
            const SizedBox(height: 20),
            SectionHeading(
              title: isFitness ? 'Your vital signs' : 'Vital signs',
              trailing: 'Live stream',
            ),
            const SizedBox(height: 11),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: VitalCard(
                    title: 'Heart rate',
                    value: '${snapshot.heartRate}',
                    unit: 'bpm',
                    status: snapshot.statusText,
                    statusColor: snapshot.statusColor,
                    icon: Icons.favorite_rounded,
                    iconWidget: PulsingHeartIcon(
                      bpm: snapshot.heartRate,
                      color: snapshot.isCritical
                          ? coral
                          : (snapshot.isExercise
                              ? const Color(0xFFE89635)
                              : coral),
                      size: 18,
                    ),
                    color: snapshot.isCritical
                        ? coral
                        : (snapshot.isExercise
                            ? const Color(0xFFE89635)
                            : coral),
                    data: snapshot.heartRateHistory,
                    latestSampleText: 'Live stream · just now',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VitalCard(
                    title: 'Blood oxygen',
                    value: snapshot.spo2.toStringAsFixed(1),
                    unit: '% SpO₂',
                    status: snapshot.spo2 < 90
                        ? 'Hypoxemia warning'
                        : 'Within baseline',
                    statusColor: snapshot.spo2 < 90 ? coral : forest,
                    icon: Icons.air_rounded,
                    color: snapshot.spo2 < 90 ? coral : forest,
                    data: snapshot.spo2History,
                    latestSampleText: 'Live stream · just now',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Hospital Continuous Cardiac Oscilloscope Monitor
            const SectionHeading(
              title: 'Cardiac Rhythm (Lead II)',
              trailing: 'Continuous ECG',
            ),
            const SizedBox(height: 8),
            EcgOscilloscope(
              bpm: snapshot.heartRate,
              color: snapshot.isCritical
                  ? coral
                  : (snapshot.isExercise
                      ? const Color(0xFFE89635)
                      : const Color(0xFF00FF66)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SurfacePanel(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.thermostat_rounded,
                            color: forest, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Skin Temp',
                              style: TextStyle(
                                  color: mutedInk,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${snapshot.temperature.toStringAsFixed(1)} °C',
                              style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SurfacePanel(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.speed_rounded,
                            color: forest, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gait Speed',
                              style: TextStyle(
                                  color: mutedInk,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${snapshot.speedKmh} km/h',
                              style: const TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeading(
              title: isFitness ? 'Today’s movement' : 'Location & movement',
              trailing: 'GPS fix active',
            ),
            const SizedBox(height: 11),
            if (isFitness)
              ActivitySummary(name: subject)
            else
              const LocationSummary(),
            const SizedBox(height: 18),
            const ConnectivityCard(),
            const SizedBox(height: 18),
            const DemoNote(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: TelemetryService.instance,
    builder: (context, _) {
      final snapshot = TelemetryService.instance.snapshot;
      return DashboardPage(
        title: 'Health history',
        subtitle: 'A closer look at $name’s readings.',
        children: [
          const LecturerDemoBar(),
          const SizedBox(height: 14),
          const TimeRangeSelector(),
          const SizedBox(height: 18),
          TrendPanel(
            title: 'Heart rate',
            value: '${snapshot.heartRate} bpm',
            caption: 'Resting baseline  ·  60–100 bpm',
            color: snapshot.isCritical
                ? coral
                : (snapshot.isExercise ? const Color(0xFFE89635) : coral),
            values: snapshot.heartRateHistory,
          ),
          const SizedBox(height: 14),
          TrendPanel(
            title: 'Blood oxygen',
            value: '${snapshot.spo2.toStringAsFixed(1)}%',
            caption: 'Typical range  ·  95–100%',
            color: snapshot.spo2 < 90 ? coral : forest,
            values: snapshot.spo2History,
          ),
          const SizedBox(height: 14),
          const DataDisclaimer(),
        ],
      );
    },
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({required this.name, super.key});

  final String name;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _geofenceEnabled = true;

  @override
  Widget build(BuildContext context) => DashboardPage(
    title: 'Location',
    subtitle: 'Movement and safe-zone status for ${widget.name}.',
    children: [
      const DemoMap(),
      const SizedBox(height: 16),
      const LocationSummary(compact: true),
      const SizedBox(height: 16),
      SurfacePanel(
        child: Material(
          color: Colors.white,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _geofenceEnabled,
            activeTrackColor: forest,
            onChanged: (value) => setState(() => _geofenceEnabled = value),
            title: const Text(
              'Home safe zone',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              _geofenceEnabled
                  ? 'Radius  ·  250 m'
                  : 'Location-based alerts paused',
            ),
            secondary: const Icon(Icons.fence_rounded, color: forest),
          ),
        ),
      ),
      const SizedBox(height: 16),
      const SectionHeading(title: 'Recent places'),
      const SizedBox(height: 8),
      const RecentPlaceRow(
        icon: Icons.home_outlined,
        title: 'Home',
        detail: 'Last seen today, 9:41 AM',
      ),
      const RecentPlaceRow(
        icon: Icons.park_outlined,
        title: 'Riverside Gardens',
        detail: 'Yesterday, 4:18 PM',
      ),
      const SizedBox(height: 14),
      const DataDisclaimer(),
    ],
  );
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) => DashboardPage(
    title: 'Activity',
    subtitle: 'Your movement, at a glance.',
    trailing: const NotificationButton(),
    children: [
      const ActivitySummary(name: 'You', expanded: true),
      const SizedBox(height: 16),
      const TrendPanel(
        title: 'Heart rate during movement',
        value: '104 bpm',
        caption: 'Today  ·  sample activity session',
        color: coral,
        values: [
          0.36,
          0.4,
          0.47,
          0.56,
          0.68,
          0.62,
          0.75,
          0.82,
          0.7,
          0.61,
          0.52,
          0.44,
        ],
      ),
      const SizedBox(height: 16),
      const LocationSummary(compact: true),
      const SizedBox(height: 16),
      const DataDisclaimer(),
    ],
  );
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: TelemetryService.instance,
    builder: (context, _) {
      final snapshot = TelemetryService.instance.snapshot;
      return DashboardPage(
        title: 'Alerts',
        subtitle: 'Health and location updates for $name.',
        children: [
          const LecturerDemoBar(),
          const SizedBox(height: 14),
          AlertSummary(expanded: true, snapshot: snapshot),
          const SizedBox(height: 15),
          const SectionHeading(title: 'Recent activity', trailing: 'Today'),
          const SizedBox(height: 8),
          if (snapshot.isCritical) ...[
            const AlertRow(
              icon: Icons.crisis_alert_rounded,
              title: 'CRITICAL: SpO₂ 88% & 138 BPM',
              detail: 'SOS trigger · Caregiver alert sent',
              color: coral,
            ),
          ] else if (snapshot.isExercise) ...[
            const AlertRow(
              icon: Icons.directions_run_rounded,
              title: 'Elevated heart rate (Cardio zone)',
              detail: 'Brisk activity detected · 118 BPM',
              color: Color(0xFFE89635),
            ),
          ],
          const AlertRow(
            icon: Icons.check_circle_outline_rounded,
            title: 'Readings within baseline',
            detail: 'Heart rate and SpO₂ · 9:42 AM',
            color: forest,
          ),
          const AlertRow(
            icon: Icons.location_on_outlined,
            title: 'Home safe zone entered',
            detail: 'Geofence · 9:41 AM',
            color: forest,
          ),
          AlertRow(
            icon: Icons.battery_5_bar_rounded,
            title: 'Band battery is good',
            detail: 'Battery at ${snapshot.batteryPercentage}% · 9:30 AM',
            color: forest,
          ),
          const SizedBox(height: 14),
          const DataDisclaimer(),
        ],
      );
    },
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontal = constraints.maxWidth > 700 ? 36.0 : 20.0;
      final contentWidth = constraints.maxWidth > 900 ? 900.0 : double.infinity;
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: contentWidth,
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 26),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 25),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(color: mutedInk, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 21),
              ...children,
            ],
          ),
        ),
      );
    },
  );
}

class DeviceStatusBanner extends StatelessWidget {
  const DeviceStatusBanner({
    required this.name,
    this.isCritical = false,
    this.battery = 88,
    this.onTap,
    super.key,
  });

  final String name;
  final bool isCritical;
  final int battery;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCritical ? const Color(0xFF9E2A2B) : forest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isCritical ? coral : forest).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCritical ? Icons.emergency_rounded : Icons.watch_rounded,
              color: isCritical ? Colors.white : lime,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar_rounded, size: 10, color: Colors.white),
                          SizedBox(width: 3),
                          Text('3D', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Utano Band AU-001  ·  HiveMQ MQTT · Batt $battery%',
                  style: const TextStyle(color: Color(0xFFD3E5D8), fontSize: 11),
                ),
              ],
            ),
          ),
          LiveRadarDot(
            color: isCritical ? Colors.white : lime,
            label: isCritical ? 'ALERT' : 'LIVE',
          ),
        ],
      ),
    ),
  );
}

class Utano3dHardwareCard extends StatelessWidget {
  const Utano3dHardwareCard({
    required this.onOpen3d,
    this.battery = 94,
    super.key,
  });

  final VoidCallback? onOpen3d;
  final int battery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: forest.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: forest.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: forest.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: forest,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive 3D Hardware Model',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Removable Pod • Washable Fabric Band',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: forest.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: forest.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '360° ORBIT',
                  style: TextStyle(
                    color: forest,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Explore the 3D wearable: spin the band, pop the pod out for washing, view the dual green PPG optical sensors, or inspect the 3-pin snap cradle.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors_rounded, color: forest, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Dual Green LEDs',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.power_settings_new_rounded, color: Color(0xFF38BDF8), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Power Key ⏻',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onOpen3d,
                style: ElevatedButton.styleFrom(
                  backgroundColor: forest,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text(
                  'Launch 3D',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VitalCard extends StatelessWidget {
  const VitalCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.icon,
    required this.color,
    required this.data,
    this.iconWidget,
    this.statusColor,
    this.latestSampleText,
    super.key,
  });

  final String title;
  final String value;
  final String unit;
  final String status;
  final IconData icon;
  final Color color;
  final List<double> data;
  final Widget? iconWidget;
  final Color? statusColor;
  final String? latestSampleText;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            iconWidget ?? Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: mutedInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedCounter(
            value: double.tryParse(value) ?? 0.0,
            unit: unit,
            style: const TextStyle(
              color: ink,
              fontSize: 35,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
            unitStyle: const TextStyle(
              color: mutedInk,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          latestSampleText ?? 'Latest sample · 9:42 AM',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: mutedInk, fontSize: 9.5),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 36,
          width: double.infinity,
          child: CustomPaint(painter: SparklinePainter(data, color)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              (statusColor == coral)
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: statusColor ?? forest,
              size: 13,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: statusColor ?? forest,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class SparklinePainter extends CustomPainter {
  const SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final point = Offset(
        size.width * index / (values.length - 1),
        size.height * (1 - values[index]),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    final last = Offset(size.width, size.height * (1 - values.last));
    canvas.drawCircle(last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({required this.title, this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: const TextStyle(
            color: forest,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
    ],
  );
}

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    required this.child,
    this.padding = const EdgeInsets.all(15),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}

class LocationSummary extends StatelessWidget {
  const LocationSummary({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        const DemoMap(compact: true),
        Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: forest, size: 19),
              const SizedBox(width: 7),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home safe zone',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Within 250 m · Updated 9:41 AM',
                      style: TextStyle(color: mutedInk, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Text(
                '1.2 km/h',
                style: TextStyle(
                  color: ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class DemoMap extends StatelessWidget {
  const DemoMap({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 104 : 220,
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFE8EFE1),
      borderRadius: compact
          ? const BorderRadius.vertical(top: Radius.circular(13))
          : BorderRadius.circular(15),
    ),
    child: CustomPaint(
      painter: const MapPainter(),
      child: Stack(
        children: [
          Positioned(
            left: compact ? 15 : 18,
            top: compact ? 13 : 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SAMPLE LOCATION',
                style: TextStyle(
                  color: mutedInk,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.2, -0.05),
            child: RadarMapPin(compact: compact),
          ),
          Positioned(
            right: 12,
            bottom: 11,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                size: 15,
                color: forest,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class MapPainter extends CustomPainter {
  const MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final park = Paint()..color = const Color(0xFFD4E4C8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.59,
          -size.height * 0.15,
          size.width * 0.32,
          size.height * 0.65,
        ),
        const Radius.circular(22),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.width * 0.2,
          size.height * 0.66,
          size.width * 0.49,
          size.height * 0.62,
        ),
        const Radius.circular(30),
      ),
      park,
    );
    final road = Paint()
      ..color = const Color(0xFFF8FAF5)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-10, size.height * 0.47),
      Offset(size.width + 10, size.height * 0.3),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.43, -10),
      Offset(size.width * 0.53, size.height + 10),
      road,
    );
    final minorRoad = Paint()
      ..color = const Color(0xFFF8FAF5)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.7, -4),
      Offset(size.width * 0.82, size.height + 4),
      minorRoad,
    );
    canvas.drawLine(
      Offset(-4, size.height * 0.78),
      Offset(size.width * 0.48, size.height * 0.72),
      minorRoad,
    );
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => false;
}

class AlertSummary extends StatelessWidget {
  const AlertSummary({this.expanded = false, this.snapshot, super.key});

  final bool expanded;
  final TelemetrySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final isCritical = snapshot?.isCritical ?? false;
    final isExercise = snapshot?.isExercise ?? false;

    final bgColor = isCritical
        ? const Color(0xFFFDEEEC)
        : (isExercise ? const Color(0xFFFEF5EA) : const Color(0xFFEAF2E7));
    final borderColor = isCritical
        ? coral.withValues(alpha: 0.5)
        : (isExercise
            ? const Color(0xFFE89635).withValues(alpha: 0.5)
            : const Color(0xFFD7E5D3));
    final iconColor = isCritical
        ? coral
        : (isExercise ? const Color(0xFFE89635) : forest);
    final titleText = isCritical
        ? (snapshot?.alertMessage ?? 'CRITICAL: Biometric Threshold Exceeded')
        : (isExercise
            ? 'Cardio Zone Active · 118 BPM'
            : 'All readings within baseline');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical
                ? Icons.warning_amber_rounded
                : (isExercise
                    ? Icons.directions_run_rounded
                    : Icons.check_circle_rounded),
            color: iconColor,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 5),
                  Text(
                    isCritical
                        ? 'Immediate intervention recommended. Alert notifications dispatched to registered caregivers.'
                        : (isExercise
                            ? 'Heart rate elevated during aerobic movement. SpO₂ remains stable at 96.5%.'
                            : 'No biometric anomalies detected in the latest sample. Home safe zone is active.'),
                    style: const TextStyle(color: mutedInk, fontSize: 11.5),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      isCritical
                          ? 'Emergency alert active · Live GPS lock'
                          : 'No new alerts · Live stream active',
                      style: const TextStyle(color: mutedInk, fontSize: 10.5),
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

class ConnectivityCard extends StatelessWidget {
  const ConnectivityCard({super.key});

  @override
  Widget build(BuildContext context) => SurfacePanel(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        const Icon(Icons.wifi_rounded, color: forest, size: 19),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wi-Fi connected',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              Text(
                'LTE standby · MQTT / TLS',
                style: TextStyle(fontSize: 9.5, color: mutedInk),
              ),
            ],
          ),
        ),
        const Icon(Icons.battery_5_bar_rounded, color: forest, size: 19),
        const SizedBox(width: 4),
        const Text(
          '84%',
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class ActivitySummary extends StatelessWidget {
  const ActivitySummary({required this.name, this.expanded = false, super.key});

  final String name;
  final bool expanded;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Movement today',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                color: mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '4,826',
              style: TextStyle(
                color: ink,
                fontSize: 31,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text(
                'steps',
                style: TextStyle(color: mutedInk, fontSize: 11),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2E7),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                '64% of goal',
                style: TextStyle(
                  color: forest,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: const LinearProgressIndicator(
            value: 0.64,
            minHeight: 7,
            color: forest,
            backgroundColor: Color(0xFFE8EDE6),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 15),
          const Divider(height: 1, color: line),
          const SizedBox(height: 13),
          const Row(
            children: [
              Expanded(
                child: MetricStat(label: 'Active time', value: '38 min'),
              ),
              Expanded(
                child: MetricStat(label: 'Distance', value: '2.4 km'),
              ),
              Expanded(
                child: MetricStat(label: 'Avg pace', value: '4.1 km/h'),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class MetricStat extends StatelessWidget {
  const MetricStat({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: mutedInk, fontSize: 9.5)),
    ],
  );
}

class TimeRangeSelector extends StatefulWidget {
  const TimeRangeSelector({super.key});

  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
  int _selected = 0;
  final _ranges = const ['Day', 'Week', 'Month'];

  @override
  Widget build(BuildContext context) => SegmentedButton<int>(
    segments: List.generate(
      _ranges.length,
      (index) => ButtonSegment(value: index, label: Text(_ranges[index])),
    ),
    selected: {_selected},
    showSelectedIcon: false,
    onSelectionChanged: (values) => setState(() => _selected = values.first),
  );
}

class TrendPanel extends StatelessWidget {
  const TrendPanel({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.values,
    super.key,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final List<double> values;

  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: mutedInk, fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(caption, style: const TextStyle(color: mutedInk, fontSize: 10.5)),
        const SizedBox(height: 15),
        SizedBox(
          height: 112,
          width: double.infinity,
          child: CustomPaint(painter: TrendPainter(values, color)),
        ),
        const SizedBox(height: 7),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12 AM', style: TextStyle(color: mutedInk, fontSize: 9)),
            Text('6 AM', style: TextStyle(color: mutedInk, fontSize: 9)),
            Text('12 PM', style: TextStyle(color: mutedInk, fontSize: 9)),
            Text('6 PM', style: TextStyle(color: mutedInk, fontSize: 9)),
            Text('Now', style: TextStyle(color: mutedInk, fontSize: 9)),
          ],
        ),
      ],
    ),
  );
}

class TrendPainter extends CustomPainter {
  const TrendPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = size.height * index / 3;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      points.add(
        Offset(
          size.width * index / (values.length - 1),
          size.height * (1 - values[index]),
        ),
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final middle = (previous.dx + current.dx) / 2;
      path.cubicTo(
        middle,
        previous.dy,
        middle,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.01),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = color);
    canvas.drawCircle(
      points.last,
      7,
      Paint()..color = color.withValues(alpha: 0.13),
    );
  }

  @override
  bool shouldRepaint(covariant TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class RecentPlaceRow extends StatelessWidget {
  const RecentPlaceRow({
    required this.icon,
    required this.title,
    required this.detail,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: forest, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(color: mutedInk, fontSize: 10),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: mutedInk, size: 19),
      ],
    ),
  );
}

class AlertRow extends StatelessWidget {
  const AlertRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: const TextStyle(color: mutedInk, fontSize: 10),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: mutedInk, size: 18),
      ],
    ),
  );
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({this.onSignOut, this.profile, super.key});

  final VoidCallback? onSignOut;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Account & Device Options',
    onPressed: () {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle_rounded,
                        color: forest, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? 'Theophany Bandure',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          '${profile?.email ?? "theophany@vitalband.com"} · ${profile?.role.title ?? "Caregiver"}',
                          style: const TextStyle(color: mutedInk, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.phone_forwarded_rounded,
                      color: coral),
                  title: const Text(
                      'Test Automated Emergency Relative Call',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                      'Triggers automated voice dispatch screen directly',
                      style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    TelemetryService.instance.triggerStationarySpike();
                    TelemetryService.instance.fastForwardCountdown();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: ink),
                  title: const Text('Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                      'Return to account login / create demo account',
                      style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSignOut?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: ink,
      fixedSize: const Size(42, 42),
    ),
    icon: const Icon(Icons.more_vert_rounded, size: 21),
  );
}

class DataDisclaimer extends StatelessWidget {
  const DataDisclaimer({super.key});

  @override
  Widget build(BuildContext context) => const Text(
    'Sample prototype data only. Not a medical device; do not use for diagnosis or emergencies.',
    textAlign: TextAlign.center,
    style: TextStyle(color: mutedInk, fontSize: 10, height: 1.4),
  );
}

class DemoNote extends StatelessWidget {
  const DemoNote({super.key});

  @override
  Widget build(BuildContext context) => const Text(
    'DEMO MODE | Sample readings, no medical use',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: mutedInk,
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
    ),
  );
}
