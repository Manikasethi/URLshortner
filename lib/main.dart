import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      home: const MyHomePage(title: 'URL Shortener'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter URL to shorten:',
                  hintText: 'https://www.example.com',
                  border: const UnderlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                print("url to shorten is::${controller.text}");
                final shortenedURL = await shortenURL(url: controller.text);
                if (shortenedURL != null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Shortened URL Successfully"),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final uri = Uri.parse(shortenedURL);
                                        if (await canLaunch(uri.toString())) {
                                          print(
                                              "Yes, the URL can be launched...");
                                          await launch(uri.toString());
                                        } else {
                                          print("Unable to open url");
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   const SnackBar(
                                          //     content:
                                          //         Text("Unable to open URL."),
                                          //   ),
                                          // );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        color: Colors.grey.shade300,
                                        child: Text(
                                          shortenedURL,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                              ClipboardData(text: shortenedURL))
                                          .then(
                                        (_) => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'URL is copied to clipboard'),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  controller.clear();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: const Text("Shorten URL"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> shortenURL({required String url}) async {
    try {
      final result = await http.post(
        Uri.parse('https://cleanuri.com/api/v1/shorten'),
        body: {'url': url},
      );
      if (result.statusCode == 200) {
        final jsonResult = jsonDecode(result.body);
        return jsonResult['result_url'];
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
    return null;
  }
}
