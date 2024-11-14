import 'package:flutter/material.dart';
import 'db_wrapper.dart';

enum ROUTES { HOME, PLAYER, SETTINGS, DB }

class LoadingPanel extends StatefulWidget {
  @override
  State<LoadingPanel> createState() => _LoadingPanelState();
}

class _LoadingPanelState extends State<LoadingPanel> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: Text('Error initializing database'),
            ),
          );
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final List<ROUTES> availableRoutes = [
    ROUTES.PLAYER,
    ROUTES.SETTINGS,
    ROUTES.DB
  ];

  ROUTES currentRoute = ROUTES.HOME;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Current Route: ${widget.currentRoute}'),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: widget.availableRoutes.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.currentRoute = widget.availableRoutes[index];
                      });
                    },
                    child: Text(widget.availableRoutes[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
