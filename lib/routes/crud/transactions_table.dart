import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class SupplierTransactions {
  final int locationId;
  final String flightNumber;
  final String transactionInvoiceNumber;
  final double supplierInvoiceQty;
  final int supplierId;
  final DateTime supplierInvoiceDate;
  final double transactionAmount;
  final int transactionId;

  SupplierTransactions({
    required this.locationId,
    required this.flightNumber,
    required this.transactionInvoiceNumber,
    required this.supplierInvoiceQty,
    required this.supplierId,
    required this.supplierInvoiceDate,
    required this.transactionAmount,
    required this.transactionId,
  });

  factory SupplierTransactions.fromJson(Map<String, dynamic> json) {
    return SupplierTransactions(
      locationId: json['location_id'],
      flightNumber: json['flight_number'],
      transactionInvoiceNumber: json['transaction_invoice_number'],
      supplierInvoiceQty: (json['supplier_invoice_qty'] ?? 0).toDouble(),
      supplierId: json['supplier_id'],
      supplierInvoiceDate: DateTime.parse(json['supplier_invoice_date']),
      transactionAmount: (json['transaction_amount'] ?? 0).toDouble(),
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'flight_number': flightNumber,
      'transaction_invoice_number': transactionInvoiceNumber,
      'supplier_invoice_qty': supplierInvoiceQty,
      'supplier_id': supplierId,
      'supplier_invoice_date': supplierInvoiceDate.toIso8601String(),
      'transaction_amount': transactionAmount,
      'transaction_id': transactionId,
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
  final int _pageSize = 10;
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
        title: 'Transaction ID',
        field: 'transaction_id',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Location ID',
        field: 'location_id',
        type: PlutoColumnType.number(),
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
        title: 'Supplier ID',
        field: 'supplier_id',
        type: PlutoColumnType.number(),
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

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final transaction = SupplierTransactions.fromJson(item);

          return PlutoRow(
            cells: {
              'transaction_id': PlutoCell(value: transaction.transactionId),
              'location_id': PlutoCell(value: transaction.locationId),
              'flight_number': PlutoCell(value: transaction.flightNumber),
              'transaction_invoice_number':
              PlutoCell(value: transaction.transactionInvoiceNumber),
              'supplier_invoice_qty':
              PlutoCell(value: transaction.supplierInvoiceQty),
              'supplier_id': PlutoCell(value: transaction.supplierId),
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
    fetchSupplierTransactions(
        filters: filters); // Fetch data with applied filters
  }

  Future<void> _editTransaction(int transactionId) async {
    print('Edit transaction with ID: $transactionId');
    // Implement edit functionality
  }

  Future<void> _deleteTransaction(int transactionId) async {
    await SupabaseConfig.client
        .from('supplier_transactions')
        .delete()
        .eq('transaction_id', transactionId);
    fetchSupplierTransactions();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchSupplierTransactions();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredSupplierTransactions(
      Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query =
      SupabaseConfig.client.from('supplier_transactions').select('*');

      // Apply filters dynamically
      filters.forEach((field, value) {
        query = query.ilike(
            field, '%$value%'); // Apply filters to the correct fields
      });

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
          final transaction = SupplierTransactions.fromJson(item);

          return PlutoRow(
            cells: {
              'transaction_id': PlutoCell(value: transaction.transactionId),
              'location_id': PlutoCell(value: transaction.locationId),
              'flight_number': PlutoCell(value: transaction.flightNumber),
              'transaction_invoice_number':
              PlutoCell(value: transaction.transactionInvoiceNumber),
              'supplier_invoice_qty':
              PlutoCell(value: transaction.supplierInvoiceQty),
              'supplier_id': PlutoCell(value: transaction.supplierId),
              'supplier_invoice_date':
              PlutoCell(value: transaction.supplierInvoiceDate),
              'transaction_amount':
              PlutoCell(value: transaction.transactionAmount),
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
      print('Error fetching supplier transactions: $e');
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

                  // Listen for filter changes and trigger a data fetch
                  _stateManager.addListener(() {
                    final filters = _extractFilters();
                    _fetchFilteredSupplierTransactions(
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