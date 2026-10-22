/**
 * CHOLA DYNASTY THAYAKATTAI 3D (சோழர் தாயக்கட்டை)
 * Authentic Imperial Chola Era Indian Board Game
 * 
 * Features:
 * - High-Fidelity 3D Board mapped with traditional hand-carved Chola Board (board_chola.jpg)
 * - Raised 3D Dark Rosewood outer carved frame and beveled token trays
 * - Lathe-turned 3D Solid Brass Summit Boss Medallion with golden PBR reflections
 * - Royal Chola Medallion Coins (Gold Tiger Kasu & Ruby Enamel Kasu) with beaded milled rims
 * - Chola Hardwood Cube Dice with circular inlaid brass ring pips + Brass Stick Dice toggle
 * - Antique Indian Royal Silk Carpet Floor with intricate floral motifs
 * - Temple lamp lighting (Kuthuvilakku amber glow) + Directional sunlight with soft shadows
 * - Full 360° OrbitControls and Camera Presets (Photo Top-Down, Chola 3D, Dice Cam, Coin Trays)
 * - Authentic Tamil/English audio synthesizers, voice callouts, and intelligent Imperial AI Bot
 */

// ==========================================
// 1. GAME CONSTANTS & WORLD COORDINATES
// ==========================================

const TOKENS_PER_TEAM = 4;
const BOARD_WIDTH = 450;
const BOARD_LENGTH = 522.4; // 450 * (1024 / 882) matches board_chola.jpg aspect ratio

// Image dimensions: 882 x 1024
// Coordinate converter from image pixel (px, py) to 3D world (x, z):
const to3D = (px, py) => ({
  x: Number(((px - 441) / 882 * BOARD_WIDTH).toFixed(1)),
  z: Number(((py - 512) / 1024 * BOARD_LENGTH).toFixed(1))
});

const CELLS_3D = {};

function init3DGeometry() {
  // 1. Horizontal Crossbar (13 cells across y ≈ 642 px, from x=146 to x=735)
  for (let c = 0; c < 13; c++) {
    const px = 146 + c * ((735 - 146) / 12);
    const isRed = (c === 0 || c === 6 || c === 12);
    const coords = to3D(px, 642);
    CELLS_3D[`mid_${c}`] = { id: `mid_${c}`, ...coords, type: isRed ? 'red' : 'ivory' };
  }

  // 2. Center Vertical Spine (Below center cross, y goes from 692 to 850)
  const bCenterY = [692, 742, 792, 850];
  bCenterY.forEach((py, idx) => {
    const isRed = (idx === 3);
    const coords = to3D(441, py);
    CELLS_3D[`b_center_${idx}`] = { id: `b_center_${idx}`, ...coords, type: isRed ? 'red' : 'ivory' };
  });

  // 3. Center Vertical Spine (Above center cross, y goes from 592 up to 342)
  const uCenterY = [592, 542, 492, 442, 392, 342];
  uCenterY.forEach((py, idx) => {
    const coords = to3D(441, py);
    CELLS_3D[`u_center_${idx}`] = { id: `u_center_${idx}`, ...coords, type: 'ivory' };
  });

  // 4. Sacred Summit Brass Boss (At x=441, y=320)
  const summitCoords = to3D(441, 320);
  CELLS_3D['summit'] = { id: 'summit', ...summitCoords, type: 'summit' };

  // 5. Outer Flanks (Upper Left, Top, Upper Right)
  // Outer Left Vertical Edge (from y=642 up to y=140 at x=146)
  const flankRows = 9;
  for (let i = 0; i < flankRows; i++) {
    const py = 642 - (i + 1) * ((642 - 140) / (flankRows + 1));
    const coordsLeft = to3D(146, py);
    CELLS_3D[`u_left_${i}`] = { id: `u_left_${i}`, ...coordsLeft, type: 'ivory' };

    const coordsRight = to3D(735, py);
    CELLS_3D[`u_right_${i}`] = { id: `u_right_${i}`, ...coordsRight, type: 'ivory' };
  }

  // Top Flank (13 cells across y=140 from x=146 to x=735)
  for (let c = 0; c < 13; c++) {
    const px = 146 + c * ((735 - 146) / 12);
    const isRed = (c === 0 || c === 6 || c === 12);
    const coords = to3D(px, 140);
    CELLS_3D[`top_${c}`] = { id: `top_${c}`, ...coords, type: isRed ? 'red' : 'ivory' };
  }

  // 6. Stepped Gopuram / Temple Tower Wings (The W-shaped sacred path)
  // Left Tower (Vertical column inside the crimson border at x=258)
  const leftTowerY = [550, 495, 440, 385, 330];
  leftTowerY.forEach((py, idx) => {
    const coords = to3D(258, py);
    CELLS_3D[`l_tower_${idx}`] = { id: `l_tower_${idx}`, ...coords, type: 'gold_spire' };
  });

  // Left Stepped Staircase (From tower bottom up to summit)
  const leftSteps = [
    { px: 294, py: 510 },
    { px: 331, py: 468 },
    { px: 368, py: 426 },
    { px: 405, py: 384 },
  ];
  leftSteps.forEach((s, idx) => {
    const coords = to3D(s.px, s.py);
    CELLS_3D[`l_step_${idx}`] = { id: `l_step_${idx}`, ...coords, type: 'gold_spire' };
  });

  // Right Stepped Staircase (From summit down to right tower)
  const rightSteps = [
    { px: 477, py: 384 },
    { px: 514, py: 426 },
    { px: 551, py: 468 },
    { px: 588, py: 510 },
  ];
  rightSteps.forEach((s, idx) => {
    const coords = to3D(s.px, s.py);
    CELLS_3D[`r_step_${idx}`] = { id: `r_step_${idx}`, ...coords, type: 'ruby_spire' };
  });

  // Right Tower (Vertical column inside the crimson border at x=624)
  const rightTowerY = [550, 495, 440, 385, 330];
  rightTowerY.forEach((py, idx) => {
    const coords = to3D(624, py);
    CELLS_3D[`r_tower_${idx}`] = { id: `r_tower_${idx}`, ...coords, type: 'ruby_spire' };
  });
}

init3DGeometry();

// PATH ROUTES
// Team 1 (Chola Gold): Spawns at mid_0 (Left Red Safe Haven)
const PATH_TEAM1 = [
  'mid_0',
  'u_left_0', 'u_left_1', 'u_left_2', 'u_left_3', 'u_left_4', 'u_left_5', 'u_left_6', 'u_left_7', 'u_left_8',
  'top_0', 'top_1', 'top_2', 'top_3', 'top_4', 'top_5', 'top_6', 'top_7', 'top_8', 'top_9', 'top_10', 'top_11', 'top_12',
  'u_right_8', 'u_right_7', 'u_right_6', 'u_right_5', 'u_right_4', 'u_right_3', 'u_right_2', 'u_right_1', 'u_right_0',
  'mid_12', 'mid_11', 'mid_10', 'mid_9', 'mid_8', 'mid_7', 'mid_6',
  'b_center_0', 'b_center_1', 'b_center_2', 'b_center_3',
  'b_center_2', 'b_center_1', 'b_center_0', 'mid_6',
  'l_tower_0', 'l_tower_1', 'l_tower_2', 'l_tower_3', 'l_tower_4',
  'l_tower_3', 'l_tower_2', 'l_tower_1', 'l_tower_0',
  'l_step_0', 'l_step_1', 'l_step_2', 'l_step_3',
  'summit'
];

// Team 2 (Chola Ruby): Spawns at mid_12 (Right Red Safe Haven)
const PATH_TEAM2 = [
  'mid_12',
  'u_right_0', 'u_right_1', 'u_right_2', 'u_right_3', 'u_right_4', 'u_right_5', 'u_right_6', 'u_right_7', 'u_right_8',
  'top_12', 'top_11', 'top_10', 'top_9', 'top_8', 'top_7', 'top_6', 'top_5', 'top_4', 'top_3', 'top_2', 'top_1', 'top_0',
  'u_left_8', 'u_left_7', 'u_left_6', 'u_left_5', 'u_left_4', 'u_left_3', 'u_left_2', 'u_left_1', 'u_left_0',
  'mid_0', 'mid_1', 'mid_2', 'mid_3', 'mid_4', 'mid_5', 'mid_6',
  'b_center_0', 'b_center_1', 'b_center_2', 'b_center_3',
  'b_center_2', 'b_center_1', 'b_center_0', 'mid_6',
  'r_tower_0', 'r_tower_1', 'r_tower_2', 'r_tower_3', 'r_tower_4',
  'r_tower_3', 'r_tower_2', 'r_tower_1', 'r_tower_0',
  'r_step_3', 'r_step_2', 'r_step_1', 'r_step_0',
  'summit'
];

const TEAM_PATHS = {
  team1: PATH_TEAM1,
  team2: PATH_TEAM2,
};

// 6 coin slots in the carved wooden trays matching the exact photo (2 rows of 3)
const BASE_SLOTS = {
  team1: [
    { x: -105, z: 113 }, { x: -84, z: 113 }, { x: -63, z: 113 },
    { x: -105, z: 145 }, { x: -84, z: 145 }, { x: -63, z: 145 }
  ],
  team2: [
    { x: 63, z: 113 }, { x: 84, z: 113 }, { x: 105, z: 113 },
    { x: 63, z: 145 }, { x: 84, z: 145 }, { x: 105, z: 145 }
  ]
};

// Dice positions outside the board on the Royal Velvet Rolling Mat (Left side, unobstructed by HUD)
const DICE_OUTSIDE_POSITIONS = {
  mat: { x: -325, y: -9.2, z: 65 },
  stick1: { x: -342, y: -0.75, z: 35 },
  stick2: { x: -308, y: -0.75, z: 75 },
  cube1: { x: -340, y: 1.5, z: 35 },
  cube2: { x: -310, y: 1.5, z: 75 }
};
const DICE_TRAY_POSITIONS = DICE_OUTSIDE_POSITIONS;

// ==========================================
// 2. PROCEDURAL HIGH-RES TEXTURE GENERATORS
// ==========================================

class CholaTextureFactory {
  // 1. Antique Indian Royal Silk Carpet Floor (Matching photo backdrop)
  static createCarpetTexture() {
    const c = document.createElement('canvas');
    c.width = 1024;
    c.height = 1024;
    const ctx = c.getContext('2d');

    // Deep rich antique Persian/Indian carpet base
    ctx.fillStyle = '#2a0a10';
    ctx.fillRect(0, 0, 1024, 1024);

    // Ornate floral repeating rug pattern
    ctx.strokeStyle = '#4a151d';
    ctx.lineWidth = 1;
    for (let i = 0; i < 1024; i += 8) {
      ctx.beginPath();
      ctx.moveTo(0, i);
      ctx.lineTo(1024, i);
      ctx.stroke();
    }

    // Outer intricate runner border
    ctx.strokeStyle = '#8c5e26';
    ctx.lineWidth = 18;
    ctx.strokeRect(30, 30, 964, 964);

    ctx.strokeStyle = '#2d5a3f';
    ctx.lineWidth = 10;
    ctx.strokeRect(50, 50, 924, 924);

    ctx.strokeStyle = '#caa14a';
    ctx.lineWidth = 4;
    ctx.strokeRect(65, 65, 894, 894);

    // Center grand medallion
    const cx = 512, cy = 512;
    const rad = 280;
    const g = ctx.createRadialGradient(cx, cy, 20, cx, cy, rad);
    g.addColorStop(0, '#751825');
    g.addColorStop(0.6, '#461019');
    g.addColorStop(1, '#2a0a10');
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.arc(cx, cy, rad, 0, Math.PI * 2);
    ctx.fill();

    // Medallion lotus petals
    ctx.strokeStyle = '#d4af37';
    ctx.lineWidth = 3;
    for (let a = 0; a < Math.PI * 2; a += Math.PI / 12) {
      const x1 = cx + Math.cos(a) * (rad - 40);
      const y1 = cy + Math.sin(a) * (rad - 40);
      const x2 = cx + Math.cos(a + 0.15) * rad;
      const y2 = cy + Math.sin(a + 0.15) * rad;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.quadraticCurveTo(x1, y1, x2, y2);
      ctx.stroke();
    }

    const tex = new THREE.CanvasTexture(c);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(2, 2);
    tex.anisotropy = 4;
    return tex;
  }

