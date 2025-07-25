import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoTask {
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  bool isCompleted;

  TodoTask({
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = Priority.medium,
    this.isCompleted = false,
  });
}

enum Priority { low, medium, high }

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<TodoTask> _tasks = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Priority _selectedPriority = Priority.medium;
  String _filter = 'all';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tasks.add(TodoTask(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDate,
          priority: _selectedPriority,
        ));
        _titleController.clear();
        _descriptionController.clear();
        _selectedDate = DateTime.now();
        _selectedPriority = Priority.medium;
      });
      Navigator.of(context).pop();
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _editTask(int index) {
    final task = _tasks[index];
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedDate = task.dueDate;
    _selectedPriority = task.priority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildTaskForm(
            onSave: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _tasks[index] = TodoTask(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDate,
                    priority: _selectedPriority,
                    isCompleted: task.isCompleted,
                  );
                });
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskForm({required VoidCallback onSave}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Priority:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('Low'),
                  selected: _selectedPriority == Priority.low,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = Priority.low;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: _selectedPriority == Priority.medium,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = Priority.medium;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('High'),
                  selected: _selectedPriority == Priority.high,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = Priority.high;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSave,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  List<TodoTask> get _filteredTasks {
    switch (_filter) {
      case 'completed':
        return _tasks.where((task) => task.isCompleted).toList();
      case 'pending':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'high':
        return _tasks.where((task) => task.priority == Priority.high).toList();
      case 'today':
        final today = DateTime.now();
        return _tasks.where((task) => 
          task.dueDate.year == today.year &&
          task.dueDate.month == today.month &&
          task.dueDate.day == today.day
        ).toList();
      default:
        return _tasks;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced To-Do App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'high',
                child: Text('High Priority'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('Due Today'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildTaskForm(onSave: _addTask),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: _buildTaskForm(onSave: _addTask),
                          );
                        },
                      );
                    },
                    child: const Text('Add your first task'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Dismissible(
                  key: Key(task.title + index.toString()),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) => _deleteTask(_tasks.indexOf(task)),
                  child: Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(
                            _tasks.indexOf(task)),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty)
                            Text(task.description),
                          Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                            style: TextStyle(
                              color: task.dueDate.isBefore(DateTime.now()) &&
                                      !task.isCompleted
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: _getPriorityColor(task.priority),
                            size: 16,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTask(_tasks.indexOf(task)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}