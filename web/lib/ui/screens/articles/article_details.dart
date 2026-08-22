import 'package:immozen/data/model/article_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticleDetails extends StatelessWidget {
  const ArticleDetails({required this.article, super.key});
  final ArticleModel article;
  static Route route(RouteSettings settings) {
    final arguments = settings.arguments! as Map;
    return BlurredRouter(
      builder: (context) {
        return ArticleDetails(
          article: arguments['model'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  10,
                ),
                child: SizedBox(
                  width: context.screenWidth,
                  height: 200.rh(
                    context,
                  ),
                  child: UiUtils.getImage(
                    article.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),
              Text(article.date.toString())
                  .size(context.font.small)
                  .color(context.color.textLightColor),
              const SizedBox(
                height: 12,
              ),
              Text(
                (article.title ?? '').firstUpperCase(),
              )
                  .size(
                    context.font.larger,
                  )
                  .color(
                    context.color.textColorDark,
                  )
                  .bold(
                    weight: FontWeight.w500,
                  ),
              SizedBox(
                height: 4.rh(context),
              ),
              Html(data: article.description ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
