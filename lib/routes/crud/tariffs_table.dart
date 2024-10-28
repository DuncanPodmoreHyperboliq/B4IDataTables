import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class Tariffs {
  final double tariffDifferential;
  final int supplierId;
  final double tariffThroughput;
  final int contractId;
  final DateTime validFrom;
  final int locationId;
  final double tariffHookupFee;
  final double tariffImportPremium;
  final double tariffTransportCost;
  final double tariffBasePrice;
  final double tariffMarkup;
  final DateTime validTo;
  final int tariffId;

  Tariffs({
    required this.tariffDifferential,
    required this.supplierId,
    required this.tariffThroughput,
    required this.contractId,
    required this.validFrom,
    required this.locationId,
    required this.tariffHookupFee,
    required this.tariffImportPremium,
    required this.tariffTransportCost,
    required this.tariffBasePrice,
    required this.tariffMarkup,
    required this.validTo,
    required this.tariffId,
  });

  factory Tariffs.fromJson(Map<String, dynamic> json) {
    return Tariffs(
      tariffDifferential: (json['tariff_differential'] ?? 0).toDouble(),
      supplierId: json['supplier_id'] ?? 0,
      tariffThroughput: (json['tariff_throughput'] ?? 0).toDouble(),
      contractId: json['contract_id'] ?? 0,
      validFrom: DateTime.parse(json['valid_from'] ?? DateTime.now().toIso8601String()),
      locationId: json['location_id'] ?? 0,
      tariffHookupFee: (json['tariff_hookup_fee'] ?? 0).toDouble(),
      tariffImportPremium: (json['tariff_import_premium'] ?? 0).toDouble(),
      tariffTransportCost: (json['tariff_transport_cost'] ?? 0).toDouble(),
      tariffBasePrice: (json['tariff_base_price'] ?? 0).toDouble(),
      tariffMarkup: (json['tariff_markup'] ?? 0).toDouble(),
      validTo: DateTime.parse(json['valid_to'] ?? DateTime.now().toIso8601String()),
      tariffId: json['tariff_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tariff_differential': tariffDifferential,
      'supplier_id': supplierId,
      'tariff_throughput': tariffThroughput,
      'contract_id': contractId,
      'valid_from': validFrom.toIso8601String(),
      'location_id': locationId,
      'tariff_hookup_fee': tariffHookupFee,
      'tariff_import_premium': tariffImportPremium,
      'tariff_transport_cost': tariffTransportCost,
      'tariff_base_price': tariffBasePrice,
      'tariff_markup': tariffMarkup,
      'valid_to': validTo.toIso8601String(),
      'tariff_id': tariffId,
    };
  }
}

class TariffsTable extends StatefulWidget {
  final double width;
  final double height;

  const TariffsTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _TariffsTableState createState() => _TariffsTableState();
}

class _TariffsTableState extends State<TariffsTable> {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  late PlutoGridStateManager _stateManager;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _loading = true;
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    fetchTariffs();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Tariff ID',
        field: 'tariff_id',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Supplier ID',
        field: 'supplier_id',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Contract ID',
        field: 'contract_id',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Location ID',
        field: 'location_id',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Valid From',
        field: 'valid_from',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Valid To',
        field: 'valid_to',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Tariff Base Price',
        field: 'tariff_base_price',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Markup',
        field: 'tariff_markup',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Differential',
        field: 'tariff_differential',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Throughput',
        field: 'tariff_throughput',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Hookup Fee',
        field: 'tariff_hookup_fee',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Import Premium',
        field: 'tariff_import_premium',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
      ),
      PlutoColumn(
        title: 'Tariff Transport Cost',
        field: 'tariff_transport_cost',
        type: PlutoColumnType.number(
          format: '#,###.#####',
        ),
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

  Future<void> fetchTariffs({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('tariffs').select(
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
        print('Error fetching tariffs: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final tariff = Tariffs.fromJson(item);

          return PlutoRow(
            cells: {
              'tariff_id': PlutoCell(value: tariff.tariffId),
              'supplier_id': PlutoCell(value: tariff.supplierId),
              'contract_id': PlutoCell(value: tariff.contractId),
              'location_id': PlutoCell(value: tariff.locationId),
              'valid_from': PlutoCell(value: tariff.validFrom),
              'valid_to': PlutoCell(value: tariff.validTo),
              'tariff_base_price': PlutoCell(value: tariff.tariffBasePrice),
              'tariff_markup': PlutoCell(value: tariff.tariffMarkup),
              'tariff_differential': PlutoCell(value: tariff.tariffDifferential),
              'tariff_throughput': PlutoCell(value: tariff.tariffThroughput),
              'tariff_hookup_fee': PlutoCell(value: tariff.tariffHookupFee),
              'tariff_import_premium': PlutoCell(value: tariff.tariffImportPremium),
              'tariff_transport_cost': PlutoCell(value: tariff.tariffTransportCost),
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
      print('Error fetching tariffs: $e');
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
    fetchTariffs(filters: filters); // Fetch data with applied filters
  }

  Future<void> _editTariff(int tariffId) async {
    print('Edit tariff with ID: $tariffId');
    // Implement edit functionality
  }

  Future<void> _deleteTariff(int tariffId) async {
    await SupabaseConfig.client
        .from('tariffs')
        .delete()
        .eq('tariff_id', tariffId);
    fetchTariffs();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchTariffs();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredTariffs(Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query = SupabaseConfig.client.from('tariffs').select('*');

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
        print('Error fetching tariffs: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final tariff = Tariffs.fromJson(item);

          return PlutoRow(
            cells: {
              'tariff_id': PlutoCell(value: tariff.tariffId),
              'supplier_id': PlutoCell(value: tariff.supplierId),
              'contract_id': PlutoCell(value: tariff.contractId),
              'location_id': PlutoCell(value: tariff.locationId),
              'valid_from': PlutoCell(value: tariff.validFrom),
              'valid_to': PlutoCell(value: tariff.validTo),
              'tariff_base_price': PlutoCell(value: tariff.tariffBasePrice),
              'tariff_markup': PlutoCell(value: tariff.tariffMarkup),
              'tariff_differential': PlutoCell(value: tariff.tariffDifferential),
              'tariff_throughput': PlutoCell(value: tariff.tariffThroughput),
              'tariff_hookup_fee': PlutoCell(value: tariff.tariffHookupFee),
              'tariff_import_premium': PlutoCell(value: tariff.tariffImportPremium),
              'tariff_transport_cost': PlutoCell(value: tariff.tariffTransportCost),
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
      print('Error fetching tariffs: $e');
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
                    final filters = _extractFilters();
                    _fetchFilteredTariffs(
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
