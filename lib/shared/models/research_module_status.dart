enum ResearchModuleAvailability {
  available,
  backendPending,
}

class ResearchModuleStatus {
  const ResearchModuleStatus({
    required this.key,
    required this.title,
    required this.description,
    required this.availability,
  });

  final String key;
  final String title;
  final String description;

  final ResearchModuleAvailability
      availability;

  bool get isAvailable {
    return availability ==
        ResearchModuleAvailability.available;
  }

  bool get isBackendPending {
    return availability ==
        ResearchModuleAvailability
            .backendPending;
  }
}

const riskGuidelineModuleStatus =
    ResearchModuleStatus(
  key: 'risk-guidelines',
  title: 'Risk Assessment Guidelines',
  description:
      'Versioned risk thresholds, bands, modifiers, recommendations, publishing, and rollback.',
  availability:
      ResearchModuleAvailability.available,
);

const hydrationGuidelineModuleStatus =
    ResearchModuleStatus(
  key: 'hydration-guidelines',
  title: 'Hydration Guidelines',
  description:
      'Versioned hydration calculation rules, special conditions, limits, and clinical source metadata.',
  availability:
      ResearchModuleAvailability.backendPending,
);