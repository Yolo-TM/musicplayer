import 'package:flutter/material.dart';
import "config.dart" as CFG;
import "sites/search.dart" as SearchPage;
import "sites/song.dart" as Song;
import 'dart:io';

void main() {
  runApp(MaterialApp(home: MainSite()));
}

class MainSite extends StatefulWidget {
  const MainSite({Key? key}) : super(key: key);
  @override
  State<MainSite> createState() => _MainSite();
}

class _MainSite extends State<MainSite> {
  @override
  void initState() {
    super.initState();
    Future<void> load() async {
      CFG.LoadData();
      setState(() {});
    }

    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // Navigate to the Search Screen
              IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SearchPage.SearchPage())),
                  icon: const Icon(Icons.search))
            ],
            backgroundColor: CFG.HomeColor,
          ),
          body: Container(
            child: ListView(
              children: [
                // Current Playlist Songs, also sortable via drag and drop
                // at the top is always the current song
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.download),
            onPressed: () {
              setState(() {});
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow),
                label: "Current Playlist",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tag),
                label: "All Tags",
              ),
            ],
          ),
          drawer: Drawer(
            child: Center(
              child: ButtonBar(
                children: [
                  TextButton(
                    child: const Text("Search for new Songs"),
                    onPressed: () {
                      Directory dir = Directory('/storage/emulated/0/');
                      List<FileSystemEntity> _files;
                      _files =
                          dir.listSync(recursive: true, followLinks: false);
                      for (FileSystemEntity entity in _files) {
                        String path = entity.path;
                        if (path.endsWith('.mp3')) {
                          CFG.CreateSong(path);
                        }
                        ;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
