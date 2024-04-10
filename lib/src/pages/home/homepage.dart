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
              return Center(child: Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: myLoadingIndicator())));
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

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin  {
  final _scrollControl = ScrollController();


  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      
      body: CustomScrollView(controller: _scrollControl, slivers: [
        SliverAppBar(
          title: overScrolled ? const Text("Hello") : null,
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: 200,
          flexibleSpace: !overScrolled
              ? const FlexibleSpaceBar(
                  title: Text(
                    "Welcome to Note Loom!",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              : Container(),
        ),
        SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(45))),
                child: Column(
                  children: _getUserNotes(),
                )))
      ]),
    );
  }

  List<Widget> _getUserNotes() {
    return List.generate(
      10,
      (index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.primary)),
          height: 200,
          width: double.infinity,
          child: Center(child: Text(index.toString())),
        ),
      ),
    );
  }
}
