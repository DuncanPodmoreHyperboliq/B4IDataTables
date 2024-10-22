import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      originCode: json['originCode'] ?? '',
      destinationCode: json['destinationCode'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      departureStatus: json['departureStatus'] ?? '',
      status: json['status'] ?? '',
      arrivalStatus: json['arrivalStatus'] ?? '',
      estimatedDeparture: json['estimatedDeparture'] ?? '',
      actualDeparture: json['actualDeparture'] ?? '',
      estimatedArrival: json['estimatedArrival'] ?? '',
      actualArrival: json['actualArrival'] ?? '',
      scheduledDeparture: json['scheduledDeparture'] ?? '',
      scheduledArrival: json['scheduledArrival'] ?? '',
      currentDepartureDisplayText: json['currentDepartureDisplayText'] ?? '',
      currentArrivalDisplayText: json['currentArrivalDisplayText'] ?? '',
      currentDeparture: DateTime.parse(json['currentDeparture'] ?? DateTime.now().toIso8601String()),
      currentArrival: DateTime.parse(json['currentArrival'] ?? DateTime.now().toIso8601String()),
      departureGate: json['departureGate'],
      baggageReclaimId: json['baggageReclaimId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originCode': originCode,
      'destinationCode': destinationCode,
      'flightNumber': flightNumber,
      'departureStatus': departureStatus,
      'status': status,
      'arrivalStatus': arrivalStatus,
      'estimatedDeparture': estimatedDeparture,
      'actualDeparture': actualDeparture,
      'estimatedArrival': estimatedArrival,
      'actualArrival': actualArrival,
      'scheduledDeparture': scheduledDeparture,
      'scheduledArrival': scheduledArrival,
      'currentDepartureDisplayText': currentDepartureDisplayText,
      'currentArrivalDisplayText': currentArrivalDisplayText,
      'currentDeparture': currentDeparture.toIso8601String(),
      'currentArrival': currentArrival.toIso8601String(),
      'departureGate': departureGate,
      'baggageReclaimId': baggageReclaimId,
    };
  }
}

class FlightsTable extends StatefulWidget {
  final double width;
  final double height;

  const FlightsTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _FlightsTableState createState() => _FlightsTableState();
}

class _FlightsTableState extends State<FlightsTable> {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  List<PlutoRow> filteredRows = [];
  late PlutoGridStateManager _stateManager;

  int _currentPage = 1;
  final int _pageSize = 10;
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
        title: 'Flight Number',
        field: 'flightNumber',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Origin',
        field: 'originCode',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Destination',
        field: 'destinationCode',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Departure Status',
        field: 'departureStatus',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Arrival Status',
        field: 'arrivalStatus',
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
        title: 'Estimated Departure',
        field: 'estimatedDeparture',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Estimated Arrival',
        field: 'estimatedArrival',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Actual Departure',
        field: 'actualDeparture',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Actual Arrival',
        field: 'actualArrival',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Departure Gate',
        field: 'departureGate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Baggage Reclaim',
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

  Future<void> fetchFlights() async {
    try {
      setState(() => _loading = true);

      final response = await http.get(Uri.parse('https://n8n.morne.me/webhook/flights/day'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final flight = Flight.fromJson(item);

          return PlutoRow(
            cells: {
              'flightNumber': PlutoCell(value: flight.flightNumber),
              'originCode': PlutoCell(value: flight.originCode),
              'destinationCode': PlutoCell(value: flight.destinationCode),
              'departureStatus': PlutoCell(value: flight.departureStatus),
              'arrivalStatus': PlutoCell(value: flight.arrivalStatus),
              'scheduledDeparture': PlutoCell(value: flight.scheduledDeparture),
              'scheduledArrival': PlutoCell(value: flight.scheduledArrival),
              'estimatedDeparture': PlutoCell(value: flight.estimatedDeparture),
              'estimatedArrival': PlutoCell(value: flight.estimatedArrival),
              'actualDeparture': PlutoCell(value: flight.actualDeparture),
              'actualArrival': PlutoCell(value: flight.actualArrival),
              'departureGate': PlutoCell(value: flight.departureGate ?? ''),
              'baggageReclaimId': PlutoCell(value: flight.baggageReclaimId ?? ''),
              'actions': PlutoCell(value: ''),
            },
          );
        }).toList();

        setState(() {
          rows = newRows;
          filteredRows = List<PlutoRow>.from(rows);
          _totalRecords = rows.length;
        });
      } else {
        print('Failed to load flights data.');
      }
    } catch (e) {
      print('Error fetching flights: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    final filters = _stateManager.filterRows;
    if (filters.isEmpty) {
      setState(() {
        filteredRows = List<PlutoRow>.from(rows);
        _totalRecords = filteredRows.length;
        _currentPage = 1;
      });
      return;
    }

    setState(() {
      filteredRows = rows.where((row) {
        bool matches = true;
        for (final filter in filters) {
          final columnField = filter.cells['column']?.value?.field;
          final filterType = filter.cells['filterType']?.value;
          final filterValue = filter.cells['value']?.value;

          final cellValue = row.cells[columnField]?.value?.toString() ?? '';

          if (filterType is PlutoFilterTypeContains) {
            matches &= cellValue.toLowerCase().contains(filterValue.toLowerCase());
          } else if (filterType is PlutoFilterTypeEquals) {
            matches &= cellValue.toLowerCase() == filterValue.toLowerCase();
          }
          // Implement other filter types as needed
        }
        return matches;
      }).toList();
      _totalRecords = filteredRows.length;
      _currentPage = 1;
    });
  }

  void _onFilterChanged() {
    _applyFilters();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
  }

  List<PlutoRow> _getCurrentPageRows() {
    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return filteredRows.sublist(
      start,
      end > filteredRows.length ? filteredRows.length : end,
    );
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
                rows: _getCurrentPageRows(),
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;

                  // Listen for filter changes and trigger a data fetch
                  _stateManager.setFilter(
                        (event) {
                      _onFilterChanged();
                      return true;
                    },
                  );
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
      child: totalPages > 1
          ? Row(
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
      )
          : Container(),
    );
  }
}
