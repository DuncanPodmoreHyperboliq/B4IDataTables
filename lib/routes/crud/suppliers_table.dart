import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
}

class Suppliers {
  final String supplierName;
  final String supplierInvoiceName;
  final String supplierUniqueId;
  final int supplierId;

  Suppliers({
    required this.supplierName,
    required this.supplierInvoiceName,
    required this.supplierUniqueId,
    required this.supplierId,
  });

  factory Suppliers.fromJson(Map<String, dynamic> json) {
    return Suppliers(
      supplierName: json['supplier_name'] ?? '',
      supplierInvoiceName: json['supplier_invoice_name'] ?? '',
      supplierUniqueId: json['supplier_unique_id'] ?? '',
      supplierId: json['supplier_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'supplier_invoice_name': supplierInvoiceName,
      'supplier_unique_id': supplierUniqueId,
      'supplier_id': supplierId,
    };
  }
}

class SuppliersTable extends StatefulWidget {
  final double width;
  final double height;

  const SuppliersTable({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _SuppliersTableState createState() => _SuppliersTableState();
}

class _SuppliersTableState extends State<SuppliersTable> {
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
    fetchSuppliers();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Supplier ID',
        field: 'supplier_id',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Supplier Name',
        field: 'supplier_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Invoice Name',
        field: 'supplier_invoice_name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Unique ID',
        field: 'supplier_unique_id',
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

  Future<void> fetchSuppliers({Map<String, String>? filters}) async {
    try {
      setState(() => _loading = true);

      var query = SupabaseConfig.client.from('suppliers').select(
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
          final supplier = Suppliers.fromJson(item);

          return PlutoRow(
            cells: {
              'supplier_id': PlutoCell(value: supplier.supplierId),
              'supplier_name': PlutoCell(value: supplier.supplierName),
              'supplier_invoice_name':
              PlutoCell(value: supplier.supplierInvoiceName),
              'supplier_unique_id': PlutoCell(value: supplier.supplierUniqueId),
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
      print('Error fetching suppliers: $e');
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
    fetchSuppliers(filters: filters); // Fetch data with applied filters
  }

  Future<void> _editSupplier(int supplierId) async {
    print('Edit supplier with ID: $supplierId');
    // Implement edit functionality
  }

  Future<void> _deleteSupplier(int supplierId) async {
    await SupabaseConfig.client
        .from('suppliers')
        .delete()
        .eq('supplier_id', supplierId);
    fetchSuppliers();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
      fetchSuppliers();
    });
  }

  // Fetch filtered data from Supabase
  Future<void> _fetchFilteredSuppliers(Map<String, String> filters) async {
    setState(() => _loading = true);

    try {
      // Build the query with filters
      var query = SupabaseConfig.client.from('suppliers').select('*');

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

      if (response.data != null && response.data.isNotEmpty) {
        final List<dynamic> data = response.data;

        // Convert fetched data to PlutoRows
        final newRows = data.map<PlutoRow>((item) {
          final supplier = Suppliers.fromJson(item);

          return PlutoRow(
            cells: {
              'supplier_id': PlutoCell(value: supplier.supplierId),
              'supplier_name': PlutoCell(value: supplier.supplierName),
              'supplier_invoice_name':
              PlutoCell(value: supplier.supplierInvoiceName),
              'supplier_unique_id': PlutoCell(value: supplier.supplierUniqueId),
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
      print('Error fetching suppliers: $e');
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
                    _fetchFilteredSuppliers(
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
