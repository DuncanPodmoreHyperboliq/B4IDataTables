import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class Upliftment {
  final String? flightFrom;
  final String? flightTo;
  final double? upliftVolume;
  final DateTime? transactionDate;
  final String? transactionInvoiceNumber;
  final double? transactionAmountIncVat;
  final double? transactionAmountExclVat;
  final String? status;
  final String? supplierLocation;
  final bool? isSplit;
  final String? supplierName;
  final DateTime? flightDateTime;
  final String? flightAircraftRegistration;
  final String? flightNumber;
  final String? fuelSlip;
  final num? originalValueIfCorrected;
  final double? purchasePricePerLiter;
  final double? salesPricePerLiter;
  final double? purchasePrice;
  final double? salePrice;
  final double? gp;

  Upliftment({
    this.flightFrom,
    this.flightTo,
    this.upliftVolume,
    this.transactionDate,
    this.transactionInvoiceNumber,
    this.transactionAmountIncVat,
    this.transactionAmountExclVat,
    this.status,
    this.supplierLocation,
    this.isSplit,
    this.supplierName,
    this.flightDateTime,
    this.flightAircraftRegistration,
    this.flightNumber,
    this.fuelSlip,
    this.originalValueIfCorrected,
    this.purchasePricePerLiter,
    this.salesPricePerLiter,
    this.purchasePrice,
    this.salePrice,
    this.gp,
  });

  factory Upliftment.fromJson(Map<String, dynamic> json) {
    return Upliftment(
      flightFrom: json['flight_from'],
      flightTo: json['flight_to'],
      upliftVolume: (json['uplift_volume'] ?? 0).toDouble(),
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : null,
      transactionInvoiceNumber: json['transaction_invoice_number'],
      transactionAmountIncVat: (json['transaction_amount_inc_vat'] ?? 0).toDouble(),
      transactionAmountExclVat: (json['transaction_amount_excl_vat'] ?? 0).toDouble(),
      status: json['status'],
      supplierLocation: json['supplier_location'],
      isSplit: json['is_split'],
      supplierName: json['supplier_name'],
      flightDateTime: json['flight_date_time'] != null
          ? DateTime.parse(json['flight_date_time'])
          : null,
      flightAircraftRegistration: json['flight_aircraft_registration'],
      flightNumber: json['flight_number'],
      fuelSlip: json['fuel_slip'],
      originalValueIfCorrected: json['original_value_if_corrected'],
      purchasePricePerLiter: (json['purchase_price_per_liter'] ?? 0).toDouble(),
      salesPricePerLiter: (json['sales_price_per_liter'] ?? 0).toDouble(),
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      gp: (json['gp'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight_from': flightFrom,
      'flight_to': flightTo,
      'uplift_volume': upliftVolume,
      'transaction_date': transactionDate?.toIso8601String(),
      'transaction_invoice_number': transactionInvoiceNumber,
      'transaction_amount_inc_vat': transactionAmountIncVat,
      'transaction_amount_excl_vat': transactionAmountExclVat,
      'status': status,
      'supplier_location': supplierLocation,
      'is_split': isSplit,
      'supplier_name': supplierName,
      'flight_date_time': flightDateTime?.toIso8601String(),
      'flight_aircraft_registration': flightAircraftRegistration,
      'flight_number': flightNumber,
      'fuel_slip': fuelSlip,
      'original_value_if_corrected': originalValueIfCorrected,
      'purchase_price_per_liter': purchasePricePerLiter,
      'sales_price_per_liter': salesPricePerLiter,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'gp': gp,
    };
  }
}

class UpliftmentTable extends StatefulWidget {
  final double width;
  final double height;

  const UpliftmentTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _UpliftmentTableState createState() => _UpliftmentTableState();
}

class _UpliftmentTableState extends State<UpliftmentTable> {
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
    fetchUpliftments();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Flight From',
        field: 'flight_from',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight To',
        field: 'flight_to',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Uplift Volume',
        field: 'uplift_volume',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Transaction Date',
        field: 'transaction_date',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Invoice Number',
        field: 'transaction_invoice_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Amount Inc VAT',
        field: 'transaction_amount_inc_vat',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Amount Excl VAT',
        field: 'transaction_amount_excl_vat',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Supplier Location',
        field: 'supplier_location',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Is Split',
        field: 'is_split',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Supplier Name',
        field: 'supplier_name',
        type: PlutoColumnType.text(),
      ),
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
        title: 'Fuel Slip',
        field: 'fuel_slip',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Original Value If Corrected',
        field: 'original_value_if_corrected',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Purchase Price/Liter',
        field: 'purchase_price_per_liter',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Sales Price/Liter',
        field: 'sales_price_per_liter',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Purchase Price',
        field: 'purchase_price',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Sale Price',
        field: 'sale_price',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'GP',
        field: 'gp',
        type: PlutoColumnType.number(),
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

  Future<void> fetchUpliftments({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('upliftments').select(
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
        print('Error fetching upliftments: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final upliftment = Upliftment.fromJson(item);

          return PlutoRow(
            cells: {
              'flight_from': PlutoCell(value: upliftment.flightFrom ?? ''),
              'flight_to': PlutoCell(value: upliftment.flightTo ?? ''),
              'uplift_volume': PlutoCell(value: upliftment.upliftVolume ?? 0),
              'transaction_date': PlutoCell(value: upliftment.transactionDate),
              'transaction_invoice_number':
              PlutoCell(value: upliftment.transactionInvoiceNumber ?? ''),
              'transaction_amount_inc_vat':
              PlutoCell(value: upliftment.transactionAmountIncVat ?? 0),
              'transaction_amount_excl_vat':
              PlutoCell(value: upliftment.transactionAmountExclVat ?? 0),
              'status': PlutoCell(value: upliftment.status ?? ''),
              'supplier_location':
              PlutoCell(value: upliftment.supplierLocation ?? ''),
              'is_split': PlutoCell(value: upliftment.isSplit != null
                  ? upliftment.isSplit! ? 'Yes' : 'No'
                  : 'Unknown'),
              'supplier_name': PlutoCell(value: upliftment.supplierName ?? ''),
              'flight_date_time':
              PlutoCell(value: upliftment.flightDateTime ?? DateTime.now()),
              'flight_aircraft_registration':
              PlutoCell(value: upliftment.flightAircraftRegistration ?? ''),
              'flight_number': PlutoCell(value: upliftment.flightNumber ?? ''),
              'fuel_slip': PlutoCell(value: upliftment.fuelSlip ?? ''),
              'original_value_if_corrected':
              PlutoCell(value: upliftment.originalValueIfCorrected ?? 0),
              'purchase_price_per_liter':
              PlutoCell(value: upliftment.purchasePricePerLiter ?? 0),
              'sales_price_per_liter':
              PlutoCell(value: upliftment.salesPricePerLiter ?? 0),
              'purchase_price': PlutoCell(value: upliftment.purchasePrice ?? 0),
              'sale_price': PlutoCell(value: upliftment.salePrice ?? 0),
              'gp': PlutoCell(value: upliftment.gp ?? 0),
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
      print('Error fetching upliftments: $e');
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
    fetchUpliftments(filters: filters); // Fetch data with applied filters
  }

  Future<void> _editUpliftment(int upliftmentId) async {
    print('Edit upliftment with ID: $upliftmentId');
    // Implement edit functionality
  }

  Future<void> _deleteUpliftment(int upliftmentId) async {
    await SupabaseConfig.client
        .from('upliftments')
        .delete()
        .eq('upliftment_id', upliftmentId);
    fetchUpliftments();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchUpliftments();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredUpliftments(Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query = SupabaseConfig.client.from('upliftments').select('*');

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
        print('Error fetching upliftments: ');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final upliftment = Upliftment.fromJson(item);

          return PlutoRow(
            cells: {
              'flight_from': PlutoCell(value: upliftment.flightFrom ?? ''),
              'flight_to': PlutoCell(value: upliftment.flightTo ?? ''),
              'uplift_volume': PlutoCell(value: upliftment.upliftVolume ?? 0),
              'transaction_date': PlutoCell(value: upliftment.transactionDate),
              'transaction_invoice_number':
              PlutoCell(value: upliftment.transactionInvoiceNumber ?? ''),
              'transaction_amount_inc_vat':
              PlutoCell(value: upliftment.transactionAmountIncVat ?? 0),
              'transaction_amount_excl_vat':
              PlutoCell(value: upliftment.transactionAmountExclVat ?? 0),
              'status': PlutoCell(value: upliftment.status ?? ''),
              'supplier_location':
              PlutoCell(value: upliftment.supplierLocation ?? ''),
              'is_split': PlutoCell(value: upliftment.isSplit != null
                  ? upliftment.isSplit! ? 'Yes' : 'No'
                  : 'Unknown'),
              'supplier_name': PlutoCell(value: upliftment.supplierName ?? ''),
              'flight_date_time':
              PlutoCell(value: upliftment.flightDateTime ?? DateTime.now()),
              'flight_aircraft_registration':
              PlutoCell(value: upliftment.flightAircraftRegistration ?? ''),
              'flight_number': PlutoCell(value: upliftment.flightNumber ?? ''),
              'fuel_slip': PlutoCell(value: upliftment.fuelSlip ?? ''),
              'original_value_if_corrected':
              PlutoCell(value: upliftment.originalValueIfCorrected ?? 0),
              'purchase_price_per_liter':
              PlutoCell(value: upliftment.purchasePricePerLiter ?? 0),
              'sales_price_per_liter':
              PlutoCell(value: upliftment.salesPricePerLiter ?? 0),
              'purchase_price': PlutoCell(value: upliftment.purchasePrice ?? 0),
              'sale_price': PlutoCell(value: upliftment.salePrice ?? 0),
              'gp': PlutoCell(value: upliftment.gp ?? 0),
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
      print('Error fetching upliftments: $e');
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
                  _stateManager.setFilter(
                        (event) {
                      final filters = _extractFilters();
                      _fetchFilteredUpliftments(
                          filters); // Fetch data with filters
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
