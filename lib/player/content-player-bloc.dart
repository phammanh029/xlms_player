import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

class ContentPlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ContentPlayerEventMove extends ContentPlayerEvent {
  final int index;

  ContentPlayerEventMove({@required this.index});

  @override
  List<Object> get props => [index];
}

// state
class ContentPlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class ContentPlayerStateInitial extends ContentPlayerState {}

class ContentPlayerStateLoading extends ContentPlayerState {}

class ContentPlayerStateChanged extends ContentPlayerState {
  final int index;

  ContentPlayerStateChanged({@required this.index});

  @override
  List<Object> get props => [index];
}

class ContentPlayerStateError extends ContentPlayerState {
  final String error;

  ContentPlayerStateError({@required this.error});

  @override
  List<Object> get props => [error];
}

// bloc
class ContentPlayerBloc extends Bloc<ContentPlayerEvent, ContentPlayerState> {
  @override
  ContentPlayerState get initialState => ContentPlayerStateInitial();

  @override
  Stream<ContentPlayerState> mapEventToState(ContentPlayerEvent event) async* {
    if (event is ContentPlayerEventMove) {
      // play audio at item
      yield ContentPlayerStateChanged(index: event.index);
    }
  }
}
