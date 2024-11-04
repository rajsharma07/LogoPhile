import 'package:flutter/material.dart';
import 'package:logophile/Models/article.dart';

class ArticleDisplay extends StatelessWidget {
  const ArticleDisplay({super.key, required this.a});
  final Article a;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(a.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              a.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            a.imagePath == ""
                ? const Icon(Icons.image)
                : Image.network(
                    a.imagePath,
                    height: MediaQuery.of(context).size.height * 0.30,
                    fit: BoxFit.contain,
                  ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                a.content,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
