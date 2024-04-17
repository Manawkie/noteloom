import 'package:flutter/material.dart';
import 'package:school_app/src/components/uicomponents.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollControl = ScrollController();

  bool overScrolled = false;

  @override
  void initState() {
    _scrollControl.addListener(overScroll);
    super.initState();
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
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(
          slivers: [
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
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 3000)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(45),
                        ),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: myLoadingIndicator(),
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Recent Notes and Subjects"),
                        ..._buildList()
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ));
  }

  List<Widget> _buildList() {
    return List.generate(
        20,
        (index) => ListTile(
              title: Text("Item $index"),
            ));
  }
}
