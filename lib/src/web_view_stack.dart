import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'streaming_player.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, super.key});

  final WebViewController controller;

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    widget.controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) async {
            setState(() {
              loadingPercentage = 100;
            });
            // 检查页面中是否包含特定格式的链接
            await _checkForM3U8Link();
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            if (host.contains('youtube.com')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Blocking navigation to $host',
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
        },
      );
  }

  // 检查页面中是否包含特定的 .m3u8 链接
Future<void> _checkForM3U8Link() async {
  const script = '''
    (function() {
      const regex = /https:\\/\\/[a-zA-Z0-9./?=_-]+\\.m3u8/g;
      const matches = document.documentElement.innerHTML.match(regex);
      return matches ? matches[0] : '';
    })()
  ''';

  final result = await widget.controller.runJavaScriptReturningResult(script);

  // 使用 trim 去除多余空白字符
  if (result is String && result.trim().isNotEmpty && result != '""') {
    final cleanedResult = result.trim().replaceAll('"', ''); // 去除多余引号
    print("xavier: result = $cleanedResult");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamingPlayer(streamUrl: cleanedResult),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: widget.controller,
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
