import 'dart:io';

import 'package:ebook_player/home.bloc.dart';
import 'package:ebook_player/player/content-player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  HomeBloc _bloc;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    _bloc = HomeBloc();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: const Text,),
        body: SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: 'Enter url of file and click download beside',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              // handle clear
                              _controller.clear();
                            })),
                  )),
                  IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: () async {
                        // trigger download from url
                        // decompress file
                        if (_controller.text.isNotEmpty) {
                          _bloc.add(
                              HomeEventInternetSelected(url: _controller.text));
                        }
                      }),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () async {
                      File file =
                          await FilePicker.getFile(fileExtension: '.zip');
                      // decompress file
                      if (file != null) {
                        _bloc.add(HomeEventFileSelected(selectedFile: file));
                      }
                    },
                  ),
                ],
              )),
          Expanded(
              child: BlocBuilder(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state is HomeStateContentSet) {
                      return ContentPlayer(items: state.items);
                    }
                    if (state is HomeStateLoading) {
                      return const Center(
                          child: const CircularProgressIndicator());
                    }

                    if (state is HomeStateError) {
                      return Center(
                        child: Text(state.error),
                      );
                    }

                    return const Center(
                      child: const Text('Nothing to show'),
                    );
                  })),
        ],
      ),
    ));
  }
}
