import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/risk_guideline_model.dart';
import '../services/risk_guideline_admin_service.dart';

final riskGuidelineAdminServiceProvider =
    Provider<RiskGuidelineAdminService>(
  (ref) {
    return RiskGuidelineAdminService(
      ref.watch(dioProvider),
    );
  },
);

final riskGuidelineListProvider =
    FutureProvider.autoDispose<RiskGuidelineListResult>(
  (ref) async {
    return ref
        .watch(
          riskGuidelineAdminServiceProvider,
        )
        .listGuidelines();
  },
);

final publishedRiskGuidelineProvider =
    FutureProvider.autoDispose<RiskGuidelineModel?>(
  (ref) async {
    return ref
        .watch(
          riskGuidelineAdminServiceProvider,
        )
        .getPublishedGuideline();
  },
);

final riskGuidelineHistoryProvider =
    FutureProvider.autoDispose<RiskGuidelineListResult>(
  (ref) async {
    return ref
        .watch(
          riskGuidelineAdminServiceProvider,
        )
        .getHistory();
  },
);

final riskGuidelineDetailProvider =
    FutureProvider.autoDispose
        .family<RiskGuidelineModel, String>(
  (ref, id) async {
    return ref
        .watch(
          riskGuidelineAdminServiceProvider,
        )
        .getGuideline(id);
  },
);

class RiskGuidelineAdminActions {
  RiskGuidelineAdminActions(
    this.ref,
  );

  final Ref ref;

  RiskGuidelineAdminService get _service =>
      ref.read(
        riskGuidelineAdminServiceProvider,
      );

  void _refresh() {
    ref.invalidate(
      riskGuidelineListProvider,
    );

    ref.invalidate(
      publishedRiskGuidelineProvider,
    );

    ref.invalidate(
      riskGuidelineHistoryProvider,
    );
  }

  Future<RiskGuidelineModel> create(
    Map<String, dynamic> payload,
  ) async {
    final result =
        await _service.createGuideline(
      payload,
    );

    _refresh();

    return result;
  }

  Future<RiskGuidelineModel>
      createNewVersion({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final result =
        await _service.createNewVersion(
      id: id,
      payload: payload,
    );

    _refresh();

    return result;
  }

  Future<RiskGuidelineModel> update({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final result =
        await _service.updateGuideline(
      id: id,
      payload: payload,
    );

    ref.invalidate(
      riskGuidelineDetailProvider(id),
    );

    _refresh();

    return result;
  }

  Future<RiskGuidelineModel> publish(
    String id,
  ) async {
    final result =
        await _service.publishGuideline(
      id,
    );

    ref.invalidate(
      riskGuidelineDetailProvider(id),
    );

    _refresh();

    return result;
  }

  Future<RiskGuidelineModel> archive(
    String id,
  ) async {
    final result =
        await _service.archiveGuideline(
      id,
    );

    ref.invalidate(
      riskGuidelineDetailProvider(id),
    );

    _refresh();

    return result;
  }

  Future<RiskGuidelineModel> rollback(
    String id,
  ) async {
    final result =
        await _service.rollbackGuideline(
      id,
    );

    ref.invalidate(
      riskGuidelineDetailProvider(id),
    );

    _refresh();

    return result;
  }
}

final riskGuidelineAdminActionsProvider =
    Provider<RiskGuidelineAdminActions>(
  (ref) {
    return RiskGuidelineAdminActions(
      ref,
    );
  },
);