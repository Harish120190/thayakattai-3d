const test = require('node:test');
const assert = require('node:assert');
const { rollThayakattai, getBoardGeometry, isMoveLegal, applyServerMove } = require('../src/game_engine');

test('Server Dice Generator produces valid Thayakattai outcomes', () => {
  for (let i = 0; i < 50; i++) {
    const roll = rollThayakattai();
    assert(roll.die1 >= 0 && roll.die1 <= 3);
    assert(roll.die2 >= 0 && roll.die2 <= 3);
    assert([1, 2, 3, 4, 5, 6, 12].includes(roll.totalValue));
    if (roll.totalValue === 1) {
      assert.strictEqual(roll.isThayam, true);
      assert.strictEqual(roll.isBonus, true);
    }
  }
});

test('Server Board Geometry supports 2, 4, 6, and 8 players', () => {
  assert.strictEqual(getBoardGeometry(2).totalOuterCells, 24);
  assert.strictEqual(getBoardGeometry(4).totalOuterCells, 24);
  assert.strictEqual(getBoardGeometry(6).totalOuterCells, 36);
  assert.strictEqual(getBoardGeometry(8).totalOuterCells, 48);
});

test('Server Move Validation rejects illegal moves from Kottam without Thayam', () => {
  const matchState = {
    playerCount: 4,
    activePlayerIndex: 0,
    players: [{ id: 'p0', hasCaptured: false }],
    tokens: [
      { id: 'p0_t0', playerIndex: 0, state: 'inKottam', cellIndex: -1, stepsMoved: 0 },
    ],
  };

  // Roll 2 cannot unlock piece from Kottam
  assert.strictEqual(isMoveLegal(matchState, 'p0_t0', 2), false);

  // Roll 1 (Thayam) CAN unlock piece from Kottam
  assert.strictEqual(isMoveLegal(matchState, 'p0_t0', 1), true);
});

test('Server Move Application executes capture and awards extra turn', () => {
  const matchState = {
    playerCount: 4,
    activePlayerIndex: 0,
    players: [
      { id: 'p0', name: 'Player 1', hasCaptured: false },
      { id: 'p1', name: 'Player 2', hasCaptured: false },
    ],
    tokens: [
      { id: 'p0_t0', playerIndex: 0, state: 'onTrack', cellIndex: 0, stepsMoved: 1, isSafe: true },
      { id: 'p1_t0', playerIndex: 1, state: 'onTrack', cellIndex: 2, stepsMoved: 5, isSafe: false },
    ],
    winners: [],
  };

  // P0 rolls 2 and captures P1 on cell 2!
  const nextState = applyServerMove(matchState, 'p0_t0', 2);
  const p1Token = nextState.tokens.find((t) => t.id === 'p1_t0');

  // Opponent piece knocked back to Kottam
  assert.strictEqual(p1Token.state, 'inKottam');
  assert.strictEqual(p1Token.cellIndex, -1);
  assert.strictEqual(nextState.players[0].hasCaptured, true);

  // Extra turn awarded for capture!
  assert.strictEqual(nextState.activePlayerIndex, 0);
});
