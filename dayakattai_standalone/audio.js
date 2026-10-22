/**
 * THAYA KATAI (தாயக்கட்டை) — ENHANCED PROCEDURAL WEB AUDIO SYNTHESIZER
 * Features:
 * - Acoustic wooden and brass dice tumbling clatter
 * - Crisp token movement placement tap
 * - Dramatic resonance and clash for piece captures ("Vettu")
 * - Melodic temple bell chime for safe squares (Malai)
 * - Joyful golden chime for Thayam (1) and Dayam (12)
 * - Triumphant Indian classical Mohanam raga fanfare for victory
 * - Meditative Tambura / Tanpura ambient drone toggle
 * - Master volume and mute controls
 */

class GameSoundEngine {
  constructor() {
    this.audioCtx = null;
    this.isMuted = false;
    this.masterVolume = 0.8;
    this.masterGain = null;
    this.droneGain = null;
    this.droneNodes = [];
    this.isDronePlaying = false;
  }

  _initContext() {
    if (!this.audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new AudioContext();
      this.masterGain = this.audioCtx.createGain();
      this.masterGain.gain.setValueAtTime(this.isMuted ? 0 : this.masterVolume, this.audioCtx.currentTime);
      this.masterGain.connect(this.audioCtx.destination);
    }
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
  }

  setVolume(val) {
    this.masterVolume = Math.max(0, Math.min(1, val));
    if (this.audioCtx && this.masterGain && !this.isMuted) {
      this.masterGain.gain.setValueAtTime(this.masterVolume, this.audioCtx.currentTime);
    }
  }

  toggleMute() {
    this.isMuted = !this.isMuted;
    if (this.audioCtx && this.masterGain) {
      this.masterGain.gain.setValueAtTime(this.isMuted ? 0 : this.masterVolume, this.audioCtx.currentTime);
    }
    return this.isMuted;
  }

