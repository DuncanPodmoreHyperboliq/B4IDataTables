import 'package:b4i_frontend/routes/crud/flights_table.dart';
import 'package:b4i_frontend/routes/crud/ifs_table.dart';
import 'package:b4i_frontend/routes/crud/master_file_table.dart';
import 'package:b4i_frontend/routes/crud/suppliers_table.dart';
import 'package:b4i_frontend/routes/crud/transactions_table.dart';
import 'package:flutter/material.dart';
import 'package:b4i_frontend/routes/crud/airports_table.dart';
import 'dart:html' as html;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/general_table.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const SupabasePlutoGrid(
      tableName: 'Parts',
      selectQuery: '''
      id, name, price, preset_id,
      PartPresets (id, name)
      ''',
      columnFields:
          'id,name,price,preset_id,PartPresets.name',
      columnTitles: 'ID,Part Name,Price,Preset ID,Preset Name',
      columnTypes: 'number,text,number,number,text',
      joinFields: {
        'PartPresets': 'preset_id',
        // Define the join relation: Parts.preset_id = PartPresets.id
      },
      width: 800,
      height: 600,
      enableSearch: true,
      enableColumnFiltering: true,
      enableSorting: true,
      rowsPerPage: 10,
      borderRadius: 8,
      showExport: true,
    ),
    Center(
        child: MaterialButton(
            onPressed: () => exportTableToCsv('airports'),
            child: Text('Settings Page'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'CRUD'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

Future<void> exportTableToCsv(String tableName) async {
  final response = await Supabase.instance.client.from(tableName).select();

  if (response == null) {
    print('Error fetching data: ');
    return;
  }

  final data = response as List<dynamic>;

  if (data.isEmpty) {
    print('No data found');
    return;
  }

  // Get the column names from the first item
  final columnNames = (data[0] as Map<String, dynamic>).keys.toList();

  // Build the CSV string
  String csv = '';
  csv += columnNames.join(',') + '\n';

  for (var item in data) {
    final row = columnNames.map((col) {
      final value = item[col];
      if (value != null) {
        final escaped = value.toString().replaceAll('"', '""');
        return '"$escaped"';
      } else {
        return '';
      }
    }).join(',');
    csv += row + '\n';
  }

  // Trigger download in the browser
  final bytes = utf8.encode(csv);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');

  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'data.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
