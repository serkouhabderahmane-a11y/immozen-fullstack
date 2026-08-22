import 'package:immozen/data/model/agent/agent_model.dart';
import 'package:immozen/data/model/article_model.dart';
import 'package:immozen/data/model/category.dart';
import 'package:immozen/data/model/home_slider.dart';
import 'package:immozen/data/model/project_model.dart';
import 'package:immozen/data/model/property_model.dart';
import 'package:immozen/utils/admob/native_ad_manager.dart';

class HomePageDataModel implements NativeAdWidgetContainer {
  const HomePageDataModel({
    required this.featuredSection,
    required this.mostLikedProperties,
    required this.mostViewedProperties,
    required this.projectSection,
    required this.sliderSection,
    required this.categoriesSection,
    required this.articleSection,
    required this.agentsList,
  });

  HomePageDataModel.fromJson(Map<String, dynamic> json)
      : featuredSection = (json['featured_section'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PropertyModel.fromMap)
            .toList(),
        mostLikedProperties = (json['most_liked_properties'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PropertyModel.fromMap)
            .toList(),
        mostViewedProperties = (json['most_viewed_properties'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(PropertyModel.fromMap)
            .toList(),
        projectSection = (json['project_section'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ProjectModel.fromMap)
            .toList(),
        sliderSection = (json['slider_section'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(HomeSlider.fromJson)
            .toList(),
        categoriesSection = (json['categories_section'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(Category.fromJson)
            .toList(),
        articleSection = (json['article_section'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ArticleModel.fromJson)
            .toList(),
        agentsList = (json['agents_list'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(AgentModel.fromJson)
            .toList();

  final List<PropertyModel> featuredSection;
  final List<PropertyModel> mostLikedProperties;
  final List<PropertyModel> mostViewedProperties;
  final List<ProjectModel> projectSection;
  final List<HomeSlider> sliderSection;
  final List<Category> categoriesSection;
  final List<ArticleModel> articleSection;
  final List<AgentModel> agentsList;

  HomePageDataModel copyWith({
    List<PropertyModel>? featuredSection,
    List<PropertyModel>? mostLikedProperties,
    List<PropertyModel>? mostViewedProperties,
    List<ProjectModel>? projectSection,
    List<HomeSlider>? sliderSection,
    List<Category>? categoriesSection,
    List<ArticleModel>? articleSection,
    List<AgentModel>? agentsList,
  }) {
    return HomePageDataModel(
      projectSection: projectSection ?? this.projectSection,
      mostLikedProperties: mostLikedProperties ?? this.mostLikedProperties,
      featuredSection: featuredSection ?? this.featuredSection,
      mostViewedProperties: mostViewedProperties ?? this.mostViewedProperties,
      sliderSection: sliderSection ?? this.sliderSection,
      categoriesSection: categoriesSection ?? this.categoriesSection,
      articleSection: articleSection ?? this.articleSection,
      agentsList: agentsList ?? this.agentsList,
    );
  }
}
