import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/presentation/screens/category_chip.dart';
import 'package:spendeex/providers/add_expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _splitTypes = [
    "Equally",
    "Unequally",
    "By Percentage",
    "By shares",
    "By adjustment",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddExpenseProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Add Expense"),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  provider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Save Expense", style: TextStyle(fontSize: 16)),
            ),
          ),
          body:
              provider.isLoading && provider.userGroups.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupSelection(provider),
                        SizedBox(height: 16),
                        _buildExpenseTitle(provider),
                        SizedBox(height: 16),
                        _buildExpenseDescription(provider),
                        SizedBox(height: 16),
                        AlternativeCategoryWidget(),
                        SizedBox(height: 16),
                        _buildParticipantsSection(provider),
                        SizedBox(height: 16),
                        _buildPaidBySection(provider),
                        SizedBox(height: 16),
                        _buildItemsSection(provider),
                        SizedBox(height: 16),
                        _buildTotalAmount(provider),
                      ],
                    ),
                  ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showSplitTypeBottomSheet(provider),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: Text("Split: ${provider.selectedSplitType}"),
            icon: Icon(Icons.splitscreen),
          ),
        );
      },
    );
  }

  Widget _buildGroupSelection(AddExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Group',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GroupModel>(
              value: provider.selectedGroup,
              hint: Text('Choose a group'),
              isExpanded: true,
              onChanged: (group) {
                if (group != null) {
                  provider.selectGroup(group);
                }
              },
              items:
                  provider.userGroups.map((group) {
                    return DropdownMenuItem<GroupModel>(
                      value: group,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue,
                            child: Text(
                              group.title.isNotEmpty
                                  ? group.title[0].toUpperCase()
                                  : 'G',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  group.title,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${group.participants.length} members',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTitle(AddExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Title',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: provider.updateTitle,
          decoration: InputDecoration(
            hintText: "Enter expense title",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseDescription(AddExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          onChanged: provider.updateDescription,
          decoration: InputDecoration(
            hintText: "Enter description",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(AddExpenseProvider provider) {
    if (provider.selectedGroup == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split Among',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.selectedGroup!.participants.length,
            itemBuilder: (context, index) {
              final participantId = provider.selectedGroup!.participants[index];
              final isSelected = provider.selectedParticipants.contains(
                participantId,
              );

              return GestureDetector(
                onTap: () => provider.toggleParticipant(participantId),
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'User ${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaidBySection(AddExpenseProvider provider) {
    if (provider.selectedGroup == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paid By',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.paidBy.isNotEmpty ? provider.paidBy : null,
              hint: Text('Select who paid'),
              isExpanded: true,
              onChanged: (userId) {
                if (userId != null) {
                  provider.setPaidBy(userId);
                }
              },
              items:
                  provider.selectedGroup!.participants.map((participantId) {
                    return DropdownMenuItem<String>(
                      value: participantId,
                      child: Text(
                        'User ${provider.selectedGroup!.participants.indexOf(participantId) + 1}',
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(AddExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.items.length,
          itemBuilder: (context, index) {
            return ExpenseItemWidget(
              key: ValueKey(index),
              item: provider.items[index],
              index: index,
              onUpdate:
                  (name, amount) =>
                      provider.updateExpenseItem(index, name, amount),
              onRemove:
                  provider.items.length > 1
                      ? () => provider.removeExpenseItem(index)
                      : null,
            );
          },
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: provider.addExpenseItem,
          icon: Icon(Icons.add),
          label: Text("Add Item"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: Colors.blue[50],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount(AddExpenseProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '₹${provider.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showSplitTypeBottomSheet(AddExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Split Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...List.generate(_splitTypes.length, (index) {
                final splitType = _splitTypes[index].toLowerCase();
                final isSelected = provider.selectedSplitType == splitType;

                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(_splitTypes[index]),
                  onTap: () {
                    provider.setSplitType(splitType);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _saveExpense() async {
    final provider = context.read<AddExpenseProvider>();
    final error = await provider.saveExpense();

    if (error == null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }
}

class ExpenseItemWidget extends StatefulWidget {
  final ExpenseItem item;
  final int index;
  final Function(String name, double amount) onUpdate;
  final VoidCallback? onRemove;

  const ExpenseItemWidget({
    Key? key,
    required this.item,
    required this.index,
    required this.onUpdate,
    this.onRemove,
  }) : super(key: key);

  @override
  State<ExpenseItemWidget> createState() => _ExpenseItemWidgetState();
}

class _ExpenseItemWidgetState extends State<ExpenseItemWidget> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _amountController = TextEditingController(
      text: widget.item.amount > 0 ? widget.item.amount.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Item ${widget.index + 1}",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              if (widget.onRemove != null)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: Icon(Icons.delete, color: Colors.red),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: _nameController,
            onChanged: (value) => _updateItem(),
            decoration: InputDecoration(
              hintText: "Enter item name",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _amountController,
            onChanged: (value) => _updateItem(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              prefixText: '₹ ',
            ),
          ),
        ],
      ),
    );
  }

  void _updateItem() {
    final name = _nameController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    widget.onUpdate(name, amount);
  }
}
