import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

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

class SupabasePlutoGrid extends StatefulWidget {
  const SupabasePlutoGrid({
    Key? key,
    required this.tableName,
    required this.columnFields,
    required this.columnTitles,
    required this.columnTypes,
    required this.selectQuery,
    this.joinFieldsText,
    this.width,
    this.height,
    this.enableSearch = true,
    this.enableColumnFiltering = true,
    this.enableSorting = true,
    this.rowsPerPage = 20,
    this.borderRadius = 8,
    this.showExport = true,
    this.columnColorsText, // New: Column colors
  }) : super(key: key);

  final String tableName;
  final String columnFields;
  final String columnTitles;
  final String columnTypes;
  final String selectQuery;
  Map<String, String>? get joinFields {
    return _parseJoinFields(joinFieldsText);
  }
  final String? joinFieldsText;
  final double? width;
  final double? height;
  final bool enableSearch;
  final bool enableColumnFiltering;
  final bool enableSorting;
  final int rowsPerPage;
  final double borderRadius;
  final bool showExport;
  Map<String, Color>? get columnColors {
    return _parseColumnColors(columnColorsText);
  } // New: Column colors
  final String? columnColorsText; // New: Column colors

  // Helper to parse joinFields string
  Map<String, String> _parseJoinFields(String? joinFields) {
    if (joinFields == null || joinFields.isEmpty) return {};
    try {
      final decoded = json.decode(joinFields) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('Error parsing joinFields: $e');
      return {};
    }
  }

  // Helper to parse columnColors string
  Map<String, Color> _parseColumnColors(String? columnColors) {
    if (columnColors == null || columnColors.isEmpty) return {};
    try {
      final decoded = json.decode(columnColors) as Map<String, dynamic>;
      return decoded.map((key, value) {
        return MapEntry(key, _hexToColor(value.toString()));
      });
    } catch (e) {
      debugPrint('Error parsing columnColors: $e');
      return {};
    }
  }

  // Helper to convert hex string to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add alpha if not present
    return Color(int.parse(hex, radix: 16));
  }

  @override
  State<SupabasePlutoGrid> createState() => _SupabasePlutoGridState();
}

