import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final List<String> _people = [];
  String _selectedSplitType = 'Equal';

  void _addPerson(String name) {
    if (name.isNotEmpty) {
      setState(() {
        _people.add(name);
      });
    }
  }

  void _removePerson(int index) {
    setState(() {
      _people.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            // Calendar
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSplitType,
              items: ['Equal', 'Percentage', 'Custom']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSplitType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Split Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              onSubmitted: _addPerson,
              decoration: InputDecoration(
                labelText: 'Add Person',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.add),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _people.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_people[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () => _removePerson(index),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle group creation logic here
                print('Group Name: ${_groupNameController.text}');
                print('Split Type: $_selectedSplitType');
                print('People: $_people');
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}