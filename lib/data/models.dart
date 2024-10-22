class AirportSuppliers {
  final int airportSupplierDistibution;
  final int airportId;
  final int supplierId;
  final int airportSupplierId;
  final bool airportSupplierSplit;
  final DateTime createdAt;
  final double airportSupplierVat;
  final double airportSupplierPercentage;

  AirportSuppliers({
    required this.airportSupplierDistibution,
    required this.airportId,
    required this.supplierId,
    required this.airportSupplierId,
    required this.airportSupplierSplit,
    required this.createdAt,
    required this.airportSupplierVat,
    required this.airportSupplierPercentage,
  });

  factory AirportSuppliers.fromJson(Map<String, dynamic> json) {
    return AirportSuppliers(
      airportSupplierDistibution: json['airport_supplier_distibution'],
      airportId: json['airport_id'],
      supplierId: json['supplier_id'],
      airportSupplierId: json['airport_supplier_id'],
      airportSupplierSplit: json['airport_supplier_split'],
      createdAt: DateTime.parse(json['created_at']),
      airportSupplierVat: json['airport_supplier_vat'].toDouble(),
      airportSupplierPercentage: json['airport_supplier_percentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport_supplier_distibution': airportSupplierDistibution,
      'airport_id': airportId,
      'supplier_id': supplierId,
      'airport_supplier_id': airportSupplierId,
      'airport_supplier_split': airportSupplierSplit,
      'created_at': createdAt.toIso8601String(),
      'airport_supplier_vat': airportSupplierVat,
      'airport_supplier_percentage': airportSupplierPercentage,
    };
  }
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
      locationId: json['location_id'] != null ? json['location_id'] as int : null,
      airportId: json['airport_id'] ?? 0, // Provide a default value
      airportIata: json['airport_iata'] ?? '', // Provide a default value
      locationName: json['locations']?['location_name'], // Handle nested null values
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

class Contracts {
  final int locationId;
  final int contractId;
  final DateTime startDate;
  final DateTime endDate;
  final int rateChangeId;
  final int supplierId;

  Contracts({
    required this.locationId,
    required this.contractId,
    required this.startDate,
    required this.endDate,
    required this.rateChangeId,
    required this.supplierId,
  });

  factory Contracts.fromJson(Map<String, dynamic> json) {
    return Contracts(
      locationId: json['location_id'],
      contractId: json['contract_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      rateChangeId: json['rate_change_id'],
      supplierId: json['supplier_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'contract_id': contractId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'rate_change_id': rateChangeId,
      'supplier_id': supplierId,
    };
  }
}

class Corrections {
  final double originalValue;
  final String relatedTable;
  final DateTime correctionDate;
  final double correctedValue;
  final int relatedId;
  final int correctionId;
  final String fieldCorrected;
  final String correctionReason;
  final String correctedBy;

  Corrections({
    required this.originalValue,
    required this.relatedTable,
    required this.correctionDate,
    required this.correctedValue,
    required this.relatedId,
    required this.correctionId,
    required this.fieldCorrected,
    required this.correctionReason,
    required this.correctedBy,
  });

  factory Corrections.fromJson(Map<String, dynamic> json) {
    return Corrections(
      originalValue: json['original_value'].toDouble(),
      relatedTable: json['related_table'],
      correctionDate: DateTime.parse(json['correction_date']),
      correctedValue: json['corrected_value'].toDouble(),
      relatedId: json['related_id'],
      correctionId: json['correction_id'],
      fieldCorrected: json['field_corrected'],
      correctionReason: json['correction_reason'],
      correctedBy: json['corrected_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_value': originalValue,
      'related_table': relatedTable,
      'correction_date': correctionDate.toIso8601String(),
      'corrected_value': correctedValue,
      'related_id': relatedId,
      'correction_id': correctionId,
      'field_corrected': fieldCorrected,
      'correction_reason': correctionReason,
      'corrected_by': correctedBy,
    };
  }
}

class Countries {
  final String countryName;
  final int countryId;
  final String countryCode;

  Countries({
    required this.countryName,
    required this.countryId,
    required this.countryCode,
  });

  factory Countries.fromJson(Map<String, dynamic> json) {
    return Countries(
      countryName: json['country_name'],
      countryId: json['country_id'],
      countryCode: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_name': countryName,
      'country_id': countryId,
      'country_code': countryCode,
    };
  }
}

class PrepaymentTypes {
  final int prepaymentTypeId;
  final String prepaymentName;

  PrepaymentTypes({
    required this.prepaymentTypeId,
    required this.prepaymentName,
  });

  factory PrepaymentTypes.fromJson(Map<String, dynamic> json) {
    return PrepaymentTypes(
      prepaymentTypeId: json['prepayment_type_id'],
      prepaymentName: json['prepayment_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prepayment_type_id': prepaymentTypeId,
      'prepayment_name': prepaymentName,
    };
  }
}

class Prepayments {
  final int prepaymentTypeId;
  final int prepaymentId;
  final DateTime prepaymentDate;
  final double prepaymentAmount;
  final int supplierId;

  Prepayments({
    required this.prepaymentTypeId,
    required this.prepaymentId,
    required this.prepaymentDate,
    required this.prepaymentAmount,
    required this.supplierId,
  });

  factory Prepayments.fromJson(Map<String, dynamic> json) {
    return Prepayments(
      prepaymentTypeId: json['prepayment_type_id'],
      prepaymentId: json['prepayment_id'],
      prepaymentDate: DateTime.parse(json['prepayment_date']),
      prepaymentAmount: json['prepayment_amount'].toDouble(),
      supplierId: json['supplier_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prepayment_type_id': prepaymentTypeId,
      'prepayment_id': prepaymentId,
      'prepayment_date': prepaymentDate.toIso8601String(),
      'prepayment_amount': prepaymentAmount,
      'supplier_id': supplierId,
    };
  }
}

class ProcessingStatuses {
  final String processingStatusName;
  final int processingStatusId;

  ProcessingStatuses({
    required this.processingStatusName,
    required this.processingStatusId,
  });

  factory ProcessingStatuses.fromJson(Map<String, dynamic> json) {
    return ProcessingStatuses(
      processingStatusName: json['processing_status_name'],
      processingStatusId: json['processing_status_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processing_status_name': processingStatusName,
      'processing_status_id': processingStatusId,
    };
  }
}

class RateChange {
  final String rateChangeDay;
  final int rateChangeId;

  RateChange({
    required this.rateChangeDay,
    required this.rateChangeId,
  });

  factory RateChange.fromJson(Map<String, dynamic> json) {
    return RateChange(
      rateChangeDay: json['rate_change_day'],
      rateChangeId: json['rate_change_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate_change_day': rateChangeDay,
      'rate_change_id': rateChangeId,
    };
  }
}

class SpotSuppliers {
  final DateTime transactionDate;
  final String supplierInvoiceName;
  final int spotSupplierId;
  final String reason;
  final String supplierName;
  final double transactionAmount;
  final DateTime createdAt;

  SpotSuppliers({
    required this.transactionDate,
    required this.supplierInvoiceName,
    required this.spotSupplierId,
    required this.reason,
    required this.supplierName,
    required this.transactionAmount,
    required this.createdAt,
  });

  factory SpotSuppliers.fromJson(Map<String, dynamic> json) {
    return SpotSuppliers(
      transactionDate: DateTime.parse(json['transaction_date']),
      supplierInvoiceName: json['supplier_invoice_name'],
      spotSupplierId: json['spot_supplier_id'],
      reason: json['reason'],
      supplierName: json['supplier_name'],
      transactionAmount: json['transaction_amount'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_date': transactionDate.toIso8601String(),
      'supplier_invoice_name': supplierInvoiceName,
      'spot_supplier_id': spotSupplierId,
      'reason': reason,
      'supplier_name': supplierName,
      'transaction_amount': transactionAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
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
      supplierInvoiceQty: json['supplier_invoice_qty'].toDouble(),
      supplierId: json['supplier_id'],
      supplierInvoiceDate: DateTime.parse(json['supplier_invoice_date']),
      transactionAmount: json['transaction_amount'].toDouble(),
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
      supplierName: json['supplier_name'],
      supplierInvoiceName: json['supplier_invoice_name'],
      supplierUniqueId: json['supplier_unique_id'],
      supplierId: json['supplier_id'],
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
      tariffDifferential: json['tariff_differential'].toDouble(),
      supplierId: json['supplier_id'],
      tariffThroughput: json['tariff_throughput'].toDouble(),
      contractId: json['contract_id'],
      validFrom: DateTime.parse(json['valid_from']),
      locationId: json['location_id'],
      tariffHookupFee: json['tariff_hookup_fee'].toDouble(),
      tariffImportPremium: json['tariff_import_premium'].toDouble(),
      tariffTransportCost: json['tariff_transport_cost'].toDouble(),
      tariffBasePrice: json['tariff_base_price'].toDouble(),
      tariffMarkup: json['tariff_markup'].toDouble(),
      validTo: DateTime.parse(json['valid_to']),
      tariffId: json['tariff_id'],
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

class TransactionFiles {
  final DateTime transactionFileDate;
  final int transactionFileId;
  final String transactionFileUrl;
  final String transactionFileName;
  final double transactionFileSize;
  final int transactionId;

  TransactionFiles({
    required this.transactionFileDate,
    required this.transactionFileId,
    required this.transactionFileUrl,
    required this.transactionFileName,
    required this.transactionFileSize,
    required this.transactionId,
  });

  factory TransactionFiles.fromJson(Map<String, dynamic> json) {
    return TransactionFiles(
      transactionFileDate: DateTime.parse(json['transaction_file_date']),
      transactionFileId: json['transaction_file_id'],
      transactionFileUrl: json['transaction_file_url'],
      transactionFileName: json['transaction_file_name'],
      transactionFileSize: json['transaction_file_size'].toDouble(),
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_file_date': transactionFileDate.toIso8601String(),
      'transaction_file_id': transactionFileId,
      'transaction_file_url': transactionFileUrl,
      'transaction_file_name': transactionFileName,
      'transaction_file_size': transactionFileSize,
      'transaction_id': transactionId,
    };
  }
}

class Location {
  final int locationId;
  final String locationName;
  final int countryId;

  Location({
    required this.locationId,
    required this.locationName,
    required this.countryId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id'],
      locationName: json['location_name'],
      countryId: json['country_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_name': locationName,
      'country_id': countryId,
    };
  }
}


class TransactionStatuses {
  final DateTime transactionStatusProcessingDate;
  final int processingStatusId;
  final int transactionStatusId;
  final int transactionId;

  TransactionStatuses({
    required this.transactionStatusProcessingDate,
    required this.processingStatusId,
    required this.transactionStatusId,
    required this.transactionId,
  });

  factory TransactionStatuses.fromJson(Map<String, dynamic> json) {
    return TransactionStatuses(
      transactionStatusProcessingDate: DateTime.parse(json['transaction_status_processing_date']),
      processingStatusId: json['processing_status_id'],
      transactionStatusId: json['transaction_status_id'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_status_processing_date': transactionStatusProcessingDate.toIso8601String(),
      'processing_status_id': processingStatusId,
      'transaction_status_id': transactionStatusId,
      'transaction_id': transactionId,
    };
  }
}

