import 'package:immozen/data/cubits/Personalized/add_update_personalized_interest.dart';
import 'package:immozen/data/cubits/agents/fetch_agents_cubit.dart';
import 'package:immozen/data/cubits/agents/fetch_project_by_agents_cubit.dart';
import 'package:immozen/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:immozen/data/cubits/agents/fetch_property_by_agent_cubit.dart';
import 'package:immozen/data/cubits/agents/fetch_property_cubit.dart';
import 'package:immozen/data/cubits/fetch_faqs_cubit.dart';
import 'package:immozen/data/cubits/home_page_data_cubit.dart';
import 'package:immozen/data/cubits/property/fetch_city_property_list.dart';
import 'package:immozen/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:nested/nested.dart';

class RegisterCubits {
  List<SingleChildWidget> register() {
    return [
      BlocProvider(create: (context) => DeleteMessageCubit()),
      BlocProvider(create: (context) => LoadChatMessagesCubit()),
      BlocProvider(create: (context) => FetchFaqsCubit()),
      BlocProvider(create: (context) => FetchHomePageDataCubit()),
      BlocProvider(create: (context) => FetchProjectByAgentCubit()),
      BlocProvider(create: (context) => FetchPropertyByAgentCubit()),
      BlocProvider(create: (context) => FetchAgentsPropertyCubit()),
      BlocProvider(create: (context) => FetchAgentsProjectCubit()),
      BlocProvider(create: (context) => FetchAgentsCubit()),
      BlocProvider(create: (context) => AuthCubit()),
      BlocProvider(create: (context) => FetchMyProjectsListCubit()),
      BlocProvider(create: (context) => FetchProjectsCubit()),
      BlocProvider(create: (context) => HomePageInfinityScrollCubit()),
      BlocProvider(create: (context) => LoginCubit()),
      BlocProvider(create: (context) => CompanyCubit()),
      BlocProvider(create: (context) => PropertyCubit()),
      BlocProvider(create: (context) => FetchCategoryCubit()),
      BlocProvider(create: (context) => HouseTypeCubit()),
      BlocProvider(create: (context) => SearchPropertyCubit()),
      BlocProvider(create: (context) => DeleteAccountCubit()),
      BlocProvider(create: (context) => TopViewedPropertyCubit()),
      BlocProvider(create: (context) => ProfileSettingCubit()),
      BlocProvider(create: (context) => NotificationCubit()),
      BlocProvider(create: (context) => AppThemeCubit()),
      BlocProvider(create: (context) => AuthenticationCubit()),
      BlocProvider(create: (context) => FetchHomePropertiesCubit()),
      BlocProvider(create: (context) => FetchTopRatedPropertiesCubit()),
      BlocProvider(create: (context) => FetchMyPropertiesCubit()),
      BlocProvider(create: (context) => FetchPropertyFromCategoryCubit()),
      BlocProvider(create: (context) => FetchNotificationsCubit()),
      BlocProvider(create: (context) => LanguageCubit()),
      BlocProvider(create: (context) => GooglePlaceAutocompleteCubit()),
      BlocProvider(create: (context) => FetchArticlesCubit()),
      BlocProvider(create: (context) => FetchSystemSettingsCubit()),
      BlocProvider(create: (context) => FavoriteIDsCubit()),
      BlocProvider(create: (context) => FetchPromotedPropertiesCubit()),
      BlocProvider(create: (context) => FetchMostViewedPropertiesCubit()),
      BlocProvider(create: (context) => FetchFavoritesCubit()),
      BlocProvider(create: (context) => CreatePropertyCubit()),
      BlocProvider(create: (context) => UserDetailsCubit()),
      BlocProvider(create: (context) => FetchLanguageCubit()),
      BlocProvider(create: (context) => LikedPropertiesCubit()),
      BlocProvider(create: (context) => EnquiryIdsLocalCubit()),
      BlocProvider(create: (context) => AddToFavoriteCubitCubit()),
      BlocProvider(create: (context) => FetchSubscriptionPackagesCubit()),
      BlocProvider(create: (context) => RemoveFavoriteCubit()),
      BlocProvider(create: (context) => GetApiKeysCubit()),
      BlocProvider(create: (context) => FetchCityCategoryCubit()),
      BlocProvider(create: (context) => SetPropertyViewCubit()),
      BlocProvider(create: (context) => GetChatListCubit()),
      BlocProvider(create: (context) => FetchPropertyReportReasonsListCubit()),
      BlocProvider(create: (context) => FetchMostLikedPropertiesCubit()),
      BlocProvider(create: (context) => FetchNearbyPropertiesCubit()),
      BlocProvider(create: (context) => FetchOutdoorFacilityListCubit()),
      BlocProvider(create: (context) => FetchRecentPropertiesCubit()),
      BlocProvider(create: (context) => PropertyEditCubit()),
      BlocProvider(create: (context) => FetchCityPropertyList()),
      BlocProvider(create: (context) => FetchPersonalizedPropertyList()),
      BlocProvider(create: (context) => AddUpdatePersonalizedInterest()),
      BlocProvider(create: (context) => GetSubsctiptionPackageLimitsCubit()),
    ];
  }
}
