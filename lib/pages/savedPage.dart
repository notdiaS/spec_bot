import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/models.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<BuildModel> savedBuilds = [];

  @override
  void initState() {
    super.initState();
    loadBuilds();
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: sPrimaryColor,
      body: savedBuilds.isEmpty
          ? const Center(child: Text('No builds saved yet!'))
          : ListView.builder(
        itemCount: savedBuilds.length,
        itemBuilder: (context, index) {
          final build = savedBuilds[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Build ${index + 1}'),
              subtitle: Text(
                'CPU: ${build.cpu}\nMotherboard: ${build.motherboard}\nGPU: ${build.gpu}\nRAM: ${build.ram}\nPSU: ${build.psu}',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadBuilds() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? rawBuilds = prefs.getStringList('savedBuilds');
    print("Raw Builds from SharedPreferences: $rawBuilds");

    setState(() {
      savedBuilds =
          rawBuilds?.map((e) => BuildModel.fromJson(jsonDecode(e))).toList() ?? [];
    });

    print("Parsed Builds: $savedBuilds");
  }

}