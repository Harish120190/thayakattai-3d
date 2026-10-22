import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kolam_background.dart';
import '../../core/widgets/netrik_button.dart';
import '../../data/models/player.dart';
import '../game_board/game_board_screen.dart';

class GameLobbyScreen extends ConsumerStatefulWidget {
  final bool isHost;

  const GameLobbyScreen({super.key, required this.isHost});

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  late String _roomCode;
  final int _playerCount = 4;
  late List<Map<String, dynamic>> _lobbySlots;
  bool _isLocalReady = true;
  final TextEditingController _joinCodeController = TextEditingController();
  bool _hasJoined = false;

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _roomCode = _generateRoomCode();
      _hasJoined = true;
      _initSlots();
    } else {
      _roomCode = '';
      _hasJoined = false;
    }
  }

  void _initSlots() {
    final storage = ref.read(localStorageProvider);
    _lobbySlots = List.generate(_playerCount, (idx) {
      if (idx == 0) {
        return {
          'name': storage.username,
          'isHost': true,
          'isAI': false,
          'isReady': true,
        };
      } else {
        return {
          'name': 'AI Bot $idx',
          'isHost': false,
          'isAI': true,
          'isReady': true,
        };
      }
    });
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? l10n.tr('create_room') : l10n.tr('join_room')),
      ),
      body: KolamBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: !_hasJoined
              ? _buildJoinLobbyForm(context, l10n)
              : _buildActiveLobbyView(context, l10n),
        ),
      ),
    );
  }

  Widget _buildJoinLobbyForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.meeting_room, size: 64, color: AppColors.gold),
        const SizedBox(height: 16),
        const Text(
          'Enter 6-Digit Room Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.ivory,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ask the host for their code to join their multiplayer match',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _joinCodeController,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            color: AppColors.goldLight,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            hintText: 'e.g. THAYA7',
            hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        NetrikButton(
          label: 'Join Lobby',
          icon: Icons.login,
          onPressed: () {
            final code = _joinCodeController.text.trim().toUpperCase();
            if (code.length == 6) {
              setState(() {
                _roomCode = code;
                _hasJoined = true;
                _initSlots();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid 6-character code')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActiveLobbyView(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room Code Banner
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('room_code'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Text(
                    _roomCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.gold),
                tooltip: 'Copy Code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _roomCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.tr('copied'))),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Player Slots List
        Text(
          'Players in Room (${_lobbySlots.length}/$_playerCount)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: ListView.separated(
            itemCount: _lobbySlots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final slot = _lobbySlots[idx];
              final color = AppColors.getPlayerColor(idx);
              final isHost = slot['isHost'] as bool;
              final isAI = slot['isAI'] as bool;
              final isReady = slot['isReady'] as bool;

              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ivory,
                            ),
                          ),
                          Row(
                            children: [
                              if (isHost)
                                const Text(
                                  'Host • ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.goldLight,
                                  ),
                                ),
                              Text(
                                isAI ? 'AI Opponent' : 'Human Player',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isReady
                            ? AppColors.emerald.withValues(alpha: 0.2)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isReady
                              ? AppColors.emerald
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        isReady ? l10n.tr('ready') : l10n.tr('not_ready'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isReady
                              ? AppColors.emeraldLight
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Host Start Action or Participant Ready Toggle
        if (widget.isHost) ...[
          NetrikButton(
            label: l10n.tr('start_game'),
            icon: Icons.play_arrow,
            onPressed: _startLobbyGame,
          ),
        ] else ...[
          NetrikButton(
            label: _isLocalReady ? 'Cancel Ready' : l10n.tr('ready'),
            isSecondary: _isLocalReady,
            onPressed: () {
              setState(() => _isLocalReady = !_isLocalReady);
            },
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }

  void _startLobbyGame() {
    final players = <PlayerModel>[];
    for (var i = 0; i < _lobbySlots.length; i++) {
      final slot = _lobbySlots[i];
      players.add(PlayerModel(
        id: 'usr_$i',
        name: slot['name'] as String,
        colorHex: '#${AppColors.getPlayerColor(i).toARGB32().toRadixString(16)}',
        playerIndex: i,
        isAI: slot['isAI'] as bool,
        aiDifficulty: AIDifficulty.medium,
      ));
    }

    ref.read(gameControllerProvider.notifier).startNewGame(
          playerCount: _playerCount,
          players: players,
          tokensPerPlayer: 4,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameBoardScreen()),
    );
  }
}