  // 2. Chola Royal Gold Tiger Coin Face Texture (சோழர் பொற்காசு)
  static createGoldCoinTexture() {
    const c = document.createElement('canvas');
    c.width = 512;
    c.height = 512;
    const ctx = c.getContext('2d');

    // Concentric lathe-turned antique gold background
    const g = ctx.createRadialGradient(256, 256, 10, 256, 256, 256);
    g.addColorStop(0, '#fff4b0');
    g.addColorStop(0.3, '#f2ca52');
    g.addColorStop(0.7, '#c99624');
    g.addColorStop(0.95, '#875d08');
    g.addColorStop(1, '#573b03');
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.arc(256, 256, 256, 0, Math.PI * 2);
    ctx.fill();

    // Fine concentric lathe groove rings
    ctx.strokeStyle = 'rgba(100, 70, 10, 0.25)';
    ctx.lineWidth = 1.5;
    for (let r = 30; r < 240; r += 14) {
      ctx.beginPath();
      ctx.arc(256, 256, r, 0, Math.PI * 2);
      ctx.stroke();
    }

    // Beaded milled outer rim (36 circular beads)
    const numBeads = 36;
    for (let i = 0; i < numBeads; i++) {
      const angle = (i / numBeads) * Math.PI * 2;
      const bx = 256 + Math.cos(angle) * 232;
      const by = 256 + Math.sin(angle) * 232;
      ctx.fillStyle = '#fff8cb';
      ctx.beginPath();
      ctx.arc(bx, by, 7, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#7c5306';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    // Inner relief ring
    ctx.strokeStyle = '#573b03';
    ctx.lineWidth = 5;
    ctx.beginPath();
    ctx.arc(256, 256, 210, 0, Math.PI * 2);
    ctx.stroke();

    // Embossed Chola Royal Tiger (சோழர் புலி) Crest in relief
    ctx.save();
    ctx.translate(256, 256);
    
    // Shadow for relief depth
    ctx.shadowColor = 'rgba(0,0,0,0.6)';
    ctx.shadowBlur = 8;
    ctx.shadowOffsetX = 3;
    ctx.shadowOffsetY = 4;

    // Tiger head and body silhouette in antique gold
    ctx.fillStyle = '#fffae0';
    ctx.strokeStyle = '#6e4a06';
    ctx.lineWidth = 4;

    // Body & raised forepaw
    ctx.beginPath();
    ctx.ellipse(15, 30, 80, 50, -0.2, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Tiger Head
    ctx.beginPath();
    ctx.arc(-55, -20, 42, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Snout & Ears
    ctx.beginPath();
    ctx.moveTo(-90, -15);
    ctx.lineTo(-75, -5);
    ctx.lineTo(-65, -30);
    ctx.lineTo(-50, -60);
    ctx.lineTo(-30, -35);
    ctx.lineTo(-10, -55);
    ctx.lineTo(0, -25);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Curled Royal Tail
    ctx.beginPath();
    ctx.lineWidth = 14;
    ctx.strokeStyle = '#fffae0';
    ctx.arc(95, 0, 50, Math.PI * 0.4, Math.PI * 1.6, false);
    ctx.stroke();
    ctx.lineWidth = 4;
    ctx.strokeStyle = '#6e4a06';
    ctx.stroke();

    // Royal Parasol / Sun Disc above tiger
    ctx.fillStyle = '#ffef96';
    ctx.beginPath();
    ctx.arc(-10, -110, 24, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Tamil Chola Script (சோழர்)
    ctx.shadowBlur = 0;
    ctx.fillStyle = '#5c3d04';
    ctx.font = '900 36px "Noto Sans Tamil", Cinzel, serif';
    ctx.textAlign = 'center';
    ctx.fillText('சோழர்', 0, 150);

    ctx.restore();

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 8;
    return tex;
  }

  // 3. Chola Royal Ruby Lacquer Coin Face Texture (சோழர் மாணிக்கக் காசு)
  static createRubyCoinTexture() {
    const c = document.createElement('canvas');
    c.width = 512;
    c.height = 512;
    const ctx = c.getContext('2d');

    // Deep royal ruby / garnet lacquer gradient
    const g = ctx.createRadialGradient(256, 256, 10, 256, 256, 256);
    g.addColorStop(0, '#c92a42');
    g.addColorStop(0.4, '#9e1b2f');
    g.addColorStop(0.75, '#6a0a18');
    g.addColorStop(1, '#3b020b');
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.arc(256, 256, 256, 0, Math.PI * 2);
    ctx.fill();

    // Beaded antique gold rim
    const numBeads = 36;
    for (let i = 0; i < numBeads; i++) {
      const angle = (i / numBeads) * Math.PI * 2;
      const bx = 256 + Math.cos(angle) * 232;
      const by = 256 + Math.sin(angle) * 232;
      ctx.fillStyle = '#fce59f';
      ctx.beginPath();
      ctx.arc(bx, by, 7, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#4a050d';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    ctx.strokeStyle = '#e0b543';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(256, 256, 210, 0, Math.PI * 2);
    ctx.stroke();

    // Embossed Royal Celestial Yali (யாளி) / Lion crest in antique gold relief
    ctx.save();
    ctx.translate(256, 256);
    ctx.shadowColor = 'rgba(0,0,0,0.7)';
    ctx.shadowBlur = 8;
    ctx.shadowOffsetX = 3;
    ctx.shadowOffsetY = 4;

    ctx.fillStyle = '#ffeaa6';
    ctx.strokeStyle = '#42030a';
    ctx.lineWidth = 4;

    // Celestial Lion Body
    ctx.beginPath();
    ctx.ellipse(10, 25, 75, 45, 0.2, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Lion Head & Mane
    ctx.beginPath();
    ctx.arc(-50, -25, 45, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Radiating Mane Spikes
    for (let a = -Math.PI * 0.9; a < Math.PI * 0.2; a += 0.35) {
      const mx = -50 + Math.cos(a) * 58;
      const my = -25 + Math.sin(a) * 58;
      ctx.beginPath();
      ctx.arc(mx, my, 8, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();
    }

    // Upright Curled Tail
    ctx.beginPath();
    ctx.lineWidth = 14;
    ctx.strokeStyle = '#ffeaa6';
    ctx.arc(85, -5, 45, Math.PI * 0.2, Math.PI * 1.5, true);
    ctx.stroke();
    ctx.lineWidth = 4;
    ctx.strokeStyle = '#42030a';
    ctx.stroke();

    // Tamil inscription (வீரம் / Valor)
    ctx.shadowBlur = 0;
    ctx.fillStyle = '#ffeed0';
    ctx.font = '900 36px "Noto Sans Tamil", Cinzel, serif';
    ctx.textAlign = 'center';
    ctx.fillText('வீரம்', 0, 150);

    ctx.restore();

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 8;
    return tex;
  }

  // 4. Hardwood Cube Dice Face with Inlaid Brass Ring Pips (Matching Photo)
  static createWoodDiceFaceTexture(pips) {
    const c = document.createElement('canvas');
    c.width = 256;
    c.height = 256;
    const ctx = c.getContext('2d');

    // Rich Indian Teak / Walnut woodgrain
    const g = ctx.createLinearGradient(0, 0, 256, 256);
    g.addColorStop(0, '#784620');
    g.addColorStop(0.3, '#5e3212');
    g.addColorStop(0.65, '#48240a');
    g.addColorStop(1, '#371805');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 256, 256);

    // Subtle wood fibers
    ctx.strokeStyle = 'rgba(25, 10, 2, 0.35)';
    ctx.lineWidth = 1;
    for (let y = 6; y < 256; y += 7) {
      ctx.beginPath();
      ctx.moveTo(0, y + (Math.sin(y * 0.1) * 3));
      ctx.lineTo(256, y + (Math.cos(y * 0.08) * 4));
      ctx.stroke();
    }

    // Rounded beveled outer border
    ctx.strokeStyle = '#271003';
    ctx.lineWidth = 8;
    ctx.strokeRect(4, 4, 248, 248);

    // Helper to draw an authentic circular brass-inlaid ring pip
    const drawBrassPip = (x, y) => {
      // Outer brass ring
      const brassGrad = ctx.createRadialGradient(x, y, 10, x, y, 22);
      brassGrad.addColorStop(0, '#fde68a');
      brassGrad.addColorStop(0.5, '#d4af37');
      brassGrad.addColorStop(1, '#856114');
      ctx.fillStyle = brassGrad;
      ctx.beginPath();
      ctx.arc(x, y, 22, 0, Math.PI * 2);
      ctx.fill();

      // Recessed dark wood center hole
      ctx.fillStyle = '#1c0902';
      ctx.beginPath();
      ctx.arc(x, y, 12, 0, Math.PI * 2);
      ctx.fill();

      // Subtle brass rim highlight
      ctx.strokeStyle = '#fff5ba';
      ctx.lineWidth = 2.5;
      ctx.beginPath();
      ctx.arc(x, y, 20.5, -Math.PI * 0.7, Math.PI * 0.2);
      ctx.stroke();

      // Recessed inner shadow
      ctx.strokeStyle = '#0a0300';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(x, y, 12, 0, Math.PI * 2);
      ctx.stroke();
    };

    // Pip layouts for faces 1 to 6
    const c1 = 64, c2 = 128, c3 = 192;
    switch (pips) {
      case 1:
        drawBrassPip(c2, c2);
        break;
      case 2:
        drawBrassPip(c1, c1);
        drawBrassPip(c3, c3);
        break;
      case 3:
        drawBrassPip(c1, c1);
        drawBrassPip(c2, c2);
        drawBrassPip(c3, c3);
        break;
      case 4:
        drawBrassPip(c1, c1);
        drawBrassPip(c3, c1);
        drawBrassPip(c1, c3);
        drawBrassPip(c3, c3);
        break;
      case 5:
        drawBrassPip(c1, c1);
        drawBrassPip(c3, c1);
        drawBrassPip(c2, c2);
        drawBrassPip(c1, c3);
        drawBrassPip(c3, c3);
        break;
      case 6:
        drawBrassPip(c1, 56);
        drawBrassPip(c1, c2);
        drawBrassPip(c1, 200);
        drawBrassPip(c3, 56);
        drawBrassPip(c3, c2);
        drawBrassPip(c3, 200);
        break;
    }

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 4;
    return tex;
  }

  // 5. Traditional Dayakattai Rectangular Stick Face Texture (High-Def 512x128)
  static createStickFaceTex(dots, isBrass = false) {
    const c = document.createElement('canvas');
    c.width = 512;
    c.height = 128;
    const ctx = c.getContext('2d');

    if (isBrass) {
      // Solid lathe-turned antique brass
      const g = ctx.createLinearGradient(0, 0, 0, 128);
      g.addColorStop(0, '#fff6d1');
      g.addColorStop(0.2, '#f0d278');
      g.addColorStop(0.5, '#c99e32');
      g.addColorStop(0.85, '#8c6b1a');
      g.addColorStop(1, '#5e430a');
      ctx.fillStyle = g;
      ctx.fillRect(0, 0, 512, 128);

      // Fine brushed metallic horizontal lines
      ctx.strokeStyle = 'rgba(100, 75, 15, 0.2)';
      ctx.lineWidth = 1;
      for (let y = 4; y < 128; y += 5) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(512, y);
        ctx.stroke();
      }
    } else {
      // Imperial Indian Dark Rosewood / Teak
      const g = ctx.createLinearGradient(0, 0, 0, 128);
      g.addColorStop(0, '#542610');
      g.addColorStop(0.25, '#3d1a08');
      g.addColorStop(0.65, '#2c1205');
      g.addColorStop(1, '#1d0b03');
      ctx.fillStyle = g;
      ctx.fillRect(0, 0, 512, 128);

      // Natural woodgrain fibers
      ctx.strokeStyle = 'rgba(15, 6, 2, 0.35)';
      ctx.lineWidth = 1.5;
      for (let y = 6; y < 128; y += 7) {
        ctx.beginPath();
        ctx.moveTo(0, y + Math.sin(y * 0.1) * 3);
        ctx.lineTo(512, y + Math.cos(y * 0.08) * 4);
        ctx.stroke();
      }
    }

    // Beveled outer boundary
    ctx.strokeStyle = isBrass ? '#473205' : '#140602';
    ctx.lineWidth = 6;
    ctx.strokeRect(3, 3, 506, 122);

    // Decorative brass cap bands on left and right ends
    const drawCapBand = (startX) => {
      const bandGrad = ctx.createLinearGradient(startX, 0, startX + 32, 0);
      bandGrad.addColorStop(0, '#a37c22');
      bandGrad.addColorStop(0.5, '#f5d878');
      bandGrad.addColorStop(1, '#856315');
      ctx.fillStyle = bandGrad;
      ctx.fillRect(startX, 6, 32, 116);

      ctx.strokeStyle = '#573e08';
      ctx.lineWidth = 2;
      ctx.strokeRect(startX, 6, 32, 116);

      // Engraved diamond pattern on band
      ctx.strokeStyle = '#fff5bd';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(startX + 16, 12);
      ctx.lineTo(startX + 26, 64);
      ctx.lineTo(startX + 16, 116);
      ctx.lineTo(startX + 6, 64);
      ctx.closePath();
      ctx.stroke();
    };

    drawCapBand(6);
    drawCapBand(474);

    // Helper to draw authentic circular brass-inlaid ring pip
    const drawStickPip = (x, y) => {
      // Outer brass ring
      const brassGrad = ctx.createRadialGradient(x, y, 6, x, y, 22);
      brassGrad.addColorStop(0, '#fff4b5');
      brassGrad.addColorStop(0.4, '#e0b843');
      brassGrad.addColorStop(0.85, '#8c6817');
      brassGrad.addColorStop(1, '#4f3807');
      ctx.fillStyle = brassGrad;
      ctx.beginPath();
      ctx.arc(x, y, 22, 0, Math.PI * 2);
      ctx.fill();

      // Recessed dark wood/lacquer center hole
      ctx.fillStyle = '#0f0501';
      ctx.beginPath();
      ctx.arc(x, y, 12, 0, Math.PI * 2);
      ctx.fill();

      // Specular highlight crescent
      ctx.strokeStyle = '#fffde6';
      ctx.lineWidth = 2.5;
      ctx.beginPath();
      ctx.arc(x, y, 20.5, -Math.PI * 0.7, Math.PI * 0.1);
      ctx.stroke();

      // Inner shadow ring
      ctx.strokeStyle = '#050201';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.arc(x, y, 12, 0, Math.PI * 2);
      ctx.stroke();
    };

    const centerY = 64;

    if (dots === 0) {
      // Dayam / 0: Royal Chola 8-pointed star / Sun Medallion (✦)
      const cx = 256, cy = 64;
      ctx.save();
      ctx.translate(cx, cy);

      // Radiating golden petals
      for (let a = 0; a < Math.PI * 2; a += Math.PI / 4) {
        ctx.save();
        ctx.rotate(a);
        const rayGrad = ctx.createLinearGradient(0, 0, 36, 0);
        rayGrad.addColorStop(0, '#fff2ad');
        rayGrad.addColorStop(0.6, '#d4af37');
        rayGrad.addColorStop(1, '#825e11');
        ctx.fillStyle = rayGrad;
        ctx.beginPath();
        ctx.moveTo(0, -6);
        ctx.lineTo(36, 0);
        ctx.lineTo(0, 6);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
      }

      // Center brass boss
      drawStickPip(0, 0);
      ctx.restore();
    } else if (dots === 1) {
      drawStickPip(256, centerY);
    } else if (dots === 2) {
      drawStickPip(180, centerY);
      drawStickPip(332, centerY);
    } else if (dots === 3) {
      drawStickPip(140, centerY);
      drawStickPip(256, centerY);
      drawStickPip(372, centerY);
    } else if (dots === 4) {
      drawStickPip(110, centerY);
      drawStickPip(207, centerY);
      drawStickPip(305, centerY);
      drawStickPip(402, centerY);
    }

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 4;
    return tex;
  }

  // Lathe-turned brass end cap for rectangular stick ends (128x128)
  static createStickEndCapTex(isBrass = false) {
    const c = document.createElement('canvas');
    c.width = 128;
    c.height = 128;
    const ctx = c.getContext('2d');

    const g = ctx.createRadialGradient(64, 64, 4, 64, 64, 64);
    g.addColorStop(0, '#fff8c7');
    g.addColorStop(0.3, '#dfb746');
    g.addColorStop(0.75, '#876516');
    g.addColorStop(1, '#422f06');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 128, 128);

    ctx.strokeStyle = '#382503';
    ctx.lineWidth = 4;
    ctx.strokeRect(2, 2, 124, 124);

    // Concentric lathe grooves
    ctx.strokeStyle = 'rgba(70, 48, 8, 0.45)';
    ctx.lineWidth = 2;
    for (let r = 16; r <= 52; r += 12) {
      ctx.beginPath();
      ctx.arc(64, 64, r, 0, Math.PI * 2);
      ctx.stroke();
    }

    // Center rivet boss
    ctx.fillStyle = '#fff4a8';
    ctx.beginPath();
    ctx.arc(64, 64, 8, 0, Math.PI * 2);
    ctx.fill();

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 4;
    return tex;
  }

  // Royal Velvet Dice Rolling Mat Texture (outside the board)
  static createDiceMatTexture() {
    const c = document.createElement('canvas');
    c.width = 256;
    c.height = 512;
    const ctx = c.getContext('2d');

    // Deep royal crimson / burgundy velvet
    const g = ctx.createLinearGradient(0, 0, 256, 512);
    g.addColorStop(0, '#420811');
    g.addColorStop(0.35, '#2e040a');
    g.addColorStop(0.7, '#240207');
    g.addColorStop(1, '#170104');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 256, 512);

    // Subtle velvet weave noise
    ctx.fillStyle = 'rgba(255, 180, 180, 0.025)';
    for (let i = 0; i < 6000; i++) {
      const rx = Math.random() * 256;
      const ry = Math.random() * 512;
      ctx.fillRect(rx, ry, 1.5, 1.5);
    }

    // Gold embroidered outer border
    ctx.strokeStyle = '#c49a31';
    ctx.lineWidth = 8;
    ctx.strokeRect(12, 12, 232, 488);

    ctx.strokeStyle = '#735211';
    ctx.lineWidth = 2;
    ctx.strokeRect(18, 18, 220, 476);

    ctx.strokeStyle = '#ffd86b';
    ctx.lineWidth = 1.5;
    ctx.strokeRect(22, 22, 212, 468);

    // Center gold-embroidered Chola lotus medallion
    const cx = 128, cy = 256;
    ctx.strokeStyle = 'rgba(212, 175, 55, 0.35)';
    ctx.lineWidth = 2;
    for (let a = 0; a < Math.PI * 2; a += Math.PI / 6) {
      const x1 = cx + Math.cos(a) * 45;
      const y1 = cy + Math.sin(a) * 45;
      ctx.beginPath();
      ctx.arc(x1, y1, 14, 0, Math.PI * 2);
      ctx.stroke();
    }
    ctx.beginPath();
    ctx.arc(cx, cy, 22, 0, Math.PI * 2);
    ctx.stroke();

    const tex = new THREE.CanvasTexture(c);
    tex.anisotropy = 4;
    return tex;
  }
}

// ==========================================
// 3. THREE.JS 3D SCENE & WORLD BUILDER
// ==========================================

class BoardWorld3D {
  constructor(containerEl, onTokenClick, onDiceClick) {
    this.container = containerEl;
    this.onTokenClick = onTokenClick;
    this.onDiceClick = onDiceClick;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0a0503);

    this.camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 10, 2500);
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.container.appendChild(this.renderer.domElement);

    this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.06;
    this.controls.maxPolarAngle = Math.PI / 2 - 0.04;
    this.controls.minDistance = 220;
    this.controls.maxDistance = 1200;

    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();
    this.interactiveMeshes = [];

    // Mesh stores
    this.tileMeshes = {};
    this.tokenMeshes = {};
    this.cubeDiceMeshes = [];
    this.stickDiceMeshes = [];
    this.diceMode = 'cubes'; // 'cubes' (Chola Hardwood Dice) or 'sticks' (Brass Sticks)
    this.summitBrassBossMesh = null;
    this.ambientLamps = [];

    this.setupLighting();
    this.buildEnvironmentAndBoard();
    this.buildSummitBrassBoss();
    this.buildDice();
    this.setupEvents();

    // Default to the exact Photo View matching the user's photograph
    this.setCameraView('top');
    this.animate();
  }

  setupLighting() {
    // 1. Warm temple interior ambient light
    const ambientLight = new THREE.AmbientLight(0xffecd0, 0.85);
    this.scene.add(ambientLight);

    // 2. Primary directional sunlight casting crisp soft shadows
    const dirLight = new THREE.DirectionalLight(0xfffaea, 1.35);
    dirLight.position.set(140, 520, 240);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 2048;
    dirLight.shadow.mapSize.height = 2048;
    dirLight.shadow.camera.near = 50;
    dirLight.shadow.camera.far = 1000;
    const d = 360;
    dirLight.shadow.camera.left = -d;
    dirLight.shadow.camera.right = d;
    dirLight.shadow.camera.top = d;
    dirLight.shadow.camera.bottom = -d;
    dirLight.shadow.bias = -0.0004;
    this.scene.add(dirLight);

    // 3. Subtle blue ambient fill light
    const fillLight = new THREE.DirectionalLight(0xa5c4f2, 0.35);
    fillLight.position.set(-220, 320, -220);
    this.scene.add(fillLight);

    // 4. Two warm temple brass oil lamps (Kuthuvilakku glow) on left and right
    const leftLamp = new THREE.PointLight(0xffaa33, 0.9, 450);
    leftLamp.position.set(-280, 75, 40);
    this.scene.add(leftLamp);
    this.ambientLamps.push(leftLamp);

    const rightLamp = new THREE.PointLight(0xffaa33, 0.9, 450);
    rightLamp.position.set(280, 75, 40);
    this.scene.add(rightLamp);
    this.ambientLamps.push(rightLamp);

    // 5. Golden specular light focused on Summit Brass Boss
    const summitLight = new THREE.PointLight(0xffd700, 1.1, 300);
    summitLight.position.set(0, 55, -98);
    this.scene.add(summitLight);
  }

  buildEnvironmentAndBoard() {
    // 1. Antique Indian Royal Silk Carpet Floor
    const carpetTex = CholaTextureFactory.createCarpetTexture();
    const carpetGeo = new THREE.PlaneGeometry(1600, 1600);
    const carpetMat = new THREE.MeshStandardMaterial({
      map: carpetTex,
      roughness: 0.9,
      metalness: 0.05,
    });
    const carpetMesh = new THREE.Mesh(carpetGeo, carpetMat);
    carpetMesh.rotation.x = -Math.PI / 2;
    carpetMesh.position.y = -10;
    carpetMesh.receiveShadow = true;
    this.scene.add(carpetMesh);

    // 2. Real 3D Raised Beveled Rosewood Outer Rim (Frame)
    const frameW = BOARD_WIDTH + 36;
    const frameL = BOARD_LENGTH + 36;
    const frameGeo = new THREE.BoxGeometry(frameW, 20, frameL);
    const rosewoodMat = new THREE.MeshStandardMaterial({
      color: 0x33170a,
      roughness: 0.45,
      metalness: 0.15,
    });
    const frameMesh = new THREE.Mesh(frameGeo, rosewoodMat);
    frameMesh.position.y = 0;
    frameMesh.castShadow = true;
    frameMesh.receiveShadow = true;
    this.scene.add(frameMesh);

    // 3. The Chola Board Surface Mesh (textured with board_chola.jpg)
    const textureLoader = new THREE.TextureLoader();
    const boardTex = textureLoader.load('board_chola.jpg');
    boardTex.anisotropy = this.renderer.capabilities.getMaxAnisotropy();

    // Box geometry for the board slab: top face gets the board photo, sides get dark rosewood
    const boardGeo = new THREE.BoxGeometry(BOARD_WIDTH, 12, BOARD_LENGTH);
    const boardSideMat = new THREE.MeshStandardMaterial({
      color: 0x2a1207,
      roughness: 0.5,
      metalness: 0.15
    });
    const boardTopMat = new THREE.MeshStandardMaterial({
      map: boardTex,
      roughness: 0.38,
      metalness: 0.12,
    });

    // 6-material array: [right, left, top, bottom, front, back]
    const boardMaterials = [
      boardSideMat, boardSideMat,
      boardTopMat, boardSideMat,
      boardSideMat, boardSideMat
    ];

    const boardMesh = new THREE.Mesh(boardGeo, boardMaterials);
    boardMesh.position.y = 6;
    boardMesh.receiveShadow = true;
    this.scene.add(boardMesh);
    this.boardMesh = boardMesh;
    this.boardTopMat = boardTopMat;
    this.textureLoader = textureLoader;

    // 4. Subtle 3D Interactive Tiles overlaid on the board
    // These tiles are semi-translucent so the hand-carved wood grain shows through,
    // and illuminate with a warm golden glow when selected or hovered!
    const baseTileMat = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.08,
      roughness: 0.2,
      metalness: 0.1,
    });

    const redTileMat = new THREE.MeshStandardMaterial({
      color: 0x9e1b2f,
      transparent: true,
      opacity: 0.22,
      roughness: 0.25,
      metalness: 0.25,
    });

    Object.values(CELLS_3D).forEach(cell => {
      if (cell.id === 'summit') return; // Summit has dedicated 3D Brass Boss

      const isRed = (cell.type === 'red');
      const mat = (isRed ? redTileMat : baseTileMat).clone();
      const tileSize = 24;
      const tileH = 2.5;
      const geo = new THREE.BoxGeometry(tileSize, tileH, tileSize);

      const tileMesh = new THREE.Mesh(geo, mat);
      tileMesh.position.set(cell.x, 12.5 + tileH / 2, cell.z);
      tileMesh.userData = { cellId: cell.id, originalOpacity: mat.opacity, originalColor: mat.color.getHex() };

      this.scene.add(tileMesh);
      this.tileMeshes[cell.id] = tileMesh;
    });

    // 5. Royal Silk Velvet Dice Rolling Mat outside the board
    const matTex = CholaTextureFactory.createDiceMatTexture();
    const matGeo = new THREE.BoxGeometry(118, 2, 270);
    const matRimMat = new THREE.MeshStandardMaterial({
      color: 0x240e04,
      roughness: 0.5,
      metalness: 0.15
    });
    const matTopMat = new THREE.MeshStandardMaterial({
      map: matTex,
      roughness: 0.85,
      metalness: 0.08
    });
    const matMaterials = [
      matRimMat, matRimMat,
      matTopMat, matRimMat,
      matRimMat, matRimMat
    ];
    const diceMatMesh = new THREE.Mesh(matGeo, matMaterials);
    diceMatMesh.position.set(DICE_OUTSIDE_POSITIONS.mat.x, DICE_OUTSIDE_POSITIONS.mat.y, DICE_OUTSIDE_POSITIONS.mat.z);
    diceMatMesh.receiveShadow = true;
    this.scene.add(diceMatMesh);
    this.diceMatMesh = diceMatMesh;
  }

  setBoardTexture(theme) {
    const file = (theme === 'yellow') ? 'board_chola_original_yellow.jpg' : 'board_chola.jpg';
    const tex = this.textureLoader.load(file);
    tex.anisotropy = this.renderer.capabilities.getMaxAnisotropy();
    this.boardTopMat.map = tex;
    this.boardTopMat.needsUpdate = true;
  }

  // Lathe-Turned 3D Solid Brass Boss on Summit (As shown on the photo)
  buildSummitBrassBoss() {
    const bossGroup = new THREE.Group();

    const brassMat = new THREE.MeshStandardMaterial({
      color: 0xdfb142,
      metalness: 0.95,
      roughness: 0.16,
      emissive: 0x473708,
    });

    // Tier 1: Main round boss disc
    const discGeo = new THREE.CylinderGeometry(15, 16, 4, 36);
    const disc = new THREE.Mesh(discGeo, brassMat);
    disc.position.y = 2;
    disc.castShadow = true;
    bossGroup.add(disc);

    // Tier 2: Lathe-turned concentric ring
    const ringGeo = new THREE.TorusGeometry(11, 1.8, 16, 36);
    const ring = new THREE.Mesh(ringGeo, brassMat);
    ring.rotation.x = Math.PI / 2;
    ring.position.y = 4.2;
    bossGroup.add(ring);

    // Tier 3: Center boss finial dome
    const domeGeo = new THREE.CylinderGeometry(5, 6, 2.5, 24);
    const dome = new THREE.Mesh(domeGeo, brassMat);
    dome.position.y = 5.2;
    bossGroup.add(dome);

    // Summit location: x = 0, y = 12.5, z = -97.9
    bossGroup.position.set(0, 12.5, -97.9);
    this.scene.add(bossGroup);
    this.summitBrassBossMesh = bossGroup;
  }

  // Build Both 3D Dice Styles (Traditional Rectangular Sticks + Hardwood Cubes)
  buildDice() {
    this.buildBrassStickDice();
    this.buildHardwoodCubeDice();
    this.setDiceMode('sticks'); // Rectangular sticks are the default!
  }

  // 1. Two 3D Traditional Rectangular Hardwood / Brass Stick Dice (Rolling on Mat Outside Board)
  buildBrassStickDice() {
    const stickW = 82;
    const stickH = 16;
    const stickD = 16;

    const endCapMat = new THREE.MeshStandardMaterial({
      map: CholaTextureFactory.createStickEndCapTex(false),
      roughness: 0.35,
      metalness: 0.55
    });

    const topMat = new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createStickFaceTex(1, false), roughness: 0.32, metalness: 0.25 });
    const bottomMat = new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createStickFaceTex(3, false), roughness: 0.32, metalness: 0.25 });
    const frontMat = new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createStickFaceTex(2, false), roughness: 0.32, metalness: 0.25 });
    const backMat = new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createStickFaceTex(0, false), roughness: 0.32, metalness: 0.25 });

    const stickMats = [
      endCapMat, endCapMat,
      topMat, bottomMat,
      frontMat, backMat
    ];

    const stickGeo = new THREE.BoxGeometry(stickW, stickH, stickD);

    [DICE_OUTSIDE_POSITIONS.stick1, DICE_OUTSIDE_POSITIONS.stick2].forEach((pos, idx) => {
      const mesh = new THREE.Mesh(stickGeo, stickMats);
      mesh.position.set(pos.x, pos.y, pos.z);
      mesh.rotation.y = (idx === 0) ? 0.08 : -0.06;
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      mesh.visible = true;
      mesh.userData = { isDice: true, isStick: true, index: idx };

      this.scene.add(mesh);
      this.stickDiceMeshes.push(mesh);
      this.interactiveMeshes.push(mesh);
    });
  }

  // 2. Two 3D Hardwood Dice Cubes (Optional toggle)
  buildHardwoodCubeDice() {
    const cubeSize = 20;
    const cubeGeo = new THREE.BoxGeometry(cubeSize, cubeSize, cubeSize);

    const cubeMats = [
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(1), roughness: 0.35, metalness: 0.2 }),
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(6), roughness: 0.35, metalness: 0.2 }),
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(2), roughness: 0.35, metalness: 0.2 }),
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(5), roughness: 0.35, metalness: 0.2 }),
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(3), roughness: 0.35, metalness: 0.2 }),
      new THREE.MeshStandardMaterial({ map: CholaTextureFactory.createWoodDiceFaceTexture(4), roughness: 0.35, metalness: 0.2 }),
    ];

    [DICE_OUTSIDE_POSITIONS.cube1, DICE_OUTSIDE_POSITIONS.cube2].forEach((pos, idx) => {
      const mesh = new THREE.Mesh(cubeGeo, cubeMats);
      mesh.position.set(pos.x, pos.y, pos.z);
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      mesh.visible = false;
      mesh.userData = { isDice: true, isCube: true, index: idx };

      this.scene.add(mesh);
      this.cubeDiceMeshes.push(mesh);
      this.interactiveMeshes.push(mesh);
    });
  }

  // Switch between Traditional Rectangular Sticks and Hardwood Cubes
  setDiceMode(mode) {
    this.diceMode = mode;
    const isCubes = (mode === 'cubes');
    this.cubeDiceMeshes.forEach(m => m.visible = isCubes);
    this.stickDiceMeshes.forEach(m => m.visible = !isCubes);
  }

  // Create 3D Chola Royal Medallion Coin Token
  createTokenMesh(team, tokenId) {
    const group = new THREE.Group();
    const radius = 12.5;
    const height = 4.2;

    const geo = new THREE.CylinderGeometry(radius, radius, height, 36);
    const isTeam1 = (team === 'team1');

    // Face canvas texture with embossed Chola Tiger or Ruby Crest
    const faceTex = isTeam1
      ? CholaTextureFactory.createGoldCoinTexture()
      : CholaTextureFactory.createRubyCoinTexture();

    const sideColor = isTeam1 ? 0xc79724 : 0x7c0a1a;
    const sideMat = new THREE.MeshStandardMaterial({
      color: sideColor,
      roughness: 0.3,
      metalness: isTeam1 ? 0.85 : 0.4
    });

    const topMat = new THREE.MeshStandardMaterial({
      map: faceTex,
      roughness: isTeam1 ? 0.22 : 0.25,
      metalness: isTeam1 ? 0.88 : 0.42,
    });

    const mats = [sideMat, topMat, sideMat];
    const coinBody = new THREE.Mesh(geo, mats);
    coinBody.castShadow = true;
    coinBody.receiveShadow = true;
    group.add(coinBody);

    // Beaded milled outer rim
    const rimGeo = new THREE.TorusGeometry(radius - 0.5, 1.2, 16, 36);
    const rimMat = new THREE.MeshStandardMaterial({
      color: isTeam1 ? 0xffea88 : 0xffa3b5,
      roughness: 0.18,
      metalness: 0.85,
    });
    const rim = new THREE.Mesh(rimGeo, rimMat);
    rim.rotation.x = Math.PI / 2;
    rim.position.y = height / 2 + 0.2;
    group.add(rim);

    // Subtle golden/crimson celestial light ring at coin base
    const haloGeo = new THREE.RingGeometry(11, 16, 24);
    const haloMat = new THREE.MeshBasicMaterial({
      color: isTeam1 ? 0xffd700 : 0xff2b4e,
      transparent: true,
      opacity: 0,
      side: THREE.DoubleSide
    });
    const halo = new THREE.Mesh(haloGeo, haloMat);
    halo.rotation.x = -Math.PI / 2;
    halo.position.y = -height / 2 + 0.1;
    group.add(halo);

    group.userData = { tokenId, team, isToken: true, haloMesh: halo };
    this.scene.add(group);
    this.tokenMeshes[tokenId] = group;
    this.interactiveMeshes.push(coinBody);

    return group;
  }

  setTokenPosition(tokenId, x, y, z) {
    const mesh = this.tokenMeshes[tokenId];
    if (mesh) {
      mesh.position.set(x, y, z);
    }
  }

  // Smooth 3D Parabolic Hopping from current tile to target tile
  async animateHop(tokenId, targetX, targetZ, durationMs = 120) {
    const mesh = this.tokenMeshes[tokenId];
    if (!mesh) return;

    const startX = mesh.position.x;
    const startZ = mesh.position.z;
    const baseY = 16.5;
    const jumpH = 18;

    const startTime = performance.now();

    return new Promise(resolve => {
      const update = (now) => {
        const progress = Math.min(1, (now - startTime) / durationMs);
        mesh.position.x = startX + (targetX - startX) * progress;
        mesh.position.z = startZ + (targetZ - startZ) * progress;
        mesh.position.y = baseY + Math.sin(progress * Math.PI) * jumpH;

        if (progress < 1) {
          requestAnimationFrame(update);
        } else {
          mesh.position.y = baseY;
          resolve();
        }
      };
      requestAnimationFrame(update);
    });
  }

  // 3D Realistic Multi-Stage Physics Animation for Dice Rolling Outside the Board
  async animateDiceRoll(die1Val, die2Val) {
    const duration = 1100;
    const startTime = performance.now();

    // Sound: initial shake
    if (window.soundEngine && typeof window.soundEngine.playDiceShake === 'function') {
      window.soundEngine.playDiceShake();
    }

    if (this.diceMode === 'cubes') {
      const cubeRotMap = {
        1: { rx: 0, rz: -Math.PI / 2 },
        2: { rx: 0, rz: 0 },
        3: { rx: Math.PI / 2, rz: 0 },
        4: { rx: -Math.PI / 2, rz: 0 },
        5: { rx: Math.PI, rz: 0 },
        6: { rx: 0, rz: Math.PI / 2 }
      };

      const rot1 = cubeRotMap[die1Val] || { rx: 0, rz: 0 };
      const rot2 = cubeRotMap[die2Val] || { rx: 0, rz: 0 };
      let impactPlayed = [false, false];

      return new Promise(resolve => {
        const loop = (now) => {
          const elapsed = now - startTime;
          const p = Math.min(1, elapsed / duration);

          this.cubeDiceMeshes.forEach((mesh, idx) => {
            const timeOffset = idx * 30;
            const lp = Math.min(1, Math.max(0, (elapsed - timeOffset) / (duration - 35)));
            const basePos = (idx === 0) ? DICE_OUTSIDE_POSITIONS.cube1 : DICE_OUTSIDE_POSITIONS.cube2;
            const rot = (idx === 0) ? rot1 : rot2;

            let curY = basePos.y;
            let curZ = basePos.z;

            if (lp < 0.18) {
              const sp = lp / 0.18;
              curY = basePos.y + Math.sin(sp * Math.PI * 0.5) * 80 + Math.sin(sp * 20) * 2;
              curZ = basePos.z - sp * 40;
            } else if (lp < 0.55) {
              const tp = (lp - 0.18) / 0.37;
              curY = basePos.y + 80 * (1 - tp) + Math.sin(tp * Math.PI) * 20;
              curZ = (basePos.z - 40) + tp * 50;
              const spins = (1 - tp) * Math.PI * 10;
              mesh.rotation.x = spins + rot.rx;
              mesh.rotation.y = spins * 0.7;
              mesh.rotation.z = spins + rot.rz;
            } else if (lp < 0.8) {
              if (!impactPlayed[idx] && window.soundEngine && typeof window.soundEngine.playDiceImpact === 'function') {
                impactPlayed[idx] = true;
                window.soundEngine.playDiceImpact(0.7);
              }
              const bp = (lp - 0.55) / 0.25;
              curY = basePos.y + Math.sin(bp * Math.PI) * 22;
              curZ = (basePos.z + 10) + bp * (basePos.z - (basePos.z + 10));
              const spins = (1 - bp) * Math.PI * 2;
              mesh.rotation.x = spins + rot.rx;
              mesh.rotation.z = spins + rot.rz;
            } else {
              curY = basePos.y;
              curZ = basePos.z;
              mesh.rotation.set(rot.rx, 0, rot.rz);
            }

            mesh.position.y = curY;
            mesh.position.z = curZ;
          });

          if (p < 1) {
            requestAnimationFrame(loop);
          } else {
            this.cubeDiceMeshes.forEach((mesh, idx) => {
              const basePos = (idx === 0) ? DICE_OUTSIDE_POSITIONS.cube1 : DICE_OUTSIDE_POSITIONS.cube2;
              const rot = (idx === 0) ? rot1 : rot2;
              mesh.position.set(basePos.x, basePos.y, basePos.z);
              mesh.rotation.set(rot.rx, 0, rot.rz);
            });
            if (window.soundEngine && typeof window.soundEngine.playDiceSlide === 'function') {
              window.soundEngine.playDiceSlide();
            }
            resolve();
          }
        };
        requestAnimationFrame(loop);
      });
    } else {
      // Sticks rotation map (values 0, 1, 2, 3)
      // Top (+Y): rx = 0 (Value 1)
      // Front (+Z): rx = -Math.PI / 2 (Value 2)
      // Bottom (-Y): rx = Math.PI (Value 3)
      // Back (-Z): rx = Math.PI / 2 (Value 0 / Dayam)
      const stickRotMap = {
        1: 0,
        2: -Math.PI / 2,
        3: Math.PI,
        0: Math.PI / 2,
        4: Math.PI / 2,
        5: -Math.PI / 2,
        6: Math.PI
      };

      const targetRx1 = (stickRotMap[die1Val] !== undefined) ? stickRotMap[die1Val] : 0;
      const targetRx2 = (stickRotMap[die2Val] !== undefined) ? stickRotMap[die2Val] : 0;

      let impact1Played = [false, false];
      let impact2Played = [false, false];

      return new Promise(resolve => {
        const loop = (now) => {
          const elapsed = now - startTime;
          const p = Math.min(1, elapsed / duration);

          this.stickDiceMeshes.forEach((mesh, idx) => {
            const timeOffset = idx * 35; // Asynchronous bounce delay
            const localElapsed = Math.max(0, elapsed - timeOffset);
            const lp = Math.min(1, localElapsed / (duration - 40));

            const basePos = (idx === 0) ? DICE_OUTSIDE_POSITIONS.stick1 : DICE_OUTSIDE_POSITIONS.stick2;
            const targetRx = (idx === 0) ? targetRx1 : targetRx2;
            const naturalAngle = (idx === 0) ? 0.08 : -0.06;

            let curY = basePos.y;
            let curZ = basePos.z;
            let curRx = targetRx;

            if (lp < 0.16) {
              // Phase 1: Lift & shake in hand (0% to 16%)
              const sp = lp / 0.16;
              curY = basePos.y + Math.sin(sp * Math.PI * 0.5) * 85 + Math.sin(sp * 25) * 2.5;
              curZ = basePos.z - sp * 45;
              mesh.rotation.y = naturalAngle + Math.sin(sp * 20) * 0.15;
              mesh.rotation.z = Math.cos(sp * 18) * 0.08;
              curRx = targetRx + sp * 4;
            } else if (lp < 0.48) {
              // Phase 2: Throw & Forward Flight Arc (16% to 48%)
              const tp = (lp - 0.16) / 0.32;
              curY = basePos.y + 85 * (1 - tp) + Math.sin(tp * Math.PI) * 25;
              curZ = (basePos.z - 45) + tp * 55;
              // Rapid tumbling around X axis (8 full spins = 16pi)
              const spinRot = (1 - tp) * (Math.PI * 14);
              curRx = targetRx + spinRot;
              mesh.rotation.y = naturalAngle + (1 - tp) * 0.35;
              mesh.rotation.z = (1 - tp) * 0.2;
            } else if (lp < 0.74) {
              // First Ground Impact on the Velvet Mat!
              if (!impact1Played[idx] && window.soundEngine && typeof window.soundEngine.playDiceImpact === 'function') {
                impact1Played[idx] = true;
                window.soundEngine.playDiceImpact(idx === 0 ? 0.85 : 0.65);
              }
              // Phase 3: First Rebound Bounce (48% to 74%)
              const bp = (lp - 0.48) / 0.26;
              const bounceH = Math.sin(bp * Math.PI) * 28;
              curY = basePos.y + bounceH;
              curZ = (basePos.z + 10) + bp * (basePos.z - (basePos.z + 10));
              const spinRot = (1 - bp) * (Math.PI * 4);
              curRx = targetRx + spinRot;
              mesh.rotation.y = naturalAngle + Math.sin(bp * Math.PI) * 0.1;
              mesh.rotation.z = (1 - bp) * 0.06;
            } else if (lp < 0.92) {
              // Second Impact Sound
              if (!impact2Played[idx] && window.soundEngine && typeof window.soundEngine.playDiceImpact === 'function') {
                impact2Played[idx] = true;
                window.soundEngine.playDiceImpact(0.35);
              }
              // Phase 4: Second Micro-bounce (74% to 92%)
              const bp = (lp - 0.74) / 0.18;
              const bounceH = Math.sin(bp * Math.PI) * 8;
              curY = basePos.y + bounceH;
              curZ = basePos.z;
              const spinRot = (1 - bp) * (Math.PI * 1.2);
              curRx = targetRx + spinRot;
              mesh.rotation.y = naturalAngle + (1 - bp) * 0.04;
              mesh.rotation.z = 0;
            } else {
              // Phase 5: Settle & Resting lock (92% to 100%)
              curY = basePos.y;
              curZ = basePos.z;
              curRx = targetRx;
              mesh.rotation.y = naturalAngle;
              mesh.rotation.z = 0;
            }

            mesh.position.y = curY;
            mesh.position.z = curZ;
            mesh.rotation.x = curRx;
          });

          if (p < 1) {
            requestAnimationFrame(loop);
          } else {
            this.stickDiceMeshes.forEach((mesh, idx) => {
              const basePos = (idx === 0) ? DICE_OUTSIDE_POSITIONS.stick1 : DICE_OUTSIDE_POSITIONS.stick2;
              const targetRx = (idx === 0) ? targetRx1 : targetRx2;
              mesh.position.set(basePos.x, basePos.y, basePos.z);
              mesh.rotation.set(targetRx, (idx === 0 ? 0.08 : -0.06), 0);
            });
            if (window.soundEngine && typeof window.soundEngine.playDiceSlide === 'function') {
              window.soundEngine.playDiceSlide();
            }
            resolve();
          }
        };
        requestAnimationFrame(loop);
      });
    }
  }

  // Highlight tile cells for legal moves with a soft warm beacon
  highlightCells(cellIds, colorHex = 0xffd700) {
    this.clearTileHighlights();
    cellIds.forEach(id => {
      const tile = this.tileMeshes[id];
      if (tile) {
        tile.material.opacity = 0.65;
        tile.material.color.setHex(colorHex);
        tile.position.y = 15;
      }
    });
  }

  clearTileHighlights() {
    Object.values(this.tileMeshes).forEach(tile => {
      tile.material.opacity = tile.userData.originalOpacity;
      tile.material.color.setHex(tile.userData.originalColor);
      tile.position.y = 12.5 + tile.geometry.parameters.height / 2;
    });
  }

  // Set token selection halo
  setTokenSelected(tokenId, isSelected) {
    const mesh = this.tokenMeshes[tokenId];
    if (mesh && mesh.userData.haloMesh) {
      mesh.userData.haloMesh.material.opacity = isSelected ? 0.85 : 0;
      mesh.position.y = isSelected ? 22 : 16.5;
    }
  }

  // Camera Presets
  setCameraView(mode) {
    const duration = 750;
    const startPos = this.camera.position.clone();
    const startTarget = this.controls.target.clone();

    let endPos, endTarget;

    if (mode === 'top') {
      // Classic Top-Down View framing both the carved board and rolling mat outside
      endPos = new THREE.Vector3(-45, 800, 0.01);
      endTarget = new THREE.Vector3(-45, 0, 0);
    } else if (mode === '3d') {
      // Grand 3D Tabletop Perspective showing the board and rolling mat
      endPos = new THREE.Vector3(-40, 500, 430);
      endTarget = new THREE.Vector3(-40, 0, 20);
    } else if (mode === 'dice') {
      // Close-Up on the traditional rectangular stick dice rolling on the velvet mat outside the board
      endPos = new THREE.Vector3(-240, 215, 185);
      endTarget = new THREE.Vector3(-325, -8, 65);
    } else if (mode === 'coins') {
      // Close-Up on the carved wooden trays and engraved medallion coins
      endPos = new THREE.Vector3(0, 280, 280);
      endTarget = new THREE.Vector3(0, 15, 129);
    } else {
      endPos = new THREE.Vector3(0, 480, 420);
      endTarget = new THREE.Vector3(0, 0, 20);
    }

    const startTime = performance.now();
    const animateCam = (now) => {
      const p = Math.min(1, (now - startTime) / duration);
      const ease = 0.5 - 0.5 * Math.cos(p * Math.PI);

      this.camera.position.lerpVectors(startPos, endPos, ease);
      this.controls.target.lerpVectors(startTarget, endTarget, ease);
      this.controls.update();

      if (p < 1) requestAnimationFrame(animateCam);
    };
    requestAnimationFrame(animateCam);
  }

  // Pointer & Raycasting Events
  setupEvents() {
    const onPointerDown = (e) => {
      this.mouse.x = (e.clientX / window.innerWidth) * 2 - 1;
      this.mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;
      this.raycaster.setFromCamera(this.mouse, this.camera);

      const intersects = this.raycaster.intersectObjects(this.scene.children, true);
      if (intersects.length > 0) {
        let hit = intersects[0].object;
        while (hit && !hit.userData.isToken && !hit.userData.isDice && hit.parent !== this.scene) {
          hit = hit.parent;
        }

        if (hit && hit.userData.isToken) {
          this.onTokenClick(hit.userData.tokenId);
        } else if (hit && hit.userData.isDice) {
          this.onDiceClick();
        }
      }
    };

    window.addEventListener('pointerdown', onPointerDown);
    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    });
  }

  animate() {
    requestAnimationFrame(() => this.animate());

    // Gentle rotation of the Summit Brass Boss Medallion
    if (this.summitBrassBossMesh) {
      this.summitBrassBossMesh.rotation.y += 0.008;
    }

    // Subtle oil lamp flicker
    const t = performance.now() * 0.003;
    this.ambientLamps.forEach((lamp, i) => {
      lamp.intensity = 0.85 + Math.sin(t + i * 2) * 0.08;
    });

    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
}

