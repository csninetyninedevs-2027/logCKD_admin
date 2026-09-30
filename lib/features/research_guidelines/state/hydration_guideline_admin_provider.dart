import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/hydration_guideline_model.dart';
import '../services/hydration_guideline_admin_service.dart';

final hydrationGuidelineAdminServiceProvider =
    Provider<HydrationGuidelineAdminService>(
  (ref) {
    return HydrationGuidelineAdminService(
      ref.watch(dioProvider),
    );
  },
);

final hydrationGuidelineListProvider =
    FutureProvider.autoDispose<
        HydrationGuidelineVersionListResult>(
  (ref) async {
    return ref
        .watch(
          hydrationGuidelineAdminServiceProvider,
        )
        .listVersions();
  },
);

final publishedHydrationGuidelineProvider =
    FutureProvider.autoDispose<
        HydrationGuidelineVersion?>(
  (ref) async {
    return ref
        .watch(
          hydrationGuidelineAdminServiceProvider,
        )
        .getPublishedVersion();
  },
);

final hydrationGuidelineHistoryProvider =
    FutureProvider.autoDispose<
        HydrationGuidelineVersionListResult>(
  (ref) async {
    return ref
        .watch(
          hydrationGuidelineAdminServiceProvider,
        )
        .getHistory();
  },
);

final hydrationGuidelineVersionProvider =
    FutureProvider.autoDispose
        .family<
            HydrationGuidelineVersion,
            int>(
  (ref, version) async {
    return ref
        .watch(
          hydrationGuidelineAdminServiceProvider,
        )
        .getVersion(version);
  },
);

class HydrationGuidelineAdminActions {
  HydrationGuidelineAdminActions(
    this.ref,
  );

  final Ref ref;

  HydrationGuidelineAdminService
      get _service =>
          ref.read(
            hydrationGuidelineAdminServiceProvider,
          );

  void _refreshBase() {
    ref.invalidate(
      hydrationGuidelineListProvider,
    );

    ref.invalidate(
      publishedHydrationGuidelineProvider,
    );

    ref.invalidate(
      hydrationGuidelineHistoryProvider,
    );
  }

  Future<HydrationGuidelineVersion>
      createNewVersion(
    int sourceVersion,
  ) async {
    final result =
        await _service.createNewVersion(
      sourceVersion,
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        sourceVersion,
      ),
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        result.version,
      ),
    );

    _refreshBase();

    return result;
  }

  Future<HydrationGuidelineRule>
      updateRule({
    required String ruleId,
    required Map<String, dynamic> payload,
  }) async {
    final result =
        await _service.updateRule(
      ruleId: ruleId,
      payload: payload,
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        result.version,
      ),
    );

    _refreshBase();

    return result;
  }

  Future<void> publish(
    int version,
  ) async {
    await _service.publishVersion(
      version,
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        version,
      ),
    );

    _refreshBase();
  }

  Future<void> archive(
    int version,
  ) async {
    await _service.archiveVersion(
      version,
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        version,
      ),
    );

    _refreshBase();
  }

  Future<void> rollback(
    int version,
  ) async {
    await _service.rollbackVersion(
      version,
    );

    ref.invalidate(
      hydrationGuidelineVersionProvider(
        version,
      ),
    );

    _refreshBase();
  }
}

final hydrationGuidelineAdminActionsProvider =
    Provider<
        HydrationGuidelineAdminActions>(
  (ref) {
    return HydrationGuidelineAdminActions(
      ref,
    );
  },
);
