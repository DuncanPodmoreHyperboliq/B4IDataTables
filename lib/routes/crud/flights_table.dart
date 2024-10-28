import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class Flight {
  final String originCode;
  final String destinationCode;
  final String flightNumber;
  final String departureStatus;
  final String status;
  final String arrivalStatus;
  final String estimatedDeparture;
  final String actualDeparture;
  final String estimatedArrival;
  final String actualArrival;
  final String scheduledDeparture;
  final String scheduledArrival;
  final String currentDepartureDisplayText;
  final String currentArrivalDisplayText;
  final DateTime currentDeparture;
  final DateTime currentArrival;
  final String? departureGate;
  final String? baggageReclaimId;

  Flight({
    required this.originCode,
    required this.destinationCode,
    required this.flightNumber,
    required this.departureStatus,
    required this.status,
    required this.arrivalStatus,
    required this.estimatedDeparture,
    required this.actualDeparture,
    required this.estimatedArrival,
    required this.actualArrival,
    required this.scheduledDeparture,
    required this.scheduledArrival,
    required this.currentDepartureDisplayText,
    required this.currentArrivalDisplayText,
    required this.currentDeparture,
    required this.currentArrival,
    this.departureGate,
    this.baggageReclaimId,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      originCode: json['origin_code'] ?? '',
      destinationCode: json['destination_code'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      departureStatus: json['departure_status'] ?? '',
      status: json['status'] ?? '',
      arrivalStatus: json['arrival_status'] ?? '',
      estimatedDeparture: json['estimated_departure'] ?? '',
      actualDeparture: json['actual_departure'] ?? '',
      estimatedArrival: json['estimated_arrival'] ?? '',
      actualArrival: json['actual_arrival'] ?? '',
      scheduledDeparture: json['scheduled_departure'] ?? '',
      scheduledArrival: json['scheduled_arrival'] ?? '',
      currentDepartureDisplayText: json['current_departure_display_text'] ?? '',
      currentArrivalDisplayText: json['current_arrival_display_text'] ?? '',
      currentDeparture: DateTime.parse(json['current_departure'] ?? DateTime.now().toIso8601String()),
      currentArrival: DateTime.parse(json['current_arrival'] ?? DateTime.now().toIso8601String()),
      departureGate: json['departure_gate'],
      baggageReclaimId: json['baggage_reclaim_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origin_code': originCode,
      'destination_code': destinationCode,
      'flight_number': flightNumber,
      'departure_status': departureStatus,
      'status': status,
      'arrival_status': arrivalStatus,
      'estimated_departure': estimatedDeparture,
      'actual_departure': actualDeparture,
      'estimated_arrival': estimatedArrival,
      'actual_arrival': actualArrival,
      'scheduled_departure': scheduledDeparture,
      'scheduled_arrival': scheduledArrival,
      'currentDeparture_display_text': currentDepartureDisplayText,
      'current_arrival_display_text': currentArrivalDisplayText,
      'current_departure': currentDeparture.toIso8601String(),
      'current_arrival': currentArrival.toIso8601String(),
      'departure_gate': departureGate,
      'baggage_reclaim_id': baggageReclaimId,
    };
  }
}

class FlightTable extends StatefulWidget {
  final double width;
  final double height;

  const FlightTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _FlightTableState createState() => _FlightTableState();
}

class _FlightTableState extends State<FlightTable> {
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
    fetchFlights();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Origin Code',
        field: 'originCode',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Destination Code',
        field: 'destinationCode',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight Number',
        field: 'flightNumber',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Departure Status',
        field: 'departureStatus',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Arrival Status',
        field: 'arrivalStatus',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Estimated Departure',
        field: 'estimatedDeparture',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Actual Departure',
        field: 'actualDeparture',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Estimated Arrival',
        field: 'estimatedArrival',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Actual Arrival',
        field: 'actualArrival',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Scheduled Departure',
        field: 'scheduledDeparture',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Scheduled Arrival',
        field: 'scheduledArrival',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Current Departure Display Text',
        field: 'currentDepartureDisplayText',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Current Arrival Display Text',
        field: 'currentArrivalDisplayText',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Current Departure',
        field: 'currentDeparture',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Current Arrival',
        field: 'currentArrival',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Departure Gate',
        field: 'departureGate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Baggage Reclaim ID',
        field: 'baggageReclaimId',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
      ),
    ];

    // Set default filters for columns
    for (var column in columns) {
      column.setDefaultFilter(const PlutoFilterTypeContains());
    }
  }

  Future<void> fetchFlights({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('flights').select(
        '*',
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

      if (response == null) {
        print('Error fetching flights: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final flight = Flight.fromJson(item);

          return PlutoRow(
            cells: {
              'originCode': PlutoCell(value: flight.originCode),
              'destinationCode': PlutoCell(value: flight.destinationCode),
              'flightNumber': PlutoCell(value: flight.flightNumber),
              'departureStatus': PlutoCell(value: flight.departureStatus),
              'status': PlutoCell(value: flight.status),
              'arrivalStatus': PlutoCell(value: flight.arrivalStatus),
              'estimatedDeparture': PlutoCell(value: flight.estimatedDeparture),
              'actualDeparture': PlutoCell(value: flight.actualDeparture),
              'estimatedArrival': PlutoCell(value: flight.estimatedArrival),
              'actualArrival': PlutoCell(value: flight.actualArrival),
              'scheduledDeparture': PlutoCell(value: flight.scheduledDeparture),
              'scheduledArrival': PlutoCell(value: flight.scheduledArrival),
              'currentDepartureDisplayText':
              PlutoCell(value: flight.currentDepartureDisplayText),
              'currentArrivalDisplayText':
              PlutoCell(value: flight.currentArrivalDisplayText),
              'currentDeparture': PlutoCell(value: flight.currentDeparture),
              'currentArrival': PlutoCell(value: flight.currentArrival),
              'departureGate': PlutoCell(value: flight.departureGate ?? ''),
              'baggageReclaimId': PlutoCell(value: flight.baggageReclaimId ?? ''),
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
      print('Error fetching flights: $e');
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
    final filters = _extractFilters();
    fetchFlights(filters: filters); // Fetch data with applied filters
  }

  Future<void> _editFlight(String flightNumber) async {
    print('Edit flight with Flight Number: $flightNumber');
    // Implement edit functionality
  }

  Future<void> _deleteFlight(String flightNumber) async {
    await SupabaseConfig.client
        .from('flights')
        .delete()
        .eq('flightNumber', flightNumber);
    fetchFlights();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchFlights();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredFlights(Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query = SupabaseConfig.client.from('flights').select('*');

      // Apply filters dynamically
      filters.forEach((field, value) {
        query = query.ilike(field, '%$value%');
      });

      // Fetch data with pagination
      final response = await query
          .range(
        (_currentPage - 1) * _pageSize,
        (_currentPage * _pageSize) - 1,
      )
          .execute();

      if (response == null) {
        print('Error fetching flights: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final flight = Flight.fromJson(item);

          return PlutoRow(
            cells: {
              'originCode': PlutoCell(value: flight.originCode),
              'destinationCode': PlutoCell(value: flight.destinationCode),
              'flightNumber': PlutoCell(value: flight.flightNumber),
              'departureStatus': PlutoCell(value: flight.departureStatus),
              'status': PlutoCell(value: flight.status),
              'arrivalStatus': PlutoCell(value: flight.arrivalStatus),
              'estimatedDeparture': PlutoCell(value: flight.estimatedDeparture),
              'actualDeparture': PlutoCell(value: flight.actualDeparture),
              'estimatedArrival': PlutoCell(value: flight.estimatedArrival),
              'actualArrival': PlutoCell(value: flight.actualArrival),
              'scheduledDeparture': PlutoCell(value: flight.scheduledDeparture),
              'scheduledArrival': PlutoCell(value: flight.scheduledArrival),
              'currentDepartureDisplayText':
              PlutoCell(value: flight.currentDepartureDisplayText),
              'currentArrivalDisplayText':
              PlutoCell(value: flight.currentArrivalDisplayText),
              'currentDeparture': PlutoCell(value: flight.currentDeparture),
              'currentArrival': PlutoCell(value: flight.currentArrival),
              'departureGate': PlutoCell(value: flight.departureGate ?? ''),
              'baggageReclaimId': PlutoCell(value: flight.baggageReclaimId ?? ''),
              'actions': PlutoCell(value: ''),
            },
          );
        }).toList();

        setState(() {
          _stateManager.refRows.clear();
          _stateManager.removeAllRows();
          _stateManager.refRows.addAll(newRows);
        });
      } else {
        print('No data found.');
      }
    } catch (e) {
      print('Error fetching flights: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_totalRecords / _pageSize).ceil();

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


                  // Listen for filter changes and trigger a data fetch
                  _stateManager.addListener(() {
                    _onFilterChanged();
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
            onPressed:
            _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
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
