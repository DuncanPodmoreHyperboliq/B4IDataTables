import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class Airports {
  final String airportIcao;
  final String airportName;
  final int? locationId; // Allow locationId to be nullable
  final int airportId;
  final String airportIata;
  final String? locationName; // Add nullable location name for the join

  Airports({
    required this.airportIcao,
    required this.airportName,
    this.locationId, // Nullable field
    required this.airportId,
    required this.airportIata,
    this.locationName, // Nullable field for location name
  });

  factory Airports.fromJson(Map<String, dynamic> json) {
    return Airports(
      airportIcao: json['airport_icao'] ?? '', // Provide a default value
      airportName: json['airport_name'] ?? '', // Provide a default value
      locationId:
      json['location_id'] != null ? json['location_id'] as int : null,
      airportId: json['airport_id'] ?? 0, // Provide a default value
      airportIata: json['airport_iata'] ?? '', // Provide a default value
      locationName: json['locations']
      ?['location_name'], // Handle nested null values
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport_icao': airportIcao,
      'airport_name': airportName,
      'location_id': locationId,
      'airport_id': airportId,
      'airport_iata': airportIata,
      'location_name': locationName,
    };
  }
}

class AirportsTable extends StatefulWidget {
  @override
  _AirportsTableState createState() => _AirportsTableState();
  final double width;
  final double height;

  const AirportsTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);
}

class _AirportsTableState extends State<AirportsTable> {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  late PlutoGridStateManager _stateManager;

