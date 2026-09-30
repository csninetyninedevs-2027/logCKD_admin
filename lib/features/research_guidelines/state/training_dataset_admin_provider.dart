import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/training_dataset_model.dart';
import '../services/training_dataset_admin_service.dart';

final trainingDatasetAdminServiceProvider =
    Provider<TrainingDatasetAdminService>(
  (ref) {
    return TrainingDatasetAdminService(
      ref.watch(dioProvider),
    );
  },
);

final trainingDatasetListProvider =
    FutureProvider.autoDispose<
        TrainingDatasetListResult>(
  (ref) async {
    return ref
        .watch(
          trainingDatasetAdminServiceProvider,
        )
        .listDatasets();
  },
);

final trainingDatasetDetailProvider =
    FutureProvider.autoDispose.family<
        TrainingDatasetModel,
        String>(
  (ref, id) async {
    return ref
        .watch(
          trainingDatasetAdminServiceProvider,
        )
        .getDataset(id);
  },
);

final trainingDatasetVersionsProvider =
    FutureProvider.autoDispose.family<
        TrainingDatasetListResult,
        String>(
  (ref, datasetKey) async {
    return ref
        .watch(
          trainingDatasetAdminServiceProvider,
        )
        .getVersions(datasetKey);
  },
);

class TrainingDatasetAdminActions {
  TrainingDatasetAdminActions(
    this.ref,
  );

  final Ref ref;

  TrainingDatasetAdminService get _service =>
      ref.read(
        trainingDatasetAdminServiceProvider,
      );

  Future<TrainingDatasetModel> activate(
    String id,
  ) async {
    final result =
        await _service.activate(id);

    _refresh();

    return result;
  }

  Future<TrainingDatasetModel> deactivate(
    String id,
  ) async {
    final result =
        await _service.deactivate(id);

    _refresh();

    return result;
  }

  Future<TrainingDatasetModel> archive(
    String id,
  ) async {
    final result =
        await _service.archive(id);

    _refresh();

    return result;
  }

  void _refresh() {
    ref.invalidate(
      trainingDatasetListProvider,
    );
  }
}

final trainingDatasetAdminActionsProvider =
    Provider<TrainingDatasetAdminActions>(
  (ref) {
    return TrainingDatasetAdminActions(
      ref,
    );
  },
);