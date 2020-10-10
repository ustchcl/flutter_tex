import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_tex/src/utils/core_utils.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class TeXViewState extends State<TeXView> with AutomaticKeepAliveClientMixin {
  WebViewPlusController _controller;
  double _height = 1;
  String _lastData;
  bool _pageLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    updateKeepAlive();
    _buildTeXView();
    return IndexedStack(
      index: widget.loadingWidgetBuilder?.call(context) != null
          ? _height == 1 ? 1 : 0
          : 0,
      children: <Widget>[
        SizedBox(
          height: _height,
          child: WebViewPlus(
            initialUrl:
                "packages/flutter_tex/js/${widget.renderingEngine?.name ?? 'katex'}/index.html",
            onWebViewCreated: (controller) {
              this._controller = controller;
            },
            javascriptChannels: jsChannels(),
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
        widget.loadingWidgetBuilder?.call(context) ?? SizedBox.shrink()
      ],
    );
  }

  Set<JavascriptChannel> jsChannels() {
    return Set.from([
      JavascriptChannel(
          name: "InputCallback",
          onMessageReceived: (jm) {
            try {
              var json = jsonDecode(jm.message.replaceAll("'", '"'));
              widget.inputCallback?.call(json);
            } catch (e) {
              print(e);
            }
          }),
      JavascriptChannel(
          name: 'TeXViewRenderedCallback',
          onMessageReceived: (_) async {
            double height = await _controller.getHeight();
            if (this._height != height)
              setState(() {
                this._height = height;
              });
            widget.onRenderFinished?.call(height);
          }),
      JavascriptChannel(
          name: 'OnTapCallback',
          onMessageReceived: (jm) {
            widget.child.onTapManager(jm.message);
          }),
      JavascriptChannel(
          name: 'OnPageLoaded',
          onMessageReceived: (jm) {
            _pageLoaded = true;
            _buildTeXView();
          })
    ]);
  }

  void _buildTeXView() {
    if (_pageLoaded && _controller != null && getRawData(widget) != _lastData) {
      if (widget.loadingWidgetBuilder != null) _height = 1;
      _controller.evaluateJavascript(
          "var jsonData = " + getRawData(widget) + ";initView(jsonData);");
      this._lastData = getRawData(widget);
    }
  }
}
