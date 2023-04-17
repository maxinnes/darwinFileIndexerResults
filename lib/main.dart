import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sunburst Chart'),
        ),
        body: SunburstChartWidget(),
      ),
    );
  }
}

class SunburstChartWidget extends StatefulWidget {
  @override
  _SunburstChartWidgetState createState() => _SunburstChartWidgetState();
}

class _SunburstChartWidgetState extends State<SunburstChartWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SunburstData>>(
      future: _fetchSunburstData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SfSunburstChart(
            dataLabelSettings: SunburstDataLabelSettings(isVisible: true),
            series: _getSunburstSeries(snapshot.data!),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  SunburstSeries<SunburstData, String> _getSunburstSeries(
      List<SunburstData> data) {
    return SunburstSeries<SunburstData, String>(
      dataSource: data,
      valueMapper: (SunburstData d, _) => d.value,
      levelMapper: (SunburstData d, _) => d.level,
      idMapper: (SunburstData d, _) => d.id,
      parentIdsMapper: (SunburstData d, _) => d.parentId,
      colorValueMapper: (SunburstData d, _) => d.color,
      dataLabelMapper: (SunburstData d, _) => d.label,
    );
  }

  Future<List<SunburstData>> _fetchSunburstData() async {
    List<SunburstData> sunburstData = [];

    // Use the DatabaseHelper class to fetch data from the SQLite database
    List<Map<String, dynamic>> data = await DatabaseHelper().fetchData();

    // A helper function to find the parent id of a given path
    String findParentId(String path) {
      if (path == '/') return '';
      List<String> parts = path.split('/');
      parts.removeLast();
      return '/' + parts.sublist(1).join('/');
    }

    // Process the data and create SunburstData instances
    for (var row in data) {
      String path = row['path'];
      String id = path;
      String parentId = findParentId(path);
      String label = path.split('/').last;

      // Customize the following code based on your specific requirements
      sunburstData.add(SunburstData(
        id: id,
        parentId: parentId,
        label: label,
        level: path.split('/').length - 1,
        value: row['size'],
        color: row['isDirectory'] == 1 ? Colors.blue : Colors.orange,
      ));
    }

    // Add root directory as the central node
    sunburstData.add(SunburstData(
      id: '/',
      parentId: '',
      label: '/',
      level: 0,
      value: 0,
      color: Colors.red,
    ));

    return sunburstData;
  }
}

class SunburstData {
  SunburstData({
    required this.id,
    required this.parentId,
    required this.label,
    required this.level,
    required this.value,
    required this.color,
  });

  String id;
  String parentId;
  String label;
  int level;
  num value;
  Color color;
}
