import 'dart:io';

import 'package:ebook_player/model/PlayerItem.dart';
import 'package:ebook_player/player/content-player-bloc.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    _bloc = ContentPlayerBloc();
    _bloc.add(ContentPlayerEventMove(item: widget.items[0]));
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView(
          onPageChanged: (index) {
            _bloc.add(ContentPlayerEventMove(item: widget.items[index]));
          },
          children: widget.items
              .map((item) => Image.file(File(item.imagePath)))
              .toList()),
    );
  }
}