// ==========================================
// 4. MAIN GAME CONTROLLER & LOGIC
// ==========================================

class IndianTraditionalGame3D {
  constructor() {
    this.isVsAI = true;
    this.difficulty = 'hard'; // 'easy', 'normal', 'hard' (Raja Raja Chola)
    this.diceStyle = 'sticks'; // 'sticks' (Traditional Rectangular Sticks) or 'cubes'
    this.activeTeam = 'team1';
    this.turnPhase = 'waitingForRoll';
    this.currentRoll = null;
    this.isBonusRoll = false;
    this.isAnimating = false;
    this.voiceEnabled = true;

    this.sound = window.soundEngine;

    // 4 active tokens per team (all 6 visible in tray, 4 actively played)
    this.tokens = {
      team1: Array.from({ length: TOKENS_PER_TEAM }, (_, i) => ({
        id: `t1_${i}`,
        team: 'team1',
        state: 'base', // 'base', 'track', 'summit'
        pathIndex: -1,
      })),
      team2: Array.from({ length: TOKENS_PER_TEAM }, (_, i) => ({
        id: `t2_${i}`,
        team: 'team2',
        state: 'base',
        pathIndex: -1,
      })),
    };

    // Extra decorative coins to fill all 6 slots in each wooden tray matching the photo
    this.decorativeTokens = {
      team1: ['t1_d1', 't1_d2'],
      team2: ['t2_d1', 't2_d2'],
    };

    this.scores = {
      team1: { finished: 0, captures: 0 },
      team2: { finished: 0, captures: 0 },
    };

    this.stats = {
      totalTurns: 0,
      thayamCount: 0,
      dayamCount: 0,
      totalCaptures: 0,
      rollHistory: [],
    };

    this.movableTokenIds = [];
    this.selectedTokenId = null;

    // Initialize 3D World
    const container = document.getElementById('webgl-container');
    this.world3D = new BoardWorld3D(
      container,
      (tokenId) => this.handleTokenClick(tokenId),
      () => this.handleRollClick()
    );

    // Initialize tokens in tray slots
    this.init3DTokens();

    this.initDOM();
    this.updateUI();
  }

