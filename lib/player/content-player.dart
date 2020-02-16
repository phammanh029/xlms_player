import 'dart:io';

import 'package:ebook_player/model/PlayerItem.dart';
import 'package:ebook_player/player/content-player-bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentPlayer extends StatefulWidget {
  final List<PlayerItem> items;

  const ContentPlayer({Key key, @required this.items})
      : assert(items != null),
        super(key: key);

  @override
  _ContentPlayerState createState() => _ContentPlayerState();
}

class _ContentPlayerState extends State<ContentPlayer> {
  ContentPlayerBloc _bloc;
  final PageController _controller = PageController();
  @override
  void initState() {
    _bloc = ContentPlayerBloc();
    _bloc.add(ContentPLayerEventInitial(totalItem: widget.items.length));
    _bloc.add(ContentPlayerEventMove(item: widget.items[0]));
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ContentPlayerStateDone) {
            if (_controller.page < widget.items.length - 1) {
              _controller.nextPage(
                  duration: Duration(seconds: 2), curve: Curves.easeInOutExpo);
            }
          }
        },
        child: Column(
          children: <Widget>[
            BlocBuilder(
                bloc: _bloc,
                builder: (context, state) {
                  return Text(
                      '${_controller.page.toInt() + 1} / ${widget.items.length}');
                }),
            Expanded(
              child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    _bloc
                        .add(ContentPlayerEventMove(item: widget.items[index]));
                  },
                  children: widget.items
                      .map((item) => Image.file(File(item.imagePath)))
                      .toList()),
            ),
            BlocBuilder(
                bloc: _bloc,
                builder: (context, state) {
                  if (state is ContentPlayerStateProgressChanged) {
                    return LinearProgressIndicator(value: state.percent);
                  }

                  if (state is ContentPlayerStateDone) {
                    return state.isCompleted
                        ? const Text('All page completed')
                        : const Text('Move to next page in a few seconds');
                  }

                  return const CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
  }
}
