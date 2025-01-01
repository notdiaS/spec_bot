import 'dart:convert';

class ComponentModel {
  final String model;
  final String avgPrice;
  final String url;

  ComponentModel({
    required this.model,
    required this.avgPrice,
    required this.url,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      model: json['Model'],
      avgPrice: json['AvgPrice'],
      url: json['URL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Model': model,
      'AvgPrice': avgPrice,
      'URL': url,
    };
  }
}

class BuildModel {
  final ComponentModel cpu;
  final ComponentModel motherboard;
  final ComponentModel gpu;
  final ComponentModel ram;
  final ComponentModel psu;

  BuildModel({
    required this.cpu,
    required this.motherboard,
    required this.gpu,
    required this.ram,
    required this.psu,
  });

  factory BuildModel.fromJson(Map<String, dynamic> json) {
    return BuildModel(
      cpu: ComponentModel.fromJson(jsonDecode(json['cpu'])),
      motherboard: ComponentModel.fromJson(jsonDecode(json['motherboard'])),
      gpu: ComponentModel.fromJson(jsonDecode(json['gpu'])),
      ram: ComponentModel.fromJson(jsonDecode(json['ram'])),
      psu: ComponentModel.fromJson(jsonDecode(json['psu'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu': jsonEncode(cpu.toJson()),
      'motherboard': jsonEncode(motherboard.toJson()),
      'gpu': jsonEncode(gpu.toJson()),
      'ram': jsonEncode(ram.toJson()),
      'psu': jsonEncode(psu.toJson()),
    };
  }

}