  init3DTokens() {
    ['team1', 'team2'].forEach(team => {
      // 4 active tokens
      this.tokens[team].forEach((tok, idx) => {
        this.world3D.createTokenMesh(team, tok.id);
        const slot = BASE_SLOTS[team][idx];
        this.world3D.setTokenPosition(tok.id, slot.x, 16.5, slot.z);
      });

      // 2 decorative tokens filling slots 4 and 5 in the tray
      this.decorativeTokens[team].forEach((decId, i) => {
        this.world3D.createTokenMesh(team, decId);
        const slot = BASE_SLOTS[team][4 + i];
        this.world3D.setTokenPosition(decId, slot.x, 16.5, slot.z);
      });
    });
  }

  initDOM() {
    // Toolbar buttons
    this.modeBtn = document.getElementById('mode-btn');
    this.diffBtn = document.getElementById('diff-btn');
    this.diceStyleBtn = document.getElementById('dice-style-btn');
    this.soundBtn = document.getElementById('sound-btn');
    this.voiceBtn = document.getElementById('voice-btn');
    this.statsBtn = document.getElementById('stats-btn');
    this.rulesBtn = document.getElementById('rules-btn');
    this.restartBtn = document.getElementById('restart-btn');

    // Camera preset buttons
    this.camTopBtn = document.getElementById('cam-top-btn');
    this.cam3DBtn = document.getElementById('cam-3d-btn');
    this.camDiceBtn = document.getElementById('cam-dice-btn');
    this.camCoinsBtn = document.getElementById('cam-coins-btn');
    this.camResetBtn = document.getElementById('cam-reset-btn');

    // HUD controls
    this.rollBtn = document.getElementById('roll-btn');
    this.hintBtn = document.getElementById('hint-btn');
    this.turnCard = document.getElementById('turn-card');
    this.turnPlayerName = document.getElementById('turn-player-name');
    this.turnHintText = document.getElementById('turn-hint-text');
    this.rollTamilName = document.getElementById('roll-tamil-name');
    this.rollNumber = document.getElementById('roll-number');
    this.rollTagPill = document.getElementById('roll-tag-pill');
    this.tickerMsg = document.getElementById('ticker-msg');
    this.historyPills = document.getElementById('history-pills');
    this.boardBanner = document.getElementById('board-banner');
    this.bannerIcon = document.getElementById('banner-icon');
    this.bannerTitle = document.getElementById('banner-title');

    // Modals
    this.rulesModal = document.getElementById('rules-modal');
    this.closeRulesBtn = document.getElementById('close-rules-btn');
    this.understoodBtn = document.getElementById('understood-btn');

    this.statsModal = document.getElementById('stats-modal');
    this.closeStatsBtn = document.getElementById('close-stats-btn');
    this.closeStatsFooterBtn = document.getElementById('close-stats-footer-btn');

    this.victoryModal = document.getElementById('victory-modal');
    this.playAgainBtn = document.getElementById('play-again-btn');

    this.setupListeners();
  }

