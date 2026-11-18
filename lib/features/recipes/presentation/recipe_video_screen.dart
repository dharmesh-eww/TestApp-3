import 'package:flutter/material.dart';
import 'package:testapp_3/core/theme/app_theme.dart';
import 'package:testapp_3/localization/app_localizations.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Inline YouTube player shown only when a recipe has a valid video URL.
class RecipeYoutubeEmbed extends StatefulWidget {
  const RecipeYoutubeEmbed({super.key, required this.videoUrl, required this.title});
  final String videoUrl;
  final String title;

  @override
  State<RecipeYoutubeEmbed> createState() => _RecipeYoutubeEmbedState();
}

class _RecipeYoutubeEmbedState extends State<RecipeYoutubeEmbed> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false, enableCaption: true),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return _VideoUnavailable(title: widget.title);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.terracotta,
        ),
        builder: (context, player) => player,
      ),
    );
  }
}

class RecipeVideoScreen extends StatefulWidget {
  const RecipeVideoScreen({super.key, required this.recipeTitle, required this.videoUrl});
  final String recipeTitle;
  final String videoUrl;

  @override
  State<RecipeVideoScreen> createState() => _RecipeVideoScreenState();
}

class _RecipeVideoScreenState extends State<RecipeVideoScreen> {
  YoutubePlayerController? _controller;
  late final String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (_videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false, enableCaption: true),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.recipeTitle)),
        body: _VideoUnavailable(title: widget.recipeTitle),
      );
    }
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.terracotta,
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.recipeTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(widget.recipeTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoUnavailable extends StatelessWidget {
  const _VideoUnavailable({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
    child: Column(
      children: [
        Icon(Icons.video_library_outlined, size: 36, color: AppTheme.muted),
        const SizedBox(height: 8),
        Text(appStrings(context).recipeLabel('Video unavailable'), style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
        Text(title, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
      ],
    ),
  );
}
