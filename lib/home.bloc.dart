import 'package:ebook_player/model/PlayerItem.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeEventInitial extends HomeEvent {}

class HomeEventFileSelected extends HomeEvent {
  final File selectedFile;

  HomeEventFileSelected({@required this.selectedFile});

  @override
  List<Object> get props => [selectedFile];
}

class HomeEventInternetSelected extends HomeEvent {
  final String url;

  HomeEventInternetSelected({@required this.url});

  @override
  List<Object> get props => [url];
}

// state
class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeStateInitial extends HomeState {}

class HomeStateLoading extends HomeState {}

class HomeStateError extends HomeState {
  final String error;

  HomeStateError({@required this.error});
  @override
  List<Object> get props => [error];
}

class HomeStateContentSet extends HomeState {
  final List<PlayerItem> items;

  HomeStateContentSet({@required this.items});
  @override
  List<Object> get props => [items];
}

// bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> localFile(String subPath) async {
    final path = await _localPath;
    return '$path/$subPath';
  }

  @override
  HomeState get initialState => HomeStateInitial();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomeEventInternetSelected) {
      // handle download
      try {
        yield HomeStateLoading();
        Dio dio = new Dio();
        final savePath = await localFile(Uuid().v4());
        final response = await dio.download(event.url, savePath);
        if (response.statusCode == 200) {
          // add new event
          add(HomeEventFileSelected(selectedFile: File(savePath)));
        }
      } catch (error) {
        yield HomeStateError(error: error.toString());
      }
    }
    if (event is HomeEventFileSelected) {
      // do extract
      try {
// Decode the Zip file
        final bytes = await event.selectedFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        // Extract the contents of the Zip archive to disk.
        final List<String> fileNames = [];
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            final fileItem = File(await localFile(filename));
            await (await fileItem.create(recursive: true)).writeAsBytes(data);
            fileNames.add(fileItem.path);
          } else {
            await Directory(await localFile(filename)).create(recursive: true);
          }
        }
        final items = fileNames
            .where((String file) => !file.toLowerCase().endsWith('.mp3'))
            .map((file) => PlayerItem(
                imagePath: file,
                audioPath: file.substring(0, file.lastIndexOf('.')) + '.mp3'))
            .toList();
        yield HomeStateContentSet(items: items);
      } catch (error) {
        yield HomeStateError(error: error.toString());
      }
    }
  }
}