class _SupabasePlutoGridState extends State<SupabasePlutoGrid> {
  late List<PlutoColumn> _columns;
  List<PlutoRow> _rows = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String _errorMessage = '';
  late final PlutoGridStateManager _stateManager;
  int _totalRows = 0;
  late Map<String, String> _fieldTypeMap;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _initializeFieldTypeMap();
  }

  void _initializeFieldTypeMap() {
    final fields = widget.columnFields.split(',');
    final types = widget.columnTypes.split(',');

    if (fields.length != types.length) {
      throw Exception(
          'Column fields and types must have the same number of items');
    }

    _fieldTypeMap = {
      for (int i = 0; i < fields.length; i++)
        fields[i].trim(): types[i].trim().toLowerCase(),
    };
  }

  void _initializeColumns() {
    final fields = widget.columnFields.split(',');
    final titles = widget.columnTitles.split(',');
    final types = widget.columnTypes.split(',');

    if (titles.length != fields.length || types.length != fields.length) {
      throw Exception(
          'Column fields, titles, and types must have the same number of items');
    }

    final initialWidth = (widget.width ?? 800) / fields.length;

    _columns = List.generate(fields.length, (index) {
      PlutoColumnType type;
      switch (types[index].trim().toLowerCase()) {
        case 'number':
          type = PlutoColumnType.number();
          break;
        case 'date':
          type = PlutoColumnType.date();
          break;
        case 'select':
          type = PlutoColumnType.select(['']);
          break;
        default:
          type = PlutoColumnType.text();
      }

      // Check if the current column has a specified color
      final field = fields[index].trim();
      final color =
          widget.columnColors != null ? widget.columnColors![field] : null;

      return PlutoColumn(
        title: titles[index].trim(),
        field: field,
        type: type,
        enableFilterMenuItem: widget.enableColumnFiltering,
        enableSorting: widget.enableSorting,
        width: initialWidth,
        minWidth: 80,
        enableContextMenu: true,
        enableDropToResize: true,
        // Apply a custom renderer if a color is specified
        renderer: color != null
            ? (rendererContext) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: color.withOpacity(0.2), // Light background color
                  child: Text(
                    rendererContext.cell.value?.toString() ?? '',
                    style: TextStyle(
                      color: color, // Text color matching the highlight
                    ),
                  ),
                );
              }
            : null,
        // Set header text style if color is specified
        // titleTextStyle: color != null
        //     ? TextStyle(
        //   color: color,
        //   fontWeight: FontWeight.bold,
        // )
        //     : null,
      );
    });
  }

  void _toggleRowExpansion(PlutoRow row) {
    // Future implementation if needed
  }

  Future<PlutoLazyPaginationResponse> _fetch(
    PlutoLazyPaginationRequest request,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final fields =
          widget.columnFields.split(',').map((e) => e.trim()).toList();

      // Get the total count of rows
      final countResult = await supabase
          .from(widget.tableName)
          .select('*', const FetchOptions(count: CountOption.exact))
          .limit(1)
          .execute();

      _totalRows = countResult.count ?? 0;

      // Build the query
      final queryBuilder =
          supabase.from(widget.tableName).select(widget.selectQuery);

      // Apply filters if enabled
      if (widget.enableSearch && request.filterRows.isNotEmpty) {
        final filterMap = FilterHelper.convertRowsToMap(request.filterRows);
        for (var entry in filterMap.entries) {
          final field = entry.key;
          final type = _fieldTypeMap[field];

          for (var filter in entry.value) {
            final filterType = filter.entries.first;
            final filterValue = filterType.value;

            if (type == null) continue; // Skip if type is unknown

            switch (type) {
              case 'text':
                switch (filterType.key) {
                  case 'Contains':
                    queryBuilder.ilike(field, '%$filterValue%');
                    break;
                  case 'Equals':
                    queryBuilder.eq(field, filterValue);
                    break;
                  // Add more text-based filters if needed
                }
                break;

              case 'number':
                switch (filterType.key) {
                  case 'Equals':
                    queryBuilder.eq(
                        field, num.tryParse(filterValue) ?? filterValue);
                    break;
                  case 'Greater than':
                    queryBuilder.gt(
                        field, num.tryParse(filterValue) ?? filterValue);
                    break;
                  case 'Less than':
                    queryBuilder.lt(
                        field, num.tryParse(filterValue) ?? filterValue);
                    break;
                  // Add more numeric-based filters if needed
                }
                break;

              case 'date':
                switch (filterType.key) {
                  case 'Equals':
                    queryBuilder.eq(field, filterValue);
                    break;
                  case 'Before':
                    queryBuilder.lte(field, filterValue);
                    break;
                  case 'After':
                    queryBuilder.gte(field, filterValue);
                    break;
                  // Add more date-based filters if needed
                }
                break;

              // Handle other types as necessary
            }
          }
        }
      }

      // Calculate pagination range
      final start = (request.page - 1) * widget.rowsPerPage;
      final end = start + widget.rowsPerPage - 1;

      // Add sorting if enabled
      if (widget.enableSorting &&
          request.sortColumn != null &&
          !request.sortColumn!.sort.isNone) {
        queryBuilder.order(
          request.sortColumn!.field,
          ascending: request.sortColumn!.sort == PlutoColumnSort.ascending,
        );
      }

      // Execute query with pagination
      final response = await queryBuilder.range(start, end).execute();
      final data = response.data as List<dynamic>;
      // print(data); // Debug print to verify the data structure

      // Convert the response to PlutoRows
      final rows = data.map<PlutoRow>((row) {
        return PlutoRow(
          cells: Map.fromEntries(
            fields.map((field) {
              try {
                // Handle nested fields and ensure correct type casting
                dynamic value = row;
                final parts = field.split('.');

                // Traverse nested data if necessary
                for (var part in parts) {
                  value = value?[part];
                }

                // Ensure the value is correctly cast for PlutoCell
                if (value is int || value is double || value is String) {
                  return MapEntry(field, PlutoCell(value: value));
                } else if (value is DateTime) {
                  return MapEntry(
                      field, PlutoCell(value: value.toIso8601String()));
                } else {
                  return MapEntry(
                      field, PlutoCell(value: value?.toString() ?? ''));
                }
              } catch (e) {
                print('Error processing field "$field": $e');
                return MapEntry(field, PlutoCell(value: ''));
              }
            }),
          ),
        );
      }).toList();

      return PlutoLazyPaginationResponse(
        totalPage: (_totalRows / widget.rowsPerPage).ceil(),
        rows: rows,
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error loading data: ${e.toString()}');
      return PlutoLazyPaginationResponse(
        totalPage: 0,
        rows: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Column(
        children: [
          if (widget.showExport)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _isExporting ? null : () => exportTableToCsv(widget.tableName),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: PlutoGrid(
              columns: _columns,
              rows: _rows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                _stateManager = event.stateManager;
                _stateManager.setShowColumnFilter(widget.enableColumnFiltering);
              },
              createFooter: (stateManager) {
                return PlutoLazyPagination(
                  fetch: _fetch,
                  stateManager: stateManager,
                  initialFetch: true,
                  fetchWithFiltering: widget.enableSearch,
                  fetchWithSorting: widget.enableSorting,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
