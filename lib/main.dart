import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SQFLite",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journal = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshJournal();
  }

  void _refreshJournal() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      _journal = data;
      _isLoading = false;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }
    await DatabaseHelper.createItem(_titleController.text, _descriptionController.text);
    _refreshJournal();
  }

  Future<void> _updateItem(int id) async {
    await DatabaseHelper.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
    );
    _refreshJournal();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal = _journal.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(hintText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                } else {
                  await _updateItem(id);
                }
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);
    _refreshJournal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("SQFLite")),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _journal.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange[200],
          margin: EdgeInsets.all(15),
          child: ListTile(
            title: Text(_journal[index]['title']),
            subtitle: Text(_journal[index]['description']),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showForm(_journal[index]['id']),
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _deleteItem(_journal[index]['id']),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
