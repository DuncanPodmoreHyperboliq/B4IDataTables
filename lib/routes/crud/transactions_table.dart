import 'package:flutter/material.dart';

import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class SupplierTransactions {
  final int transactionId;
  final int locationId;
  final String locationName;
  final String flightNumber;
  final String transactionInvoiceNumber;
  final double supplierInvoiceQty;
  final int supplierId;
  final String supplierName;
  final DateTime supplierInvoiceDate;
  final double transactionAmount;

  SupplierTransactions({
    required this.transactionId,
    required this.locationId,
    required this.locationName,
    required this.flightNumber,
    required this.transactionInvoiceNumber,
    required this.supplierInvoiceQty,
    required this.supplierId,
    required this.supplierName,
    required this.supplierInvoiceDate,
    required this.transactionAmount,
  });

  factory SupplierTransactions.fromJson(Map<String, dynamic> json) {
    return SupplierTransactions(
      transactionId: json['transaction_id'],
      locationId: json['location_id'],
      locationName: json['location']?['location_name'] ?? '',
      flightNumber: json['flight_number'],
      transactionInvoiceNumber: json['transaction_invoice_number'],
      supplierInvoiceQty: (json['supplier_invoice_qty'] ?? 0).toDouble(),
      supplierId: json['supplier_id'],
      supplierName: json['supplier']?['supplier_name'] ?? '',
      supplierInvoiceDate: DateTime.parse(json['supplier_invoice_date']),
      transactionAmount: (json['transaction_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'location_id': locationId,
      'location_name': locationName,
      'flight_number': flightNumber,
      'transaction_invoice_number': transactionInvoiceNumber,
      'supplier_invoice_qty': supplierInvoiceQty,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'supplier_invoice_date': supplierInvoiceDate.toIso8601String(),
      'transaction_amount': transactionAmount,
    };
  }
}

class SupplierTransactionsTable extends StatefulWidget {
  final double width;
  final double height;

  const SupplierTransactionsTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _SupplierTransactionsTableState createState() =>
      _SupplierTransactionsTableState();
}

class _SupplierTransactionsTableState extends State<SupplierTransactionsTable> {
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
    fetchSupplierTransactions();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Location Name',
        field: 'location_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Flight Number',
        field: 'flight_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Invoice Number',
        field: 'transaction_invoice_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Invoice Qty',
        field: 'supplier_invoice_qty',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Supplier Name',
        field: 'supplier_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Invoice Date',
        field: 'supplier_invoice_date',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Transaction Amount',
        field: 'transaction_amount',
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

  Future<void> fetchSupplierTransactions({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('supplier_transactions').select(
        '''
            *,
            supplier:supplier_id(supplier_name),
            location:location_id(location_name)
            ''',
        const FetchOptions(count: CountOption.exact),
      );

      // Apply filters dynamically
      if (filters != null && filters.isNotEmpty) {
        filters.forEach((field, value) {
          if (field == 'supplier_name') {
            query = query.ilike('supplier.supplier_name', '%$value%');
          } else if (field == 'location_name') {
            query = query.ilike('location.location_name', '%$value%');
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
        print('Error fetching supplier transactions:');
        return;
      }

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final transaction = SupplierTransactions.fromJson(item);

          return PlutoRow(
            cells: {
              'location_name': PlutoCell(value: transaction.locationName),
              'flight_number': PlutoCell(value: transaction.flightNumber),
              'transaction_invoice_number':
              PlutoCell(value: transaction.transactionInvoiceNumber),
              'supplier_invoice_qty':
              PlutoCell(value: transaction.supplierInvoiceQty),
              'supplier_name': PlutoCell(value: transaction.supplierName),
              'supplier_invoice_date':
              PlutoCell(value: transaction.supplierInvoiceDate),
              'transaction_amount':
              PlutoCell(value: transaction.transactionAmount),
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
      print('Error fetching supplier transactions: $e');
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
    fetchSupplierTransactions(
        filters: filters); // Fetch data with applied filters
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchSupplierTransactions();
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