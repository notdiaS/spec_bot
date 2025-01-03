import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:share_plus/share_plus.dart';
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
  late final BuildModel? receivedBuild;
  List<BuildModel> savedBuilds = [];
  List<TextEditingController> titleControllers = [];


  @override
  void initState() {
    super.initState();
    loadBuilds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sPrimaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sSecondaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset("assets/images/robot.png"),
            ),
            const SizedBox(width: 10),
            Text('Spec', style: stdTextStyle(Colors.white, bigFont)),
            Text('Bot', style: stdTextStyle(sTextColor, bigFont)),
          ],
        ),
        centerTitle: true,
      ),
        bottomNavigationBar: BottomNavigationBar(
        backgroundColor: sSecondaryColor,
        selectedItemColor: sTextColor,
        selectedLabelStyle: stdTextStyle(sTextColor, smallFont),
        unselectedLabelStyle: stdTextStyle(sThirdColor, smallFont),
        unselectedItemColor: sThirdColor,// Include BottomNavigationBar
        onTap: (int index) {
          if (index == 0) {
            Get.offAllNamed('/'); // Navigate to the main page
          } else if (index == 1) {
            // Do nothing, you are already on the saved page
          }
        },
        currentIndex: 1, // Set the current index to highlight "Saved"
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.robot),
            activeIcon: FaIcon(
              FontAwesomeIcons.robot,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboardList),
            activeIcon: FaIcon(
              FontAwesomeIcons.clipboardCheck,
              size: 24,
            ),
            label: 'Saved',
          ),
        ],
      ),
      body: savedBuilds.isEmpty
          ? Center(
        child: Text(
          'No builds saved yet!',
          style: stdTextStyle(sTextColor, mediumFont),
        ),
      )
          : ListView.builder(
        itemCount: savedBuilds.length,
        itemBuilder: (context, index) {
          final build = savedBuilds[index];
          return Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
            child: ExpansionTileCard(
              subtitle: Text(
                'Total: ${int.parse(build.cpu.avgPrice) + int.parse(build.motherboard.avgPrice) + int.parse(build.gpu.avgPrice) + int.parse(build.ram.avgPrice) + int.parse(build.psu.avgPrice)} ₺',
                style: stdTextStyle(sPrimaryColor, smallFont),
              ),
              borderRadius: BorderRadius.circular(15.0),
              baseColor: Colors.white,
              expandedColor: sTextColor,
              title: build.isEditingTitle
                  ? TextField(
                controller: titleControllers[index],
                onChanged: (newTitle) {
                  setState(() {
                    build.customTitle = newTitle;
                  });
                },
              )
                  : Text(
                '${index + 1}. ${build.customTitle?.isNotEmpty == true ? build.customTitle : 'Build'}',
                style: stdTextStyle(sSecondaryColor, mediumFont),
              ),
              children: [
                buildInfoRow('CPU', build.cpu.model, build.cpu.avgPrice, build.cpu.url),
                buildInfoRow('MOBO', build.motherboard.model, build.motherboard.avgPrice, build.motherboard.url),
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
                            const Icon(Icons.highlight_remove, color: sThirdColor, size: 20),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Text('Remove', style: stdTextStyle(sThirdColor, smallFont)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            build.isEditingTitle = !build.isEditingTitle;
                          });

                          if (!build.isEditingTitle) {
                            saveBuild(build, index);
                          }
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(sPrimaryColor),
                        ),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              build.isEditingTitle ? Icons.check : Icons.edit,
                              color: sThirdColor,
                              size: 20,
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Text(build.isEditingTitle ? 'Save' : 'Edit', style: stdTextStyle(sThirdColor, smallFont)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          String shareContent = """
                            '${index + 1}. ${build.customTitle?.isNotEmpty == true ? build.customTitle : 'Build #${index + 1}'}'
                            CPU: ${build.cpu.model} - ${build.cpu.avgPrice}₺ - ${build.cpu.url}
                            MOBO: ${build.motherboard.model} - ${build.motherboard.avgPrice}₺ - ${build.motherboard.url}
                            GPU: ${build.gpu.model} - ${build.gpu.avgPrice}₺ - ${build.gpu.url}
                            RAM: ${build.ram.model} - ${build.ram.avgPrice}₺ - ${build.ram.url}
                            PSU: ${build.psu.model} - ${build.psu.avgPrice}₺ - ${build.psu.url}
                            Total: ${int.parse(build.cpu.avgPrice) + int.parse(build.motherboard.avgPrice) + int.parse(build.gpu.avgPrice) + int.parse(build.ram.avgPrice) + int.parse(build.psu.avgPrice)}₺
                             """;
                          Share.share(shareContent);
                        },
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(sPrimaryColor),
                        ),
                        child: Column(
                          children: <Widget>[
                            const Icon(Icons.share_outlined, color: sThirdColor, size: 20),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                            Text('Share', style: stdTextStyle(sThirdColor, smallFont)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> loadBuilds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? rawBuilds = prefs.getStringList('savedBuilds');

    setState(() {
      savedBuilds = rawBuilds?.map((e) => BuildModel.fromJson(jsonDecode(e))).toList() ?? [];
      // Initialize titleControllers AFTER setting savedBuilds
      titleControllers = List.generate(savedBuilds.length, (index) => TextEditingController(text: savedBuilds[index].customTitle ?? 'Build'));
    });
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

  Future<void> saveBuild(BuildModel build, int index) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> builds = prefs.getStringList('savedBuilds') ?? [];

    builds[index] = jsonEncode(build.toJson());

    await prefs.setStringList('savedBuilds', builds);
  }

  Widget buildInfoRow(String label, String model, String price, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0,horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white24,borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0,top: 10.0,bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BorderedText(
                    strokeWidth: 3,
                    strokeColor: sThirdColor,
                    child: Text(
                      ('$label : ').toUpperCase(),
                      style: stdTextStyle(sStrokeColor, smallFont),
                    ),
                  ),
                  BorderedText(
                    strokeWidth: 3,
                    strokeColor: Colors.white10,
                    child: Text(
                      (model).toUpperCase(),
                      style: stdTextStyle(sThirdColor, smallFont),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20,left: 1),
                child: InkWell(
                  onTap: () => launchURL(url),
                  child: BorderedText(
                    strokeWidth: 3,
                    strokeColor: sThirdColor,
                    child: Text(
                      '🔗 $price₺',
                      style: stdTextStyle(sStrokeColor, smallFont),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}