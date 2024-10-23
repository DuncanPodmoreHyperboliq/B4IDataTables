import 'dart:convert';
import 'dart:typed_data' show Uint8List;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FFUploadedFile {
  const FFUploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  @override
  String toString() =>
      'FFUploadedFile(name: $name, bytes: ${bytes?.length ?? 0}, height: $height, width: $width, blurHash: $blurHash,)';

  String serialize() => jsonEncode(
    {
      'name': name,
      'bytes': bytes,
      'height': height,
      'width': width,
      'blurHash': blurHash,
    },
  );

  static FFUploadedFile deserialize(String val) {
    final serializedData = jsonDecode(val) as Map<String, dynamic>;
    final data = {
      'name': serializedData['name'] ?? '',
      'bytes': serializedData['bytes'] ?? Uint8List.fromList([]),
      'height': serializedData['height'],
      'width': serializedData['width'],
      'blurHash': serializedData['blurHash'],
    };
    return FFUploadedFile(
      name: data['name'] as String,
      bytes: Uint8List.fromList(data['bytes'].cast<int>().toList()),
      height: data['height'] as double?,
      width: data['width'] as double?,
      blurHash: data['blurHash'] as String?,
    );
  }

  @override
  int get hashCode => Object.hash(
    name,
    bytes,
    height,
    width,
    blurHash,
  );

  @override
  bool operator ==(other) =>
      other is FFUploadedFile &&
          name == other.name &&
          bytes == other.bytes &&
          height == other.height &&
          width == other.width &&
          blurHash == other.blurHash;
}


// Custom Action: ImportCsvToSupabase
// Parameters:
// - FFUploadedFile file


Future<void> ImportCsvToSupabase(FFUploadedFile file, String tableName) async {
  try {
    if (file.bytes == null) return;
    // Get bytes from FFUploadedFile
    final Uint8List bytes = file.bytes ?? Uint8List(0);

    if (bytes == null) {
      print('No file data found.');
      return;
    }

    // Decode bytes to String
    final String csvString = utf8.decode(bytes);

    // Parse CSV
    List<List<dynamic>> csvTable =
    const CsvToListConverter().convert(csvString);

    if (csvTable.isEmpty) {
      print('CSV file is empty.');
      return;
    }

    // Assuming first row is header
    List<String> headers = csvTable.first.map((e) => e.toString()).toList();

    // Remove header row
    csvTable.removeAt(0);

    // Prepare data for insertion
    List<Map<String, dynamic>> data = [];
    for (var row in csvTable) {
      Map<String, dynamic> rowData = {};
      for (int i = 0; i < headers.length; i++) {
        rowData[headers[i]] = row[i];
      }
      data.add(rowData);
    }

    // Get Supabase client
    final supabase = Supabase.instance.client;

    // Insert data into Supabase table (replace 'your_table_name' with your actual table name)
    final response = await supabase.from('your_table_name').insert(data);

    if (response.error != null) {
      // Handle error
      print('Error inserting data: ${response.error!.message}');
    } else {
      // Success
      print('Data inserted successfully');
    }
  } catch (e) {
    print('Error importing CSV: $e');
  }
}
