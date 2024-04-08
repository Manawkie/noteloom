import 'package:flutter/material.dart';
import 'package:school_app/src/components/uicomponents.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 2)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: myLoadingIndicator());
            }
            return const Home();
          }),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollControl = ScrollController();

  bool overScrolled = false;
  @override
  void initState() {
    super.initState();
    _scrollControl.addListener(overScroll);
  }

  @override
  void dispose() {
    _scrollControl.dispose();
    super.dispose();
  }

  void overScroll() {
    setState(() {
      if (_scrollControl.hasClients && _scrollControl.offset > 200) {
        overScrolled = true;
      } else {
        overScrolled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollControl,
      slivers: [
        SliverAppBar(
          title: overScrolled ? const Text("Hello") : null,
          backgroundColor: Theme.of(context).primaryColor,
          pinned: true,
          expandedHeight: 200,
          flexibleSpace: !overScrolled ? const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Welcome to Note Loom!",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ) : Container() ,
        ),
        SliverList.builder(
            itemCount: 20,
            itemBuilder: ((context, index) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.1,
                padding: const EdgeInsets.all(10),
                child: Text("Item: ${index + 1}"),
              );
            }))
      ],
    );
  }
}
