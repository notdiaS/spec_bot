import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bordered_text/bordered_text.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
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
  final List<String> _options = ["🕹️ Gaming", "⚖️ Balanced", "💼 Work"];
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
        selectedLabelStyle: stdTextStyle(sTextColor, smallFont),
        unselectedLabelStyle: stdTextStyle(sThirdColor, smallFont),
        unselectedItemColor: sThirdColor,
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
      body: currentPageIndex == 0
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDropdownWithSupabaseData('CPUData', 'CPU', iCpuImage),
                    buildDropdownWithSupabaseData('MoboData', 'Motherboard', iMoboImage),
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
        dropdownBuilder: (context, selectedItem) {return Container(
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: (selectedItem == null)
                ? ListTile(
              contentPadding: const EdgeInsets.only(left: 10),
              title: Text(
                "No item selected",
                style: stdTextStyle(Colors.black, smallFont),
              ),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0, left: 1.0),
                    child: Text(
                      selectedItem['Model'].toString().toUpperCase(),
                      style: stdTextStyle(sThirdColor, smallFont),
                    ),
                  ),
                  if (selectedItem.containsKey('Socket'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Text(
                        '  🧩${selectedItem['Socket'] ?? 'N/A'}',
                        style: stdTextStyle(Colors.blue, smallFont),
                      ),
                    ),
                  if (selectedItem.containsKey('Benchmark'))
                  Text(
                    '  ⚡️${selectedItem['Benchmark'] ?? ''}',
                    style: stdTextStyle(Colors.red, smallFont),
                  ),
                  if (selectedItem.containsKey('Frequency'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Text(
                        '  〰${selectedItem['Frequency'] ?? 'N/A'}',
                        style: stdTextStyle(Colors.blue, smallFont),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: Text(
                      '  💵${(double.tryParse(selectedItem['AvgPrice'] ?? '0')?.toStringAsFixed(0) ?? '0.00')}₺',
                      style: stdTextStyle(sGreenColor, smallFont),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        popupProps: PopupProps.menu(
          menuProps: MenuProps(
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          searchDelay: const Duration(milliseconds: 25),
          constraints: const BoxConstraints(maxHeight: 250),
          containerBuilder: (context, popupWidget) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: sTextColor,
                  width: 1.5,
                ),
                color: sPrimaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: popupWidget,
            );
          },
          searchFieldProps: TextFieldProps(
            style: stdTextStyle(sTextColor,smallFont),
            cursorHeight: 20,
            cursorColor: sSecondaryColor,
            decoration: const InputDecoration(
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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                      child: Text(
                        "✅${item['Model'].toString().toUpperCase()}",
                        style: stdTextStyle(sTextColor, tinyFont),
                      ),
                    ),
                    if (item.containsKey('Socket'))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 3.0),
                        child: Text(
                          '🧩${item['Socket'] ?? 'N/A'}',
                          style: stdTextStyle(Colors.blue, tinyFont),
                        ),
                      ),
                    if (item.containsKey('Benchmark'))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Row(
                          children: [
                            Text(
                              '⚡️${item['Benchmark'] ?? 'N/A'}',
                              style: stdTextStyle(Colors.red, tinyFont),
                            ),
                          ],
                        ),
                      ),
                    if (item.containsKey('Frequency'))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 3.0),
                        child: Text(
                          '〰${item['Frequency'] ?? 'N/A'}',
                          style: stdTextStyle(Colors.blue, tinyFont),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '💵${(double.tryParse(item['AvgPrice']) ?? 0).toStringAsFixed(0)}₺',
                        style: stdTextStyle(sGreenColor, tinyFont),
                      ),
                    ),
                  ],
                ),
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

  Widget buildDropdownWithSupabaseData(String tableName, String label, String image) {
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
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: sFillColor),
            ),
            clipBehavior: Clip.hardEdge,
            child:
            Column(
              children: [
                _buildBudgetColumn(),
                _buildPriceRow(),
              ],
            )
          );
        },
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      decoration: BoxDecoration(
        color: sPrimaryColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: sFillColor),
      ),
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.only(top:5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Price:',
            style: stdTextStyle(Colors.white, bigFont),
          ),
          buildPriceWidget(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: sPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: saveCurrentBuild,
            child: const FaIcon(
              FontAwesomeIcons.floppyDisk,
              color: sTextColor,
              size: 25.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetColumn() {
    return Container(
      decoration: BoxDecoration(
        color: sPrimaryColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: sFillColor),
      ),
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.only(bottom:5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                constraints: const BoxConstraints(minWidth: 60),
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
                isSelected: List.generate(
                    _options.length, (index) => index == _selectedIndex),
                children: _options
                    .map((String label) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.5, vertical: 8),
                  child: Text(
                    label,
                    style: stdTextStyle(null, smallFont),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Budget: ",
                      style: stdTextStyle(Colors.white, 18.0),
                    ),
                    Text(
                      "$currentSliderValue",
                      style: stdTextStyle(sTextColor, 18.0),
                    ),
                    Slider(
                      inactiveColor: sSecondaryColor,
                      activeColor: sTextColor,
                      thumbColor: sTextColor,
                      value: currentSliderValue,
                      min: 0,
                      max: 75000,
                      divisions: 20,
                      onChanged: (double value) {
                        setState(() {
                          currentSliderValue = value.roundToDouble();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: RoundedLoadingButton(
                  width: 60,
                  height: 60,
                  color: sSecondaryColor,
                  successColor: sTextColor,
                  controller: _btnController,
                  onPressed: _doSomething,
                  child: const FaIcon(
                    FontAwesomeIcons.screwdriverWrench,
                    color: sTextColor,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
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
        ' ${totalPrice.toStringAsFixed(0)} ₺',
        style: stdTextStyle(sTextColor, bigFont),
      ),
    );
  }

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  Future<bool> autoBuild() async {
    double budget = currentSliderValue;
    String useCase = _options[_selectedIndex].toString();

    Map<String, double> budgets = _allocateBudgets(budget, useCase);

    try {

      var data = await Future.wait([
        fetchData('CPUData'),
        fetchData('GPUData'),
        fetchData('MoboData'),
        fetchData('RAMData'),
        fetchData('PSUData')
      ]);

      List<Map<String, dynamic>> cpus = data[0];
      List<Map<String, dynamic>> gpus = data[1];
      List<Map<String, dynamic>> mobos = data[2];
      List<Map<String, dynamic>> rams = data[3];
      List<Map<String, dynamic>> psus = data[4];

      var selectedCPU = _selectBestComponent(cpus, budgets['CPU']!, _getBenchmark);
      var selectedGPU = _selectBestComponent(gpus, budgets['GPU']!, _getBenchmark);

      if (selectedCPU.isEmpty || selectedGPU.isEmpty) {
        throw Exception('CPU or GPU selection failed.');
      }

      String cpuSocket = selectedCPU['Socket'];
      var selectedMobo = _selectMatchingComponent(
        mobos,
        budgets['Mobo']!,
            (mobo) => mobo['Socket'] == cpuSocket,
      );

      bool isDDR5 = ['AM5', 'LGA1700'].contains(cpuSocket);
      var selectedRAM = _selectBestComponent(
        rams,
        budgets['RAM']!,
            (ram) => _extractFrequency(ram['Frequency']),
        isDDR5 ? 4800 : 3600,
      );

      var selectedPSU = _selectRandomComponent(psus, budgets['PSU']!);

      if ([selectedCPU, selectedGPU, selectedMobo, selectedRAM, selectedPSU]
          .any((component) => component.isEmpty)) {
        throw Exception('One or more components could not be selected.');
      }

      setState(() {
        selectedItems['CPU'] = selectedCPU;
        selectedItems['GPU'] = selectedGPU;
        selectedItems['Motherboard'] = selectedMobo;
        selectedItems['RAM'] = selectedRAM;
        selectedItems['PSU'] = selectedPSU;
      });

      return true;
    } catch (e) {
      _showErrorToast('Error fetching data!');
      return false;
    }
  }

  Map<String, double> _allocateBudgets(double budget, String useCase) {
    switch (useCase) {
      case '🕹️ Gaming':
        return {
          'GPU': budget * 0.45,
          'CPU': budget * 0.35,
          'Mobo': budget * 0.15,
          'RAM': budget * 0.1,
          'PSU': budget * 0.05,
        };
      case '💼 Work':
        return {
          'GPU': budget * 0.35,
          'CPU': budget * 0.45,
          'Mobo': budget * 0.15,
          'RAM': budget * 0.1,
          'PSU': budget * 0.05,
        };
      default:
        return {
          'GPU': budget * 0.35,
          'CPU': budget * 0.35,
          'Mobo': budget * 0.15,
          'RAM': budget * 0.1,
          'PSU': budget * 0.05,
        };
    }
  }

  Map<String, dynamic> _selectBestComponent(
      List<Map<String, dynamic>> components,
      double budget,
      Function comparator, [
        int? threshold,
      ]) {
    var filtered = components.where((c) => _getPrice(c['AvgPrice']) <= budget);

    if (threshold != null) {
      filtered = filtered.where(
              (c) => _extractFrequency(c['Frequency']) >= threshold);
    }

    return filtered.isNotEmpty
        ? filtered.reduce((a, b) => comparator(a) > comparator(b) ? a : b)
        : {};
  }

  Map<String, dynamic> _selectMatchingComponent(List<Map<String, dynamic>> components, double budget, bool Function(Map<String, dynamic>) condition) {
    var filtered = components.where((c) =>
    _getPrice(c['AvgPrice']) <= budget && condition(c)).toList();
    return filtered.isNotEmpty ? filtered[Random().nextInt(filtered.length)] : {};
  }

  Map<String, dynamic> _selectRandomComponent(List<Map<String, dynamic>> components, double budget) {
    var filtered = components
        .where((c) => _getPrice(c['AvgPrice']) <= budget)
        .toList();
    return filtered.isNotEmpty ? filtered[Random().nextInt(filtered.length)] : {};
  }

  void _showErrorToast(String message) {
    DelightToastBar(
      autoDismiss: true,
      builder: (context) => ToastCard(
        color: Colors.red,
        leading: const FaIcon(
          FontAwesomeIcons.triangleExclamation,
          size: 25,
          color: sTextColor,
        ),
        title: Text(
          message,
          style: stdTextStyle(sTextColor, smallFont),
        ),
      ),
    ).show(context);
  }

  double _getPrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }

  int _getBenchmark(Map<String, dynamic> component) {
    return int.tryParse(component['Benchmark']?.toString() ?? '0') ?? 0;
  }

  int _extractFrequency(String frequency) {
    return int.tryParse(
            RegExp(r'\d+').firstMatch(frequency)?.group(0) ?? '0') ??
        0;
  }

  void _doSomething() async {
    _btnController.start();
    bool success = await autoBuild();

    if (success) {
      _btnController.success();
      Timer(const Duration(seconds: 5), () {
        _btnController.reset();
      });
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 3), () {
        _btnController.reset();
      });
    }
  }

  Future<void> saveBuild(BuildModel build) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> builds = prefs.getStringList('savedBuilds') ?? [];
    builds.add(jsonEncode(build.toJson()));
    await prefs.setStringList('savedBuilds', builds);

  }

  void saveCurrentBuild() async {

    if (selectedItems['CPU'] == null ||
        selectedItems['Motherboard'] == null ||
        selectedItems['GPU'] == null ||
        selectedItems['RAM'] == null ||
        selectedItems['PSU'] == null) {

      DelightToastBar(
        autoDismiss: true,
        builder: (context) => ToastCard(
          color: Colors.red,
          leading: const FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 25,
            color: Colors.white,
          ),
          title: Text(
            'Please add all components!',
            style: stdTextStyle(Colors.white, smallFont),
          ),
        ),
      ).show(context);
      return;
    }

    final build = BuildModel(
      cpu: ComponentModel(
        model: selectedItems['CPU']['Model'],
        avgPrice: double.parse(selectedItems['CPU']['AvgPrice'].toString())
            .toStringAsFixed(0),
        url: selectedItems['CPU']['URL'],
      ),
      motherboard: ComponentModel(
        model: selectedItems['Motherboard']['Model'],
        avgPrice:
        double.parse(selectedItems['Motherboard']['AvgPrice'].toString())
            .toStringAsFixed(0),
        url: selectedItems['Motherboard']['URL'],
      ),
      gpu: ComponentModel(
        model: selectedItems['GPU']['Model'],
        avgPrice: double.parse(selectedItems['GPU']['AvgPrice'].toString())
            .toStringAsFixed(0),
        url: selectedItems['GPU']['URL'],
      ),
      ram: ComponentModel(
        model: selectedItems['RAM']['Model'],
        avgPrice: double.parse(selectedItems['RAM']['AvgPrice'].toString())
            .toStringAsFixed(0),
        url: selectedItems['RAM']['URL'],
      ),
      psu: ComponentModel(
        model: selectedItems['PSU']['Model'],
        avgPrice: double.parse(selectedItems['PSU']['AvgPrice'].toString())
            .toStringAsFixed(0),
        url: selectedItems['PSU']['URL'],
      ),
    );

    await saveBuild(build);

    DelightToastBar(
      autoDismiss: true,
      builder: (context) => ToastCard(
        color: sThirdColor,
        leading: const FaIcon(
          FontAwesomeIcons.checkToSlot,
          size: 25,
          color: sTextColor,
        ),
        title: Text(
          'Build Saved Successfully!',
          style: stdTextStyle(sTextColor, smallFont),
        ),
      ),
    ).show(context);
  }

}
