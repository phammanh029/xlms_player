import 'package:audioplayers/audioplayers.dart';
import 'package:ebook_player/model/PlayerItem.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

class ContentPlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ContentPlayerEventMove extends ContentPlayerEvent {
  final PlayerItem item;

  ContentPlayerEventMove({@required this.item});

  @override
  List<Object> get props => [item];
}

class ContentPLayerEventDone extends ContentPlayerEvent {}

class ContentPLayerEventProgressChanged extends ContentPlayerEvent {
  final double value;

  ContentPLayerEventProgressChanged({@required this.value});
  @override
  List<Object> get props => [value];
}

// state
class ContentPlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class ContentPlayerStateInitial extends ContentPlayerState {}

class ContentPlayerStateLoading extends ContentPlayerState {}

class ContentPlayerStateDone extends ContentPlayerState {}

class ContentPlayerStateProgressChanged extends ContentPlayerState {
  final double percent;

  ContentPlayerStateProgressChanged({@required this.percent});

  @override
  List<Object> get props => [percent];
}

class ContentPlayerStateChanged extends ContentPlayerState {
  final String imagePath;

  ContentPlayerStateChanged({@required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

class ContentPlayerStateError extends ContentPlayerState {
  final String error;

  ContentPlayerStateError({@required this.error});

  @override
  List<Object> get props => [error];
}

// bloc
class ContentPlayerBloc extends Bloc<ContentPlayerEvent, ContentPlayerState> {
  final player = AudioPlayer();
  ContentPlayerBloc() {
    player.onPlayerCompletion.listen((event) {
      add(ContentPLayerEventDone());
    }, onDone: () {
      print('onDone');
      // move next
    });

    player.onAudioPositionChanged.listen((event) async {
      final duration = await player.getDuration();
      final current = await player.getCurrentPosition();
      add(ContentPLayerEventProgressChanged(value: current / duration));
    });
  }

  void onPlayerComplete() {}

  @override
  ContentPlayerState get initialState => ContentPlayerStateInitial();

  @override
  Future<void> close() {
    player.dispose();
    return super.close();
  }

  @override
  Stream<ContentPlayerState> mapEventToState(ContentPlayerEvent event) async* {
    // print('>>> test');
    if (event is ContentPlayerEventMove) {
      // print(event.item.audioPath);
      if (player.state == AudioPlayerState.PLAYING ||
          player.state == AudioPlayerState.PAUSED) {
        await player.stop();
      }
      player.play(event.item.audioPath, isLocal: true);
      // play audio at item
      yield ContentPlayerStateChanged(imagePath: event.item.imagePath);
    }

    if (event is ContentPLayerEventDone) {
      yield ContentPlayerStateDone();
    }

    if (event is ContentPLayerEventProgressChanged) {
      yield ContentPlayerStateProgressChanged(percent: event.value);
    }
  }
}
