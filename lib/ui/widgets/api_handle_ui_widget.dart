import 'package:flutter/material.dart';
import 'package:cricket/common/common.dart';
import 'package:cricket/ui/ui.dart';

class ApiHandleUiWidget extends StatelessWidget {
  final Widget loadingWidget;
  final Widget successWidget;
  final Widget errorWidget;
  final Widget emptyWidget;
  final Widget networkError;
  final Widget holdWidget;
  final ApiCallStatus apiCallStatus;

  const ApiHandleUiWidget({
    super.key,
    required this.successWidget,
    required this.apiCallStatus,
    this.loadingWidget = const LoadingWidget(),
    this.errorWidget = const SomeThingErrorWidget(),
    this.emptyWidget = const EmptyDataWidget(),
    this.networkError = const NetworkErrorWidget(),
    this.holdWidget = const LoadingWidget(),
  });

  @override
  Widget build(BuildContext context) {
    if (apiCallStatus == ApiCallStatus.loading) {
      return loadingWidget;
    } else if (apiCallStatus == ApiCallStatus.error) {
      return errorWidget;
    } else if (apiCallStatus == ApiCallStatus.empty) {
      return emptyWidget;
    } else if (apiCallStatus == ApiCallStatus.networkError) {
      return networkError;
    } else if (apiCallStatus == ApiCallStatus.holding) {
      return holdWidget;
    }
    return successWidget;
  }
}
