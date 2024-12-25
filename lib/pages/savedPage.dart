import 'dart:convert';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return Scaffold(
      backgroundColor: sPrimaryColor,
      body: savedBuilds.isEmpty
          ? const Center(child: Text('No builds saved yet!'))
          : ListView.builder(
              itemCount: savedBuilds.length,
              itemBuilder: (context, index) {
                final build = savedBuilds[index];
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                  child: ExpansionTileCard(
                    borderRadius: BorderRadius.circular(15.0),
                    baseColor: sTextColor,
                    title: Text(
                      'Build ${index + 1}',
                      style: stdTextStyle(sSecondaryColor, smallFont),
                    ),
                    children: [
                      buildInfoRow('CPU', build.cpu.model, build.cpu.avgPrice, build.cpu.url),
                      buildInfoRow('Motherboard', build.motherboard.model, build.motherboard.avgPrice, build.motherboard.url),
                      buildInfoRow('GPU', build.gpu.model, build.gpu.avgPrice, build.gpu.url),
                      buildInfoRow('RAM', build.ram.model, build.ram.avgPrice, build.ram.url),
                      buildInfoRow('PSU', build.psu.model, build.psu.avgPrice, build.psu.url),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: OverflowBar(
                          alignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                removeBuild(index);
                              },
                              child: Column(
                                children: <Widget>[
                                  const Icon(Icons.highlight_remove,
                                      color: sThirdColor, size: 20),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Text('Remove',
                                      style:
                                          stdTextStyle(sThirdColor, smallFont)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          sPrimaryColor)),
                              child: Column(
                                children: <Widget>[
                                  const Icon(Icons.share_outlined,
                                      color: sThirdColor, size: 20),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.0),
                                  ),
                                  Text('Share',
                                      style:
                                          stdTextStyle(sThirdColor, smallFont)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Load saved builds from SharedPreferences
  Future<void> loadBuilds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? rawBuilds = prefs.getStringList('savedBuilds');

    setState(() {
      savedBuilds =
          rawBuilds?.map((e) => BuildModel.fromJson(jsonDecode(e))).toList() ??
              [];
    });

    // print("Parsed Builds: $savedBuilds");
  }

  Future<void> removeBuild(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> builds = prefs.getStringList('savedBuilds') ?? [];

    if (index >= 0 && index < builds.length) {
      builds.removeAt(index);
      await prefs.setStringList('savedBuilds', builds);
      await loadBuilds();
    }
  }

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildInfoRow(String label, String model, String price, String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0,top: 10.0,bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              ('$label:  $model').toUpperCase(),
              style: stdTextStyle(sSecondaryColor, smallFont),
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => launchURL(url),
              child: Text(
                '₺$price',
                style: const TextStyle(
                  fontSize: 14,
                  color: sTextColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
