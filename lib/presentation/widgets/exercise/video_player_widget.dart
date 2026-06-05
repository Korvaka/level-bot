import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  const ExerciseVideoPlayer({
    super.key,
    required this.url,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
  });

  final String url;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool showControls;
  final double aspectRatio;

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;
  bool _showOverlay = true;
  double _playbackSpeed = 1.0;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          if (widget.autoPlay) _play();
        }
      });

    _controller.addListener(() {
      if (mounted) {
        final playing = _controller.value.isPlaying;
        if (playing != _isPlaying) {
          setState(() => _isPlaying = playing);
        }
        if (_controller.value.position >= _controller.value.duration &&
            _controller.value.duration > Duration.zero) {
          setState(() {
            _isPlaying = false;
            _showOverlay = true;
          });
          _controller.seekTo(Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.play();
    setState(() {
      _isPlaying = true;
      _showOverlay = false;
    });
  }

  void _pause() {
    _controller.pause();
    setState(() {
      _isPlaying = false;
      _showOverlay = true;
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _setSpeed(double speed) {
    _controller.setPlaybackSpeed(speed);
    setState(() => _playbackSpeed = speed);
  }

  void _openFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPlayer(
          controller: _controller,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _initialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : _buildPlaceholder(),
            if (_initialized && widget.showControls) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black87,
      child: widget.thumbnailUrl != null
          ? Image.network(widget.thumbnailUrl!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultPlaceholder())
          : _buildDefaultPlaceholder(),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: AppColors.darkCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center_rounded,
              size: 48, color: AppColors.primary),
          const SizedBox(height: 8),
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return GestureDetector(
      onTap: () {
        setState(() => _showOverlay = !_showOverlay);
      },
      child: AnimatedOpacity(
        opacity: _showOverlay || !_isPlaying ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SpeedButton(
                      speed: _playbackSpeed,
                      onChanged: _setSpeed,
                      speeds: _speeds,
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_rounded,
                          color: Colors.white, size: 22),
                      onPressed: _openFullScreen,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Center play button
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const Spacer(),
              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (_, value, __) {
                    final duration = value.duration.inMilliseconds.toDouble();
                    final position = value.position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, duration);
                    return Slider(
                      value: duration > 0 ? position / duration : 0.0,
                      onChanged: duration > 0
                          ? (v) => _controller.seekTo(
                                Duration(
                                    milliseconds: (v * duration).round()),
                              )
                          : null,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.white24,
                      thumbColor: AppColors.primary,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.speed,
    required this.onChanged,
    required this.speeds,
  });

  final double speed;
  final void Function(double) onChanged;
  final List<double> speeds;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: speed,
      onSelected: onChanged,
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '${speed}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      itemBuilder: (_) => speeds
          .map((s) => PopupMenuItem(
                value: s,
                child: Text(
                  '${s}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  const _FullScreenVideoPlayer({
    required this.controller,
    required this.onClose,
  });

  final VideoPlayerController controller;
  final VoidCallback onClose;

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit_rounded,
                    color: Colors.white, size: 28),
                onPressed: widget.onClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
