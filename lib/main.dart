import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert'; // For encoding/decoding JSON
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WishlistScreen(),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, dynamic>> _wishlist = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWishlist(); // Load wishlist when the app starts
  }

  // Load wishlist from local storage
  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistData = prefs.getString('wishlist');
    if (wishlistData != null) {
      setState(() {
        _wishlist.addAll(List<Map<String, dynamic>>.from(json.decode(wishlistData)));
      });
    }
  }

  // Save wishlist to local storage
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('wishlist', json.encode(_wishlist));
  }

  void _addWishlistItem(String title) {
    if (title.isEmpty) return;

    setState(() {
      _wishlist.add({
        'id': _generateUUID(),
        'title': title,
        'isCompleted': false,
      });
    });

    _saveWishlist();  // Save after adding
    _controller.clear();
  }

  String _generateUUID() {
    var random = Random();
    return '${random.nextInt(10000)}-${random.nextInt(1000)}-${random.nextInt(1000)}';
  }

  void _toggleCompletion(String id) {
    setState(() {
      final item = _wishlist.firstWhere((element) => element['id'] == id);
      item['isCompleted'] = !item['isCompleted'];
    });

    _saveWishlist();  // Save after toggling
  }

  void _deleteWishlistItem(String id) {
    setState(() {
      _wishlist.removeWhere((element) => element['id'] == id);
    });

    _saveWishlist();  // Save after deleting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Wishlist'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add your wishlist here...',
                labelStyle: TextStyle(color: Colors.purpleAccent),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addWishlistItem(_controller.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _wishlist.length,
                itemBuilder: (context, index) {
                  final item = _wishlist[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Checkbox(
                        value: item['isCompleted'],
                        onChanged: (_) => _toggleCompletion(item['id']),
                        activeColor: Colors.purple,
                      ),
                      title: Text(
                        item['title'],
                        style: TextStyle(
                          decoration: item['isCompleted']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: item['isCompleted'] ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWishlistItem(item['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
