
import 'dart:html' as html;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

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