  setupListeners() {
    this.rollBtn.addEventListener('click', () => this.handleRollClick());
    this.hintBtn.addEventListener('click', () => this.handleHintClick());

    // Dice style toggle (Traditional Rectangular Sticks vs Chola Hardwood Cubes)
    if (this.diceStyleBtn) {
      this.diceStyleBtn.addEventListener('click', () => {
        this.diceStyle = (this.diceStyle === 'sticks') ? 'cubes' : 'sticks';
        this.world3D.setDiceMode(this.diceStyle);
        const textEl = document.getElementById('dice-style-text');
        if (textEl) {
          textEl.textContent = (this.diceStyle === 'sticks') ? 'Dice: Traditional Sticks' : 'Dice: Chola Cubes';
        }
        this.setTicker(`Switched dice to ${this.diceStyle === 'sticks' ? 'Traditional Rectangular Sticks (Rolling on Velvet Mat)' : 'Chola Hardwood Cubes'}`);
      });
    }

    // Camera preset clicks
    const setActiveCam = (activeBtn) => {
      [this.camTopBtn, this.cam3DBtn, this.camDiceBtn, this.camCoinsBtn].forEach(b => {
        if (b) b.classList.remove('active');
      });
      if (activeBtn) activeBtn.classList.add('active');
    };

    if (this.camTopBtn) {
      this.camTopBtn.addEventListener('click', () => {
        setActiveCam(this.camTopBtn);
        this.world3D.setCameraView('top');
      });
    }

    if (this.cam3DBtn) {
      this.cam3DBtn.addEventListener('click', () => {
        setActiveCam(this.cam3DBtn);
        this.world3D.setCameraView('3d');
      });
    }

    if (this.camDiceBtn) {
      this.camDiceBtn.addEventListener('click', () => {
        setActiveCam(this.camDiceBtn);
        this.world3D.setCameraView('dice');
      });
    }

    if (this.camCoinsBtn) {
      this.camCoinsBtn.addEventListener('click', () => {
        setActiveCam(this.camCoinsBtn);
        this.world3D.setCameraView('coins');
      });
    }

    if (this.camResetBtn) {
      this.camResetBtn.addEventListener('click', () => {
        setActiveCam(this.camTopBtn);
        this.world3D.setCameraView('top');
      });
    }

    // Game Mode toggle (vs AI / Pass & Play)
    this.modeBtn.addEventListener('click', () => {
      this.isVsAI = !this.isVsAI;
      const modeText = document.getElementById('mode-btn-text');
      if (modeText) modeText.textContent = this.isVsAI ? 'vs Imperial AI' : 'Pass & Play';
      const t2Label = document.getElementById('team2-label-name');
      if (t2Label) t2Label.textContent = this.isVsAI ? 'Chola Ruby (AI Bot)' : 'Chola Ruby (Player 2)';
      this.setTicker(`Game mode changed to: ${this.isVsAI ? 'Player vs Imperial AI' : '2-Player Pass & Play'}`);
    });

    // AI Difficulty toggle
    this.diffBtn.addEventListener('click', () => {
      const diffs = ['easy', 'normal', 'hard'];
      const nextIdx = (diffs.indexOf(this.difficulty) + 1) % diffs.length;
      this.difficulty = diffs[nextIdx];
      const diffNames = { easy: 'Chola Guard', normal: 'Chola Commander', hard: 'Raja Raja Chola' };
      const diffText = document.getElementById('diff-btn-text');
      if (diffText) diffText.textContent = diffNames[this.difficulty];
      this.setTicker(`AI Bot intelligence set to: ${diffNames[this.difficulty]}`);
    });

    // Sound and Voice toggles
    this.soundBtn.addEventListener('click', () => {
      const muted = this.sound.toggleMute();
      document.getElementById('sound-icon').textContent = muted ? '🔇' : '🔊';
    });

    this.voiceBtn.addEventListener('click', () => {
      this.voiceEnabled = !this.voiceEnabled;
      document.getElementById('voice-icon').textContent = this.voiceEnabled ? '🗣️' : '🤐';
    });

    // Modals
    this.rulesBtn.addEventListener('click', () => this.rulesModal.classList.add('active'));
    this.closeRulesBtn.addEventListener('click', () => this.rulesModal.classList.remove('active'));
    this.understoodBtn.addEventListener('click', () => this.rulesModal.classList.remove('active'));

    this.statsBtn.addEventListener('click', () => {
      this.renderStats();
      this.statsModal.classList.add('active');
    });
    this.closeStatsBtn.addEventListener('click', () => this.statsModal.classList.remove('active'));
    this.closeStatsFooterBtn.addEventListener('click', () => this.statsModal.classList.remove('active'));

    this.restartBtn.addEventListener('click', () => this.resetGame());
    this.playAgainBtn.addEventListener('click', () => {
      this.victoryModal.classList.remove('active');
      this.resetGame();
    });
  }

