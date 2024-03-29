import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Hello"),
            backgroundColor: Colors.grey.shade700,
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
      ),
    );
  }
}
