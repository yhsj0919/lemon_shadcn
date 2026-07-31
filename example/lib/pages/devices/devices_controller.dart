import 'package:flutter/widgets.dart';

import 'device.dart';

enum DeviceStatusFilter {
  all,
  online,
  offline;

  String get label => switch (this) {
    DeviceStatusFilter.all => '全部',
    DeviceStatusFilter.online => '在线',
    DeviceStatusFilter.offline => '离线',
  };
}

/// Demo-only list state. Mirrors palsmon_saas DevicesController without lemon_x.
final class DevicesController extends ChangeNotifier {
  DevicesController() {
    _devices = List<Device>.of(_demoDevices);
    _selectedId = _devices.first.id;
  }

  late final List<Device> _devices;
  String _keyword = '';
  DeviceStatusFilter _statusFilter = DeviceStatusFilter.all;
  String? _regionFilter;
  String? _customerFilter;
  int? _selectedId;
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Device> get devices => List.unmodifiable(_devices);

  String get keyword => _keyword;

  DeviceStatusFilter get statusFilter => _statusFilter;

  String? get regionFilter => _regionFilter;

  String? get customerFilter => _customerFilter;

  int? get selectedId => _selectedId;

  bool get hasFormFilter => _regionFilter != null || _customerFilter != null;

  bool get hasActiveFilter => hasFormFilter || _keyword.trim().isNotEmpty;

  List<String> get regionOptions {
    final values = <String>{};
    for (final device in _devices) {
      final region = device.region?.trim();
      if (region != null && region.isNotEmpty) values.add(region);
    }
    return values.toList()..sort();
  }

  List<String> get customerOptions {
    final values = <String>{};
    for (final device in _devices) {
      final customer = device.customerName?.trim();
      if (customer != null && customer.isNotEmpty) values.add(customer);
    }
    return values.toList()..sort();
  }

  int countFor(DeviceStatusFilter filter) {
    return _devices.where((device) {
      return switch (filter) {
        DeviceStatusFilter.all => true,
        DeviceStatusFilter.online => device.status.isOnline,
        DeviceStatusFilter.offline => !device.status.isOnline,
      };
    }).length;
  }

  List<Device> get filteredDevices {
    final query = _keyword.trim().toLowerCase();
    final status = _statusFilter;
    final region = _regionFilter;
    final customer = _customerFilter;

    return _devices
        .where((device) {
          final matchStatus = switch (status) {
            DeviceStatusFilter.all => true,
            DeviceStatusFilter.online => device.status.isOnline,
            DeviceStatusFilter.offline => !device.status.isOnline,
          };
          if (!matchStatus) return false;
          if (region != null && device.region != region) return false;
          if (customer != null && device.customerName != customer) return false;
          if (query.isEmpty) return true;
          return device.name.toLowerCase().contains(query) ||
              device.sn.toLowerCase().contains(query) ||
              (device.customerName?.toLowerCase().contains(query) ?? false) ||
              (device.location?.toLowerCase().contains(query) ?? false) ||
              (device.address?.toLowerCase().contains(query) ?? false);
        })
        .toList(growable: false);
  }

  Device? get selectedDevice {
    final id = _selectedId;
    if (id == null) return null;
    for (final device in _devices) {
      if (device.id == id) return device;
    }
    return null;
  }

  void setKeyword(String value) {
    _keyword = value;
    notifyListeners();
  }

  void setStatusFilter(DeviceStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setRegionFilter(String? value) {
    _regionFilter = value;
    notifyListeners();
  }

  void setCustomerFilter(String? value) {
    _customerFilter = value;
    notifyListeners();
  }

  void clearFormFilters() {
    _regionFilter = null;
    _customerFilter = null;
    notifyListeners();
  }

  void clearFilters() {
    clearFormFilters();
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }
    _keyword = '';
    notifyListeners();
  }

  void selectDevice(int id) {
    _selectedId = id;
    notifyListeners();
  }

  void addDevice(Device device) {
    _devices.insert(0, device);
    _selectedId = device.id;
    notifyListeners();
  }
}

