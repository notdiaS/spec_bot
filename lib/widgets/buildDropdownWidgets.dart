// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:bordered_text/bordered_text.dart';
// import 'package:easy_url_launcher/easy_url_launcher.dart';
// import 'package:spec_bot/constants/colors.dart';
//
// import 'package:flutter/material.dart';
// import 'path_to_shared_colors/colors.dart'; // Import your shared colors file.
//
// Padding buildDropdownSearch({
//   required List<Map<String, dynamic>> items,
//   required String hwType,
//   required String icnImage,
//   required Map<String, dynamic> selectedItems,
//   required Function(Map<String, dynamic>?) onChanged,
//   required TextStyle Function(Color, double) stdTextStyle,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//     child: DropdownSearch<Map<String, dynamic>>(
//       items: items,
//       onChanged: onChanged,
//       selectedItem: selectedItems[hwType],
//       dropdownBuilder: (context, selectedItem) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: (selectedItem == null)
//               ? ListTile(
//             contentPadding: const EdgeInsets.only(left: 8),
//             title: Text("No item selected",
//                 style: stdTextStyle(sTextColor, 13.0)),
//           )
//               : ListTile(
//             contentPadding: const EdgeInsets.all(0),
//             title: Padding(
//               padding: const EdgeInsets.only(left: 10.0),
//               child: Row(
//                 children: [
//                   Text(
//                     selectedItem['Model']?.toString().toUpperCase() ??
//                         'No model available',
//                     style: stdTextStyle(sThirdColor, 14.0),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0, top: 5),
//                     child: Text(
//                         ' 💵 ${(double.tryParse(selectedItem['AvgPrice'] ?? '0')?.toStringAsFixed(2) ?? '0.00')}₺',
//                         style: stdTextStyle(sGreenColor, 14.0)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       popupProps: const PopupProps.menu(
//         constraints: BoxConstraints(maxHeight: 300),
//         searchFieldProps: TextFieldProps(
//           cursorHeight: 20,
//           cursorColor: sSecondaryColor,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: sFillColor,
//             border: OutlineInputBorder(
//               borderSide: BorderSide(color: sTextColor),
//               borderRadius: BorderRadius.all(Radius.circular(15)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: sSecondaryColor),
//               borderRadius: BorderRadius.all(Radius.circular(15)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: sTextColor),
//               borderRadius: BorderRadius.all(Radius.circular(15)),
//             ),
//           ),
//         ),
//         showSelectedItems: true,
//         showSearchBox: true,
//       ),
//       dropdownDecoratorProps: DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           filled: true,
//           fillColor: sFillColor,
//           prefixIcon: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: Image.asset(icnImage, width: 30, height: 30),
//           ),
//           label: Text(
//             hwType,
//             style: const TextStyle(
//                 fontSize: 25, color: sTextColor, fontWeight: FontWeight.w900),
//           ),
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           border: OutlineInputBorder(
//             borderSide: const BorderSide(color: sSecondaryColor),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(color: sThirdColor),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(color: sTextColor),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//       compareFn:
//           (Map<String, dynamic> item, Map<String, dynamic>? selectedItem) {
//         return item['Model'] == selectedItem!['Model'];
//       },
//     ),
//   );
// }
//
// Widget buildDropdownWithSupabaseData({
//   required String tableName,
//   required String label,
//   required String image,
//   required Future<List<Map<String, dynamic>>> Function(String) fetchData,
//   required Map<String, dynamic> selectedItems,
//   required Function(Map<String, dynamic>?) onChanged,
//   required TextStyle Function(Color, double) stdTextStyle,
// }) {
//   return FutureBuilder<List<Map<String, dynamic>>>(
//     future: fetchData(tableName),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       } else if (snapshot.hasError) {
//         return Text('Error: ${snapshot.error}',
//             style: const TextStyle(color: Colors.white));
//       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//         return const Text('No data available');
//       } else {
//         return buildDropdownSearch(
//           items: snapshot.data!,
//           hwType: label,
//           icnImage: image,
//           selectedItems: selectedItems,
//           onChanged: onChanged,
//           stdTextStyle: stdTextStyle,
//         );
//       }
//     },
//   );
// }
//
//
