const crypto = require('crypto');

/**
 * Server-authoritative Dice outcome generator using cryptographic random bytes
 */
function rollThayakattai() {
  const buf = crypto.randomBytes(2);
  const die1 = buf[0] % 4; // 0, 1, 2, 3
  const die2 = buf[1] % 4; // 0, 1, 2, 3

  let totalValue;
  if (die1 === 0 && die2 === 0) {
    totalValue = 12; // Panirendu
  } else if ((die1 === 1 && die2 === 0) || (die1 === 0 && die2 === 1)) {
    totalValue = 1; // Thayam
  } else {
    totalValue = die1 + die2;
  }

  const isThayam = totalValue === 1;
  const isBonus = (totalValue === 1 || totalValue === 5 || totalValue === 6 || totalValue === 12);

  return {
    die1,
    die2,
    totalValue,
    isThayam,
    isBonus,
    timestamp: Date.now(),
  };
}

/**
 * Board geometry configuration for 2, 4, 6, and 8 players
 */
function getBoardGeometry(playerCount) {
  switch (playerCount) {
    case 2:
      return {
        totalOuterCells: 24,
        homeStretchLength: 4,
        safeCellIndices: new Set([0, 6, 12, 18]),
        playerEntryCells: { 0: 0, 1: 12 },
      };
    case 4:
      return {
        totalOuterCells: 24,
        homeStretchLength: 4,
        safeCellIndices: new Set([0, 6, 12, 18]),
        playerEntryCells: { 0: 0, 1: 6, 2: 12, 3: 18 },
      };
    case 6:
      return {
        totalOuterCells: 36,
        homeStretchLength: 4,
        safeCellIndices: new Set([0, 6, 12, 18, 24, 30]),
        playerEntryCells: { 0: 0, 1: 6, 2: 12, 3: 18, 4: 24, 5: 30 },
      };
    case 8:
      return {
        totalOuterCells: 48,
        homeStretchLength: 4,
        safeCellIndices: new Set([0, 6, 12, 18, 24, 30, 36, 42]),
        playerEntryCells: { 0: 0, 1: 6, 2: 12, 3: 18, 4: 24, 5: 30, 6: 36, 7: 42 },
      };
    default:
      return getBoardGeometry(4);
  }
}

/**
 * Validates whether a token move is strictly legal under server rules.
 */
function isMoveLegal(matchState, tokenId, rollValue) {
  const token = matchState.tokens.find((t) => t.id === tokenId);
  if (!token) return false;
  if (token.playerIndex !== matchState.activePlayerIndex) return false;
  if (token.state === 'inPazham') return false;

  const player = matchState.players[matchState.activePlayerIndex];
  const geo = getBoardGeometry(matchState.playerCount);

  // Kottam entry requires Thayam (1)
  if (token.state === 'inKottam') {
    return rollValue === 1;
  }

  // Outer track movement
  if (token.state === 'onTrack') {
    const newSteps = token.stepsMoved + rollValue;
    if (newSteps <= geo.totalOuterCells) {
      return true;
    }
    // Trying to turn into home lane
    if (!player.hasCaptured) {
      // Must continue looping track without capture!
      return true;
    }
    const homeSteps = newSteps - geo.totalOuterCells;
    return homeSteps <= geo.homeStretchLength;
  }

  // Home stretch movement
  if (token.state === 'onHomeStretch') {
    const newHomeStep = token.cellIndex + rollValue;
    return newHomeStep <= geo.homeStretchLength;
  }

  return false;
}

/**
 * Applies move with authoritative capture checks and victory detection
 */
