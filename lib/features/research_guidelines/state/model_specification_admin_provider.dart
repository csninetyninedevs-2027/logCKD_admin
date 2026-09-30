import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/model_specification_model.dart';
import '../services/model_specification_admin_service.dart';

final modelSpecificationAdminServiceProvider =
    Provider<ModelSpecificationAdminService>(
  (ref) {
    return ModelSpecificationAdminService(
      ref.watch(dioProvider),
    );
  },
);

final modelSpecificationListProvider =
    FutureProvider.autoDispose<ModelSpecificationListResult>(
  (ref) async {
    return ref
        .watch(modelSpecificationAdminServiceProvider)
        .listSpecifications();
  },
);

class ModelSpecificationAdminActions {
  ModelSpecificationAdminActions(
    this.ref,
  );

  final Ref ref;

  ModelSpecificationAdminService get _service =>
      ref.read(
        modelSpecificationAdminServiceProvider,
      );

  void _refresh() {
    ref.invalidate(
      modelSpecificationListProvider,
    );
  }

  Future<ModelSpecificationModel> create(
    Map<String, dynamic> payload,
  ) async {
    final result =
        await _service.create(payload);

    _refresh();

    return result;
  }

  Future<ModelSpecificationModel>
      updateDocumentation({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final result =
        await _service.updateDocumentation(
      id: id,
      payload: payload,
    );

    _refresh();

    return result;
  }

  Future<ModelSpecificationModel> publish(
    String id,
  ) async {
    final result =
        await _service.publish(id);

    _refresh();

    return result;
  }

  Future<ModelSpecificationModel> archive(
    String id,
  ) async {
    final result =
        await _service.archive(id);

    _refresh();

    return result;
  }
}

final modelSpecificationAdminActionsProvider =
    Provider<ModelSpecificationAdminActions>(
  (ref) {
    return ModelSpecificationAdminActions(ref);
  },
);