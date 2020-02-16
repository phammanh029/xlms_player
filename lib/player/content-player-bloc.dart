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

class ContentPlayerEventPause extends ContentPlayerEvent {}

class ContentPLayerEventDone extends ContentPlayerEvent {
  final bool completed;

  ContentPLayerEventDone({this.completed = false});

  @override
  List<Object> get props => [completed];
}

class ContentPLayerEventInitial extends ContentPlayerEvent {
  final int totalItem;

  ContentPLayerEventInitial({@required this.totalItem});
  @override
  List<Object> get props => [totalItem];
}

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

// class ContentPlayerState extends ContentPlayerState {}

class ContentPlayerStateLoading extends ContentPlayerState {}

class ContentPlayerStateDone extends ContentPlayerState {
  final bool isCompleted;

  ContentPlayerStateDone({@required this.isCompleted});

  @override
  List<Object> get props => [isCompleted];
}

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
  int _total = 0;
  int _current = 0;
  ContentPlayerBloc() {
    player.onPlayerCompletion.listen((event) {
      add(ContentPLayerEventDone(completed: _current == _total));
    }, onDone: () {});

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
    if (event is ContentPLayerEventInitial) {
      _total = event.totalItem;
      _current = 0;
      yield ContentPlayerStateInitial();
    }

    if (event is ContentPlayerEventPause) {
      switch (player.state) {
        case AudioPlayerState.PLAYING:
          await player.pause();
          break;
        case AudioPlayerState.PAUSED:
          await player.resume();
          break;
        default:
          break;
      }
      yield state;
    }
    // print('>>> test');
    if (event is ContentPlayerEventMove) {
      // print(event.item.audioPath);
      if (player.state == AudioPlayerState.PLAYING ||
          player.state == AudioPlayerState.PAUSED) {
        await player.stop();
      }
      player.play(event.item.audioPath, isLocal: true);
      _current++;
      // play audio at item
      yield ContentPlayerStateChanged(imagePath: event.item.imagePath);
    }

    if (event is ContentPLayerEventDone) {
      yield ContentPlayerStateDone(isCompleted: event.completed);
    }

    if (event is ContentPLayerEventProgressChanged) {
      yield ContentPlayerStateProgressChanged(percent: event.value);
    }
  }
}
