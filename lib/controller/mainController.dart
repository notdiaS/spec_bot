import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../constants/models.dart';

class MainController extends GetxController {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  var currentPageIndex = 0.obs;
  var currentSliderValue = 0.0.obs;
  var selectedIndex = 0.obs;
  final RxList<Widget> pages = RxList<Widget>([]);
  final RxMap<String, dynamic> selectedItems = RxMap<String, dynamic>.of({});
  var isLoading = false.obs;
  var isAutoBuilding = false.obs;
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  final SupabaseClient supabase = Supabase.instance.client;
  List<String> get options => _options;
  final List<String> _options = ["🕹️ Gaming", "⚖️ Balanced", "💼 Work"];

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

    prefs.setString(cacheKey, jsonEncode(processedData));
    return processedData;
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
      List<Map<String, dynamic>> components, double budget, Function comparator,
      [int? threshold]) {
    var filtered = components.where((c) => _getPrice(c['AvgPrice']) <= budget);

    if (threshold != null) {
      filtered =
          filtered.where((c) => _extractFrequency(c['Frequency']) >= threshold);
    }

    return filtered.isNotEmpty
        ? filtered.reduce((a, b) => comparator(a) > comparator(b) ? a : b)
        : {};
  }

  Map<String, dynamic> _selectMatchingComponent(
      List<Map<String, dynamic>> components,
      double budget,
      bool Function(Map<String, dynamic>) condition) {
    var filtered = components
        .where((c) => _getPrice(c['AvgPrice']) <= budget && condition(c))
        .toList();
    return filtered.isNotEmpty
        ? filtered[Random().nextInt(filtered.length)]
        : {};
  }

  Map<String, dynamic> _selectRandomComponent(
      List<Map<String, dynamic>> components, double budget) {
    var filtered =
        components.where((c) => _getPrice(c['AvgPrice']) <= budget).toList();
    return filtered.isNotEmpty
        ? filtered[Random().nextInt(filtered.length)]
        : {};
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


  void updateSliderValue(double value) =>
      currentSliderValue.value = value.roundToDouble();
  void updateSelectedIndex(int index) => selectedIndex.value = index;
  void updateSelectedItem(String hwType, dynamic item) {
    selectedItems[hwType] = item;
    selectedItems.refresh();
  }

  double calculateTotalPrice() {
    return selectedItems.values.fold(0.0, (sum, item) {
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
  }

  Future<bool> autoBuild() async {
    isAutoBuilding.value = true;
    double budget = currentSliderValue.value;
    String useCase = _options[selectedIndex.value];

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

      var selectedCPU =
          _selectBestComponent(cpus, budgets['CPU']!, _getBenchmark);
      var selectedGPU =
          _selectBestComponent(gpus, budgets['GPU']!, _getBenchmark);

      if (selectedCPU.isEmpty || selectedGPU.isEmpty) {
        throw Exception('CPU or GPU selection failed.');
      }

      String cpuSocket = selectedCPU['Socket'];
      var selectedMobo = _selectMatchingComponent(
          mobos, budgets['Mobo']!, (mobo) => mobo['Socket'] == cpuSocket);

      bool isDDR5 = ['AM5', 'LGA1700'].contains(cpuSocket);
      var selectedRAM = _selectBestComponent(rams, budgets['RAM']!,
          (ram) => _extractFrequency(ram['Frequency']), isDDR5 ? 4800 : 3600);

      var selectedPSU = _selectRandomComponent(psus, budgets['PSU']!);

      if ([selectedCPU, selectedGPU, selectedMobo, selectedRAM, selectedPSU]
          .any((component) => component.isEmpty)) {
        throw Exception('One or more components could not be selected.');
      }

      updateSelectedItem('CPU', selectedCPU);
      updateSelectedItem('GPU', selectedGPU);
      updateSelectedItem('Motherboard', selectedMobo);
      updateSelectedItem('RAM', selectedRAM);
      updateSelectedItem('PSU', selectedPSU);

      return true;
    } catch (e) {
      _showErrorToast('Error fetching data!');
      return false;
    } finally {
      isAutoBuilding.value = false;
    }
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

  void _showErrorToast(String message) {
    if (Get.context != null) {
      // Check if context is available
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
      ).show(Get.context!);
    } else {
      print("Context is null. Cannot show toast: $message"); // Fallback
    }
  }

  void doAutoBuild() async {
    btnController.start();
    bool success = await autoBuild();

    if (success) {
      btnController.success();
      Timer(const Duration(seconds: 2), () {
        btnController.reset();
      });
    } else {
      btnController.error();
      Timer(const Duration(seconds: 2), () {
        btnController.reset();
      });
      _showErrorToast(
          "An error occurred during auto build."); // Show toast on auto build error.
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
      ).show(Get.context!);
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
    ).show(Get.context!);
  }
}