  // ==========================================
  // 5. GAMEPLAY & RULES ENGINE
  // ==========================================

  async handleRollClick() {
    if (this.turnPhase !== 'waitingForRoll' || this.isAnimating) return;
    if (this.isVsAI && this.activeTeam === 'team2') return;

    await this.executeRoll();
  }

  async executeRoll() {
    this.isAnimating = true;
    this.turnPhase = 'rolling';
    this.updateUI();

    let d1, d2, total, tamilName, isBonus, isSpawnRoll;

    if (this.diceStyle === 'cubes') {
      // 2 Hardwood 6-sided Cubes with circular brass pips
      d1 = Math.floor(Math.random() * 6) + 1;
      d2 = Math.floor(Math.random() * 6) + 1;

      // In Chola traditional play:
      // Double 1s: Thayam (1) + Bonus roll!
      // Double 6s: Dayam (12) + Bonus roll!
      // Doubles (2-2, 3-3, 4-4, 5-5): Grants bonus roll!
      // Total = d1 + d2 (or 1 if double 1s)
      if (d1 === 1 && d2 === 1) {
        total = 1;
        tamilName = 'தாயம் (Thayam)';
        isBonus = true;
        isSpawnRoll = true;
      } else if (d1 === 6 && d2 === 6) {
        total = 12;
        tamilName = 'பன்னிரண்டு (Dayam 12)';
        isBonus = true;
        isSpawnRoll = true;
      } else {
        total = d1 + d2;
        const names = {
          2: 'இரண்டு (2)', 3: 'மூன்று (3)', 4: 'நான்கு (4)',
          5: 'ஐந்து (5)', 6: 'ஆறு (6)', 7: 'ஏழு (7)',
          8: 'எட்டு (8)', 9: 'ஒன்பது (9)', 10: 'பத்து (10)',
          11: 'பதினொன்று (11)'
        };
        tamilName = names[total] || `${total}`;
        isBonus = (d1 === d2) || (total === 5 || total === 6);
        isSpawnRoll = (d1 === 1 || d2 === 1 || total === 1);
      }
    } else {
      // Traditional 4-sided brass stick dice
      d1 = Math.floor(Math.random() * 4);
      d2 = Math.floor(Math.random() * 4);

      if (d1 === 0 && d2 === 0) {
        total = 12;
        tamilName = 'பன்னிரண்டு (Dayam 12)';
        isBonus = true;
        isSpawnRoll = true;
      } else if ((d1 === 0 && d2 === 1) || (d1 === 1 && d2 === 0)) {
        total = 1;
        tamilName = 'தாயம் (Thayam)';
        isBonus = true;
        isSpawnRoll = true;
      } else {
        total = d1 + d2;
        isBonus = (total === 5 || total === 6);
        isSpawnRoll = false;
        const names = {
          2: 'இரண்டு (2)', 3: 'மூன்று (3)', 4: 'நான்கு (4)',
          5: 'ஐந்து (5)', 6: 'ஆறு (6)'
        };
        tamilName = names[total] || `${total}`;
      }
    }

    this.currentRoll = { d1, d2, total, tamilName, isBonus, isSpawnRoll };
    this.stats.rollHistory.unshift(this.currentRoll);
    if (total === 1) this.stats.thayamCount++;
    if (total === 12) this.stats.dayamCount++;

    // Acoustic wooden/brass dice roll sound
    this.sound.playDiceRoll();

    // 3D physics tumbling animation
    await this.world3D.animateDiceRoll(d1, d2);

    // Voice announcement
    if (this.voiceEnabled) {
      if (total === 1) this.sound.speak('தாயம்!');
      else if (total === 12) this.sound.speak('பன்னிரண்டு!');
      else if (isBonus) this.sound.speak(tamilName);
    }

    if (total === 1) this.sound.playThayam();

    // Check legal moves
    const legalTokens = this.getLegalMoves(this.activeTeam, this.currentRoll);

    if (legalTokens.length === 0) {
      this.setTicker(`No legal moves for ${this.getTeamTitle(this.activeTeam)} with ${this.currentRoll.total}.`);
      await this.sleep(900);
      this.isAnimating = false;
      this.endTurn(this.currentRoll.isBonus);
      return;
    }

    this.movableTokenIds = legalTokens.map(t => t.id);
    this.turnPhase = 'waitingForMove';
    this.isAnimating = false;
    this.updateUI();

    // If only one token is legal, auto-select it
    if (this.movableTokenIds.length === 1) {
      this.selectToken(this.movableTokenIds[0]);
    }

    // AI Bot turn handler
    if (this.isVsAI && this.activeTeam === 'team2') {
      await this.sleep(600);
      this.executeAIMove();
    }
  }

