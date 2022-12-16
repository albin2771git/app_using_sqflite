import 'package:app_using_sqflite/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter TODO APP',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> data = [];

  bool isLoading = true;

  void refreshData() async {
    final data_entered = await Sql_helper.getItems();
    setState(() {
      data = data_entered;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    refreshData();
    super.initState();
  }

  final TextEditingController title_controller = TextEditingController();
  final TextEditingController description_controller = TextEditingController();

  void showform(int? id) async {
    if (id != null) {
      final existingData = data.firstWhere((element) => element['id'] == id);
      title_controller.text = existingData['title'];
      description_controller.text = existingData['description'];
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: title_controller,
                    decoration: InputDecoration(hintText: 'Title'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: description_controller,
                    decoration: InputDecoration(hintText: 'Description'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await addItem();
                        }
                        if (id != null) {
                          await updateItem(id);
                        }
                        title_controller.text = '';
                        description_controller.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'create new' : 'Update'))
                ],
              ),
            ));
  }

  Future<void> addItem() async {
    await Sql_helper.createItem(
        title_controller.text, description_controller.text);
    refreshData();
  }

  Future<void> updateItem(int id) async {
    await Sql_helper.updateitem(
        id, title_controller.text, description_controller.text);
    refreshData();
  }

  //delete an item
  void deleteItem(int id) async {
    await Sql_helper.deleteItem(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sucessfully deleted a data')));
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Flutter SqfLite'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => Card(
                color: Colors.purple[280],
                margin: EdgeInsets.all(13),
                child: ListTile(
                  title: Text(data[index]['title']),
                  subtitle: Text(data[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => showform(data[index]['id']),
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => deleteItem(data[index]['id']),
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showform(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
