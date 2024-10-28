import 'package:b4i_frontend/data/export_to_csv.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePlutoGrid extends StatefulWidget {
  const SupabasePlutoGrid({
    Key? key,
    required this.tableName,
    required this.columnFields,
    required this.columnTitles,
    required this.columnTypes,
    this.joinFields,
    this.width,
    this.height,
    this.enableSearch = true,
    this.enableColumnFiltering = true,
    this.enableSorting = true,
    this.rowsPerPage = 20,
    this.borderRadius = 8,
    this.showExport = true,
  }) : super(key: key);

  final String tableName;
  final String columnFields;
  final String columnTitles;
  final String columnTypes;
  final Map<String, String>? joinFields; // New: Join configuration
  final double? width;
  final double? height;
  final bool enableSearch;
  final bool enableColumnFiltering;
  final bool enableSorting;
  final int rowsPerPage;
  final double borderRadius;
  final bool showExport;

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
  bool _isRowExpanded = false; // Track row expansion state

  @override
  void initState() {
    super.initState();
    _initializeColumns();
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

      return PlutoColumn(
        title: titles[index].trim(),
        field: fields[index].trim(),
        type: type,
        enableFilterMenuItem: widget.enableColumnFiltering,
        enableSorting: widget.enableSorting,
        width: initialWidth,
        minWidth: 80,
        enableContextMenu: true,
        enableDropToResize: true,
      );
    });
  }


  void _toggleRowExpansion(PlutoRow row) {
    // setState(() {
    //   row.setExpanded(!_isRowExpanded);
    //   _isRowExpanded = !_isRowExpanded;
    // });
  }

  Future<PlutoLazyPaginationResponse> _fetch(
      PlutoLazyPaginationRequest request,
      ) async {
    try {
      final supabase = Supabase.instance.client;

      final fields = widget.columnFields.split(',').map((e) => e.trim()).toList();

      // Get the total count of rows
      final countResult = await supabase
          .from(widget.tableName)
          .select('*', const FetchOptions(count: CountOption.exact))
          .limit(1)
          .execute();

      _totalRows = countResult.count ?? 0;

      // Build the query
      final queryBuilder = supabase.from(widget.tableName).select(
          '''
      id, name, price, preset_id,
      PartPresets (id, name)
      '''
      );

      // Apply filters if enabled
      if (widget.enableSearch && request.filterRows.isNotEmpty) {
        final filterMap = FilterHelper.convertRowsToMap(request.filterRows);
        for (var entry in filterMap.entries) {
          for (var filter in entry.value) {
            final filterType = filter.entries.first;
            switch (filterType.key) {
              case 'Contains':
                queryBuilder.ilike(entry.key, '%${filterType.value}%');
                break;
              case 'Equals':
                queryBuilder.eq(entry.key, filterType.value);
                break;
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
                  value = row?[part];
                }

                // Ensure the value is correctly cast for PlutoCell
                if (value is int || value is double || value is String) {
                  return MapEntry(field, PlutoCell(value: value));
                } else {
                  return MapEntry(field, PlutoCell(value: value?.toString() ?? ''));
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
                    onPressed: _isExporting ? null : () => exportTableToCsv(''),
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
