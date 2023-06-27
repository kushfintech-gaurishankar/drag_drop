import 'package:drag_drop/VideoPlayer/model/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  final PageController pageController = PageController();
  List<VideoModel> videos = [];

  VideoPlayerCubit() : super(VPInit());

  VPPlay get _state => VPPlay(pageController: pageController, videos: videos);

  loadVideos() async {
    const List<String> urls = [
      "https://viewstoryapp.com/media/images/video_Mvdv0PB.mp4",
      "https://viewstoryapp.com/media/images/video_4kX3fsn.mp4",
      "https://viewstoryapp.com/media/images/video_FEuR5BA.mp4",
      "https://viewstoryapp.com/media/images/video_Ald3JL6.mp4",
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    ];

    for (int i = 0; i < urls.length; i++) {
      VideoPlayerController vpController =
          VideoPlayerController.network(urls[i]);

      vpController.initialize().then((value) {
        videos[i] = VideoModel(controller: vpController, initialized: true);

        videos = videos.toList();
        emit(_state);
      });
      vpController.setLooping(true);
      videos.add(VideoModel(controller: vpController));
    }
    videos.first.controller.play();

    emit(_state);
  }

  play(int index) => videos[index].controller.play();

  playPause({required int index, required VideoPlayerController vpController}) {
    bool playing = vpController.value.isPlaying;
    playing
        ? videos[index].controller.pause()
        : videos[index].controller.play();
  }
}
