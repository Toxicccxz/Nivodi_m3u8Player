import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'src/navigation_controls.dart';
import 'src/web_view_stack.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          primary: Colors.blueGrey,
        ),
      ),
      themeMode: ThemeMode.dark, // 设置为暗色主题，如果想随系统变化则使用 ThemeMode.system
      home: const WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://missav.ws/dm223/en'),
      );
  }

  Future<bool> _onWillPop() async {
    // 检查 WebView 是否可以返回到上一个页面
    if (await controller.canGoBack()) {
      // 如果可以，回到上一个页面
      await controller.goBack();
      return false; // 阻止默认的返回行为
    }
    return true; // 否则允许返回退出应用
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 设置返回按钮的处理函数
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter WebView'),
          actions: [
            NavigationControls(controller: controller),
          ],
        ),
        body: WebViewStack(controller: controller),
      ),
    );
  }
}
