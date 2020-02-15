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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView(
          onPageChanged: (index) {
            // change content
            _bloc.add(ContentPlayerEventMove(index: index));
          },
          children: widget.items
              .map((item) => Image.file(File(item.imagePath)))
              .toList()),
    );
  }
}
