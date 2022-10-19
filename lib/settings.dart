import 'dart:core';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

final Color HomeColor = Color.fromRGBO(100, 255, 0, 255);
final Color ContrastColor = Color.fromRGBO(0, 0, 0, 0);

Map Songs = {};
Map Tags = {};

Future<void> ShowSth(String info, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(info),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void LoadData() {
  String appDocDirectory = "storage/emulated/0/Music";
  File(appDocDirectory + '/songs.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Song currentsong = Song.fromJson(value); // TODO: Check if file exists

          Songs[key] = currentsong;
        });
      }
    });
  });
  ValidateSongs();

  File(appDocDirectory + '/tags.json')
      .create(recursive: true)
      .then((File file) {
    file.readAsString().then((String contents) {
      if (contents.isNotEmpty) {
        jsonDecode(contents).forEach((key, value) {
          Tag currenttag = Tag.fromJson(value);
          Tags[currenttag.id] = currenttag;
        });
      }
    });
  });
  UpdateAllTags();
}

/* Songs */
class Song {
  String path = "";
  String filename = "";
  String title = "Song Title";
  String interpret = "Song Interpret";
  bool hastags = false;
  List tags = [];
  Song(this.path);
  Info() {
    print("Song Info");
    print(path);
    print(filename);
    print(title);
    print(interpret);
    print(tags.toString());
  }

  Song.fromJson(Map<String, dynamic> json)
      : path = json['p'],
        filename = json['f'],
        title = json['t'],
        interpret = json['i'],
        hastags = json['h'],
        tags = json['ta'];
  Map<String, dynamic> toJson(Song value) => {
        'p': value.path,
        'f': value.filename,
        't': value.title,
        'i': value.interpret,
        'h': value.hastags,
        'ta': value.tags
      };
}

bool CreateSong(path) {
  String filename = path
      .split("/")
      .last; // INFO: already filters for multiple file of the same song
  if (Songs.containsKey(filename)) {
    return false;
  }
  String interpret =
      path.split("/").last.split(" - ").first.replaceAll(RegExp(".mp3"), "");

  String title = path
      .split("/")
      .last
      .split(" - ")
      .last
      .replaceAll(RegExp(".mp3"), "")
      .split(" _ ")
      .first;

  Song newsong = Song(path);
  newsong.title = title;
  newsong.filename = filename;
  newsong.interpret = interpret;
  Songs[filename] = newsong;
  return true;
}

void UpdateSongInterpret(String key, String newtitle) {
  Songs[key].interpret = newtitle;
  SaveSongs();
}

void UpdateSongTitle(String key, String newtitle) {
  Songs[key].title = newtitle;
  SaveSongs();
}

void UpdateSongTags(String key, List newtags, List oldtags) {
  Songs[key].tags = newtags;

  if (oldtags.isEmpty || newtags.isEmpty) {
    Songs[key].hastags = false;
  } else {
    Songs[key].hastags = true;
  }
  UpdateAllTags();
  SaveSongs();
}

void DeleteSong(Song s) {
  if (Songs.containsKey(s.filename)) {
    Songs.remove(s.filename);
  }
  UpdateAllTags();
  SaveSongs();
}

void SaveSongs() async {
  String appDocDirectory = "storage/emulated/0/Music";
  String json = "{";
  Songs.forEach((k, v) {
    json += '"' + k + '":' + jsonEncode(v.toJson(v)) + ",";
  });
  File(appDocDirectory + '/songs.json')
      .writeAsString(json.substring(0, json.length - 1) + "}");
  // remove last comma, close json
  LoadData();
}

// Check if file in Song path still exists
void ValidateSongs() async {
  Songs.forEach((k, v) {
    if (!File(v.path).existsSync()) {
      print("Song " + v.path + " does not exist anymore!");
      DeleteSong(v);
    }
  });
}

/* Tags */

class Tag {
  String name = "New Tag";
  int id = -1;
  int used = 0;
  Tag(this.name);
  Tag.fromJson(Map<String, dynamic> json)
      : name = json['n'],
        used = json['u'],
        id = json['i'];
  Map<String, dynamic> toJson(Tag value) =>
      {'n': value.name, 'u': value.used, 'i': value.id};
}

void CreateTag(name) {
  if (Tags.containsKey(name)) {
    print("Trying to create existing Tag!");
    return;
  }

  Tag newtag = Tag(name);
  newtag.id = Tags.length + 1;
  Tags[newtag.id] = newtag;
  SaveTags();
}

void UpdateTagName(tag, name) {
  if (Tags.containsKey(tag)) {
    Tags[tag].name = name;
    SaveTags();
  }
}

void SaveTags() async {
  String appDocDirectory = "storage/emulated/0/Music";

  String json = "{";
  Tags.forEach((k, v) {
    json += '"' + k.toString() + '":' + jsonEncode(v.toJson(v)) + ",";
  });

  File(appDocDirectory + '/tags.json').writeAsString(
      json.substring(0, json.length - 1) +
          "}"); // remove last comma, close json
  LoadData();
}

// TODO rework this using the Song Function for Tag Editing
void DeleteTag(Tag t) {
  Tags.remove(t.id);
  Songs.forEach(
    (k, v) {
      if (v.tags.contains(t.id)) {
        v.tags.remove(t.id);
      }
    },
  );
  SaveTags();
  SaveSongs();
}

void UpdateAllTags() {
  Tags.forEach((k, v) {
    v.used = 0;
  });
  Songs.forEach((k, v) {
    v.tags.forEach((element) {
      Tags[element].used += 1;
    });
  });
}

Map GetSongsFromTag(Tag T) {
  Map songs = {};

  for (String s in Songs.keys) {
    Song so = Songs[s];
    List t = so.tags;
    if (t.indexOf(T.id, 0) != -1) {
      songs[so.filename] = so;
    }
  }
  return songs;
}

/* Playlist */
class CurrentPlayList {
  List<Song> songs = [];
  int last_added_pos = 0;
  void AddToPlaylist(Song song) {
    if (!songs.contains(song)) {
      songs.add(song);
    }
  }

  void PlayNext(Song song) {
    last_added_pos = 0;
    if (!songs.contains(song)) {
      songs.insert(0, song);
    } else {
      songs.remove(song);
      songs.insert(0, song);
    }
  }

  void PlayAfterLastAdded(Song song) {
    last_added_pos += 1;
    if (!songs.contains(song)) {
      songs.insert(last_added_pos, song);
    } else {
      songs.remove(song);
      songs.insert(last_added_pos, song);
    }
  }

  void Shuffle() {
    songs.shuffle();
  }
}

CurrentPlayList CurrList = CurrentPlayList();
