import 'package:immozen/data/model/home_page_data_model.dart';
import 'package:immozen/data/repositories/home_screen_data_repository.dart';
import 'package:immozen/exports/main_export.dart';

abstract class FetchHomePageDataState {}

class FetchHomePageDataInitial extends FetchHomePageDataState {}

class FetchHomePageDataLoading extends FetchHomePageDataState {}

class FetchHomePageDataSuccess extends FetchHomePageDataState {
  FetchHomePageDataSuccess({
    required this.homePageDataModel,
  });

  final HomePageDataModel homePageDataModel;

  FetchHomePageDataSuccess copyWith() {
    HomePageDataModel? homePageDataModel;
    return FetchHomePageDataSuccess(
      homePageDataModel: homePageDataModel ?? this.homePageDataModel,
    );
  }
}

class FetchHomePageDataFailure extends FetchHomePageDataState {
  FetchHomePageDataFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchHomePageDataCubit extends Cubit<FetchHomePageDataState> {
  FetchHomePageDataCubit() : super(FetchHomePageDataInitial());
  final HomeScreenDataRepository _homeScreenDataRepository =
      HomeScreenDataRepository();

  Future<void> fetch({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchHomePageDataLoading());
      final (homepageDataModel: homePageDataModel) =
          await _homeScreenDataRepository.fetchAllHomePageData();
      emit(
        FetchHomePageDataSuccess(
          homePageDataModel: homePageDataModel,
        ),
      );
      print("sucess emiting the class");
    } catch (e) {
      print("error home page");
      print(e);
      if (!isClosed) emit(FetchHomePageDataFailure(e));
    }
  }

  bool isHomePageDataEmpty() {
    if (state is FetchHomePageDataSuccess) {
      final data = (state as FetchHomePageDataSuccess).homePageDataModel;

      bool isEmpty = false;

      if (data.featuredSection.isEmpty) {
        print("featuredSection is empty");
        isEmpty = true;
      }
      if (data.mostLikedProperties.isEmpty) {
        print("mostLikedProperties is empty");
        isEmpty = true;
      }
      if (data.mostViewedProperties.isEmpty) {
        print("mostViewedProperties is empty");
        isEmpty = true;
      }
      if (data.projectSection.isEmpty) {
        print("projectSection is empty");
        isEmpty = true;
      }
      if (data.sliderSection.isEmpty) {
        print("sliderSection is empty");
        isEmpty = true;
      }
      if (data.categoriesSection.isEmpty) {
        print("categoriesSection is empty");
        isEmpty = true;
      }
      if (data.articleSection.isEmpty) {
        print("articleSection is empty");
        isEmpty = true;
      }
      if (data.agentsList.isEmpty) {
        print("agentsList is empty");
        isEmpty = true;
      }

      return isEmpty;
    }
    return true;
  }
}
