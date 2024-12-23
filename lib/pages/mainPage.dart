import 'dart:async';
import 'dart:convert';
import 'package:bordered_text/bordered_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spec_bot/pages/savedPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../constants/models.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double currentSliderValue = 0.0;

  int _selectedIndex = 0;
  final List<String> _options = ['Gaming', 'Everyday', 'Work'];

  final Map<String, dynamic> selectedItems = {};
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_$tableName';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(cachedData));
    }

    final response = await supabase.from(tableName).select();

    final processedData = response.map((item) {
      final data = item;
      return {
        'Model': data['Model'],
        'AvgPrice': data['Average_Price'],
        'URL': data['URL'],
        if (data.containsKey('Benchmark')) 'Benchmark': data['Benchmark'],
        if (data.containsKey('Socket')) 'Socket': data['Socket'],
        if (data.containsKey('Frequency')) 'Frequency': data['Frequency'],
      };
    }).toList();

    // Cache the data
    prefs.setString(cacheKey, jsonEncode(processedData));
    return processedData;
  }

  int currentPageIndex = 0;
  final List<Widget> pages = [
    const MainPage(),
    const SavedPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sPrimaryColor,
      appBar: AppBar(
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
        currentIndex: currentPageIndex,
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: sSecondaryColor,
        selectedItemColor: sTextColor,
        unselectedItemColor: sThirdColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(
              Icons.home,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(
              Icons.note,
              size: 24,
            ),
            label: 'Saved',
          ),
        ],
      ),
      body: currentPageIndex == 0
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDropdownWithSupabaseData('CPUData', 'CPU', iCpuImage),
                    buildDropdownWithSupabaseData(
                        'MoboData', 'Motherboard', iMoboImage),
                    buildDropdownWithSupabaseData('GPUData', 'GPU', iGpuImage),
                    buildDropdownWithSupabaseData('RAMData', 'RAM', iRamImage),
                    buildDropdownWithSupabaseData('PSUData', 'PSU', iPSUImage),
                    buildPriceCard(),
                  ],
                ),
              ),
            )
          : pages[currentPageIndex],
    );
  }

  Padding buildDropdownSearch(List<Map<String, dynamic>> items, String hwType, String icnImage) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenHeight * 0.0075),
      child: DropdownSearch<Map<String, dynamic>>(
        items: items,
        onChanged: (selectedItem) {
          setState(() {
            if (selectedItem != null) {
              selectedItems[hwType] = selectedItem;
            }
          });
        },
        selectedItem: selectedItems[hwType],
        dropdownBuilder: (context, selectedItem) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  width: screenWidth * 0.45,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: (selectedItem == null)
                      ? ListTile(
                          contentPadding: const EdgeInsets.only(left: 10),
                          title: Text("No item selected",
                              style: stdTextStyle(Colors.black, smallFont)),
                        )
                      : ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 1.0, left: 1.0),
                                child: Text(
                                    selectedItem['Model']
                                        .toString()
                                        .toUpperCase(),
                                    style:
                                        stdTextStyle(sThirdColor, smallFont)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1.0),
                                child: Text(
                                    ' 💵 ${(double.tryParse(selectedItem['AvgPrice'] ?? '0')?.toStringAsFixed(2) ?? '0.00')}₺',
                                    style:
                                        stdTextStyle(sGreenColor, smallFont)),
                              ),
                              if (selectedItem.containsKey('Benchmark'))
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 1.0),
                                  child: Icon(Icons.speed_outlined,
                                      color: Colors.red, size: 18),
                                ),
                              Text(
                                ' ${selectedItem['Benchmark'] ?? ''}',
                                style: stdTextStyle(Colors.red, smallFont),
                              ),
                              if (selectedItem.containsKey('Frequency'))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  child: Text(
                                      ' 〰 ${selectedItem['Frequency'] ?? 'N/A'}',
                                      style:
                                          stdTextStyle(Colors.blue, smallFont)),
                                ),
                              if (selectedItem.containsKey('Socket'))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  child: Text(
                                      ' 🧩 ${selectedItem['Socket'] ?? 'N/A'}',
                                      style:
                                          stdTextStyle(Colors.blue, smallFont)),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        },
        popupProps: PopupProps.menu(
          constraints: const BoxConstraints(maxHeight: 300),
          searchFieldProps: const TextFieldProps(
            cursorHeight: 20,
            cursorColor: sSecondaryColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: sFillColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: sTextColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: sSecondaryColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: sTextColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
          ),
          showSelectedItems: true,
          showSearchBox: true,
          isFilterOnline: true,
          itemBuilder: (context, item, isSelected) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Text(" ✅ ${item['Model'].toString().toUpperCase()}",
                        style: stdTextStyle(sTextColor, smallFont)),
                  ),
                  Text(
                      ' 💵 ${(double.tryParse(item['AvgPrice']) ?? 0).toStringAsFixed(2)}₺',
                      style: stdTextStyle(sGreenColor, smallFont)),
                  if (item.containsKey('Benchmark'))
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.speed_outlined,
                                color: Colors.red, size: 18),
                            Text(' ${item['Benchmark'] ?? 'N/A'}',
                                style: stdTextStyle(Colors.red, smallFont)),
                          ],
                        )),
                  // if (selectedItem.containsKey('Socket')) Text(' Socket: ${selectedItem['Socket'] ?? 'N/A'}', style: stdTextStyle()),
                  if (item.containsKey('Frequency'))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 3.0),
                      child: Text(' 〰 ${item['Frequency'] ?? 'N/A'}',
                          style: stdTextStyle(Colors.blue, smallFont)),
                    ),
                  if (item.containsKey('Socket'))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 3.0),
                      child: Text(' 🧩 ${item['Socket'] ?? 'N/A'}',
                          style: stdTextStyle(Colors.blue, smallFont)),
                    ),
                ],
              ),
            );
          },
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            filled: true,
            fillColor: sFillColor,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Builder(
                builder: (context) {
                  final item = selectedItems[hwType];
                  return IconButton(
                    icon: Image.asset(icnImage, width: 30, height: 30),
                    iconSize: 30,
                    onPressed: () async {
                      if (item != null && item.containsKey('URL')) {
                        await EasyLauncher.url(url: item['URL']);
                      } else {
                        print("No URL available for the selected item.");
                      }
                    },
                  );
                },
              ),
            ),
            label: BorderedText(
              strokeWidth: 2.5,
              strokeColor: sThirdColor,
              child: Text(
                hwType,
                style: stdTextStyle(sTextColor, bigFont),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: sSecondaryColor),
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: sThirdColor),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: sTextColor),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        compareFn:
            (Map<String, dynamic> item, Map<String, dynamic>? selectedItem) {
          return item['Model'] == selectedItem!['Model'];
        },
      ),
    );
  }

  Widget buildDropdownWithSupabaseData(
      String tableName, String label, String image) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchData(tableName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        } else {
          return buildDropdownSearch(snapshot.data!, label, image);
        }
      },
    );
  }

  Widget buildPriceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: sFillColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: sPrimaryColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: sFillColor),
              ),
              margin: const EdgeInsets.all(10),
              width: 100,
              height: 170,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Price:',
                      style: stdTextStyle(Colors.white, bigFont),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: buildPriceWidget()),
                  ElevatedButton(
                    onPressed: saveCurrentBuild,
                    child: const Text("Save Build"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: sPrimaryColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: sFillColor),
                ),
                margin: const EdgeInsets.all(10),
                width: 175,
                height: 170,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: ToggleButtons(
                        borderColor: sThirdColor,
                        selectedBorderColor: sTextColor,
                        borderWidth: 2,
                        selectedColor: sTextColor,
                        color: sThirdColor,
                        fillColor: sThirdColor,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        isSelected: List.generate(_options.length,
                            (index) => index == _selectedIndex),
                        children: _options
                            .map((String label) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    label,
                                    style: stdTextStyle(null, smallFont),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, bottom: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Budget: ",
                                    style: stdTextStyle(Colors.white, 18.0),
                                  ),
                                  Text(
                                    "$currentSliderValue",
                                    style: stdTextStyle(sTextColor, 18.0),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1.0, horizontal: 10),
                              child: Slider(
                                inactiveColor: sSecondaryColor,
                                activeColor: sTextColor,
                                thumbColor: sTextColor,
                                value: currentSliderValue,
                                min: 0,
                                max: 50000,
                                divisions: 20,
                                onChanged: (double value) {
                                  setState(() {
                                    currentSliderValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: RoundedLoadingButton(
                            width: 60,
                            height: 60,
                            color: sThirdColor,
                            successColor: sTextColor,
                            controller: _btnController,
                            onPressed: _doSomething,
                            child: Text('Build',
                                style: stdTextStyle(Colors.white, smallFont)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  double calculateTotalPrice() {
    double totalPrice = selectedItems.values.fold(0.0, (sum, item) {
      var avgPrice = item['AvgPrice'];
      if (avgPrice is String && avgPrice != 'N/A') {
        var parsedAvgPrice = double.tryParse(avgPrice);
        if (parsedAvgPrice != null) {
          return sum + parsedAvgPrice;
        }
      } else if (avgPrice is num) {
        return sum + avgPrice.toDouble();
      }
      return sum;
    });
    return totalPrice;
  }

  Widget buildPriceWidget() {
    double totalPrice = calculateTotalPrice();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Text(
        '${totalPrice.toStringAsFixed(0)} ₺',
        style: stdTextStyle(sTextColor, 13.0),
      ),
    );
  }

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  void _doSomething() async {
    _btnController.start();
    await autoBuild();

    _btnController.success();

    Timer(const Duration(seconds: 5), () {
      _btnController.reset();
    });
  }

  Future<void> autoBuild() async {
    double budget = currentSliderValue;
    String useCase = _options[_selectedIndex];

    double gpuBudget = budget * 0.3; // Default
    double cpuBudget = budget * 0.3; // Default
    double moboBudget = budget * 0.2; // Default
    double ramBudget = budget * 0.1; // Default
    double psuBudget = budget * 0.1; // Default

    if (useCase == 'Gaming') {
      gpuBudget = budget * 0.4;
      cpuBudget = budget * 0.25;
    } else if (useCase == 'Work') {
      cpuBudget = budget * 0.4;
      gpuBudget = budget * 0.2;
    } else if (useCase == 'Everyday') {
      gpuBudget = budget * 0.3;
      cpuBudget = budget * 0.3;
    }

    try {
      var cpuFuture = fetchData('CPUData');
      var gpuFuture = fetchData('GPUData');
      var moboFuture = fetchData('MoboData');
      var ramFuture = fetchData('RAMData');
      var psuFuture = fetchData('PSUData');

      List<Map<String, dynamic>> cpus = await cpuFuture;
      List<Map<String, dynamic>> gpus = await gpuFuture;
      List<Map<String, dynamic>> mobos = await moboFuture;
      List<Map<String, dynamic>> rams = await ramFuture;
      List<Map<String, dynamic>> psus = await psuFuture;

      Map<String, dynamic> selectedCPU = cpus
          .where((cpu) => _getPrice(cpu['AvgPrice']) <= cpuBudget)
          .reduce((a, b) => (_getBenchmark(a) > _getBenchmark(b)) ? a : b);

      Map<String, dynamic> selectedGPU = gpus
          .where((gpu) => _getPrice(gpu['AvgPrice']) <= gpuBudget)
          .reduce((a, b) => (_getBenchmark(a) > _getBenchmark(b)) ? a : b);

      Map<String, dynamic> selectedMobo = mobos
          .where((mobo) => _getPrice(mobo['AvgPrice']) <= moboBudget)
          .firstWhere((mobo) => mobo['AvgPrice'] != null, orElse: () => {});

      Map<String, dynamic> selectedRAM = rams
          .where((ram) => _getPrice(ram['AvgPrice']) <= ramBudget)
          .firstWhere((ram) => ram['AvgPrice'] != null, orElse: () => {});

      Map<String, dynamic> selectedPSU = psus
          .where((psu) => _getPrice(psu['AvgPrice']) <= psuBudget)
          .firstWhere((psu) => psu['AvgPrice'] != null, orElse: () => {});

      if (selectedCPU.isEmpty ||
          selectedGPU.isEmpty ||
          selectedMobo.isEmpty ||
          selectedRAM.isEmpty ||
          selectedPSU.isEmpty) {
        throw Exception('Error: One or more components could not be selected.');
      }

      setState(() {
        selectedItems['CPU'] = selectedCPU;
        selectedItems['GPU'] = selectedGPU;
        selectedItems['Motherboard'] = selectedMobo;
        selectedItems['RAM'] = selectedRAM;
        selectedItems['PSU'] = selectedPSU;
      });
    } catch (e) {
      print("Error fetching data: $e");
      _btnController.error();
      Timer(const Duration(seconds: 3), () {
        _btnController.reset();
      });
    }
  }

  double _getPrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _getBenchmark(Map<String, dynamic> component) {
    if (component['Benchmark'] is String) {
      return int.tryParse(component['Benchmark']) ?? 0;
    }
    return component['Benchmark'] ?? 0;
  }

// For clearing cache (use if needed)
// void clearCache() async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.clear();
// }

  Future<void> saveBuild(BuildModel build) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> builds = prefs.getStringList('savedBuilds') ?? [];
    builds.add(jsonEncode(build.toJson()));
    await prefs.setStringList('savedBuilds', builds);
    print("Saved Builds: $builds");
  }

  void saveCurrentBuild() async {
    final build = BuildModel(
      cpu: selectedItems['CPU']!,
      motherboard: selectedItems['Motherboard']!,
      gpu: selectedItems['GPU']!,
      ram: selectedItems['RAM']!,
      psu: selectedItems['PSU']!,
    );

    await saveBuild(build);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Build saved successfully!')),
    );
  }


}
