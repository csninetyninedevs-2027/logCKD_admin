import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/training_run_model.dart';
import '../services/training_run_admin_service.dart';

final trainingRunAdminServiceProvider =
    Provider<TrainingRunAdminService>(
  (ref) {
    return TrainingRunAdminService(
      ref.watch(dioProvider),
    );
  },
);

final trainingRunListProvider =
    FutureProvider.autoDispose<
        TrainingRunListResult>(
  (ref) async {
    return ref
        .watch(
          trainingRunAdminServiceProvider,
        )
        .listRuns();
  },
);

final activeTrainingDatasetsProvider =
    FutureProvider.autoDispose<
        List<TrainingDatasetChoice>>(
  (ref) async {
    return ref
        .watch(
          trainingRunAdminServiceProvider,
        )
        .listActiveTrainingDatasets();
  },
);

class TrainingRunAdminActions {
  TrainingRunAdminActions(
    this.ref,
  );

  final Ref ref;

  TrainingRunAdminService get _service =>
      ref.read(
        trainingRunAdminServiceProvider,
      );

  void _refresh() {
    ref.invalidate(
      trainingRunListProvider,
    );
  }

  Future<TrainingRunModel> createRun({
    required String algorithm,
    required String datasetKey,
    required String datasetVersion,
    required int modelSpecificationVersion,
    required int trainingConfigVersion,
    String? notes,
  }) async {
    final result =
        await _service.createRun(
      algorithm: algorithm,
      datasetKey: datasetKey,
      datasetVersion: datasetVersion,
      modelSpecificationVersion:
          modelSpecificationVersion,
      trainingConfigVersion:
          trainingConfigVersion,
      notes: notes,
    );

    _refresh();

    return result;
  }

  Future<TrainingRunModel> startRun(
    String identifier,
  ) async {
    final result =
        await _service.startRun(
      identifier,
    );

    _refresh();

    return result;
  }
}

final trainingRunAdminActionsProvider =
    Provider<TrainingRunAdminActions>(
  (ref) {
    return TrainingRunAdminActions(
      ref,
    );
  },
);