function applyServerMove(matchState, tokenId, rollValue) {
  if (!isMoveLegal(matchState, tokenId, rollValue)) {
    throw new Error(`Illegal move attempted for token ${tokenId} with roll ${rollValue}`);
  }

  const geo = getBoardGeometry(matchState.playerCount);
  const activeIdx = matchState.activePlayerIndex;
  const player = matchState.players[activeIdx];
  const tokens = [...matchState.tokens];
  const players = [...matchState.players];

  const tokenIdx = tokens.findIndex((t) => t.id === tokenId);
  const token = tokens[tokenIdx];
  let movedToken;
  let madeCapture = false;

  if (token.state === 'inKottam' && rollValue === 1) {
    const entryCell = geo.playerEntryCells[activeIdx];
    movedToken = {
      ...token,
      state: 'onTrack',
      cellIndex: entryCell,
      stepsMoved: 1,
      isSafe: geo.safeCellIndices.has(entryCell),
    };
  } else if (token.state === 'onTrack') {
    const newSteps = token.stepsMoved + rollValue;
    if (newSteps <= geo.totalOuterCells) {
      const entryCell = geo.playerEntryCells[activeIdx];
      const newCell = (entryCell + (newSteps - 1)) % geo.totalOuterCells;
      movedToken = {
        ...token,
        cellIndex: newCell,
        stepsMoved: newSteps,
        isSafe: geo.safeCellIndices.has(newCell),
      };
    } else {
      if (!player.hasCaptured) {
        // Loop outer track
        const entryCell = geo.playerEntryCells[activeIdx];
        const newCell = (entryCell + (newSteps - 1)) % geo.totalOuterCells;
        movedToken = {
          ...token,
          cellIndex: newCell,
          stepsMoved: newSteps,
          isSafe: geo.safeCellIndices.has(newCell),
        };
      } else {
        const homeSteps = newSteps - geo.totalOuterCells;
        if (homeSteps >= geo.homeStretchLength) {
          movedToken = {
            ...token,
            state: 'inPazham',
            cellIndex: 999,
            stepsMoved: geo.totalOuterCells + geo.homeStretchLength,
            isSafe: true,
          };
        } else {
          movedToken = {
            ...token,
            state: 'onHomeStretch',
            cellIndex: homeSteps,
            stepsMoved: newSteps,
            isSafe: true,
          };
        }
      }
    }
  } else if (token.state === 'onHomeStretch') {
    const newHomeStep = token.cellIndex + rollValue;
    if (newHomeStep >= geo.homeStretchLength) {
      movedToken = {
        ...token,
        state: 'inPazham',
        cellIndex: 999,
        stepsMoved: geo.totalOuterCells + geo.homeStretchLength,
        isSafe: true,
      };
    } else {
      movedToken = {
        ...token,
        cellIndex: newHomeStep,
        stepsMoved: token.stepsMoved + rollValue,
        isSafe: true,
      };
    }
  }

  // Handle Captures on non-safe track cells
  if (movedToken.state === 'onTrack' && !movedToken.isSafe) {
    for (let i = 0; i < tokens.length; i++) {
      const other = tokens[i];
      if (
        other.id !== movedToken.id &&
        other.playerIndex !== activeIdx &&
        other.state === 'onTrack' &&
        other.cellIndex === movedToken.cellIndex
      ) {
        tokens[i] = {
          ...other,
          state: 'inKottam',
          cellIndex: -1,
          stepsMoved: 0,
          isSafe: true,
        };
        madeCapture = true;
      }
    }
  }

  tokens[tokenIdx] = movedToken;

  if (madeCapture) {
    players[activeIdx] = { ...player, hasCaptured: true };
  }

  // Check victory
  const playerTokens = tokens.filter((t) => t.playerIndex === activeIdx);
  const allFinished = playerTokens.every((t) => t.state === 'inPazham');
  const winners = [...(matchState.winners || [])];

  if (allFinished && !winners.includes(activeIdx)) {
    winners.push(activeIdx);
    players[activeIdx] = { ...players[activeIdx], rank: winners.length };
  }

  const isOver = winners.length >= matchState.playerCount - 1;
  const isBonusRoll = (rollValue === 1 || rollValue === 5 || rollValue === 6 || rollValue === 12);
  const getsExtraTurn = (isBonusRoll || madeCapture);

  let nextActiveIdx = activeIdx;
  if (!getsExtraTurn || allFinished) {
    nextActiveIdx = (activeIdx + 1) % matchState.playerCount;
    while (winners.includes(nextActiveIdx) && winners.length < matchState.playerCount) {
      nextActiveIdx = (nextActiveIdx + 1) % matchState.playerCount;
    }
  }

  return {
    ...matchState,
    tokens,
    players,
    activePlayerIndex: nextActiveIdx,
    winners,
    isOver,
    turnPhase: isOver ? 'matchFinished' : 'waitingForRoll',
    currentRoll: null,
    updatedAt: Date.now(),
  };
}

module.exports = {
  rollThayakattai,
  getBoardGeometry,
  isMoveLegal,
  applyServerMove,
};
