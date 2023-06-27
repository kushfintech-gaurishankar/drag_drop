import 'package:drag_drop/VideoPlayer/bloc/video_player_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPlayerCubit()..loadVideos(),
      child: Scaffold(
        body: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
          builder: (context, state) {
            if (state is VPPlay) {
              return PageView(
                controller: state.pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  BlocProvider.of<VideoPlayerCubit>(context).play(index);
                },
                children: List.generate(state.videos.length, (index) {
                  if (state.videos[index].initialized) {
                    VideoPlayerController vpController =
                        state.videos[index].controller;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: vpController.value.aspectRatio,
                          child: GestureDetector(
                            onDoubleTap: () =>
                                BlocProvider.of<VideoPlayerCubit>(context)
                                    .playPause(
                                        index: index,
                                        vpController: vpController),
                            child: VideoPlayer(vpController),
                          ),
                        ),
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  );
                }),
              );
            }

            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }
}
