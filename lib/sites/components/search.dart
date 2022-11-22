import 'package:flutter/material.dart';
import '../../settings.dart' as CFG;

// Search Page
class SearchPage extends StatefulWidget {
  SearchPage(this.content, {Key? key}) : super(key: key);

  final content;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController();

  String searchtext = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void update(void Function() c) {
    setState(
      () {
        c();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: CFG.ContrastColor,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            backgroundColor: CFG.HomeColor,
            // The search area here
            title: Container(
              height: 40,
              child: Center(
                child: TextField(
                  onChanged: (searchtext) {
                    this.searchtext = searchtext;
                    setState(() {});
                  },
                  controller: myController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          myController.clear();
                          this.searchtext = "";
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(),
                      labelText: 'Search'),
                ),
              ),
            )),
        body: widget.content(searchtext, update),
      ),
    );
  }
}
