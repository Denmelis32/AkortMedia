// lib/providers/news_providers/news_provider_factory.dart
import 'news_provider.dart';
import 'user_profile_manager.dart';
import 'interaction_coordinator.dart';
import 'repost_manager.dart';
import 'news_data_processor.dart';
import 'news_storage_handler.dart';

class NewsProviderFactory {
  static NewsProvider create() {
    final profileManager = UserProfileManager();
    final interactionCoordinator = InteractionCoordinator();
    final repostManager = RepostManager();
    final dataProcessor = NewsDataProcessor();
    final storageHandler = NewsStorageHandler();

    return NewsProvider(
      profileManager: profileManager,
      interactionCoordinator: interactionCoordinator,
      repostManager: repostManager,
      dataProcessor: dataProcessor,
      storageHandler: storageHandler,
    );
  }

  static NewsProvider createWithCustomDependencies({
    UserProfileManager? profileManager,
    InteractionCoordinator? interactionCoordinator,
    RepostManager? repostManager,
    NewsDataProcessor? dataProcessor,
    NewsStorageHandler? storageHandler,
  }) {
    return NewsProvider(
      profileManager: profileManager ?? UserProfileManager(),
      interactionCoordinator: interactionCoordinator ?? InteractionCoordinator(),
      repostManager: repostManager ?? RepostManager(),
      dataProcessor: dataProcessor ?? NewsDataProcessor(),
      storageHandler: storageHandler ?? NewsStorageHandler(),
    );
  }
}