const _demoDevices = [
  Device(
    id: 1,
    name: '世贸国际',
    sn: 'LCD-2024-0018',
    status: DeviceStatus.online,
    resolution: '1920×1080',
    customerName: '世贸物业',
    location: 'C座大厅西侧',
    locationTags: ['C座', '大厅西侧'],
    region: '广州天河',
    address: '广州市天河区林和西路 9 号',
    floor: '1F',
    mediaPosition: '大厅主通道',
    dimensions: '55 寸',
    operatingHours: '08:00 – 22:00',
    totalUptime: '1,286 小时',
    ip: '192.168.10.18',
    lastSeenAt: '2026-07-31 11:42',
    controlId: 'CTRL-8812',
    createdAt: '2024-03-12',
    onlineDuration: '32 天 6 小时',
    voltage: '220V',
    power: '86W',
    os: 'Android 12',
    connection: '有线 / MQTT',
    temperature: '41℃',
    brightness: '78%',
    aqi: '32',
    co2: '620 ppm',
    humidity: '48%',
    managers: ['世贸物业', 'Palsmon 运维'],
  ),
  Device(
    id: 2,
    name: '星河中庭 A1',
    sn: 'LCD-2024-0042',
    status: DeviceStatus.online,
    resolution: '1080×1920',
    customerName: '星河商场',
    location: '一楼中庭',
    locationTags: ['一楼', '中庭'],
    region: '广州番禺',
    address: '广州市番禺区汉溪大道东 383 号',
    floor: '1F',
    mediaPosition: '中庭立柱旁',
    dimensions: '65 寸竖屏',
    operatingHours: '10:00 – 22:00',
    totalUptime: '980 小时',
    ip: '192.168.10.42',
    lastSeenAt: '2026-07-31 11:40',
    controlId: 'CTRL-9041',
    createdAt: '2024-06-08',
    onlineDuration: '18 天 2 小时',
    voltage: '220V',
    power: '92W',
    os: 'Android 13',
    connection: '有线 / MQTT',
    temperature: '38℃',
    brightness: '82%',
    aqi: '28',
    co2: '540 ppm',
    humidity: '52%',
    managers: ['星河商场'],
  ),
  Device(
    id: 3,
    name: '青禾正门竖屏',
    sn: 'LCD-2023-0110',
    status: DeviceStatus.offline,
    resolution: '1080×1920',
    customerName: '青禾超市',
    location: '正门入口',
    locationTags: ['正门'],
    region: '佛山禅城',
    address: '佛山市禅城区季华一路 28 号',
    floor: '1F',
    mediaPosition: '入口右侧',
    dimensions: '49 寸竖屏',
    operatingHours: '07:30 – 23:00',
    totalUptime: '2,104 小时',
    ip: '10.0.3.11',
    lastSeenAt: '2026-07-30 22:15',
    controlId: 'CTRL-3301',
    createdAt: '2023-11-02',
    onlineDuration: '—',
    voltage: '220V',
    power: '74W',
    os: 'Android 11',
    connection: 'Wi-Fi / MQTT',
    temperature: '—',
    brightness: '—',
    aqi: '—',
    co2: '—',
    humidity: '—',
    managers: ['青禾超市'],
  ),
  Device(
    id: 4,
    name: '青禾收银联屏',
    sn: 'LCD-2025-0007',
    status: DeviceStatus.fault,
    resolution: '1920×1080',
    customerName: '青禾超市',
    location: '收银区',
    locationTags: ['收银区'],
    region: '佛山禅城',
    address: '佛山市禅城区季华一路 28 号',
    floor: '1F',
    mediaPosition: '收银台上方',
    dimensions: '43 寸',
    operatingHours: '07:30 – 23:00',
    totalUptime: '416 小时',
    ip: '10.0.3.27',
    lastSeenAt: '2026-07-31 09:08',
    controlId: 'CTRL-3307',
    createdAt: '2025-01-19',
    onlineDuration: '—',
    voltage: '异常',
    power: '—',
    os: 'Android 13',
    connection: '有线 / MQTT',
    temperature: '62℃',
    brightness: '—',
    aqi: '—',
    co2: '—',
    humidity: '—',
    managers: ['青禾超市', 'Palsmon 运维'],
  ),
  Device(
    id: 5,
    name: '城际候车大厅',
    sn: 'LCD-2024-0088',
    status: DeviceStatus.online,
    resolution: '3840×2160',
    customerName: '城际客运站',
    location: '候车大厅',
    locationTags: ['候车大厅', '主屏'],
    region: '广州白云',
    address: '广州市白云区机场高速辅路',
    floor: '2F',
    mediaPosition: '检票口对面',
    dimensions: '2×2 拼接',
    operatingHours: '05:30 – 24:00',
    totalUptime: '3,560 小时',
    ip: '172.16.2.8',
    lastSeenAt: '2026-07-31 11:45',
    controlId: 'CTRL-2208',
    createdAt: '2024-02-28',
    onlineDuration: '45 天 11 小时',
    voltage: '220V',
    power: '310W',
    os: 'Android 12',
    connection: '有线 / MQTT',
    temperature: '44℃',
    brightness: '90%',
    aqi: '41',
    co2: '710 ppm',
    humidity: '55%',
    managers: ['城际客运站'],
  ),
  Device(
    id: 6,
    name: '城际餐饮区 F1',
    sn: 'LCD-2022-0301',
    status: DeviceStatus.offline,
    resolution: '1920×1080',
    customerName: '城际客运站',
    location: '三楼餐饮区',
    locationTags: ['三楼', '餐饮区'],
    region: '广州白云',
    address: '广州市白云区机场高速辅路',
    floor: '3F',
    mediaPosition: '餐饮中岛',
    dimensions: '55 寸',
    operatingHours: '08:00 – 21:00',
    totalUptime: '5,120 小时',
    ip: '172.16.2.31',
    lastSeenAt: '2026-07-29 18:20',
    controlId: 'CTRL-2231',
    createdAt: '2022-09-15',
    onlineDuration: '—',
    voltage: '220V',
    power: '88W',
    os: 'Android 10',
    connection: '有线 / MQTT',
    temperature: '—',
    brightness: '—',
    aqi: '—',
    co2: '—',
    humidity: '—',
    managers: ['城际客运站'],
  ),
];
