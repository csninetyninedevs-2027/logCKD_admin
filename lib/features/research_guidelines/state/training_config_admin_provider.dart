import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/training_config_model.dart';
import '../services/training_config_admin_service.dart';

final trainingConfigAdminServiceProvider =
    Provider<TrainingConfigAdminService>(
  (ref) {
    return TrainingConfigAdminService(
      ref.watch(dioProvider),
    );
  },
);

final trainingConfigListProvider =
    FutureProvider.autoDispose<TrainingConfigListResult>(
  (ref) async {
    return ref
        .watch(trainingConfigAdminServiceProvider)
        .listConfigs();
  },
);

class TrainingConfigAdminActions {
  TrainingConfigAdminActions(
    this.ref,
  );

  final Ref ref;

  TrainingConfigAdminService get _service =>
      ref.read(
        trainingConfigAdminServiceProvider,
      );

  void _refresh() {
    ref.invalidate(
      trainingConfigListProvider,
    );
  }

  Future<TrainingConfigModel> create(
    Map<String, dynamic> payload,
  ) async {
    final result =
        await _service.create(payload);

    _refresh();

    return result;
  }

  Future<TrainingConfigModel> updateNotes({
    required String id,
    String? notes,
  }) async {
    final result =
        await _service.updateNotes(
      id: id,
      notes: notes,
    );

    _refresh();

    return result;
  }

  Future<TrainingConfigModel> publish(
    String id,
  ) async {
    final result =
        await _service.publish(id);

    _refresh();

    return result;
  }

  Future<TrainingConfigModel> archive(
    String id,
  ) async {
    final result =
        await _service.archive(id);

    _refresh();

    return result;
  }
}

final trainingConfigAdminActionsProvider =
    Provider<TrainingConfigAdminActions>(
  (ref) {
    return TrainingConfigAdminActions(ref);
  },
);