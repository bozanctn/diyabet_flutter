import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ArticlePage3(),
  ));
}

class ArticlePage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Title'),
        backgroundColor: Color.fromRGBO(19, 69, 122, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter Development',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'by John Doe',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Published on August 28, 2024',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Flutter is an open-source UI software development kit created by Google. '
                      'It is used to develop cross-platform applications for Android, iOS, Linux, '
                      'macOS, Windows, Google Fuchsia, and the web from a single codebase. '
                      'First described in 2015, Flutter was released in May 2017.\n\n'
                      'Flutter uses Dart programming language, also developed by Google, '
                      'and the framework consists of two major components: an SDK and a UI library. '
                      'The SDK provides tools to compile your code into native machine code '
                      'for mobile devices, while the UI library provides pre-designed '
                      'widgets for building user interfaces.\n\n'
                      'One of the major advantages of Flutter is the "hot reload" feature, '
                      'which allows developers to see the changes they make in real-time, '
                      'without restarting the app. This can greatly speed up the development '
                      'process, making Flutter a popular choice among developers.\n\n'
                      'In addition, Flutter offers a wide range of widgets and tools to '
                      'customize the look and feel of your app, allowing for beautiful '
                      'and consistent UIs across different platforms. Flutter\'s popularity '
                      'continues to grow as more and more developers recognize its potential '
                      'for creating high-quality apps with less effort.',
                  style: TextStyle(fontSize: 16.0, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
