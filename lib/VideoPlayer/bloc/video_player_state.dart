part of 'video_player_bloc.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

class VPInit extends VideoPlayerState {}

class VPPlay extends VideoPlayerState {
  final PageController pageController;
  final List<VideoModel> videos;

  const VPPlay({
    required this.pageController,
    required this.videos,
  });

  @override
  List<Object> get props => [videos];
}
