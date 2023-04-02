import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// void main() async {
//   await Hive.initFlutter();
//   await Hive.openBox('todo_box');
//   runApp(MaterialApp(
//     home: Nhive(),
//   ));
// }

class Nhive extends StatefulWidget {
  @override
  State<Nhive> createState() => _NhiveState();
}

class _NhiveState extends State<Nhive> {
  List<Map<String, dynamic>> tasks = [];
  final title = TextEditingController();
  final task = TextEditingController();
  final mytaskbox = Hive.box('todo_box');
  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  Future<void> createTask(Map<String, dynamic> newtask) async {
    await mytaskbox.add(newtask);
    fetchTask();
  }

  void fetchTask() {
    final task_from_hive = mytaskbox.keys.map((key) {
      final value = mytaskbox.get(key);
      return {'id': key, 'title': value['title'], 'task': value['task']};
    }).toList();
    setState(() {
      tasks = task_from_hive.reversed.toList();
    });
  }

  Future<void> updateTask(int itemkey, Map<String, String> uTask) async {
    await mytaskbox.put(itemkey, uTask);
    fetchTask();
  }

  Future<void> deleTask(int itemkey) async {
    await mytaskbox.delete(itemkey);
    fetchTask();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('successfully Deleted')));
  }

  showTask(BuildContext context, int? itemkey) {
    if (itemkey != null) {
      final existing_task =
          tasks.firstWhere((element) => element['id'] == itemkey);
      title.text = existing_task['title'];
      task.text = existing_task['task'];
    }
    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                top: 20,
                left: 20,
                right: 20),
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(hintText: 'Title'),
                ),
                TextField(
                  controller: task,
                  decoration: InputDecoration(hintText: 'Decrption'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async {
                      if (itemkey == null) {
                        createTask({
                          'title': title.text.trim(),
                          'task': task.text.trim()
                        });
                      }
                      if (itemkey != null) {
                        updateTask(
                            itemkey, {'title': title.text, 'task': task.text});
                      }
                      title.text = '';
                      task.text = '';
                      Navigator.of(context).pop();
                    },
                    child:
                        Text(itemkey == null ? 'Create Task' : 'Update Task'))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO'),
      ),
      body: tasks.isEmpty
          ? Center(child: Text('NO Task'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (ctx, index) {
                final mytask = tasks[index];
                return Card(
                    child: ListTile(
                  title: Text(mytask['title']),
                  subtitle: Text(mytask['task']),
                  trailing: Wrap(
                    children: [
                      IconButton(
                          onPressed: () {
                            showTask(context, mytask['id']);
                          },
                          icon: Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            deleTask(mytask['id']);
                          },
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                ));
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTask(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