  // 1. Realistic brass & hardwood dice tumbling clatter
  playDiceRoll() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    // Simulate 2 elongated brass dice tumbling against rosewood board
    const hitTimes = [0, 0.07, 0.15, 0.23, 0.32, 0.42, 0.52];
    hitTimes.forEach((delay, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const filter = ctx.createBiquadFilter();

      // Alternate between deep wood thud and metallic brass ping
      const isBrass = (idx % 2 === 1);
      osc.type = isBrass ? 'triangle' : 'sine';
      
      const baseFreq = isBrass ? (380 + Math.random() * 120) : (110 + Math.random() * 40);
      osc.frequency.setValueAtTime(baseFreq, now + delay);
      osc.frequency.exponentialRampToValueAtTime(30, now + delay + 0.06);

      filter.type = isBrass ? 'highpass' : 'lowpass';
      filter.frequency.setValueAtTime(isBrass ? 400 : 250, now + delay);

      const amp = (0.22 - idx * 0.02) * (isBrass ? 0.7 : 1.0);
      gain.gain.setValueAtTime(amp, now + delay);
      gain.gain.exponentialRampToValueAtTime(0.001, now + delay + 0.07);

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(this.masterGain);

      osc.start(now + delay);
      osc.stop(now + delay + 0.08);
    });
  }

  // Realistic shake/rattle when picking up dice
  playDiceShake() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;
    for (let i = 0; i < 4; i++) {
      const delay = i * 0.035 + Math.random() * 0.01;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(280 + Math.random() * 120, now + delay);
      osc.frequency.exponentialRampToValueAtTime(80, now + delay + 0.035);
      gain.gain.setValueAtTime(0.18, now + delay);
      gain.gain.exponentialRampToValueAtTime(0.001, now + delay + 0.04);
      osc.connect(gain);
      gain.connect(this.masterGain);
      osc.start(now + delay);
      osc.stop(now + delay + 0.05);
    }
  }

  // Realistic bounce impact sound when dice strike the velvet/wood surface
  playDiceImpact(intensity = 0.5) {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    // 1. Low thud body
    const osc1 = ctx.createOscillator();
    const gain1 = ctx.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(140 + Math.random() * 30, now);
    osc1.frequency.exponentialRampToValueAtTime(35, now + 0.05);
    gain1.gain.setValueAtTime(0.35 * intensity, now);
    gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.06);
    osc1.connect(gain1);
    gain1.connect(this.masterGain);
    osc1.start(now);
    osc1.stop(now + 0.07);

    // 2. High metallic/hardwood click
    const osc2 = ctx.createOscillator();
    const gain2 = ctx.createGain();
    osc2.type = 'triangle';
    osc2.frequency.setValueAtTime(420 + Math.random() * 80, now);
    osc2.frequency.exponentialRampToValueAtTime(120, now + 0.03);
    gain2.gain.setValueAtTime(0.22 * intensity, now);
    gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
    osc2.connect(gain2);
    gain2.connect(this.masterGain);
    osc2.start(now);
    osc2.stop(now + 0.05);
  }

  // Settling slide friction sound
  playDiceSlide() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    const filter = ctx.createBiquadFilter();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(160, now);
    osc.frequency.linearRampToValueAtTime(60, now + 0.12);
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(220, now);
    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.14);
    osc.connect(filter);
    filter.connect(gain);
    gain.connect(this.masterGain);
    osc.start(now);
    osc.stop(now + 0.15);
  }

  // 2. Token placement click on wood
  playTokenMove() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(340, now);
    osc.frequency.exponentialRampToValueAtTime(90, now + 0.07);

    gain.gain.setValueAtTime(0.28, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.07);

    osc.connect(gain);
    gain.connect(this.masterGain);

    osc.start(now);
    osc.stop(now + 0.08);
  }

  // Quick subtle tap for intermediate hopping steps
  playTokenStep() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(420, now);
    osc.frequency.exponentialRampToValueAtTime(120, now + 0.04);

    gain.gain.setValueAtTime(0.18, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);

    osc.connect(gain);
    gain.connect(this.masterGain);

    osc.start(now);
    osc.stop(now + 0.05);
  }

  // Tamil & English Traditional Voice Callouts via Web Speech API
  speakCallout(type, lang = 'ta') {
    if (this.isMuted || !window.speechSynthesis) return;
    try {
      const phrases = {
        thayam: { ta: 'தாயம்!', en: 'Thayam!' },
        panirendu: { ta: 'பன்னிரண்டு!', en: 'Twelve!' },
        ainthu: { ta: 'ஐந்து!', en: 'Five!' },
        aaru: { ta: 'ஆறு!', en: 'Six!' },
        vettu: { ta: 'வெட்டு!', en: 'Capture! Vettu!' },
        pazham: { ta: 'பழம்!', en: 'Home! Pazham!' },
        victory: { ta: 'வெற்றி!', en: 'Victory!' }
      };

      const entry = phrases[type];
      if (!entry) return;
      const text = (lang === 'ta' ? entry.ta : entry.en) || entry.ta;

      // Cancel any ongoing speech to prevent backlog
      window.speechSynthesis.cancel();

      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 1.05;
      utterance.pitch = 1.1;
      utterance.volume = Math.min(1.0, this.masterVolume * 1.2);
      if (lang === 'ta') {
        utterance.lang = 'ta-IN';
      } else {
        utterance.lang = 'en-US';
      }
      window.speechSynthesis.speak(utterance);
    } catch (e) {
      // Graceful degradation if speech synthesis not permitted
    }
  }

  // 3. Piece capture / Vettu clash (dramatic resonance)
  playCapture() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    // Strike layer 1: Sharp wood clash
    const osc1 = ctx.createOscillator();
    const gain1 = ctx.createGain();
    osc1.type = 'sawtooth';
    osc1.frequency.setValueAtTime(520, now);
    osc1.frequency.exponentialRampToValueAtTime(80, now + 0.28);
    gain1.gain.setValueAtTime(0.35, now);
    gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.28);
    osc1.connect(gain1);
    gain1.connect(this.masterGain);
    osc1.start(now);
    osc1.stop(now + 0.3);

    // Strike layer 2: Deep bass resonance
    const osc2 = ctx.createOscillator();
    const gain2 = ctx.createGain();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(140, now);
    osc2.frequency.exponentialRampToValueAtTime(45, now + 0.35);
    gain2.gain.setValueAtTime(0.4, now);
    gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
    osc2.connect(gain2);
    gain2.connect(this.masterGain);
    osc2.start(now);
    osc2.stop(now + 0.38);
  }

  // 4. Safe square chime (temple bell harmonic)
  playSafeZone() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    [587.33, 880, 1174.66].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + idx * 0.03);

      gain.gain.setValueAtTime(0.14 / (idx + 1), now + idx * 0.03);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

      osc.connect(gain);
      gain.connect(this.masterGain);

      osc.start(now + idx * 0.03);
      osc.stop(now + 0.38);
    });
  }

  // 5. Thayam / Dayam celebration chime
  playThayamChime() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    const notes = [659.25, 783.99, 1046.50]; // E5, G5, C6
    notes.forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const start = now + idx * 0.08;

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, start);

      gain.gain.setValueAtTime(0.18, start);
      gain.gain.exponentialRampToValueAtTime(0.001, start + 0.28);

      osc.connect(gain);
      gain.connect(this.masterGain);

      osc.start(start);
      osc.stop(start + 0.3);
    });
  }

  // 6. Tactical hint chime
  playHintSound() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    [523.25, 659.25].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const start = now + idx * 0.09;

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, start);

      gain.gain.setValueAtTime(0.12, start);
      gain.gain.exponentialRampToValueAtTime(0.001, start + 0.2);

      osc.connect(gain);
      gain.connect(this.masterGain);

      osc.start(start);
      osc.stop(start + 0.22);
    });
  }

  // 7. Victory fanfare — Raga Mohanam (C4, D4, E4, G4, A4, C5)
  playVictory() {
    if (this.isMuted) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    const mohanamScale = [
      { f: 261.63, d: 0.15 }, // Sa
      { f: 293.66, d: 0.15 }, // Ri
      { f: 329.63, d: 0.15 }, // Ga
      { f: 392.00, d: 0.18 }, // Pa
      { f: 440.00, d: 0.22 }, // Dha
      { f: 523.25, d: 0.60 }  // High Sa
    ];

    let t = now;
    mohanamScale.forEach((note) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(note.f, t);

      gain.gain.setValueAtTime(0.24, t);
      gain.gain.exponentialRampToValueAtTime(0.001, t + note.d + 0.1);

      osc.connect(gain);
      gain.connect(this.masterGain);

      osc.start(t);
      osc.stop(t + note.d + 0.12);

      t += note.d;
    });
  }

  // 8. Meditative Indian Tanpura Drone
  toggleAmbientDrone() {
    this._initContext();
    if (this.isDronePlaying) {
      this.stopAmbientDrone();
      return false;
    } else {
      this.startAmbientDrone();
      return true;
    }
  }

  startAmbientDrone() {
    if (this.isDronePlaying) return;
    this._initContext();
    const ctx = this.audioCtx;
    const now = ctx.currentTime;

    this.droneGain = ctx.createGain();
    this.droneGain.gain.setValueAtTime(0.001, now);
    this.droneGain.gain.exponentialRampToValueAtTime(0.06, now + 1.2);
    this.droneGain.connect(this.masterGain);

    // Tanpura tuning: Pa (196 Hz) and Sa (130.81 Hz, 261.63 Hz)
    const droneFreqs = [130.81, 196.00, 261.63, 392.00];
    this.droneNodes = droneFreqs.map(freq => {
      const osc = ctx.createOscillator();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);
      osc.connect(this.droneGain);
      osc.start(now);
      return osc;
    });

    this.isDronePlaying = true;
  }

  stopAmbientDrone() {
    if (!this.isDronePlaying) return;
    const now = this.audioCtx.currentTime;
    if (this.droneGain) {
      this.droneGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.8);
      setTimeout(() => {
        this.droneNodes.forEach(node => {
          try { node.stop(); } catch(e){}
        });
        this.droneNodes = [];
      }, 900);
    }
    this.isDronePlaying = false;
  }
}

window.soundEngine = new GameSoundEngine();