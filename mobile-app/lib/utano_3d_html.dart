const String kUtano3dWebGLHtml = r"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { width: 100%; height: 100%; overflow: hidden; background: #070B14; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
    .flex { display: flex; }
    .flex-col { flex-direction: column; }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .justify-center { justify-content: center; }
    .gap-1 { gap: 0.25rem; }
    .gap-1\.5 { gap: 0.375rem; }
    .gap-2 { gap: 0.5rem; }
    .gap-2\.5 { gap: 0.625rem; }
    .gap-3 { gap: 0.75rem; }
    .relative { position: relative; }
    .absolute { position: absolute; }
    .inset-0 { top: 0; right: 0; bottom: 0; left: 0; }
    .w-full { width: 100%; }
    .h-full { height: 100%; }
    .block { display: block; }
    .hidden { display: none; }
    .pointer-events-none { pointer-events: none; }
    .pointer-events-auto { pointer-events: auto; }
    .rounded-lg { border-radius: 0.5rem; }
    .rounded-xl { border-radius: 0.75rem; }
    .rounded-2xl { border-radius: 1rem; }
    .rounded-full { border-radius: 9999px; }
    .border { border-width: 1px; border-style: solid; }
    .border-slate-700 { border-color: #334155; }
    .border-slate-800 { border-color: #1e293b; }
    .bg-slate-900 { background-color: #0f172a; }
    .bg-slate-800 { background-color: #1e293b; }
    .text-white { color: #ffffff; }
    .text-slate-200 { color: #e2e8f0; }
    .text-slate-300 { color: #cbd5e1; }
    .text-slate-400 { color: #94a3b8; }
    .text-cyan-300 { color: #67e8f9; }
    .text-cyan-400 { color: #22d3ee; }
    .text-emerald-400 { color: #34d399; }
    .text-amber-300 { color: #fcd34d; }
    .font-bold { font-weight: 700; }
    .font-semibold { font-weight: 600; }
    .font-mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; }
    .shadow-xl { box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.4), 0 8px 10px -6px rgba(0, 0, 0, 0.4); }
    .backdrop-blur-md { backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); }
    .grid { display: grid; }
    .grid-cols-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    @media (min-width: 640px) {
      .sm\:grid-cols-4 { grid-template-columns: repeat(4, minmax(0, 1fr)); }
    }
</style>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      user-select: none;
      -webkit-user-select: none;
    }
    .cam-pill {
      transition: all 0.22s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .cam-pill.active {
      background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
      color: #ffffff;
      border-color: #38bdf8;
      font-weight: 600;
      box-shadow: 0 0 16px rgba(56, 189, 248, 0.4);
      transform: translateY(-1px);
    }
    .hotspot-btn {
      position: absolute;
      transform: translate(-50%, -50%);
      transition: transform 0.18s ease, opacity 0.2s ease, background-color 0.2s ease;
      cursor: pointer;
      z-index: 20;
    }
    .hotspot-btn:hover {
      transform: translate(-50%, -50%) scale(1.12);
      z-index: 30;
    }
    @keyframes pulseRing {
      0% { transform: scale(0.9); opacity: 0.85; }
      70% { transform: scale(1.75); opacity: 0; }
      100% { transform: scale(1.75); opacity: 0; }
    }
    .ring-anim::before {
      content: '';
      position: absolute;
      inset: -4px;
      border-radius: 9999px;
      border: 2px solid currentColor;
      animation: pulseRing 2s infinite;
    }
    input[type=range].v-slider {
      -webkit-appearance: none;
      appearance: none;
      background: transparent;
      cursor: pointer;
    }
    input[type=range].v-slider::-webkit-slider-runnable-track {
      height: 6px;
      border-radius: 999px;
      background: linear-gradient(90deg, #1e293b 0%, #0284c7 50%, #10b981 100%);
    }
    input[type=range].v-slider::-webkit-slider-thumb {
      -webkit-appearance: none;
      appearance: none;
      width: 16px;
      height: 16px;
      border-radius: 50%;
      background: #ffffff;
      border: 2.5px solid #38bdf8;
      box-shadow: 0 0 10px rgba(56, 189, 248, 0.9);
      margin-top: -5px;
    }
  </style>
  <style>
    html, body { width: 100%; height: 100%; min-height: 0; overflow: hidden; }
    body { padding: 6px; }
    #experience { display: flex; flex-direction: column; width: 100%; height: 100%; min-height: 0; gap: 8px; padding: 8px; overflow: hidden; }
    #stage-wrap { position: relative; flex: 1 1 auto; min-height: 0; width: 100%; overflow: hidden; }
    #stage-wrap > canvas { display: block; width: 100%; height: 100%; }
    #hud-overlay, #hotspots-layer { position: absolute; inset: 0; }
    #hud-overlay { pointer-events: none; }
    #hotspots-layer { pointer-events: none; overflow: hidden; }
    #stage-mode-card { position: absolute; z-index: 4; top: 8px; left: 8px; width: min(210px, calc(100% - 132px)); }
    #stage-telemetry { position: absolute; z-index: 4; top: 8px; right: 8px; max-width: 115px; }
    #stage-pod-controls { position: absolute; z-index: 4; bottom: 8px; left: 8px; max-width: calc(100% - 16px); flex-wrap: wrap; }
    #stage-actions { position: absolute; z-index: 4; right: 8px; bottom: 8px; }
    @media (max-width: 480px) {
      body { padding: 4px; }
      #experience { gap: 6px; padding: 6px; }
      #stage-mode-card { top: 6px; left: 6px; padding: 6px; }
      #stage-telemetry { top: 6px; right: 6px; padding: 6px; }
      #stage-mode-card #mode-desc { display: none; }
      #stage-pod-controls { right: 8px; bottom: 42px; }
      #stage-actions { right: 8px; bottom: 8px; }
    }
  </style>
</head>
<body class="bg-transparent text-[var(--foreground)] antialiased p-1 sm:p-2">

  <div id="experience" class="bg-[var(--card)] text-[var(--foreground)] border border-[var(--border)] rounded-2xl p-3.5 shadow-2xl overflow-hidden flex flex-col gap-2.5">
    
    <!-- Top Bar: Brand + Guided Onboarding Wizard Steps -->
    <div class="flex flex-wrap items-center justify-between gap-2 pb-2 border-b border-[var(--border)]">
      <div class="flex items-center gap-2.5">
        <div class="w-9 h-9 rounded-xl bg-slate-900 border border-cyan-500/40 flex items-center justify-center p-1.5 relative shadow-inner">
          <svg class="w-full h-full text-cyan-400" viewBox="0 0 100 100" fill="none">
            <path d="M50 82 C20 60 12 36 25 22 C35 12 45 20 50 30 C55 20 65 12 75 22 C88 36 80 60 50 82 Z" stroke="#ffffff" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M18 48 L38 48 L44 32 L53 64 L60 42 L66 48 L82 48" stroke="#38bdf8" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div>
          <div class="flex items-center gap-1.5">
            <h2 class="text-sm font-bold text-[var(--foreground)] tracking-tight">Utano Interactive 3D Hardware Experience</h2>
            <span id="status-badge" class="text-[10px] bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 px-1.5 py-0.5 rounded font-mono font-semibold">POD DOCKED • LIVE</span>
          </div>
          <p class="text-xs text-[var(--muted-foreground)]">Tap the 3D hotspots directly on the band, snap the pod in/out, or peel open the internal PCB layers</p>
        </div>
      </div>

      <!-- Interactive Guided Experience Controls -->
      <div class="flex items-center gap-1.5">
        <button id="btn-tour" onclick="startGuidedTour()" class="px-2.5 py-1 rounded-lg bg-cyan-950/90 hover:bg-cyan-900 border border-cyan-500/50 text-xs font-semibold text-cyan-300 transition-all flex items-center gap-1.5 shadow">
          <span>▶</span>
          <span id="tour-txt">Guided Setup Tour</span>
        </button>
        <button id="btn-bg" onclick="toggleBg()" class="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 border border-slate-600 text-xs font-medium text-white transition-all">
          ☀️ Studio
        </button>
      </div>
    </div>

    <!-- Main 3D Interactive Stage -->
    <div id="stage-wrap" class="relative w-full h-[390px] rounded-xl border border-slate-800 overflow-hidden cursor-grab active:cursor-grabbing flex items-center justify-center select-none">
      <canvas id="mini-gl" class="w-full h-full block"></canvas>
      <canvas id="hud-overlay" class="w-full h-full block absolute inset-0 pointer-events-none"></canvas>

      <!-- Dynamic 3D Anchor Hotspots Container (Clickable directly in 3D space!) -->
      <div id="hotspots-layer" class="absolute inset-0 pointer-events-none overflow-hidden"></div>

      <!-- Top-Left Interactive Step / Context Card -->
      <div id="stage-mode-card" class="absolute top-2 left-2 bg-slate-900/92 backdrop-blur-md border border-slate-700/80 rounded-xl p-2.5 max-w-[210px] sm:max-w-[245px] shadow-xl pointer-events-auto">
        <div class="flex items-center justify-between gap-1.5">
          <div id="mode-title" class="text-[11px] sm:text-xs font-bold text-cyan-300 flex items-center gap-1 truncate">
            <span>🔍</span> <span>What's Inside Pod</span>
          </div>
          <span id="step-counter" class="text-[9px] font-mono px-1 py-0.2 rounded bg-slate-800 text-slate-300 border border-slate-700 shrink-0">STEP 4/4</span>
        </div>
        <div id="mode-desc" class="text-[10px] sm:text-[11px] text-slate-300 leading-tight mt-1 line-clamp-2">
          Tap any floating 3D board to isolate it and inspect hardware.
        </div>
        <!-- Context-sensitive Interactive Action Button inside the HUD card -->
        <div class="mt-1.5 pt-1.5 border-t border-slate-800 flex items-center justify-between gap-1">
          <button id="context-action-btn" onclick="triggerContextSim()" class="w-full py-1 px-2 rounded-lg bg-gradient-to-r from-cyan-600 to-sky-600 hover:from-cyan-500 hover:to-sky-500 text-white font-semibold text-[10px] sm:text-[11px] flex items-center justify-center gap-1 shadow transition-all">
            <span id="context-action-icon">⚡</span>
            <span id="context-action-lbl">Run Hardware Diagnostic</span>
          </button>
        </div>
      </div>

      <!-- Top-Right Live Biometric & Connectivity Telemetry HUD -->
      <div id="stage-telemetry" class="absolute top-2 right-2 bg-slate-900/90 backdrop-blur-md border border-slate-700/80 rounded-xl px-2.5 py-1.5 flex flex-col gap-0.5 pointer-events-none shadow-lg text-[10px]">
        <div class="flex items-center justify-between gap-2">
          <span class="text-slate-400 flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span> HR</span>
          <span id="hud-hr" class="font-mono font-bold text-emerald-400">72 BPM</span>
        </div>
        <div class="flex items-center justify-between gap-2">
          <span class="text-slate-400">SpO₂/Temp</span>
          <span id="hud-spo2" class="font-mono font-bold text-cyan-300">98% • 36.6°C</span>
        </div>
        <div class="flex items-center justify-between gap-2 pt-0.5 border-t border-slate-800/80 text-[9px]">
          <span class="text-slate-400">Link</span>
          <span id="hud-link" class="font-mono text-amber-300">LTE+Wi-Fi</span>
        </div>
      </div>

      <!-- Bottom-Left Tactile Explode & Peel Scrubber -->
      <div id="stage-pod-controls" class="absolute bottom-2.5 left-2.5 bg-slate-900/90 backdrop-blur-md border border-slate-700/90 text-slate-200 text-xs px-3 py-1.5 rounded-xl flex items-center gap-2.5 shadow-lg">
        <button onclick="toggleDock()" class="px-2 py-0.5 rounded bg-slate-800 hover:bg-slate-700 border border-slate-600 text-[11px] font-semibold text-cyan-300 transition-all" id="quick-dock-btn">
          ⇄ Pop Pod Out
        </button>
        <div class="h-3.5 w-[1px] bg-slate-700"></div>
        <div class="flex items-center gap-1.5">
          <span class="text-cyan-400 font-semibold text-[11px]">Peel Pod:</span>
          <input id="exp-slider" type="range" min="0" max="100" value="100" class="v-slider w-20 sm:w-24" oninput="onSliderExplode(this.value)">
          <span id="exp-val" class="font-mono text-[11px] text-cyan-300 w-7">100%</span>
        </div>
      </div>

      <!-- Bottom-Right Interactive Hint / Layer Reset -->
      <div id="stage-actions" class="absolute bottom-2.5 right-2.5 flex items-center gap-1.5">
        <button id="btn-reset-layer" onclick="selectLayer(-1)" class="hidden bg-amber-950/90 backdrop-blur-md border border-amber-500/60 hover:border-amber-400 text-[11px] font-semibold text-amber-300 px-2.5 py-1.5 rounded-xl transition-all shadow-lg">
          ↺ Show All 5 Layers
        </button>
        <button onclick="toggleSpin()" class="bg-slate-900/90 backdrop-blur-md border border-slate-700 hover:border-slate-500 text-[11px] font-medium text-slate-200 px-2.5 py-1.5 rounded-xl flex items-center gap-1.5 shadow-lg">
          <span id="sp-dot" class="w-1.5 h-1.5 rounded-full bg-slate-500"></span>
          <span id="sp-txt">Orbit: Manual</span>
        </button>
      </div>
    </div>

    <!-- Bottom Interactive Experience Bar (4 Clean Core Presets) -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-0.5 text-xs">
      <button id="v-docked" onclick="setPreset('docked')" class="cam-pill px-2.5 py-2 rounded-xl border border-slate-700 text-slate-300 flex items-center justify-center gap-1.5 font-medium">
        <span>💪</span> <span>1. Worn on Arm</span>
      </button>
      <button id="v-split" onclick="setPreset('split')" class="cam-pill px-2.5 py-2 rounded-xl border border-slate-700 text-slate-300 flex items-center justify-center gap-1.5 font-medium">
        <span>🔄</span> <span>2. Removable Pod</span>
      </button>
      <button id="v-sensors" onclick="setPreset('sensors')" class="cam-pill px-2.5 py-2 rounded-xl border border-slate-700 text-slate-300 flex items-center justify-center gap-1.5 font-medium">
        <span>💚</span> <span>3. Skin Sensors</span>
      </button>
      <button id="v-inside" onclick="setPreset('inside')" class="cam-pill active px-2.5 py-2 rounded-xl border border-slate-700 flex items-center justify-center gap-1.5 font-medium">
        <span>🔍</span> <span>4. Inside the Pod</span>
      </button>
    </div>

  </div>

  <script>
    const canvas = document.getElementById('mini-gl');
    const hudCanvas = document.getElementById('hud-overlay');
    const hudCtx = hudCanvas.getContext('2d');
    const hotspotsLayer = document.getElementById('hotspots-layer');
    const gl = canvas.getContext('webgl', { antialias: true, alpha: false }) || canvas.getContext('experimental-webgl');

    let width = 0, height = 0, dpr = 1;
    function resize() {
      if (!canvas || !canvas.parentElement) return;
      const r = canvas.parentElement.getBoundingClientRect();
      width = Math.max(1, Math.floor(r.width));
      height = Math.max(1, Math.floor(r.height));
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      hudCanvas.width = width * dpr;
      hudCanvas.height = height * dpr;
      if (gl) gl.viewport(0, 0, canvas.width, canvas.height);
    }
    window.addEventListener('resize', resize);
    if ('ResizeObserver' in window) {
      new ResizeObserver(resize).observe(canvas.parentElement);
    }
    resize();

    // =========================================================================
    // UX STATE & INTERACTIVE SIMULATIONS
    // =========================================================================
    let currentMode = 'inside';
    let selectedLayer = -1; // -1 = all, 0..4 = specific internal layer isolated
    let rotX = 0.35, rotY = -0.42;
    let targetRotX = 0.35, targetRotY = -0.42;
    let zoom = 1.16, targetZoom = 1.16;
    let detach = 1.0, targetDetach = 1.0;
    let explode = 1.0, targetExplode = 1.0;
    let podFlip = 0.0, targetPodFlip = 0.0;
    let sleeveFade = 1.0, targetSleeveFade = 1.0;
    let sceneOffsetX = -0.48, targetSceneOffsetX = -0.48;
    let sceneOffsetY = -0.04, targetSceneOffsetY = -0.04;
    let autoSpin = false;
    let studioWhite = true;
    let washSplash = false;
    let clock = 0;

    // Tactile Feedback Effects
    let snapShockwave = 0.0; // 1.0 -> 0.0 concentric magnetic ring when pod snaps in/out
    let simEffectTimer = 0.0; // Active hardware diagnostic simulation timer
    let simEffectType = '';   // 'gps', 'lte', 'sensors', 'battery', 'scan', 'stretch'
    let fabricStretch = 0.0;  // Elastic stretch animation for Nylon-Spandex weave
    let tourTimer = null;
    let tourStep = 0;

    // 5 Internal Layers Metadata ("What's Inside the Pod")
    const internalLayersMeta = [
      {
        idx: 0,
        title: 'Water-resistant casing',
        sub: 'Splash & sweat resistant PC/ABS shell',
        detail: 'Protects internal electronics from sweat & rain. Features illuminated Heart-ECG emblem & cyan status bar.',
        actionLbl: '💧 Test Splash Seal & LED Bar',
        simType: 'casing',
        color: '#0284c7',
        camRotX: 0.45, camRotY: -0.35, camZoom: 1.38
      },
      {
        idx: 1,
        title: 'GPS module',
        sub: 'Location & movement speed tracking',
        detail: 'Ceramic L1 patch antenna locks onto multi-constellation satellites for real-time outdoor location & speed.',
        actionLbl: '🛰️ Simulate Live GPS Satellite Lock',
        simType: 'gps',
        color: '#059669',
        camRotX: 0.40, camRotY: -0.50, camZoom: 1.42
      },
      {
        idx: 2,
        title: 'Cellular (LTE) & Wi-Fi + Main PCB',
        sub: 'Automatic fallback & controller MCU',
        detail: 'Main controller PCB processes biometric streams and automatically falls back from Wi-Fi to LTE cellular.',
        actionLbl: '📡 Test Wi-Fi → LTE Auto-Fallback',
        simType: 'lte',
        color: '#0d9488',
        camRotX: 0.34, camRotY: -0.42, camZoom: 1.42
      },
      {
        idx: 3,
        title: 'Battery (1000mAh LiPo)',
        sub: 'High-density rechargeable cell',
        detail: '1000mAh lithium-polymer pouch cell with smart power management for continuous day-and-night monitoring.',
        actionLbl: '⚡ Simulate Fast Pogo Charge Surge',
        simType: 'battery',
        color: '#d97706',
        camRotX: 0.30, camRotY: -0.38, camZoom: 1.42
      },
      {
        idx: 4,
        title: 'Sensors (HR, SpO₂, Temp, Motion)',
        sub: 'Direct skin optical array (| : |)',
        detail: 'Dual green 525nm PPG optical bars, infrared SpO₂ emitter, clinical skin thermistor & 6-axis motion IMU.',
        actionLbl: '💚 Pulse Dual Green Optical Sensors',
        simType: 'sensors',
        color: '#10b981',
        camRotX: -0.25, camRotY: 0.35, camZoom: 1.45
      }
    ];

    const droplets = Array.from({ length: 40 }, (_, i) => ({
      angle: (i / 40) * Math.PI * 2 + Math.random() * 0.5,
      radius: 1.35 + Math.random() * 1.45,
      y: (Math.random() - 0.5) * 1.65,
      speed: 0.7 + Math.random() * 1.3,
      size: 2.5 + Math.random() * 4.5,
      phase: Math.random() * Math.PI * 2
    }));

    // Pointer & Drag Handling
    let isDragging = false, dragDist = 0, lastX = 0, lastY = 0;
    canvas.addEventListener('mousedown', (e) => {
      isDragging = true; dragDist = 0; lastX = e.clientX; lastY = e.clientY;
      stopGuidedTour();
      autoSpin = false; updateSpinUI();
    });
    window.addEventListener('mouseup', () => { isDragging = false; });
    window.addEventListener('mousemove', (e) => {
      if (!isDragging) return;
      const dx = e.clientX - lastX, dy = e.clientY - lastY;
      dragDist += Math.hypot(dx, dy);
      targetRotY += dx * 0.008;
      targetRotX += dy * 0.008;
      targetRotX = Math.max(-1.45, Math.min(1.45, targetRotX));
      lastX = e.clientX; lastY = e.clientY;
    });

    // Double-click anywhere on the 3D stage to smoothly cycle Worn -> Detached -> Exploded Inside!
    canvas.addEventListener('dblclick', () => {
      stopGuidedTour();
      if (currentMode === 'docked') setPreset('split');
      else if (currentMode === 'split') setPreset('inside');
      else setPreset('docked');
    });

    canvas.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) {
        isDragging = true; dragDist = 0; lastX = e.touches[0].clientX; lastY = e.touches[0].clientY;
        stopGuidedTour();
        autoSpin = false; updateSpinUI();
      }
    }, { passive: true });
    window.addEventListener('touchend', () => { isDragging = false; });
    window.addEventListener('touchmove', (e) => {
      if (!isDragging || e.touches.length !== 1) return;
      const dx = e.touches[0].clientX - lastX, dy = e.touches[0].clientY - lastY;
      dragDist += Math.hypot(dx, dy);
      targetRotY += dx * 0.01;
      targetRotX += dy * 0.01;
      targetRotX = Math.max(-1.45, Math.min(1.45, targetRotX));
      lastX = e.touches[0].clientX; lastY = e.touches[0].clientY;
    }, { passive: true });

    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      targetZoom += e.deltaY * -0.0012;
      targetZoom = Math.max(0.65, Math.min(2.4, targetZoom));
    }, { passive: false });

    function toggleSpin() {
      autoSpin = !autoSpin;
      updateSpinUI();
    }
    function updateSpinUI() {
      document.getElementById('sp-txt').innerText = autoSpin ? 'Orbit: Auto' : 'Orbit: Manual';
      document.getElementById('sp-dot').className = autoSpin
        ? 'w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse'
        : 'w-1.5 h-1.5 rounded-full bg-slate-500';
    }

    function toggleBg() {
      studioWhite = !studioWhite;
      document.getElementById('btn-bg').innerText = studioWhite ? '☀️ Studio' : '🛰️ Dark HUD';
    }

    function toggleDock() {
      stopGuidedTour();
      snapShockwave = 1.0;
      if (targetDetach > 0.5) {
        setPreset('docked');
      } else {
        setPreset('split');
      }
    }

    function onSliderExplode(val) {
      stopGuidedTour();
      const v = parseFloat(val) / 100.0;
      targetExplode = v;
      document.getElementById('exp-val').innerText = Math.round(v * 100) + '%';
      if (v > 0.12) {
        currentMode = 'inside';
        targetDetach = 1.0;
        targetSleeveFade = Math.min(1.0, v * 1.15);
        targetSceneOffsetX = -0.48 * v;
        updateActivePill('inside');
      } else {
        targetSleeveFade = 0.0;
        targetSceneOffsetX = 0.0;
      }
    }

    function selectLayer(idx) {
      stopGuidedTour();
      selectedLayer = (selectedLayer === idx) ? -1 : idx;
      const resetBtn = document.getElementById('btn-reset-layer');
      if (selectedLayer === -1) {
        resetBtn.classList.add('hidden');
        document.getElementById('mode-title').innerHTML = '<span>🔍</span> <span>What\'s Inside the Pod (All 5 Layers)</span>';
        document.getElementById('mode-desc').innerText = 'Tap any floating 3D board or callout on the right to isolate it and run a live hardware test.';
        document.getElementById('context-action-lbl').innerText = 'Run Full System Diagnostic Scan';
        targetRotX = 0.35; targetRotY = -0.42; targetZoom = 1.16;
      } else {
        const L = internalLayersMeta[selectedLayer];
        resetBtn.classList.remove('hidden');
        document.getElementById('mode-title').innerHTML = `<span>✨</span> <span>${L.title}</span>`;
        document.getElementById('mode-desc').innerText = L.detail;
        document.getElementById('context-action-lbl').innerText = L.actionLbl;
        targetRotX = L.camRotX;
        targetRotY = L.camRotY;
        targetZoom = L.camZoom;
        simEffectType = L.simType;
        simEffectTimer = 1.0;
      }
    }

    function triggerContextSim() {
      simEffectTimer = 1.0;
      snapShockwave = 1.0;
      if (currentMode === 'docked') {
        simEffectType = 'scan';
        document.getElementById('hud-hr').innerText = (71 + Math.floor(Math.random() * 5)) + ' BPM';
      } else if (currentMode === 'split') {
        toggleDock();
      } else if (currentMode === 'sensors') {
        simEffectType = 'sensors';
        document.getElementById('hud-hr').innerText = '75 BPM (LOCKED)';
      } else if (currentMode === 'fibers') {
        simEffectType = 'stretch';
        fabricStretch = 1.0;
      } else if (currentMode === 'wash') {
        washSplash = true;
        simEffectType = 'wash';
      } else if (currentMode === 'inside') {
        if (selectedLayer !== -1) {
          simEffectType = internalLayersMeta[selectedLayer].simType;
        } else {
          simEffectType = 'all_layers';
        }
      }
    }

    // Guided 4-Step Interactive Tour (1. Worn -> 2. Removable Pod -> 3. Skin Sensors -> 4. Inside Pod)
    function startGuidedTour() {
      if (tourTimer) {
        stopGuidedTour();
        return;
      }
      const steps = ['docked', 'split', 'sensors', 'inside'];
      tourStep = 0;
      document.getElementById('tour-txt').innerText = '⏸ Stop Tour';
      setPreset(steps[tourStep], true);
      tourTimer = setInterval(() => {
        tourStep = (tourStep + 1) % steps.length;
        setPreset(steps[tourStep], true);
      }, 4200);
    }

    function stopGuidedTour() {
      if (tourTimer) {
        clearInterval(tourTimer);
        tourTimer = null;
        document.getElementById('tour-txt').innerText = '▶ Guided Setup Tour';
      }
    }

    function updateActivePill(mode) {
      document.querySelectorAll('.cam-pill').forEach(b => b.classList.remove('active'));
      const btn = document.getElementById('v-' + mode);
      if (btn) btn.classList.add('active');
    }

    const modeConfigs = {
      docked: {
        title: '💪 1. Upper-Arm Sleeve (Worn)',
        step: 'STEP 1/4',
        desc: 'Pod sits securely inside the breathable sleeve. Tap the 3D pod hotspot to pop it out!',
        action: '💓 Pulse Live Heart & ECG Telemetry',
        badge: 'POD DOCKED • ACTIVE'
      },
      split: {
        title: '🔄 2. Removable Electronics Pod',
        step: 'STEP 2/4',
        desc: 'Water-resistant pod detaches smoothly from the sleeve cradle. Tap "Snap Pod In" to lock it magnetically.',
        action: '🧲 Snap Pod Magnetically Into Sleeve',
        badge: 'POD DETACHED'
      },
      sensors: {
        title: '💚 3. Skin-Contact Optical Array',
        step: 'STEP 3/4',
        desc: 'Dual glowing green PPG optical LEDs sit directly against the skin through the inner cutout for accurate readings.',
        action: '💚 Boost 525nm Optical Skin Scan',
        badge: 'SKIN CONTACT LOCKED'
      },
      inside: {
        title: '🔍 4. What\'s Inside the Pod (5-Layer CAD)',
        step: 'STEP 4/4',
        desc: 'Tap any of the 5 floating 3D hardware layers or callout cards on the right to isolate & test that component!',
        action: '⚡ Pulse All 5 Internal Hardware Layers',
        badge: 'EXPLODED TEARDOWN'
      }
    };

    function setPreset(mode, fromTour = false) {
      if (!fromTour) stopGuidedTour();
      currentMode = mode;
      selectedLayer = -1;
      document.getElementById('btn-reset-layer').classList.add('hidden');
      updateActivePill(mode);

      const cfg = modeConfigs[mode] || modeConfigs.docked;
      document.getElementById('mode-title').innerText = cfg.title;
      document.getElementById('step-counter').innerText = cfg.step;
      document.getElementById('mode-desc').innerText = cfg.desc;
      document.getElementById('context-action-lbl').innerText = cfg.action;
      document.getElementById('status-badge').innerText = cfg.badge;

      washSplash = false;
      snapShockwave = 1.0;

      if (mode === 'docked') {
        autoSpin = true; updateSpinUI();
        targetDetach = 0.0; targetExplode = 0.0; targetPodFlip = 0.0; targetSleeveFade = 0.0;
        targetRotX = 0.26; targetRotY = -0.22; targetZoom = 1.14;
        targetSceneOffsetX = 0.0; targetSceneOffsetY = 0.0;
        document.getElementById('quick-dock-btn').innerText = '⇄ Pop Pod Out';
      } else if (mode === 'split') {
        autoSpin = false; updateSpinUI();
        targetDetach = 1.0; targetExplode = 0.0; targetPodFlip = 0.0; targetSleeveFade = 0.0;
        targetRotX = 0.28; targetRotY = -0.25; targetZoom = 0.96;
        targetSceneOffsetX = 0.0; targetSceneOffsetY = 0.0;
        document.getElementById('quick-dock-btn').innerText = '⇄ Snap Pod In';
      } else if (mode === 'sensors') {
        autoSpin = false; updateSpinUI();
        targetDetach = 1.0; targetExplode = 0.0; targetPodFlip = 1.0; targetSleeveFade = 0.0;
        targetRotX = -0.18; targetRotY = 0.28; targetZoom = 1.38;
        targetSceneOffsetX = -1.22; targetSceneOffsetY = 0.0;
        document.getElementById('quick-dock-btn').innerText = '⇄ Snap Pod In';
      } else if (mode === 'inside') {
        autoSpin = false; updateSpinUI();
        targetDetach = 1.0; targetExplode = 1.0; targetPodFlip = 0.0; targetSleeveFade = 1.0;
        targetRotX = 0.35; targetRotY = -0.42; targetZoom = 1.16;
        targetSceneOffsetX = -0.48; targetSceneOffsetY = -0.04;
        document.getElementById('quick-dock-btn').innerText = '⇄ Assemble & Dock';
      }

      document.getElementById('exp-slider').value = Math.round(targetExplode * 100);
      document.getElementById('exp-val').innerText = Math.round(targetExplode * 100) + '%';
    }

    // =========================================================================
    // PROCEDURAL HIGH-RES TEXTURES (Nylon-Spandex Weave, Pod, Cradle, PCBs, Battery)
    // =========================================================================
    function bindAndUploadTex(tex, canvasElem, repeat = false) {
      gl.bindTexture(gl.TEXTURE_2D, tex);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, canvasElem);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, repeat ? gl.REPEAT : gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, repeat ? gl.REPEAT : gl.CLAMP_TO_EDGE);
    }

    const strapTex = gl.createTexture();
    function initStrapTex() {
      const c = document.createElement('canvas');
      c.width = 1024; c.height = 512;
      const ctx = c.getContext('2d');
      ctx.fillStyle = '#14171d';
      ctx.fillRect(0, 0, 1024, 512);

      // Interwoven diagonal herringbone nylon-spandex weave
      for (let y = 0; y < 512; y += 2) {
        for (let x = 0; x < 1024; x += 2) {
          const rib = Math.sin((x * 0.24) + (y % 16 < 8 ? y * 0.24 : -y * 0.24));
          const crossWeave = Math.cos((x * 0.15) - (y * 0.30));
          const heather = ((x * 37 ^ y * 73) % 31) - 15;
          const v = Math.max(10, Math.min(72, 24 + rib * 9 + crossWeave * 5.5 + heather * 0.7));
          ctx.fillStyle = `rgb(${v}, ${v + 2}, ${v + 5})`;
          ctx.fillRect(x, y, 2, 2);
        }
      }

      // Silver-grey spandex stretch filaments
      ctx.lineWidth = 1.2;
      for (let i = 0; i < 720; i++) {
        const fx = (i * 97) % 1024;
        const fy = 44 + ((i * 53) % 424);
        const len = 11 + (i % 15);
        const dir = (i % 2 === 0) ? 0.55 : -0.55;
        const alpha = 0.09 + (i % 5) * 0.038;
        ctx.strokeStyle = `rgba(195, 208, 225, ${alpha})`;
        ctx.beginPath();
        ctx.moveTo(fx, fy);
        ctx.lineTo(fx + len, fy + len * dir);
        ctx.stroke();
      }

      // Ribbed Elastic Piping Hems
      ctx.fillStyle = '#0d0f14';
      ctx.fillRect(0, 0, 1024, 44);
      ctx.fillRect(0, 468, 1024, 44);
      for (let x = 0; x < 1024; x += 4) {
        ctx.fillStyle = (x % 8 === 0) ? '#1c2029' : '#090b0e';
        ctx.fillRect(x, 0, 2, 42);
        ctx.fillRect(x, 470, 2, 42);
      }

      // Double Lockstitch Seam Thread
      ctx.strokeStyle = '#384152';
      ctx.lineWidth = 2.8;
      ctx.setLineDash([8, 5]);
      ctx.beginPath();
      ctx.moveTo(0, 44); ctx.lineTo(1024, 44);
      ctx.moveTo(0, 52); ctx.lineTo(1024, 52);
      ctx.moveTo(0, 468); ctx.lineTo(1024, 468);
      ctx.moveTo(0, 460); ctx.lineTo(1024, 460);
      ctx.stroke();
      ctx.setLineDash([]);

      bindAndUploadTex(strapTex, c, true);
    }

    const podTex = gl.createTexture();
    function initPodTex() {
      const c = document.createElement('canvas');
      c.width = 1024; c.height = 1024;
      const ctx = c.getContext('2d');
      ctx.fillStyle = '#161920';
      ctx.fillRect(0, 0, 1024, 1024);
      for (let y = 0; y < 1024; y += 4) {
        for (let x = 0; x < 1024; x += 4) {
          const g = ((x * 13 + y * 29) % 7) - 3;
          const v = 22 + g;
          ctx.fillStyle = `rgb(${v}, ${v + 2}, ${v + 5})`;
          ctx.fillRect(x, y, 4, 4);
        }
      }

      // Front Face: Heart + ECG & Horizontal Cyan Light Bar
      const cxF = 512, cyF = 205;
      ctx.save();
      ctx.strokeStyle = 'rgba(255,255,255,0.08)';
      ctx.lineWidth = 8;
      ctx.beginPath(); ctx.roundRect(120, 45, 784, 420, 150); ctx.stroke();

      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 10;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.beginPath();
      const hw = 64;
      ctx.moveTo(cxF, cyF + 54);
      ctx.bezierCurveTo(cxF - hw * 1.35, cyF - 20, cxF - hw * 0.85, cyF - 68, cxF, cyF - 25);
      ctx.bezierCurveTo(cxF + hw * 0.85, cyF - 68, cxF + hw * 1.35, cyF - 20, cxF, cyF + 54);
      ctx.stroke();

      ctx.strokeStyle = '#7dd3fc';
      ctx.lineWidth = 8.5;
      ctx.beginPath();
      ctx.moveTo(cxF - 90, cyF + 5);
      ctx.lineTo(cxF - 28, cyF + 5);
      ctx.lineTo(cxF - 14, cyF - 35);
      ctx.lineTo(cxF + 8, cyF + 35);
      ctx.lineTo(cxF + 23, cyF - 10);
      ctx.lineTo(cxF + 38, cyF + 5);
      ctx.lineTo(cxF + 90, cyF + 5);
      ctx.stroke();

      const barY = 350, barW = 165, barH = 22;
      ctx.beginPath();
      ctx.roundRect(cxF - barW / 2, barY - barH / 2, barW, barH, 11);
      ctx.fillStyle = '#38bdf8';
      ctx.shadowColor = '#00d8ff';
      ctx.shadowBlur = 28;
      ctx.fill();

      ctx.beginPath();
      ctx.roundRect(cxF - barW * 0.36, barY - barH * 0.26, barW * 0.72, barH * 0.52, 6);
      ctx.fillStyle = '#ffffff';
      ctx.fill();
      ctx.restore();

      // Back Face: Skin-Contact Sensor Area (| : | Dual Green Optical Bars)
      const cxB = 512, cyB = 768;
      ctx.save();
      const sw = 270, sh = 185, sx = cxB - sw / 2, sy = cyB - sh / 2;
      ctx.beginPath(); ctx.roundRect(sx - 12, sy - 12, sw + 24, sh + 24, 38);
      ctx.fillStyle = '#07090c'; ctx.fill();
      ctx.beginPath(); ctx.roundRect(sx, sy, sw, sh, 30);
      ctx.fillStyle = '#030705'; ctx.fill();

      const glowR = ctx.createRadialGradient(cxB, cyB, 8, cxB, cyB, 145);
      glowR.addColorStop(0, 'rgba(16, 255, 95, 0.70)');
      glowR.addColorStop(0.6, 'rgba(10, 200, 75, 0.25)');
      glowR.addColorStop(1, 'rgba(0,0,0,0)');
      ctx.fillStyle = glowR;
      ctx.fillRect(sx - 10, sy - 10, sw + 20, sh + 20);

      [-68, 68].forEach(dx => {
        ctx.fillStyle = '#00ff66';
        ctx.shadowColor = '#00ff66';
        ctx.shadowBlur = 18;
        ctx.beginPath(); ctx.roundRect(cxB + dx - 9, cyB - 36, 18, 72, 6); ctx.fill();
        ctx.fillStyle = '#eafff2';
        ctx.beginPath(); ctx.roundRect(cxB + dx - 4, cyB - 28, 8, 56, 3); ctx.fill();
      });
      [-18, 18].forEach(dy => {
        ctx.fillStyle = '#10b981';
        ctx.beginPath(); ctx.arc(cxB, cyB + dy, 9, 0, Math.PI * 2); ctx.fill();
        ctx.fillStyle = '#d1fae5';
        ctx.beginPath(); ctx.arc(cxB, cyB + dy, 4, 0, Math.PI * 2); ctx.fill();
      });
      ctx.restore();

      [
        { x: cxB - 200, y: cyB - 36 }, { x: cxB - 200, y: cyB + 36 },
        { x: cxB + 200, y: cyB - 36 }, { x: cxB + 200, y: cyB + 36 }
      ].forEach(p => {
        ctx.beginPath(); ctx.arc(p.x, p.y, 22, 0, Math.PI * 2); ctx.fillStyle = '#08090c'; ctx.fill();
        const gGrad = ctx.createRadialGradient(p.x - 4, p.y - 4, 2, p.x, p.y, 18);
        gGrad.addColorStop(0, '#fef08a'); gGrad.addColorStop(0.5, '#eab308'); gGrad.addColorStop(1, '#713f12');
        ctx.beginPath(); ctx.arc(p.x, p.y, 17, 0, Math.PI * 2); ctx.fillStyle = gGrad; ctx.fill();
      });

      bindAndUploadTex(podTex, c, false);
    }

    const cradleTex = gl.createTexture();
    function initCradleTex() {
      const c = document.createElement('canvas');
      c.width = 1024; c.height = 512;
      const ctx = c.getContext('2d');
      ctx.fillStyle = '#13161c'; ctx.fillRect(0, 0, 1024, 512);
      ctx.fillStyle = '#0a0c10'; ctx.beginPath(); ctx.roundRect(130, 60, 764, 392, 160); ctx.fill();

      const cx = 512, cy = 256;
      ctx.fillStyle = '#050807'; ctx.strokeStyle = '#1e242d'; ctx.lineWidth = 6;
      ctx.beginPath(); ctx.roundRect(330, 140, 364, 232, 36); ctx.fill(); ctx.stroke();

      const glow = ctx.createRadialGradient(cx, cy, 8, cx, cy, 130);
      glow.addColorStop(0, 'rgba(0, 255, 100, 0.55)');
      glow.addColorStop(1, 'rgba(0, 0, 0, 0)');
      ctx.fillStyle = glow; ctx.fillRect(340, 150, 344, 212);

      [-55, 55].forEach(dx => {
        ctx.fillStyle = '#00ff66';
        ctx.beginPath(); ctx.roundRect(cx + dx - 8, cy - 30, 16, 60, 5); ctx.fill();
        ctx.fillStyle = '#ffffff';
        ctx.beginPath(); ctx.roundRect(cx + dx - 3, cy - 22, 6, 44, 2); ctx.fill();
      });
      [-15, 15].forEach(dy => {
        ctx.fillStyle = '#34d399';
        ctx.beginPath(); ctx.arc(cx, cy + dy, 7, 0, Math.PI * 2); ctx.fill();
      });

      bindAndUploadTex(cradleTex, c, false);
    }

    const pcbTex = gl.createTexture();
    function initPcbTex() {
      const c = document.createElement('canvas');
      c.width = 512; c.height = 512;
      const ctx = c.getContext('2d');
      ctx.fillStyle = '#065f46';
      ctx.fillRect(0, 0, 512, 512);

      ctx.strokeStyle = '#34d399';
      ctx.lineWidth = 2.5;
      for (let i = 0; i < 28; i++) {
        const y = 30 + i * 16;
        ctx.beginPath();
        ctx.moveTo(25, y);
        ctx.lineTo(140 + (i % 5) * 35, y);
        ctx.lineTo(180 + (i % 5) * 35, y + 12);
        ctx.lineTo(485, y + 12);
        ctx.stroke();
      }

      ctx.strokeStyle = '#fbbf24';
      ctx.lineWidth = 5;
      ctx.strokeRect(18, 18, 476, 476);
      ctx.fillStyle = '#f59e0b';
      for (let i = 0; i < 12; i++) {
        ctx.fillRect(32 + i * 38, 24, 18, 12);
        ctx.fillRect(32 + i * 38, 476, 18, 12);
      }

      ctx.fillStyle = '#d97706';
      ctx.beginPath(); ctx.roundRect(65, 145, 135, 135, 14); ctx.fill();
      ctx.fillStyle = '#fef08a';
      ctx.beginPath(); ctx.roundRect(82, 162, 101, 101, 8); ctx.fill();
      ctx.fillStyle = '#92400e';
      ctx.beginPath(); ctx.arc(132, 212, 10, 0, Math.PI * 2); ctx.fill();

      ctx.fillStyle = '#94a3b8';
      ctx.beginPath(); ctx.roundRect(235, 120, 155, 140, 10); ctx.fill();
      ctx.strokeStyle = '#e2e8f0'; ctx.lineWidth = 3; ctx.stroke();

      ctx.fillStyle = '#1e293b';
      ctx.beginPath(); ctx.roundRect(245, 290, 110, 110, 8); ctx.fill();
      ctx.strokeStyle = '#cbd5e1'; ctx.lineWidth = 2; ctx.stroke();

      bindAndUploadTex(pcbTex, c, false);
    }

    const batteryTex = gl.createTexture();
    function initBatteryTex() {
      const c = document.createElement('canvas');
      c.width = 512; c.height = 512;
      const ctx = c.getContext('2d');
      const grad = ctx.createLinearGradient(0, 0, 512, 512);
      grad.addColorStop(0, '#facc15');
      grad.addColorStop(0.5, '#eab308');
      grad.addColorStop(1, '#ca8a04');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, 512, 512);

      ctx.fillStyle = '#1e293b';
      ctx.fillRect(0, 0, 75, 512);
      ctx.fillStyle = '#b45309';
      ctx.fillRect(75, 0, 22, 512);

      ctx.fillStyle = 'rgba(0,0,0,0.18)';
      ctx.fillRect(140, 190, 240, 18);
      ctx.fillRect(140, 230, 180, 14);
      ctx.fillRect(140, 265, 210, 14);

      bindAndUploadTex(batteryTex, c, false);
    }

    initStrapTex();
    initPodTex();
    initCradleTex();
    initPcbTex();
    initBatteryTex();

    // =========================================================================
    // WEBGL SHADERS (With Highlight & Dim Support for Interactive Layer Isolation)
    // =========================================================================
    const vsSrc = `
      attribute vec3 aPos; attribute vec3 aNorm; attribute vec2 aUV;
      uniform mat4 uModel; uniform mat4 uView; uniform mat4 uProj; uniform mat3 uNormMat;
      varying vec3 vNormal; varying vec3 vWorldPos; varying vec2 vUV;
      void main() {
        vec4 w = uModel * vec4(aPos, 1.0);
        vWorldPos = w.xyz; vNormal = normalize(uNormMat * aNorm); vUV = aUV;
        gl_Position = uProj * uView * w;
      }
    `;
    const fsSrc = `
      precision highp float;
      varying vec3 vNormal; varying vec3 vWorldPos; varying vec2 vUV;
      uniform sampler2D uTex;
      uniform int uPartType;
      uniform vec3 uCamPos;
      uniform float uTime;
      uniform float uHighlight; // > 0 = selected glow, < 0 = dimmed

      void main() {
        if (uPartType == 5) {
          float r = length(vUV - vec2(0.5)) * 2.0;
          gl_FragColor = vec4(0.02, 0.03, 0.05, smoothstep(1.0, 0.1, r) * 0.32);
          return;
        }
        vec4 texCol = texture2D(uTex, vUV);
        vec3 albedo = texCol.rgb;
        vec3 N = normalize(vNormal);
        vec3 V = normalize(uCamPos - vWorldPos);
        float roughness = 0.45, metallic = 0.12;
        vec3 emission = vec3(0.0);

        if (uPartType == 0) {
          vec4 tx = texture2D(uTex, vUV + vec2(0.0012, 0.0));
          vec4 ty = texture2D(uTex, vUV + vec2(0.0, 0.0024));
          float weaveWave = sin(vUV.x * 380.0 + vUV.y * 190.0) * 0.09;
          N = normalize(N + vec3((tx.r - texCol.r) * 4.8 + weaveWave, (ty.r - texCol.r) * 4.8, 0.0));
          roughness = 0.78; metallic = 0.03;
        } else if (uPartType == 1 || uPartType == 2) {
          if (albedo.r > 0.55 && albedo.g > 0.42 && albedo.b < 0.35) { roughness = 0.16; metallic = 0.92; }
          if (albedo.g > 0.55 && albedo.r < 0.45) {
            emission = albedo * (1.5 + 0.4 * sin(uTime * 6.5));
            roughness = 0.1;
          }
          if (albedo.b > 0.65 && albedo.g > 0.45) {
            emission = albedo * (1.0 + 0.4 * sin(uTime * 6.5));
          }
        } else if (uPartType == 6) {
          roughness = 0.28; metallic = 0.45;
        }

        vec3 L1 = normalize(vec3(3.5, 6.0, 5.5));
        vec3 L2 = normalize(vec3(-5.0, 3.0, 4.0));
        vec3 L3 = normalize(vec3(0.0, 4.5, -6.0));
        float d1 = max(dot(N, L1), 0.0), d2 = max(dot(N, L2), 0.0), d3 = max(dot(N, L3), 0.0);
        float spExp = mix(140.0, 14.0, roughness), spStr = mix(0.65, 0.09, roughness);
        float s1 = pow(max(dot(N, normalize(L1 + V)), 0.0), spExp) * spStr;
        float s2 = pow(max(dot(N, normalize(L2 + V)), 0.0), spExp) * spStr * 0.6;
        float s3 = pow(max(dot(N, normalize(L3 + V)), 0.0), spExp) * spStr * 0.8;
        vec3 specCol = mix(vec3(1.0), albedo * 1.4, metallic);
        vec3 ambient = albedo * mix(vec3(0.20, 0.22, 0.27), vec3(0.45, 0.48, 0.55), N.y * 0.5 + 0.5);
        vec3 diffuse = albedo * (d1 * 0.95 + d2 * 0.55 + d3 * 0.35);
        float fresnel = pow(1.0 - max(dot(N, V), 0.0), 3.0);
        vec3 rim = vec3(0.30, 0.35, 0.42) * fresnel * (1.0 - roughness * 0.5);

        if (uHighlight > 0.5) {
          rim += vec3(0.15, 0.75, 0.98) * fresnel * (1.8 + 0.6 * sin(uTime * 8.0));
          emission += vec3(0.04, 0.14, 0.22);
        }

        vec3 col = ambient + diffuse + specCol * (s1 + s2 + s3) + rim + emission;
        if (uHighlight < -0.5) {
          col *= 0.38;
        }
        gl_FragColor = vec4(col, 1.0);
      }
    `;
    function makeS(t, s) { const sh = gl.createShader(t); gl.shaderSource(sh, s); gl.compileShader(sh); return sh; }
    const prog = gl.createProgram();
    gl.attachShader(prog, makeS(gl.VERTEX_SHADER, vsSrc));
    gl.attachShader(prog, makeS(gl.FRAGMENT_SHADER, fsSrc));
    gl.linkProgram(prog);

    const aPosLoc = gl.getAttribLocation(prog, 'aPos');
    const aNormLoc = gl.getAttribLocation(prog, 'aNorm');
    const aUVLoc = gl.getAttribLocation(prog, 'aUV');
    const uModelLoc = gl.getUniformLocation(prog, 'uModel');
    const uViewLoc = gl.getUniformLocation(prog, 'uView');
    const uProjLoc = gl.getUniformLocation(prog, 'uProj');
    const uNormMatLoc = gl.getUniformLocation(prog, 'uNormMat');
    const uTexLoc = gl.getUniformLocation(prog, 'uTex');
    const uPartTypeLoc = gl.getUniformLocation(prog, 'uPartType');
    const uCamPosLoc = gl.getUniformLocation(prog, 'uCamPos');
    const uTimeLoc = gl.getUniformLocation(prog, 'uTime');
    const uHighlightLoc = gl.getUniformLocation(prog, 'uHighlight');

    // =========================================================================
    // 3D GEOMETRY BUILDERS
    // =========================================================================
    function createBuf(pos, norm, uv, ind) {
      const pBuf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, pBuf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(pos), gl.STATIC_DRAW);
      const nBuf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, nBuf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(norm), gl.STATIC_DRAW);
      const tBuf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, tBuf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(uv), gl.STATIC_DRAW);
      const iBuf = gl.createBuffer(); gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, iBuf); gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(ind), gl.STATIC_DRAW);
      return { pBuf, nBuf, tBuf, iBuf, count: ind.length };
    }

    function makeStadiumRing(a, R, segL, segA) {
      const pts = [];
      for (let i = 0; i < segL; i++) pts.push({ x0: -a + (2 * a) * (i / segL), nx: 0, ny: 1 });
      for (let i = 0; i < segA; i++) { const ang = Math.PI/2 - Math.PI*(i/segA); pts.push({ x0: a, nx: Math.cos(ang), ny: Math.sin(ang) }); }
      for (let i = 0; i < segL; i++) pts.push({ x0: a - (2 * a) * (i / segL), nx: 0, ny: -1 });
      for (let i = 0; i <= segA; i++) { const ang = -Math.PI/2 - Math.PI*(i/segA); pts.push({ x0: -a, nx: Math.cos(ang), ny: Math.sin(ang) }); }
      return pts;
    }

    function buildRoundedSlab(a, R, zTop, zBot, isTopShell, isBotShell) {
      const Wt = 2 * (a + R), Ht = 2 * R;
      const ring = makeStadiumRing(a, R, 16, 24), Np = ring.length;
      const prof = [{ rho: 0.0, z: zTop, nr: 0, nz: 1, isF: true }];
      for (let k = 1; k <= 5; k++) {
        const f = k / 5;
        const dome = isTopShell ? (1 - f * f) * 0.04 : 0.0;
        prof.push({ rho: f * 0.85, z: zTop + dome, nr: 0.12 * f, nz: 1, isF: true });
      }
      for (let k = 0; k <= 8; k++) {
        const ang = (Math.PI / 2) * (1 - (k / 8) * 2);
        const midZ = 0.5 * (zTop + zBot), halfZ = 0.5 * (zTop - zBot);
        prof.push({
          rho: 0.85 + 0.15 * Math.cos(ang),
          z: midZ + halfZ * Math.sin(ang),
          nr: Math.cos(ang),
          nz: Math.sin(ang),
          isF: ang >= 0
        });
      }
      for (let k = 4; k >= 0; k--) {
        const f = k / 5;
        prof.push({ rho: f * 0.85, z: zBot, nr: 0, nz: -1, isF: false });
      }

      const pos = [], norm = [], uv = [], ind = [], M = prof.length;
      for (let i = 0; i < Np; i++) {
        const p = ring[i];
        for (let j = 0; j < M; j++) {
          const pr = prof[j], x = p.x0 + pr.rho * R * p.nx, y = pr.rho * R * p.ny;
          const z = pr.z;
          const nx = pr.nr * p.nx, ny = pr.nr * p.ny, nz = pr.nz, nL = Math.hypot(nx, ny, nz) || 1;
          pos.push(x, y, z); norm.push(nx/nL, ny/nL, nz/nL);
          const uP = Math.max(0.01, Math.min(0.99, (x / Wt) + 0.5)), vP = Math.max(0.01, Math.min(0.99, (y / Ht) + 0.5));
          if (isTopShell || isBotShell) {
            uv.push(pr.isF ? uP : 1.0 - uP, pr.isF ? 0.5 + 0.5 * vP : 0.5 * vP);
          } else {
            uv.push(uP, vP);
          }
        }
      }
      for (let i = 0; i < Np - 1; i++) for (let j = 0; j < M - 1; j++) {
        const A = i*M+j, B = (i+1)*M+j, C = (i+1)*M+(j+1), D = i*M+(j+1);
        ind.push(A, B, D, B, C, D);
      }
      return createBuf(pos, norm, uv, ind);
    }

    function buildCradle() {
      const a = 0.34, R = 0.58, Wt = 2*(a+R), Ht = 2*R;
      const ring = makeStadiumRing(a, R, 16, 24), Np = ring.length;
      const prof = [
        { rho: 0.94, z: -0.18, nr: 0, nz: -1 }, { rho: 1.00, z: -0.12, nr: 1, nz: -0.2 },
        { rho: 1.00, z: 0.08, nr: 1, nz: 0.1 }, { rho: 0.96, z: 0.19, nr: 0.6, nz: 0.8 },
        { rho: 0.89, z: 0.21, nr: 0, nz: 1 },   { rho: 0.84, z: 0.17, nr: -0.8, nz: 0.5 },
        { rho: 0.82, z: -0.05, nr: -1, nz: 0.1 }, { rho: 0.55, z: -0.05, nr: 0, nz: 1 },
        { rho: 0.52, z: -0.11, nr: -1, nz: 0.2 }, { rho: 0.00, z: -0.11, nr: 0, nz: 1 }
      ];
      const pos = [], norm = [], uv = [], ind = [], M = prof.length;
      for (let i = 0; i < Np; i++) {
        const p = ring[i];
        for (let j = 0; j < M; j++) {
          const pr = prof[j], x = p.x0 + pr.rho * R * p.nx, y = pr.rho * R * p.ny, z = pr.z - 0.07 * (x * x);
          const nx = pr.nr * p.nx, ny = pr.nr * p.ny, nz = pr.nz, nL = Math.hypot(nx, ny, nz) || 1;
          pos.push(x, y, z); norm.push(nx/nL, ny/nL, nz/nL);
          uv.push(Math.max(0.01, Math.min(0.99, (x / Wt) + 0.5)), Math.max(0.01, Math.min(0.99, (y / Ht) + 0.5)));
        }
      }
      for (let i = 0; i < Np - 1; i++) for (let j = 0; j < M - 1; j++) {
        const A = i*M+j, B = (i+1)*M+j, C = (i+1)*M+(j+1), D = i*M+(j+1);
        ind.push(A, B, D, B, C, D);
      }
      return createBuf(pos, norm, uv, ind);
    }

    function buildStrap() {
      const M = 88, K = 22, Rx = 2.15, Rz = 1.38, H = 1.65, T = 0.17;
      const pos = [], norm = [], uv = [], ind = [];
      for (let i = 0; i <= M; i++) {
        const u = i / M, th = u * Math.PI * 2, cx = Rx * Math.cos(th), cz = Rz * Math.sin(th);
        const tx = -Rx * Math.sin(th), tz = Rz * Math.cos(th), tL = Math.hypot(tx, tz) || 1;
        const nx = tz / tL, nz = -tx / tL;
        const lT = (u > 0.27 && u < 0.44) ? T * 1.25 : T;
        for (let j = 0; j <= K; j++) {
          const ph = (j / K) * Math.PI * 2, cp = Math.cos(ph), sp = Math.sin(ph);
          const py = (H/2) * Math.sign(cp) * Math.pow(Math.abs(cp), 0.52);
          const pt = (lT/2) * Math.sign(sp) * Math.pow(Math.abs(sp), 0.62);
          pos.push(cx + nx * pt, py, cz + nz * pt);
          const nX = nx * sp, nY = cp, nZ = nz * sp, nL = Math.hypot(nX, nY, nZ) || 1;
          norm.push(nX/nL, nY/nL, nZ/nL);
          uv.push(u * 2.0, (py / H) + 0.5);
        }
      }
      for (let i = 0; i < M; i++) for (let j = 0; j < K; j++) {
        const A = i*(K+1)+j, B = (i+1)*(K+1)+j, C = (i+1)*(K+1)+(j+1), D = i*(K+1)+(j+1);
        ind.push(A, B, D, B, C, D);
      }
      return createBuf(pos, norm, uv, ind);
    }

    function buildShadow() {
      const S = 3.8, Y = -0.95;
      return createBuf([-S,Y,-S, S,Y,-S, S,Y,S, -S,Y,S], [0,1,0,0,1,0,0,1,0,0,1,0], [0,0,1,0,1,1,0,1], [0,1,2,0,2,3]);
    }

    const podFullMesh   = buildRoundedSlab(0.28, 0.54,  0.14, -0.14, true, true);
    const topCasingMesh = buildRoundedSlab(0.28, 0.54,  0.11, -0.02, true, false);
    const gpsPcbMesh    = buildRoundedSlab(0.23, 0.45,  0.035, -0.035, false, false);
    const mainPcbMesh   = buildRoundedSlab(0.25, 0.48,  0.04, -0.04, false, false);
    const batteryMesh   = buildRoundedSlab(0.20, 0.39,  0.065, -0.065, false, false);
    const botSensorMesh = buildRoundedSlab(0.28, 0.54,  0.02, -0.11, false, true);

    const cradleMesh = buildCradle();
    const strapMesh = buildStrap();
    const shadowMesh = buildShadow();

    // Matrix Helpers
    function mat4Id() { return new Float32Array([1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]); }
    function mat4Persp(out, fov, aspect, near, far) {
      const f = 1.0 / Math.tan(fov / 2), nf = 1 / (near - far);
      out.fill(0); out[0] = f / aspect; out[5] = f; out[10] = (far + near) * nf; out[11] = -1; out[14] = (2 * far * near) * nf;
    }
    function mat4Look(out, eye, center, up) {
      let z0 = eye[0]-center[0], z1 = eye[1]-center[1], z2 = eye[2]-center[2], l = Math.hypot(z0,z1,z2); z0/=l; z1/=l; z2/=l;
      let x0 = up[1]*z2-up[2]*z1, x1 = up[2]*z0-up[0]*z2, x2 = up[0]*z1-up[1]*z0; l = Math.hypot(x0,x1,x2); x0/=l; x1/=l; x2/=l;
      let y0 = z1*x2-z2*x1, y1 = z2*x0-z0*x2, y2 = z0*x1-z1*x0;
      out[0]=x0; out[1]=y0; out[2]=z0; out[3]=0; out[4]=x1; out[5]=y1; out[6]=z1; out[7]=0;
      out[8]=x2; out[9]=y2; out[10]=z2; out[11]=0;
      out[12]=-(x0*eye[0]+x1*eye[1]+x2*eye[2]); out[13]=-(y0*eye[0]+y1*eye[1]+y2*eye[2]); out[14]=-(z0*eye[0]+z1*eye[1]+z2*eye[2]); out[15]=1;
    }
    function mat4Trans(out, a, v) {
      if (a !== out) out.set(a);
      out[12] = a[0]*v[0] + a[4]*v[1] + a[8]*v[2] + a[12];
      out[13] = a[1]*v[0] + a[5]*v[1] + a[9]*v[2] + a[13];
      out[14] = a[2]*v[0] + a[6]*v[1] + a[10]*v[2] + a[14];
      out[15] = a[3]*v[0] + a[7]*v[1] + a[11]*v[2] + a[15];
    }
    function mat4Scale(out, a, v) {
      if (a !== out) out.set(a);
      out[0]*=v[0]; out[1]*=v[0]; out[2]*=v[0]; out[3]*=v[0];
      out[4]*=v[1]; out[5]*=v[1]; out[6]*=v[1]; out[7]*=v[1];
      out[8]*=v[2]; out[9]*=v[2]; out[10]*=v[2]; out[11]*=v[2];
    }
    function mat4RotX(out, a, r) {
      const s = Math.sin(r), c = Math.cos(r), a4=a[4],a5=a[5],a6=a[6],a7=a[7],a8=a[8],a9=a[9],a10=a[10],a11=a[11];
      if (a !== out) out.set(a);
      out[4]=a4*c+a8*s; out[5]=a5*c+a9*s; out[6]=a6*c+a10*s; out[7]=a7*c+a11*s;
      out[8]=a8*c-a4*s; out[9]=a9*c-a5*s; out[10]=a10*c-a6*s; out[11]=a11*c-a7*s;
    }
    function mat4RotY(out, a, r) {
      const s = Math.sin(r), c = Math.cos(r), a0=a[0],a1=a[1],a2=a[2],a3=a[3],a8=a[8],a9=a[9],a10=a[10],a11=a[11];
      if (a !== out) out.set(a);
      out[0]=a0*c-a8*s; out[1]=a1*c-a9*s; out[2]=a2*c-a10*s; out[3]=a3*c-a11*s;
      out[8]=a0*s+a8*c; out[9]=a1*s+a9*c; out[10]=a2*s+a10*c; out[11]=a3*s+a11*c;
    }
    function mat3From4(out, a) {
      out[0]=a[0]; out[1]=a[1]; out[2]=a[2]; out[3]=a[4]; out[4]=a[5]; out[5]=a[6]; out[6]=a[8]; out[7]=a[9]; out[8]=a[10];
    }

    function projectPoint(pt, modelMat, viewMat, projMat) {
      const x = pt[0], y = pt[1], z = pt[2];
      const wx = modelMat[0]*x + modelMat[4]*y + modelMat[8]*z + modelMat[12];
      const wy = modelMat[1]*x + modelMat[5]*y + modelMat[9]*z + modelMat[13];
      const wz = modelMat[2]*x + modelMat[6]*y + modelMat[10]*z + modelMat[14];

      const vx = viewMat[0]*wx + viewMat[4]*wy + viewMat[8]*wz + viewMat[12];
      const vy = viewMat[1]*wx + viewMat[5]*wy + viewMat[9]*wz + viewMat[13];
      const vz = viewMat[2]*wx + viewMat[6]*wy + viewMat[10]*wz + viewMat[14];

      const cx = projMat[0]*vx + projMat[4]*vy + projMat[8]*vz + projMat[12];
      const cy = projMat[1]*vx + projMat[5]*vy + projMat[9]*vz + projMat[13];
      const cw = projMat[3]*vx + projMat[7]*vy + projMat[11]*vz + projMat[15];
      if (cw <= 0.001) return null;
      return {
        x: ((cx / cw) * 0.5 + 0.5) * width * dpr,
        y: (-(cy / cw) * 0.5 + 0.5) * height * dpr,
        cssX: ((cx / cw) * 0.5 + 0.5) * width,
        cssY: (-(cy / cw) * 0.5 + 0.5) * height
      };
    }

    const pMat = mat4Id(), vMat = mat4Id(), mMat = mat4Id(), nMat = new Float32Array(9);

    function drawM(buf, tex, type, highlight = 0.0) {
      gl.bindBuffer(gl.ARRAY_BUFFER, buf.pBuf); gl.enableVertexAttribArray(aPosLoc); gl.vertexAttribPointer(aPosLoc, 3, gl.FLOAT, false, 0, 0);
      gl.bindBuffer(gl.ARRAY_BUFFER, buf.nBuf); gl.enableVertexAttribArray(aNormLoc); gl.vertexAttribPointer(aNormLoc, 3, gl.FLOAT, false, 0, 0);
      gl.bindBuffer(gl.ARRAY_BUFFER, buf.tBuf); gl.enableVertexAttribArray(aUVLoc); gl.vertexAttribPointer(aUVLoc, 2, gl.FLOAT, false, 0, 0);
      gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buf.iBuf);
      gl.uniformMatrix4fv(uModelLoc, false, mMat);
      gl.uniformMatrix3fv(uNormMatLoc, false, nMat);
      gl.uniform1i(uPartTypeLoc, type);
      gl.uniform1f(uHighlightLoc, highlight);
      gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, tex); gl.uniform1i(uTexLoc, 0);
      gl.drawElements(gl.TRIANGLES, buf.count, gl.UNSIGNED_SHORT, 0);
    }

    // =========================================================================
    // DYNAMIC ON-MODEL 3D HOTSPOTS MANAGER
    // =========================================================================
    let lastHotspotKey = '';
    function syncHotspots(items) {
      const key = items.map(it => it.id).join('|');
      if (key !== lastHotspotKey) {
        lastHotspotKey = key;
        hotspotsLayer.innerHTML = '';
        items.forEach(it => {
          const btn = document.createElement('button');
          btn.id = 'hs-' + it.id;
          btn.className = `hotspot-btn pointer-events-auto flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold shadow-xl border backdrop-blur-md ${it.cls}`;
          btn.innerHTML = `<span class="w-2 h-2 rounded-full bg-current ring-anim relative"></span><span>${it.label}</span>`;
          btn.onclick = (e) => {
            e.stopPropagation();
            if (dragDist < 8) it.onClick();
          };
          hotspotsLayer.appendChild(btn);
        });
      }
      items.forEach(it => {
        const el = document.getElementById('hs-' + it.id);
        if (el && it.pt) {
          el.style.left = `${Math.max(55, Math.min(width - 65, it.pt.cssX))}px`;
          el.style.top = `${Math.max(35, Math.min(height - 45, it.pt.cssY))}px`;
          el.style.opacity = '1';
        } else if (el) {
          el.style.opacity = '0';
        }
      });
    }

    // =========================================================================
    // MAIN RENDER LOOP (3D WebGL + Interactive 2D HUD + Live Diagnostics)
    // =========================================================================
    function render() {
      if (!width || !height) resize();
      clock += 0.025;
      if (autoSpin) targetRotY += 0.0055;
      rotX += (targetRotX - rotX) * 0.12;
      rotY += (targetRotY - rotY) * 0.12;
      zoom += (targetZoom - zoom) * 0.12;
      detach += (targetDetach - detach) * 0.11;
      explode += (targetExplode - explode) * 0.10;
      podFlip += (targetPodFlip - podFlip) * 0.11;
      sleeveFade += (targetSleeveFade - sleeveFade) * 0.10;
      sceneOffsetX += (targetSceneOffsetX - sceneOffsetX) * 0.11;
      sceneOffsetY += (targetSceneOffsetY - sceneOffsetY) * 0.11;

      if (snapShockwave > 0.01) snapShockwave *= 0.92;
      else snapShockwave = 0.0;

      if (simEffectTimer > 0.01) simEffectTimer *= 0.985;
      else simEffectTimer = 0.0;

      if (fabricStretch > 0.01) fabricStretch *= 0.95;
      else fabricStretch = 0.0;

      if (studioWhite) gl.clearColor(0.95, 0.97, 0.99, 1.0);
      else gl.clearColor(0.04, 0.06, 0.11, 1.0);
      gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      gl.enable(gl.DEPTH_TEST);
      gl.useProgram(prog);

      mat4Persp(pMat, (38 * Math.PI) / 180, width / height, 0.1, 100.0);
      gl.uniformMatrix4fv(uProjLoc, false, pMat);

      const aspect = width / height;
      const fitZoom = Math.min(1, Math.max(0.7, aspect / 1.6));
      const eye = [0, 0.2, 7.2 / (zoom * fitZoom)];
      mat4Look(vMat, eye, [0, 0, 0], [0, 1, 0]);
      gl.uniformMatrix4fv(uViewLoc, false, vMat);
      gl.uniform3fv(uCamPosLoc, eye);
      gl.uniform1f(uTimeLoc, clock);

      const sceneMat = mat4Id();
      mat4Trans(sceneMat, sceneMat, [sceneOffsetX, sceneOffsetY, 0]);
      mat4RotX(sceneMat, sceneMat, rotX);
      mat4RotY(sceneMat, sceneMat, rotY);

      // 1. Draw Nylon-Spandex Sleeve & Inner Sensor Cradle
      const bandX = -1.05 * detach - 3.6 * sleeveFade;
      const bandGroup = mat4Id();
      mat4Trans(bandGroup, sceneMat, [bandX, 0.06, 0]);
      if (fabricStretch > 0.01) {
        const stretchFactor = 1.0 + Math.sin(clock * 10.0) * 0.08 * fabricStretch;
        mat4Scale(bandGroup, bandGroup, [stretchFactor, 1.0 / Math.sqrt(stretchFactor), stretchFactor]);
      }

      if (sleeveFade < 0.92) {
        mMat.set(bandGroup); mat3From4(nMat, mMat); drawM(strapMesh, strapTex, 0, currentMode === 'fibers' ? 1.0 : 0.0);
        mMat.set(bandGroup); mat4Trans(mMat, mMat, [0, 0, 1.38]); mat3From4(nMat, mMat); drawM(cradleMesh, cradleTex, 2);
      }

      // 2. Compute Pod Base Transform
      const podX = (1.0 - sleeveFade) * (bandX + detach * 2.55);
      const podY = (1.0 - sleeveFade) * (0.06 - detach * 0.08);
      const podZ = (1.0 - sleeveFade) * (1.44 - detach * 0.30);

      const podBaseMat = mat4Id();
      mat4Trans(podBaseMat, sceneMat, [podX, podY, podZ]);
      mat4RotY(podBaseMat, podBaseMat, (1.0 - sleeveFade) * detach * (-0.25) + podFlip * Math.PI);
      const flatTilt = explode * (-Math.PI * 0.42);
      mat4RotX(podBaseMat, podBaseMat, podFlip * 0.15 + flatTilt);

      hudCtx.clearRect(0, 0, hudCanvas.width, hudCanvas.height);
      const activeHotspots = [];

      if (explode < 0.04) {
        // Draw Assembled Pod
        mMat.set(podBaseMat);
        mat3From4(nMat, mMat);
        drawM(podFullMesh, podTex, 1, simEffectTimer > 0.2 ? 1.0 : 0.0);

        // Project 3D Hotspots directly onto the Pod, Cradle, and Fabric Sleeve!
        const podPt = projectPoint([0, 0.35, 0.18], podBaseMat, vMat, pMat);
        const podInsidePt = projectPoint([0, -0.38, 0.18], podBaseMat, vMat, pMat);
        const sleevePt = projectPoint([-1.55, 0.45, 0.75], bandGroup, vMat, pMat);
        const cradlePt = projectPoint([0, 0.0, 1.45], bandGroup, vMat, pMat);

        if (detach < 0.5) {
          activeHotspots.push({
            id: 'pop-pod',
            label: 'Pop Pod Out',
            pt: podPt,
            cls: 'bg-cyan-950/90 text-cyan-300 border-cyan-400/70',
            onClick: () => setPreset('split')
          });
          activeHotspots.push({
            id: 'peel-inside',
            label: '🔍 What\'s Inside Pod',
            pt: podInsidePt,
            cls: 'bg-emerald-950/90 text-emerald-300 border-emerald-400/70',
            onClick: () => setPreset('inside')
          });
        } else {
          activeHotspots.push({
            id: 'snap-in',
            label: '🧲 Snap Into Sleeve',
            pt: cradlePt,
            cls: 'bg-cyan-950/90 text-cyan-300 border-cyan-400/70',
            onClick: () => setPreset('docked')
          });
          activeHotspots.push({
            id: 'peel-open',
            label: '🔍 Open Inside Pod',
            pt: podPt,
            cls: 'bg-emerald-950/90 text-emerald-300 border-emerald-400/70',
            onClick: () => setPreset('inside')
          });
          activeHotspots.push({
            id: 'flip-sensors',
            label: podFlip > 0.5 ? 'Flip to Front' : '💚 View Skin Sensors',
            pt: podInsidePt,
            cls: 'bg-slate-900/90 text-emerald-300 border-emerald-500/60',
            onClick: () => setPreset(podFlip > 0.5 ? 'split' : 'sensors')
          });
        }
      } else {
        // =====================================================================
        // DRAW "WHAT'S INSIDE THE POD" 5 EXPLODED 3D LAYERS + CLICKABLE CALLOUTS
        // =====================================================================
        const spread = explode * 0.48;
        const meshes = [topCasingMesh, gpsPcbMesh, mainPcbMesh, batteryMesh, botSensorMesh];
        const texs   = [podTex,        pcbTex,     pcbTex,      batteryTex,  podTex];
        const types  = [1,             6,          6,           6,           1];
        const zOffs  = [2.1 * spread,  1.1 * spread, 0.1 * spread, -0.95 * spread, -2.0 * spread];

        internalLayersMeta.forEach((L, idx) => {
          mMat.set(podBaseMat);
          const extraPull = (selectedLayer === idx) ? 0.22 : 0.0;
          mat4Trans(mMat, mMat, [extraPull, 0, zOffs[idx]]);
          mat3From4(nMat, mMat);

          let hl = 0.0;
          if (selectedLayer === idx) hl = 1.0;
          else if (selectedLayer !== -1) hl = -1.0;

          drawM(meshes[idx], texs[idx], types[idx], hl);

          const pEdge = projectPoint([0.58, 0.0, 0.0], mMat, vMat, pMat);
          if (pEdge && explode > 0.35) {
            const targetCssX = Math.min(width - 115, Math.max(pEdge.cssX + 85, width * 0.66));
            const targetCssY = 74 + idx * 58;

            // Draw Leader Line on HUD Canvas
            hudCtx.save();
            const isSel = (selectedLayer === idx);
            const isDim = (selectedLayer !== -1 && !isSel);
            hudCtx.globalAlpha = isDim ? 0.32 : 1.0;

            hudCtx.fillStyle = L.color;
            hudCtx.beginPath();
            hudCtx.arc(pEdge.x, pEdge.y, (isSel ? 5.5 : 4) * dpr, 0, Math.PI * 2);
            hudCtx.fill();

            hudCtx.strokeStyle = isSel ? L.color : (studioWhite ? 'rgba(15, 23, 42, 0.45)' : 'rgba(148, 163, 184, 0.55)');
            hudCtx.lineWidth = (isSel ? 2.2 : 1.5) * dpr;
            hudCtx.beginPath();
            hudCtx.moveTo(pEdge.x, pEdge.y);
            hudCtx.lineTo((targetCssX - 82) * dpr, targetCssY * dpr);
            hudCtx.stroke();
            hudCtx.restore();

            // Create Clickable Interactive 3D Layer Pill!
            activeHotspots.push({
              id: 'layer-' + idx,
              label: `${idx + 1}. ${L.title}`,
              pt: { cssX: targetCssX, cssY: targetCssY },
              cls: isSel
                ? 'bg-sky-600 text-white border-cyan-300 ring-2 ring-cyan-400/50'
                : (isDim
                    ? 'bg-slate-900/60 text-slate-400 border-slate-700/50'
                    : 'bg-slate-900/92 text-white border-slate-600 hover:border-cyan-400'),
              onClick: () => selectLayer(idx)
            });
          }
        });
      }

      syncHotspots(activeHotspots);

      // =======================================================================
      // TACTILE VISUAL EFFECTS (Magnetic Snap Shockwave, GPS Beam, Wash Droplets)
      // =======================================================================
      if (snapShockwave > 0.02) {
        const centerPt = projectPoint([0, 0, 0], podBaseMat, vMat, pMat);
        if (centerPt) {
          hudCtx.save();
          const rad = (1.0 - snapShockwave) * 140 * dpr;
          hudCtx.strokeStyle = `rgba(56, 189, 248, ${snapShockwave * 0.85})`;
          hudCtx.lineWidth = 3 * dpr;
          hudCtx.beginPath();
          hudCtx.arc(centerPt.x, centerPt.y, rad, 0, Math.PI * 2);
          hudCtx.stroke();
          hudCtx.restore();
        }
      }

      if (simEffectTimer > 0.05) {
        const centerPt = projectPoint([0, 0, 0], podBaseMat, vMat, pMat);
        if (centerPt) {
          hudCtx.save();
          for (let r = 0; r < 3; r++) {
            const wave = ((clock * 1.6 + r * 0.33) % 1.0);
            const radius = (20 + wave * 125) * dpr;
            const alpha = (1.0 - wave) * simEffectTimer * 0.75;
            hudCtx.strokeStyle = simEffectType === 'sensors'
              ? `rgba(16, 185, 129, ${alpha})`
              : (simEffectType === 'battery'
                  ? `rgba(250, 204, 21, ${alpha})`
                  : `rgba(56, 189, 248, ${alpha})`);
            hudCtx.lineWidth = 2.2 * dpr;
            hudCtx.beginPath();
            hudCtx.arc(centerPt.x, centerPt.y, radius, 0, Math.PI * 2);
            hudCtx.stroke();
          }
          hudCtx.restore();
        }
      }

      if (washSplash) {
        hudCtx.save();
        droplets.forEach(d => {
          const a = d.angle + clock * 0.5 * d.speed;
          const bounce = Math.sin(clock * 2.8 * d.speed + d.phase) * 0.38;
          const pt = projectPoint([Math.cos(a) * d.radius, d.y + bounce, Math.sin(a) * d.radius * 0.7], bandGroup, vMat, pMat);
          if (pt) {
            const r = d.size * dpr;
            const g = hudCtx.createRadialGradient(pt.x - r*0.3, pt.y - r*0.3, r*0.1, pt.x, pt.y, r);
            g.addColorStop(0, '#ffffff');
            g.addColorStop(0.4, 'rgba(56, 189, 248, 0.88)');
            g.addColorStop(1, 'rgba(2, 132, 199, 0.1)');
            hudCtx.fillStyle = g;
            hudCtx.beginPath();
            hudCtx.arc(pt.x, pt.y, r, 0, Math.PI * 2);
            hudCtx.fill();
          }
        });
        hudCtx.restore();
      }

      // Ground Shadow
      gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      mMat.set(sceneMat); mat3From4(nMat, mMat); drawM(shadowMesh, strapTex, 5);
      gl.disable(gl.BLEND);

      requestAnimationFrame(render);
    }

    setPreset('inside');
    render();
  </script>
</body>
</html>
""";