  getLegalMoves(team, roll) {
    const legal = [];
    const teamTokens = this.tokens[team];
    const path = TEAM_PATHS[team];

    teamTokens.forEach(tok => {
      if (tok.state === 'summit') return; // already reached summit

      if (tok.state === 'base') {
        // Must roll 1 (Thayam) or 12 (Dayam) to spawn from tray
        if (roll.isSpawnRoll || roll.total === 1 || roll.total === 12) {
          legal.push(tok);
        }
      } else if (tok.state === 'track') {
        const nextIndex = tok.pathIndex + roll.total;
        if (nextIndex <= path.length - 1) {
          legal.push(tok);
        }
      }
    });

    return legal;
  }

  handleTokenClick(tokenId) {
    if (this.turnPhase !== 'waitingForMove' || this.isAnimating) return;
    if (this.isVsAI && this.activeTeam === 'team2') return;

    if (!this.movableTokenIds.includes(tokenId)) {
      this.setTicker('That coin cannot make a legal move with this roll.');
      return;
    }

    this.selectToken(tokenId);
  }

  selectToken(tokenId) {
    // Clear previous selection
    if (this.selectedTokenId) {
      this.world3D.setTokenSelected(this.selectedTokenId, false);
    }

    this.selectedTokenId = tokenId;
    this.world3D.setTokenSelected(tokenId, true);

    const token = this.findToken(tokenId);
    const targetCellId = this.getTargetCellId(token, this.currentRoll.total);
    if (targetCellId) {
      this.world3D.highlightCells([targetCellId], token.team === 'team1' ? 0xffd700 : 0xff3366);
    }

    // Prompt user to confirm move by clicking coin or rolling
    this.moveToken(token, this.currentRoll.total);
  }

  async moveToken(token, steps) {
    this.isAnimating = true;
    this.world3D.clearTileHighlights();
    this.world3D.setTokenSelected(token.id, false);

    const path = TEAM_PATHS[token.team];

    if (token.state === 'base') {
      // Spawn onto starting red square
      token.state = 'track';
      token.pathIndex = 0;
      const startCell = CELLS_3D[path[0]];

      this.sound.playTokenMove();
      await this.world3D.animateHop(token.id, startCell.x, startCell.z, 220);
      this.setTicker(`${this.getTeamTitle(token.team)} marched a royal coin onto the battlefield!`);
    } else {
      // Step-by-step hopping along path
      const startIndex = token.pathIndex;
      const targetIndex = startIndex + steps;

      for (let i = startIndex + 1; i <= targetIndex; i++) {
        const stepCell = CELLS_3D[path[i]];
        this.sound.playTokenStep();
        await this.world3D.animateHop(token.id, stepCell.x, stepCell.z, 110);
      }

      token.pathIndex = targetIndex;
      const finalCellId = path[targetIndex];

      if (finalCellId === 'summit') {
        token.state = 'summit';
        this.scores[token.team].finished++;
        this.sound.playThayam();
        this.showFloatingBanner('👑 SUMMIT REACHED!', 'A coin has ascended the sacred Summit Brass Boss!');
      } else {
        // Check for Vettu (Capture)
        await this.checkVettu(token, finalCellId);
      }
    }

    this.selectedTokenId = null;
    this.movableTokenIds = [];

    // Check Victory
    if (this.scores[token.team].finished >= TOKENS_PER_TEAM) {
      this.handleVictory(token.team);
      return;
    }

    this.isAnimating = false;
    this.endTurn(this.currentRoll.isBonus);
  }

  async checkVettu(attackerToken, cellId) {
    const cell = CELLS_3D[cellId];
    // Red squares are sacred safe havens
    if (cell && cell.type === 'red') {
      this.sound.playSafeHaven();
      return;
    }

    const opponentTeam = (attackerToken.team === 'team1') ? 'team2' : 'team1';
    const opponentPath = TEAM_PATHS[opponentTeam];

    const capturedToken = this.tokens[opponentTeam].find(t => {
      return t.state === 'track' && opponentPath[t.pathIndex] === cellId;
    });

    if (capturedToken) {
      // Vettu! Capture made!
      this.scores[attackerToken.team].captures++;
      this.stats.totalCaptures++;
      this.currentRoll.isBonus = true; // Captures grant immediate bonus roll

      this.sound.playVettu();
      if (this.voiceEnabled) this.sound.speak('வெட்டு!');

      this.showFloatingBanner('⚔️ VETTU! (CAPTURE)', `${this.getTeamTitle(attackerToken.team)} captured an opponent coin! Extra Roll granted!`);

      // Knock opponent coin back to its wooden tray slot in 3D
      capturedToken.state = 'base';
      capturedToken.pathIndex = -1;
      const slotIdx = this.tokens[opponentTeam].indexOf(capturedToken);
      const slotPos = BASE_SLOTS[opponentTeam][slotIdx];

      await this.world3D.animateHop(capturedToken.id, slotPos.x, slotPos.z, 350);
    }
  }

