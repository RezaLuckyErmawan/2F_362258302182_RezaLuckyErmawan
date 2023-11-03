import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

// URL untuk mengambil data dari API
String url = "https://jsonplaceholder.typicode.com/posts";

// Model Post
class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  // Konstruktor untuk menginisialisasi data
  Post(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

  // Factory method untuk memetakan data JSON ke objek Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] ?? 0,
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

// Future untuk mengambil data dari API
Future<List<Post>> fetchPosts() async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    List<Post> posts = body.map((dynamic item) => Post.fromJson(item)).toList();
    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'List of Posts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<List<Post>> posts = fetchPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Memuat data dari API dan menampilkan dalam ListView
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data![index].title),
                      subtitle: Text(snapshot.data![index].body),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Menampilkan pesan jika terjadi error
              return Text("${snapshot.error}");
            }

            // Menampilkan indikator loading saat menunggu data
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
