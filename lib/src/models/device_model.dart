class DeviceModel {
  final String id;
  final String name;

  DeviceModel({required this.id, required this.name});

  factory DeviceModel.fromMap(String id, Map data) {
    return DeviceModel(
      id: id,
      name: data['name'] ?? id.replaceAll('_', ' ').toUpperCase(),
    );
  }
}
