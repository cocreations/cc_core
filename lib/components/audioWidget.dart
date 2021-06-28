import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cc_core/models/core/audioItem.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:url_launcher/url_launcher.dart';

class AudioWidget extends StatefulWidget {
  AudioWidget({
    this.audioUrl,
    this.audioItem,
    this.imageFile,
    this.name = "",
    this.fileDir = "sounds",
    this.enableSeek = true,
    this.heroTag,
    this.onPlay,
  });

  /// If [audioUrl] is null, [audioItem] must not be null
  final String audioUrl;

  /// If [audioItem] is null, [audioUrl] must not be null
  final AudioItem audioItem;
  final File imageFile;
  final String name;
  final String fileDir;
  final bool enableSeek;
  final String heroTag;

  /// onPlay is called when the audio item is played
  final void Function() onPlay;
  @override
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  StreamSubscription progressBar;
  StreamSubscription onAudioStateChange;

  AudioItem _audioItem;

  File imageFile;
  bool isSliderSliding = false;
  double sliderOverride = 0;

  double startOverride = 0;

  @override
  void dispose() {
    progressBar.cancel();
    onAudioStateChange.cancel();
    super.dispose();
  }

  @override
  void initState() {
    assert(widget.audioItem != null || widget.audioUrl != null);

    if (widget.audioItem != null) {
      _audioItem = widget.audioItem;

      progressBar = _audioItem.onSeekChange.listen((newPos) async {
        if (mounted) {
          setState(() {
            // this basically makes sure when you return the soundtrail
            // the play/pause button is still set to pause
          });
        }
      });

      onAudioStateChange = _audioItem.onStateChange.listen((event) {
        setState(() {});
      });
    }

    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      if (widget.audioItem == null) {
        File audioFile = await CcData(CcApp.of(context).database).getFile(widget.audioUrl, widget.fileDir);

        _audioItem = await AudioItem.buildFromFile(audioFile);

        progressBar = _audioItem.onSeekChange.listen((newPos) async {
          if (mounted) {
            setState(() {
              // this basically makes sure when you return the soundtrail
              // the play/pause button is still set to pause
            });
          }
        });

        onAudioStateChange = _audioItem.onStateChange.listen((event) {
          setState(() {});
        });
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _showNeverGonnaGiveYouUp(void Function() onShowDialog) async {
    const String url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    if (await canLaunch(url)) {
      onShowDialog();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "You seem bored",
            style: TextStyle(color: Colors.white),
          ),
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Have a listen to this instead!",
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: Colors.orange,
                  ),
                  onPressed: () => launch(url),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  String _durationText() {
    String text = "";

    if (_audioItem.seek.inSeconds - (_audioItem.seek.inMinutes * 60) < 10) {
      text = "${_audioItem.seek.inMinutes}:0${_audioItem.seek.inSeconds - (_audioItem.seek.inMinutes * 60)} / ";
    } else {
      text = "${_audioItem.seek.inMinutes}:${_audioItem.seek.inSeconds - (_audioItem.seek.inMinutes * 60)} / ";
    }

    if (_audioItem.duration.inSeconds - (_audioItem.duration.inMinutes * 60) < 10) {
      text += "${_audioItem.duration.inMinutes}:0${_audioItem.duration.inSeconds - (_audioItem.duration.inMinutes * 60)}";
    } else {
      text += "${_audioItem.duration.inMinutes}:${_audioItem.duration.inSeconds - (_audioItem.duration.inMinutes * 60)}";
    }

    return text;
  }

  double _progressBarValue() {
    if (!isSliderSliding) {
      if (_audioItem.seek == null || _audioItem.duration == null) {
        return 0;
      }
      var returnVal = _audioItem.seek.inMilliseconds / _audioItem.duration.inMilliseconds;
      if (returnVal > 1) return 1;
      return returnVal;
    }
    return sliderOverride;
  }

  Widget _playPause() {
    if (_audioItem.state == AudioState.noAudio) return Container();

    if (_audioItem.state != AudioState.playing) {
      return IconButton(
        tooltip: "Play",
        icon: Icon(
          Icons.play_arrow,
          color: Colors.orange,
        ),
        onPressed: () {
          if (widget.onPlay != null) {
            widget.onPlay();
          }

          if (_audioItem.state == AudioState.paused) {
            _audioItem.resume();
          } else {
            _audioItem.play();
          }
        },
      );
    } else {
      return IconButton(
        tooltip: "Pause",
        icon: Icon(
          Icons.pause,
          color: Colors.orange,
        ),
        onPressed: () {
          _audioItem.pause();
        },
      );
    }
  }

  Widget _imageWidget() {
    Widget image = Container(
      padding: EdgeInsets.all(14),
      child: CircularProgressIndicator(),
    );

    if (widget.imageFile != null) {
      image = Image.file(widget.imageFile, fit: BoxFit.contain);
    } else {
      return Container(height: 60, width: 60, color: Colors.black);
    }

    if (widget.heroTag != null) {
      return Container(
        height: 60,
        width: 60,
        margin: EdgeInsets.only(right: 10),
        child: Hero(tag: widget.heroTag, child: image),
      );
    }
    return Container(
      height: 60,
      width: 60,
      margin: EdgeInsets.only(right: 10),
      child: image,
    );
  }

  Widget _seekBar() {
    if (_audioItem.state == AudioState.noAudio) return Container();
    if (widget.enableSeek) {
      return Container(
        height: 25,
        margin: EdgeInsets.only(bottom: 10),
        child: Slider(
          value: _progressBarValue(),
          activeColor: Colors.orangeAccent,
          inactiveColor: Colors.black12,
          onChangeStart: (value) {
            isSliderSliding = true;
            startOverride = value;
          },
          onChangeEnd: (value) {
            isSliderSliding = false;
            // had to remove this :(
            // if (value - startOverride > 0.9) {
            //   _showNeverGonnaGiveYouUp(() => _audioItem.pause());
            // }

            _audioItem.seek = Duration(
              milliseconds: (value * _audioItem.duration.inMilliseconds).round(),
            );
          },
          onChanged: (value) => setState(() => sliderOverride = value),
        ),
      );
    }

    return Container(
      height: 6,
      child: LinearProgressIndicator(
        value: _progressBarValue(),
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
        backgroundColor: Colors.black12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _seekBar(),
          Row(
            children: [
              _imageWidget(),
              Expanded(
                child: Container(
                  //margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 110,
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Text(
                        _durationText(),
                        style: TextStyle(color: Colors.orange),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  // add these in later
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.fast_rewind,
                  //     color: Colors.orange,
                  //   ),
                  //   onPressed: () {},
                  // ),
                  _audioItem.state != AudioState.noAudio ? _playPause() : Container(),
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.fast_forward,
                  //     color: Colors.orange,
                  //   ),
                  //   onPressed: () {},
                  // ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
