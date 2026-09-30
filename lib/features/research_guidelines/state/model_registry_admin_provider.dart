import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/model_version_model.dart';
import '../services/model_registry_admin_service.dart';

final modelRegistryAdminServiceProvider =
    Provider<ModelRegistryAdminService>(
  (ref) {
    return ModelRegistryAdminService(
      ref.watch(dioProvider),
    );
  },
);

final modelRegistryListProvider =
    FutureProvider.autoDispose<
        ModelRegistryListResult>(
  (ref) async {
    return ref
        .watch(
          modelRegistryAdminServiceProvider,
        )
        .listModels();
  },
);

final activeRandomForestModelProvider =
    FutureProvider.autoDispose<
        ModelVersionModel?>(
  (ref) async {
    return ref
        .watch(
          modelRegistryAdminServiceProvider,
        )
        .getActiveModel(
          algorithm:
              'random_forest',
        );
  },
);

final activeXgboostModelProvider =
    FutureProvider.autoDispose<
        ModelVersionModel?>(
  (ref) async {
    return ref
        .watch(
          modelRegistryAdminServiceProvider,
        )
        .getActiveModel(
          algorithm:
              'xgboost',
        );
  },
);

class ModelRegistryAdminActions {
  ModelRegistryAdminActions(
    this.ref,
  );

  final Ref ref;

  ModelRegistryAdminService
      get _service =>
          ref.read(
            modelRegistryAdminServiceProvider,
          );

  void refresh() {
    ref.invalidate(
      modelRegistryListProvider,
    );

    ref.invalidate(
      activeRandomForestModelProvider,
    );

    ref.invalidate(
      activeXgboostModelProvider,
    );
  }

  Future<dynamic> activate(
    String modelVersion,
  ) async {
    final result =
        await _service.activateModel(
      modelVersion,
    );

    refresh();

    return result;
  }

  Future<dynamic> rollback({
    required String algorithm,
    String? targetModelVersion,
  }) async {
    final result =
        await _service.rollback(
      algorithm: algorithm,
      targetModelVersion:
          targetModelVersion,
    );

    refresh();

    return result;
  }
}

final modelRegistryAdminActionsProvider =
    Provider<ModelRegistryAdminActions>(
  (ref) {
    return ModelRegistryAdminActions(
      ref,
    );
  },
);