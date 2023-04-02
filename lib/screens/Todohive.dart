import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Nhive extends StatefulWidget {
  @override
  State<Nhive> createState() => _NhiveState();
}

class _NhiveState extends State<Nhive> {
  bool Switchval = false;
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
                  decoration:
                      InputDecoration(hintText: 'Title'.tr().toString()),
                ),
                TextField(
                  controller: task,
                  decoration:
                      InputDecoration(hintText: 'Decrption'.tr().toString()),
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
                    child: Text(itemkey == null
                        ? 'Create Task'.tr().toString()
                        : 'Update Task'.tr().toString()))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ElevatedButton(
            onLongPress: () async {
              context.locale = Locale('en', 'HI');
            },
            onPressed: () async {
              context.locale = Locale('en', 'GB');
            },
            child: Text('dara')),
        title: Text('TODO'.tr().toString().toUpperCase()),
        actions: [
          Switch(
              onChanged: (bool value) {
                setState(() {
                  this.Switchval = value;
                });
                if (Switchval == false) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
              },
              value: this.Switchval),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: Text('NO Task'.tr().toString()))
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
