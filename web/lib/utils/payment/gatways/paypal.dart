import 'package:immozen/data/model/subscription_pacakage_model.dart';
import 'package:immozen/exports/main_export.dart';
import 'package:flutter/material.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
//import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
/*
class PaypalWidget extends StatefulWidget {
  const PaypalWidget({
    required this.pacakge,
    super.key,
    this.onSuccess,
    this.onFail,
  });
  final SubscriptionPackageModel pacakge;
  final Function(dynamic msg)? onSuccess;
  final Function(dynamic msg)? onFail;

  @override
  State<PaypalWidget> createState() => _PaypalWidgetState();
}

class _PaypalWidgetState extends State<PaypalWidget> {
  late final WebViewController controllerGlobal;
  bool isBack = true;

  @override
  void initState() {
    webViewInitiliased();
    super.initState();
  }

  webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features
    // ignore: cascade_invocations
    controller
      ..enableZoom(false)
      ..loadRequest(
        Uri.parse(
          '${AppSettings.baseUrl}${Api.paypal}?package_id=${widget.pacakge.id}&amount=${widget.pacakge.price}',
        ),
        headers: {'Authorization': 'Bearer ${HiveUtils.getJWT()}'},
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            final uri = Uri.parse(change.url ?? '');
            final payerID = uri.queryParameters['PayerID'];
            if (uri.host == Uri.parse(AppSettings.baseUrl).host &&
                uri.pathSegments.contains('app_payment_status')) {
              try {
                if (uri.queryParameters['error'] == 'false' &&
                    payerID != null) {
                  widget.onSuccess?.call('Payment Successful');
                } else {
                  Future.delayed(
                    Duration.zero,
                    () {
                      widget.onFail?.call('Payment Failed');
                      Navigator.pop(context);
                    },
                  );
                }
              } catch (e) {
                widget.onFail?.call(e.toString());
                Navigator.pop(context);
              }
            }
          },
        ),
      );

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    controllerGlobal = controller;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isBack,
      onPopInvoked: (didPop) async {
        if (await controllerGlobal.canGoBack()) {
          await controllerGlobal.goBack();
          isBack = true;
          setState(() {});
          return;
        } else {
          isBack = false;
          setState(() {});
          return;
        }
      },
      /*onWillPop: () async {
        if (await controllerGlobal.canGoBack()) {
          controllerGlobal.goBack();
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },*/
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: controllerGlobal),
          /*WebView(
            zoomEnabled: false,
            javascriptChannels: const {},
            javascriptMode: JavascriptMode.unrestricted,
            onProgress: (e) {
              setState(() {});
            },
            onWebViewCreated: (WebViewController controller) {
              controllerGlobal = controller;

              controller.loadUrl(
                  "${AppSettings.baseUrl}${Api.paypal}?package_id=${widget.pacakge.id}&amount=${widget.pacakge.price.toString()}",
                  headers: {"Authorization": "Bearer ${HiveUtils.getJWT()}"});
            },
            navigationDelegate: (NavigationRequest request) async {
              await _getResponse(request, widget.onSuccess, widget.onFail);
              return NavigationDecision.navigate;
            },
          ),*/
        ),
      ),
    );
  }
}
*/