  endTurn(grantBonus = false) {
    if (grantBonus) {
      this.setTicker(`${this.getTeamTitle(this.activeTeam)} earns a Royal Extra Roll!`);
      this.turnPhase = 'waitingForRoll';
      this.updateUI();

      if (this.isVsAI && this.activeTeam === 'team2') {
        setTimeout(() => this.executeRoll(), 800);
      }
      return;
    }

    // Switch teams
    this.activeTeam = (this.activeTeam === 'team1') ? 'team2' : 'team1';
    this.stats.totalTurns++;
    this.turnPhase = 'waitingForRoll';
    this.currentRoll = null;
    this.updateUI();

    if (this.isVsAI && this.activeTeam === 'team2') {
      setTimeout(() => this.executeRoll(), 750);
    }
  }

  // ==========================================
  // 6. IMPERIAL CHOLA AI BOT ENGINE
  // ==========================================

  executeAIMove() {
    const legalTokens = this.movableTokenIds.map(id => this.findToken(id));
    if (legalTokens.length === 0) return;

    let chosenToken = legalTokens[0];

    if (this.difficulty === 'hard') {
      // Raja Raja Chola: Master tactical AI
      // Priority 1: Captures (Vettu)
      // Priority 2: Reaching Summit
      // Priority 3: Landing on Red Safe Haven
      // Priority 4: Spawning new token
      // Priority 5: Advancing furthest piece
      let bestScore = -9999;

      legalTokens.forEach(tok => {
        let score = 0;
        const path = TEAM_PATHS[tok.team];

        if (tok.state === 'base') {
          score += 50;
        } else {
          const nextIdx = tok.pathIndex + this.currentRoll.total;
          const nextCellId = path[nextIdx];

          if (nextCellId === 'summit') score += 200;

          // Check if landing causes capture
          const opponentPath = TEAM_PATHS['team1'];
          const causesVettu = this.tokens['team1'].some(opp => {
            return opp.state === 'track' && opponentPath[opp.pathIndex] === nextCellId;
          });
          if (causesVettu) score += 180;

          // Check if safe haven
          const nextCell = CELLS_3D[nextCellId];
          if (nextCell && nextCell.type === 'red') score += 40;

          // Progress bonus
          score += nextIdx;
        }

        if (score > bestScore) {
          bestScore = score;
          chosenToken = tok;
        }
      });
    } else {
      // Easy / Normal AI
      chosenToken = legalTokens[Math.floor(Math.random() * legalTokens.length)];
    }

    this.selectToken(chosenToken.id);
  }

  handleHintClick() {
    if (this.turnPhase !== 'waitingForMove' || this.movableTokenIds.length === 0) {
      this.setTicker('Roll the dice first to receive a tactical hint.');
      return;
    }

    const bestToken = this.findToken(this.movableTokenIds[0]);
    this.selectToken(bestToken.id);
    this.setTicker(`Tactical Hint: March ${this.getTeamTitle(this.activeTeam)} coin ${bestToken.id.slice(-1)}!`);
  }

  // ==========================================
  // 7. UI HELPERS & NOTIFICATIONS
  // ==========================================

  updateUI() {
    // Turn status card
    const isTeam1 = (this.activeTeam === 'team1');
    const teamTitle = isTeam1 ? 'Chola Gold (தங்கப் புலி)' : (this.isVsAI ? 'Chola Ruby (AI Bot)' : 'Chola Ruby');

    if (this.turnPlayerName) {
      this.turnPlayerName.textContent = `${teamTitle}'s Turn`;
    }

    const dot = document.getElementById('turn-dot');
    if (dot) {
      dot.style.background = isTeam1 ? 'var(--gold-primary)' : 'var(--pink-primary)';
      dot.style.boxShadow = isTeam1 ? '0 0 10px var(--gold-shadow)' : '0 0 10px rgba(236,72,153,0.6)';
    }

    if (this.turnHintText) {
      if (this.turnPhase === 'waitingForRoll') {
        this.turnHintText.textContent = isTeam1
          ? 'Roll the Chola hardwood dice!'
          : (this.isVsAI ? 'Imperial AI is deliberating...' : 'Player 2: Roll the dice!');
      } else if (this.turnPhase === 'rolling') {
        this.turnHintText.textContent = 'Dice tumbling across teakwood board...';
      } else if (this.turnPhase === 'waitingForMove') {
        this.turnHintText.textContent = 'Click on any highlighted royal coin to march!';
      }
    }

    // Roll result badge
    if (this.currentRoll) {
      if (this.rollNumber) this.rollNumber.textContent = this.currentRoll.total;
      if (this.rollTamilName) this.rollTamilName.textContent = this.currentRoll.tamilName;
      if (this.rollTagPill) {
        this.rollTagPill.textContent = this.currentRoll.isBonus ? 'ROYAL BONUS ROLL!' : 'STANDARD MOVE';
        this.rollTagPill.className = `roll-tag-pill ${this.currentRoll.isBonus ? 'bonus' : ''}`;
      }
    }

    // Roll button state
    if (this.rollBtn) {
      const canRoll = (this.turnPhase === 'waitingForRoll' && (!this.isVsAI || isTeam1));
      this.rollBtn.disabled = !canRoll;
    }

    // Scoreboard numbers
    ['team1', 'team2'].forEach(team => {
      const inBase = this.tokens[team].filter(t => t.state === 'base').length;
      const onTrack = this.tokens[team].filter(t => t.state === 'track').length;
      const atHome = this.scores[team].finished;
      const vettu = this.scores[team].captures;

      const baseEl = document.getElementById(`${team}-base-count`);
      const trackEl = document.getElementById(`${team}-track-count`);
      const homeEl = document.getElementById(`${team}-home-count`);
      const vettuEl = document.getElementById(`${team}-vettu-count`);

      if (baseEl) baseEl.textContent = inBase;
      if (trackEl) trackEl.textContent = onTrack;
      if (homeEl) homeEl.textContent = `${atHome} / ${TOKENS_PER_TEAM}`;
      if (vettuEl) vettuEl.textContent = vettu;
    });

    // History pills
    if (this.historyPills && this.stats.rollHistory.length > 0) {
      this.historyPills.innerHTML = this.stats.rollHistory.slice(0, 7).map(r => `
        <span class="history-pill ${r.isBonus ? 'bonus' : ''}" title="${r.tamilName}">
          ${r.total}
        </span>
      `).join('');
    }
  }

  showFloatingBanner(title, message) {
    if (!this.boardBanner) return;
    if (this.bannerTitle) this.bannerTitle.textContent = title;
    this.boardBanner.classList.add('active');
    this.setTicker(message);

    setTimeout(() => {
      this.boardBanner.classList.remove('active');
    }, 2400);
  }

  setTicker(msg) {
    if (this.tickerMsg) {
      this.tickerMsg.textContent = msg;
    }
  }

  handleVictory(winningTeam) {
    const isGold = (winningTeam === 'team1');
    const winnerName = isGold ? 'CHOLA GOLD (தங்கப் புலிகள்)' : 'CHOLA RUBY (மாணிக்கப் படைகள்)';

    this.sound.playVictory();
    if (this.voiceEnabled) this.sound.speak('வெற்றி! சோழர் பெருவெற்றி!');

    const titleEl = document.getElementById('victory-title');
    const descEl = document.getElementById('victory-desc');
    const detailsEl = document.getElementById('victory-details');

    if (titleEl) titleEl.textContent = `${winnerName} TRIUMPHS!`;
    if (descEl) descEl.textContent = 'All 4 Royal Medallion Coins have reached the sacred Summit Brass Boss!';
    if (detailsEl) {
      detailsEl.innerHTML = `
        <p>Total Rounds: <b>${this.stats.totalTurns}</b></p>
        <p>Total Captures (Vettu): <b>${this.stats.totalCaptures}</b></p>
        <p>Thayam Rolls (1): <b>${this.stats.thayamCount}</b></p>
        <p>Dayam Rolls (12): <b>${this.stats.dayamCount}</b></p>
      `;
    }

    this.victoryModal.classList.add('active');
  }

  renderStats() {
    const grid = document.getElementById('stats-metric-grid');
    if (!grid) return;

    grid.innerHTML = `
      <div class="metric-box">
        <div class="metric-num">${this.stats.totalTurns}</div>
        <div class="metric-label">Total Turns</div>
      </div>
      <div class="metric-box">
        <div class="metric-num">${this.stats.totalCaptures}</div>
        <div class="metric-label">Captures (Vettu)</div>
      </div>
      <div class="metric-box">
        <div class="metric-num">${this.stats.thayamCount}</div>
        <div class="metric-label">Thayam Rolls (1)</div>
      </div>
      <div class="metric-box">
        <div class="metric-num">${this.stats.dayamCount}</div>
        <div class="metric-label">Dayam Rolls (12)</div>
      </div>
      <div class="metric-box">
        <div class="metric-num">${this.scores.team1.finished} / 4</div>
        <div class="metric-label">Gold Coins at Summit</div>
      </div>
      <div class="metric-box">
        <div class="metric-num">${this.scores.team2.finished} / 4</div>
        <div class="metric-label">Ruby Coins at Summit</div>
      </div>
    `;
  }

  resetGame() {
    this.activeTeam = 'team1';
    this.turnPhase = 'waitingForRoll';
    this.currentRoll = null;
    this.isBonusRoll = false;
    this.isAnimating = false;
    this.selectedTokenId = null;
    this.movableTokenIds = [];

    this.scores = {
      team1: { finished: 0, captures: 0 },
      team2: { finished: 0, captures: 0 },
    };

    this.stats = {
      totalTurns: 0,
      thayamCount: 0,
      dayamCount: 0,
      totalCaptures: 0,
      rollHistory: [],
    };

    // Reset tokens to base tray slots
    ['team1', 'team2'].forEach(team => {
      this.tokens[team].forEach((tok, idx) => {
        tok.state = 'base';
        tok.pathIndex = -1;
        const slot = BASE_SLOTS[team][idx];
        this.world3D.setTokenPosition(tok.id, slot.x, 16.5, slot.z);
        this.world3D.setTokenSelected(tok.id, false);
      });
    });

    this.world3D.clearTileHighlights();
    this.setTicker('New Chola Royal Match started! Roll the dice to begin.');
    this.updateUI();
  }

  findToken(tokenId) {
    return this.tokens.team1.find(t => t.id === tokenId) ||
           this.tokens.team2.find(t => t.id === tokenId);
  }

  getTargetCellId(token, steps) {
    const path = TEAM_PATHS[token.team];
    if (token.state === 'base') {
      return path[0];
    } else {
      const idx = token.pathIndex + steps;
      return (idx < path.length) ? path[idx] : null;
    }
  }

  getTeamTitle(team) {
    return (team === 'team1') ? 'Chola Gold' : 'Chola Ruby';
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// ==========================================
// 8. BOOTSTRAP APPLICATION
// ==========================================

window.addEventListener('DOMContentLoaded', () => {
  window.soundEngine = new GameSoundEngine();
  window.gameApp = new IndianTraditionalGame3D();
});
