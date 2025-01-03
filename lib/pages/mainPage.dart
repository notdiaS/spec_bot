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
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spec_bot/pages/savedPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../constants/models.dart';
import 'package:spec_bot/controller/mainController.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final mainController = Get.put(MainController());

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
     currentIndex: mainController.currentPageIndex.value,
       onTap: (int index) {
         if (index == 0) {
           Get.offAllNamed('/');
         } else if (index == 1) {
           Get.toNamed('/saved');
         }
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
      body: Obx(
      () => mainController.currentPageIndex.value == 0
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
         : mainController.pages[mainController.currentPageIndex.value],
     )
     );
  }

  Padding buildDropdownSearch(List<Map<String, dynamic>> items, String hwType, String icnImage) {
    double screenWidth = MediaQuery.of(Get.context!).size.width;
    double screenHeight = MediaQuery.of(Get.context!).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenHeight * 0.0075),
    child: Obx(()=> DropdownSearch<Map<String, dynamic>>(
    items: items,
    onChanged: (selectedItem) {
    mainController.updateSelectedItem(hwType, selectedItem!);
    },
    selectedItem: mainController.selectedItems[hwType],
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
                  final item = mainController.selectedItems[hwType];
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
    compareFn: (Map<String, dynamic> item, Map<String, dynamic>? selectedItem) {
    return item['Model'] == selectedItem!['Model'];
        },
      ),
    )
    );
  }

  Widget buildDropdownWithSupabaseData(String tableName, String label, String image) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: mainController.fetchData(tableName),
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: sFillColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            _buildBudgetColumn(),
            _buildPriceRow(),
          ],
        ),
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
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Price:',
            style: stdTextStyle(Colors.white, bigFont),
          ),
          Obx(() => mainController.isAutoBuilding.value ? const CircularProgressIndicator() : buildPriceWidget()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: sPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: mainController.saveCurrentBuild,
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
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Obx(
                () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                  mainController.updateSelectedIndex(index);
                },
                isSelected: List.generate(
                  mainController.options.length,
                      (index) => index == mainController.selectedIndex.value,
                ),
                children: mainController.options.map((String label) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 8),
                    child: Text(
                      label,
                      style: stdTextStyle(null, smallFont),
                    ),
                  );
                }).toList(),
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
                    Obx(() => Text(
                      "${mainController.currentSliderValue.value}",
                      style: stdTextStyle(sTextColor, 18.0),
                    )),
                    Obx(
                          () => Slider(
                        inactiveColor: sSecondaryColor,
                        activeColor: sTextColor,
                        thumbColor: sTextColor,
                        value: mainController.currentSliderValue.value,
                        min: 0,
                        max: 75000,
                        divisions: 20,
                        onChanged: (double value) {
                          mainController.updateSliderValue(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Obx(()=>RoundedLoadingButton(
                  width: 60,
                  height: 60,
                  color: sSecondaryColor,
                  successColor: sTextColor,
                  controller: mainController.btnController,
                  onPressed: mainController.doAutoBuild,
                  child: mainController.isAutoBuilding.value ? const CircularProgressIndicator(color: Colors.white,) : const FaIcon(
                    FontAwesomeIcons.screwdriverWrench,
                    color: sTextColor,
                    size: 25,
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double calculateTotalPrice() {
    double totalPrice = mainController.selectedItems.values.fold(0.0, (sum, item) {
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
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Text(
        ' ${mainController.calculateTotalPrice().toStringAsFixed(0)} ₺',
        style: stdTextStyle(sTextColor, bigFont),
      ),
    ));
  }

}
