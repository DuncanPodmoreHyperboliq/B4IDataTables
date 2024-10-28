import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class IFS {
  final int ifsId;
  final DateTime? flightDateTime;
  final String? flightAircraftRegistration;
  final String? flightNumber;
  final int? flightOriginId;
  final String? flightOriginName;
  final int? flightDestinationId;
  final String? flightDestinationName;
  final double? upliftVolume;
  final DateTime? createdAt;
  final String? invoiceNo;

  IFS({
    required this.ifsId,
    this.flightDateTime,
    this.flightAircraftRegistration,
    this.flightNumber,
    this.flightOriginId,
    this.flightOriginName,
    this.flightDestinationId,
    this.flightDestinationName,
    this.upliftVolume,
    this.createdAt,
    this.invoiceNo,
  });

  factory IFS.fromJson(Map<String, dynamic> json) {
    return IFS(
      ifsId: json['ifs_id'],
      flightDateTime: json['flight_date_time'] != null
          ? DateTime.parse(json['flight_date_time'])
          : null,
      flightAircraftRegistration: json['flight_aircraft_registration'],
      flightNumber: json['flight_number'],
      flightOriginId: json['flight_origin_id'],
      flightOriginName: json['flight_origin']?['airport_name'] ?? '',
      flightDestinationId: json['flight_destination_id'],
      flightDestinationName: json['flight_destination']?['airport_name'] ?? '',
      upliftVolume: (json['uplift_volume'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      invoiceNo: json['invoice_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ifs_id': ifsId,
      'flight_date_time': flightDateTime?.toIso8601String(),
      'flight_aircraft_registration': flightAircraftRegistration,
      'flight_number': flightNumber,
      'flight_origin_id': flightOriginId,
      'flight_origin_name': flightOriginName,
      'flight_destination_id': flightDestinationId,
      'flight_destination_name': flightDestinationName,
      'uplift_volume': upliftVolume,
      'created_at': createdAt?.toIso8601String(),
      'invoice_no': invoiceNo,
    };
  }
}

class IFSTable extends StatefulWidget {
  final double width;
  final double height;

  const IFSTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _IFSTableState createState() => _IFSTableState();
}

class _IFSTableState extends State<IFSTable> {
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
    fetchIFSRecords();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Flight Date/Time',
        field: 'flight_date_time',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Aircraft Registration',
        field: 'flight_aircraft_registration',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight Number',
        field: 'flight_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight Origin',
        field: 'flight_origin_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight Destination',
        field: 'flight_destination_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Uplift Volume',
        field: 'uplift_volume',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Created At',
        field: 'created_at',
        type: PlutoColumnType.date(),
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

  Future<void> fetchIFSRecords({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('ifs').select(
        '''
        *,
        flight_origin:flight_origin_id(airport_name),
        flight_destination:flight_destination_id(airport_name)
        ''',
        const FetchOptions(count: CountOption.exact),
      );

      // Apply filters dynamically
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((field, value) {
          if (field == 'flight_origin_name') {
            query = query.ilike('flight_origin.airport_name', '%$value%');
          } else if (field == 'flight_destination_name') {
            query = query.ilike('flight_destination.airport_name', '%$value%');
          } else {
            query = query.ilike(field, '%$value%');
          }
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
        print('Error fetching IFS records: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final ifsRecord = IFS.fromJson(item);

          return PlutoRow(
            cells: {
              'flight_date_time': PlutoCell(value: ifsRecord.flightDateTime),
              'flight_aircraft_registration':
              PlutoCell(value: ifsRecord.flightAircraftRegistration ?? ''),
              'flight_number': PlutoCell(value: ifsRecord.flightNumber ?? ''),
              'flight_origin_name':
              PlutoCell(value: ifsRecord.flightOriginName ?? ''),
              'flight_destination_name':
              PlutoCell(value: ifsRecord.flightDestinationName ?? ''),
              'uplift_volume': PlutoCell(value: ifsRecord.upliftVolume ?? 0),
              'created_at': PlutoCell(value: ifsRecord.createdAt),
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
      print('Error fetching IFS records: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Helper function to extract active filters
  Map<String, String> _extractFilters() {
    final filters = <String, String>{};

    for (final filterRow in _stateManager.filterRows) {
      String? columnField = filterRow.cells['column']?.value?.field;
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
    fetchIFSRecords(filters: filters); // Fetch data with applied filters
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchIFSRecords();
    });
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
      child: totalPages > 1
          ? Row(
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
      )
          : Container(),
    );
  }
}