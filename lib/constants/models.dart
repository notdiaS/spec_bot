import 'dart:convert';

class BuildModel {
  final Map<String, dynamic> cpu;
  final Map<String, dynamic> motherboard;
  final Map<String, dynamic> gpu;
  final Map<String, dynamic> ram;
  final Map<String, dynamic> psu;

  BuildModel({
    required this.cpu,
    required this.motherboard,
    required this.gpu,
    required this.ram,
    required this.psu,
  });

  Map<String, dynamic> toJson() {
    return {
      'cpu': jsonEncode(cpu),
      'motherboard': jsonEncode(motherboard),
      'gpu': jsonEncode(gpu),
      'ram': jsonEncode(ram),
      'psu': jsonEncode(psu),
    };
  }

  factory BuildModel.fromJson(Map<String, dynamic> json) {
    return BuildModel(
      cpu: jsonDecode(json['cpu']),
      motherboard: jsonDecode(json['motherboard']),
      gpu: jsonDecode(json['gpu']),
      ram: jsonDecode(json['ram']),
      psu: jsonDecode(json['psu']),
    );
  }
}
