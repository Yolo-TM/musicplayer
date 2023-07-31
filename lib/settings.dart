import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';

import 'classes/playlist.dart';
import 'classes/song.dart';
import "classes/tag.dart";

Color HomeColor = const Color.fromRGBO(61, 61, 61, 0);
Color ContrastColor = const Color.fromRGBO(0, 255, 76, 0);

Map Config = {
  "HomeColor": HomeColor.value,
  "ContrastColor": ContrastColor.value,
  "SearchPaths": ["storage/emulated/0/Music", "storage/emulated/0/Download", "C:", "D:", "Library"],
  "Playlist": [],
};

/* Config */
void SaveConfig() {
  SaveSongs();
  String appDocDirectory = "storage/emulated/0/Music";
  File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
    file.writeAsString(jsonEncode(Config));
  });
}

void LoadData(reload, MyAudioHandler audioHandler) async {
  String appDocDirectory = "storage/emulated/0/Music";

  Future.delayed(const Duration(seconds: 2), () {
    try {
      // Load Config
      File('$appDocDirectory/config.json').create(recursive: true).then((File file) {
        file.readAsString().then((String contents) {
          if (contents.isNotEmpty) {
            jsonDecode(contents).forEach((key, value) {
              Config[key] = value;
            });
          }
          // Load Songs
          File('$appDocDirectory/songs.json').create(recursive: true).then((File file) {
            file.readAsString().then((String contents) {
              if (contents.isNotEmpty) {
                jsonDecode(contents).forEach((key, value) async {
                  await Future.delayed(const Duration(milliseconds: 1));
                  Song currentsong = Song.fromJson(value);
                  Songs[key] = currentsong;
                });
                ValidateSongs();
              }
              // Load Tags
              File('$appDocDirectory/tags.json').create(recursive: true).then((File file) {
                file.readAsString().then((String contents) {
                  if (contents.isNotEmpty) {
                    jsonDecode(contents).forEach((key, value) async {
                      await Future.delayed(const Duration(milliseconds: 1));

                      Tag currenttag = Tag.fromJson(value);
                      Tags[currenttag.id] = currenttag;
                    });
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    UpdateAllTags();
                    audioHandler.LoadPlaylist(reload);
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {}
  });
}
