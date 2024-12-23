import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPageController extends GetxController {

  RxDouble currentSliderValue = 0.0.obs;

  RxInt currentPageIndex = 0.obs;
  RxInt currentPurposeIndex = 0.obs;

  RxMap<String, dynamic> selectedItems = <String, dynamic>{}.obs;

  final SupabaseClient supabase = Supabase.instance.client;


  // Calculate total price
  double calculateTotalPrice() {
    return selectedItems.values.fold(0.0, (sum, item) {
      var avgPrice = item['AvgPrice'];
      if (avgPrice == null || avgPrice == 'N/A') {
        return sum;
      }
      if (avgPrice is String) {
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

}