  int _currentPage = 1;
  final int _pageSize = 100;
  bool _loading = true;
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    fetchAirports();
  }

  void _initializeColumns() {
    // Create individual columns first
    PlutoColumn idColumn = PlutoColumn(
      title: 'ID',
      field: 'airport_id',
      type: PlutoColumnType.number(),
      enableEditingMode: false,
    );
    idColumn.setDefaultFilter(const PlutoFilterTypeContains());

    PlutoColumn icaoColumn = PlutoColumn(
      title: 'ICAO',
      field: 'airport_icao',
      type: PlutoColumnType.text(),
    );
    icaoColumn.setDefaultFilter(const PlutoFilterTypeContains());

    PlutoColumn iataColumn = PlutoColumn(
      title: 'IATA',
      field: 'airport_iata',
      type: PlutoColumnType.text(),
    );
    iataColumn.setDefaultFilter(const PlutoFilterTypeContains());

    PlutoColumn airportNameColumn = PlutoColumn(
      title: 'Airport Name',
      field: 'airport_name',
      type: PlutoColumnType.text(),
    );
    airportNameColumn.setDefaultFilter(const PlutoFilterTypeContains());

    PlutoColumn locationNameColumn = PlutoColumn(
      title: 'Location Name',
      field: 'location_name',
      type: PlutoColumnType.text(),
    );
    locationNameColumn.setDefaultFilter(const PlutoFilterTypeContains());

    PlutoColumn actionsColumn = PlutoColumn(
      title: 'Actions',
      field: 'actions',
      type: PlutoColumnType.text(),
      enableEditingMode: false,
    );

    // Add the columns to the list
    columns = [
      idColumn,
      icaoColumn,
      iataColumn,
      airportNameColumn,
      locationNameColumn,
      actionsColumn,
    ];
  }

  Future<void> fetchAirports({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('airports').select(
        'airport_id, airport_icao, airport_iata, airport_name, locations(location_name, location_id)',
        const FetchOptions(count: CountOption.exact),
      );

      // Apply filters dynamically
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((field, value) {
          query = query.ilike(field, '%$value%');
        });
      }

      // Fetch data with pagination
      final response = await query
          .range(
        (_currentPage - 1) * _pageSize,
        (_currentPage * _pageSize) - 1,
      )
          .execute();

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final airport = Airports.fromJson(item);
          final locationName = item['locations']?['location_name'] ?? 'Unknown';

          return PlutoRow(
            cells: {
              'airport_id': PlutoCell(value: airport.airportId),
              'airport_icao': PlutoCell(value: airport.airportIcao),
              'airport_iata': PlutoCell(value: airport.airportIata),
              'airport_name': PlutoCell(value: airport.airportName),
              'location_name': PlutoCell(value: locationName),
              'actions': PlutoCell(value: ''),
            },
          );
        }).toList();

        setState(() {
          rows = newRows;
          _totalRecords = response.count ?? 0;
        });
      } else {
        print('No data found.');
        setState(() {
          rows = [];
          _totalRecords = 0;
        });
      }
    } catch (e) {
      print('Error fetching airports: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Helper function to extract active filters
  Map<String, String> _extractFilters() {
    final filters = <String, String>{};

    for (final filterRow in _stateManager.filterRows) {
      String? columnField = filterRow.cells['column']?.value;
      String filterValue = filterRow.cells['value']?.value;

      // If both field and value are valid, add to filters
      if (columnField != null &&
          columnField.isNotEmpty &&
          filterValue.isNotEmpty) {
        filters[columnField] = filterValue;
      }
    }

    return filters;
  }

  void _onFilterChanged() {
    final filters = <String, String>{};
    for (var column in columns) {
      final filter = _stateManager.filteredCellValue(column: column);
      if (filter != null && filter.filterValue.isNotEmpty) {
        filters[column.field] = filter.filterValue;
      }
    }
    fetchAirports(filters: filters); // Fetch data with applied filters
  }

  Future<void> _editAirport(int airportId) async {
    print('Edit airport with ID: $airportId');
  }

  Future<void> _deleteAirport(int airportId) async {
    await SupabaseConfig.client
        .from('airports')
        .delete()
        .eq('airport_id', airportId);
    fetchAirports();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchAirports();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredAirports(Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query = SupabaseConfig.client.from('airports').select(
          'airport_id, airport_icao, airport_iata, airport_name, locations(location_name, location_id)');

      // Apply filters dynamically
      filters.forEach((field, value) {
        query = query.ilike(
            field, '%$value%'); // Apply filters to the correct fields
      });

      // Fetch the filtered data
      final response = await query;

      if (response != null) {
        final List<dynamic> data = response;

        setState(() {
          try {
            _stateManager.refRows.clear(); // Clear current rows
            List<PlutoRow> newRows = data.map<PlutoRow>((item) {
              final airport = Airports.fromJson(item);
              final locationName =
                  item['locations']?['location_name'] ?? 'Unknown';

              return PlutoRow(
                cells: {
                  'airport_id': PlutoCell(value: airport.airportId),
                  'airport_icao': PlutoCell(value: airport.airportIcao),
                  'airport_iata': PlutoCell(value: airport.airportIata),
                  'airport_name': PlutoCell(value: airport.airportName),
                  'location_name': PlutoCell(value: locationName),
                  'actions': PlutoCell(value: ''),
                },
              );
            }).toList();
            print('new rows');
            print(newRows);
            // _stateManager.refRows.clear(); // Clear current rows
            // _stateManager.removeRows(_stateManager.refRows.toList());
            _stateManager.removeAllRows();

            _stateManager.refRows.addAll(newRows);
          } catch (e) {
            print('here 1');
            print(e);
          }
        });
      } else {
        print('No data found.');
      }
    } catch (e) {
      print('Error fetching airports: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_totalRecords / _pageSize).ceil();

    TextEditingController _searchController = TextEditingController();

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  print('null check');
                  print(_stateManager == null);

                  // Listen for filter changes and trigger a data fetch
                  _stateManager.addListener(() {
                    final filters = _extractFilters();
                    _fetchFilteredAirports(
                        filters); // Fetch data with filters
                  });
                },
                configuration: const PlutoGridConfiguration(
                  columnSize: PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.equal,
                  ),
                ),
              ),
            ),
          ),
          _buildPaginationControls(totalPages),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => _onPageChanged(_currentPage - 1)
                : null,
          ),
          Text('Page $_currentPage of $totalPages'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () => _onPageChanged(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}