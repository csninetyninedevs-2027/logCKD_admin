class FoodNutrients {
  const FoodNutrients({
    this.energyKcal,
    this.proteinG,
    this.carbohydratesG,
    this.fatG,
    this.sodiumMg,
    this.potassiumMg,
    this.cholesterolMg,
    this.fiberG,
    this.sugarG,
  });

  final double? energyKcal;
  final double? proteinG;
  final double? carbohydratesG;
  final double? fatG;
  final double? sodiumMg;
  final double? potassiumMg;
  final double? cholesterolMg;
  final double? fiberG;
  final double? sugarG;

  factory FoodNutrients.fromJson(
    Map<String, dynamic>? json,
  ) {
    double? number(dynamic value) {
      return (value as num?)?.toDouble();
    }

    json ??= const {};

    return FoodNutrients(
      energyKcal: number(
        json['energyKcal'],
      ),
      proteinG: number(
        json['proteinG'],
      ),
      carbohydratesG: number(
        json['carbohydratesG'],
      ),
      fatG: number(
        json['fatG'],
      ),
      sodiumMg: number(
        json['sodiumMg'],
      ),
      potassiumMg: number(
        json['potassiumMg'],
      ),
      cholesterolMg: number(
        json['cholesterolMg'],
      ),
      fiberG: number(
        json['fiberG'],
      ),
      sugarG: number(
        json['sugarG'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energyKcal': energyKcal,
      'proteinG': proteinG,
      'carbohydratesG':
          carbohydratesG,
      'fatG': fatG,
      'sodiumMg': sodiumMg,
      'potassiumMg': potassiumMg,
      'cholesterolMg': cholesterolMg,
      'fiberG': fiberG,
      'sugarG': sugarG,
    };
  }
}

class AdminFood {
  const AdminFood({
    required this.id,
    required this.fdcId,
    required this.name,
    required this.filipinoName,
    required this.category,
    required this.nutrientBasis,
    required this.nutrients,
    required this.sourceType,
    required this.provider,
    required this.dataset,
    required this.editableByAdmin,
    required this.isActive,
  });

  final String? id;
  final int? fdcId;

  final String name;
  final String? filipinoName;
  final String? category;

  final String nutrientBasis;

  final FoodNutrients nutrients;

  final String sourceType;

  final String? provider;
  final String? dataset;

  final bool editableByAdmin;
  final bool isActive;

  factory AdminFood.fromJson(
    Map<String, dynamic> json,
  ) {
    final source =
        (json['source']
                as Map<String, dynamic>?) ??
            const {};

    return AdminFood(
      id: json['id'] as String?,
      fdcId:
          (json['fdcId'] as num?)
              ?.toInt(),
      name:
          (json['name'] as String?) ??
              '',
      filipinoName:
          json['filipinoName']
              as String?,
      category:
          json['category'] as String?,
      nutrientBasis:
          (json['nutrientBasis']
                  as String?) ??
              'per 100 g',
      nutrients:
          FoodNutrients.fromJson(
        json['nutrientsPer100g']
            as Map<String, dynamic>?,
      ),
      sourceType:
          (json['sourceType']
                  as String?) ??
              'other',
      provider:
          source['provider'] as String?,
      dataset:
          source['dataset'] as String?,
      editableByAdmin:
          json['editableByAdmin'] ==
              true,
      isActive:
          json['isActive'] != false,
    );
  }
}

class FoodListPage {
  const FoodListPage({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.foods,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  final List<AdminFood> foods;

  factory FoodListPage.fromJson(
    Map<String, dynamic> json,
  ) {
    return FoodListPage(
      total:
          (json['total'] as num?)
                  ?.toInt() ??
              0,
      page:
          (json['page'] as num?)
                  ?.toInt() ??
              1,
      limit:
          (json['limit'] as num?)
                  ?.toInt() ??
              25,
      totalPages:
          (json['totalPages']
                      as num?)
                  ?.toInt() ??
              1,
      foods:
          ((json['data'] as List?) ??
                  const [])
              .map(
                (item) =>
                    AdminFood.fromJson(
                  item as Map<
                      String,
                      dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class FoodDraft {
  const FoodDraft({
    required this.name,
    required this.filipinoName,
    required this.category,
    required this.nutrients,
  });

  final String name;
  final String? filipinoName;
  final String? category;

  final FoodNutrients nutrients;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'filipinoName':
          filipinoName,
      'category': category,
      'nutrientsPer100g':
          nutrients.toJson(),
    };
  }
}

class BulkValidationItem {
  const BulkValidationItem({
    required this.index,
    required this.name,
    required this.valid,
    required this.errors,
    required this.warnings,
  });

  final int index;
  final String? name;

  final bool valid;

  final List<String> errors;
  final List<String> warnings;

  factory BulkValidationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return BulkValidationItem(
      index:
          (json['index'] as num?)
                  ?.toInt() ??
              0,
      name:
          json['name'] as String?,
      valid:
          json['valid'] == true,
      errors:
          ((json['errors'] as List?) ??
                  const [])
              .map(
                (item) => '$item',
              )
              .toList(),
      warnings:
          ((json['warnings']
                      as List?) ??
                  const [])
              .map(
                (item) => '$item',
              )
              .toList(),
    );
  }
}

class BulkValidationResponse {
  const BulkValidationResponse({
    required this.total,
    required this.valid,
    required this.invalid,
    required this.warnings,
    required this.items,
  });

  final int total;
  final int valid;
  final int invalid;
  final int warnings;

  final List<BulkValidationItem>
      items;

  factory BulkValidationResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final summary =
        (json['summary']
                as Map<String, dynamic>?) ??
            const {};

    return BulkValidationResponse(
      total:
          (summary['total'] as num?)
                  ?.toInt() ??
              0,
      valid:
          (summary['valid'] as num?)
                  ?.toInt() ??
              0,
      invalid:
          (summary['invalid'] as num?)
                  ?.toInt() ??
              0,
      warnings:
          (summary['warnings']
                      as num?)
                  ?.toInt() ??
              0,
      items:
          ((json['results'] as List?) ??
                  const [])
              .map(
                (item) =>
                    BulkValidationItem
                        .fromJson(
                  item as Map<
                      String,
                      dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class BulkImportResponse {
  const BulkImportResponse({
    required this.imported,
    required this.skipped,
  });

  final int imported;
  final int skipped;

  factory BulkImportResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final summary =
        (json['summary']
                as Map<String, dynamic>?) ??
            const {};

    return BulkImportResponse(
      imported:
          (summary['imported']
                      as num?)
                  ?.toInt() ??
              0,
      skipped:
          (summary['skipped']
                      as num?)
                  ?.toInt() ??
              0,
    );
  }
}