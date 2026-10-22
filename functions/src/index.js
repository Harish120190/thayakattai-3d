const { rollThayakattai, isMoveLegal, applyServerMove } = require('./game_engine');

// Server-side endpoints for Cloud Functions
exports.rollThayakattai = rollThayakattai;
exports.isMoveLegal = isMoveLegal;
exports.applyServerMove = applyServerMove;

exports.createRoomHandler = async (data, context) => {
  const { hostId, playerCount = 4, isPrivate = true } = data;
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let roomCode = '';
  for (let i = 0; i < 6; i++) {
    roomCode += chars[Math.floor(Math.random() * chars.length)];
  }

  return {
    roomId: `RM_${Date.now()}`,
    roomCode,
    hostId,
    playerCount,
    isPrivate,
    status: 'lobby',
    createdAt: Date.now(),
  };
};

exports.generateTrustedRollHandler = async (data, context) => {
  return rollThayakattai();
};

exports.submitMoveHandler = async (data, context) => {
  const { matchState, tokenId, rollValue } = data;
  return applyServerMove(matchState, tokenId, rollValue);
};
