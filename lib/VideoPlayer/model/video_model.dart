import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

class VideoModel extends Equatable {
  final VideoPlayerController controller;
  final bool initialized;

  const VideoModel({
    required this.controller,
     this.initialized = false,
  });

  @override
  List<Object?> get props => [controller, initialized];
}
