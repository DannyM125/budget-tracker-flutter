import 'package:budget_app/utils/category.dart';
import 'package:budget_app/utils/transactions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/color_utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Category> categories = Category.getInstance();

  void _pickColor() async {
    Color? newColor = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Primary Color'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.yellow,
                  Colors.purple,
                  Colors.teal,
                  Colors.black,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );

    if (newColor != null) {
      setState(() {
        ColorUtils.setPrimaryColor(newColor);
      });
    }
  }

  void _addNewCategory() async {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Select Color:'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.yellow,
                  Colors.purple,
                  Colors.teal,
                  Colors.pink,
                  Colors.indigo,
                  Colors.cyan,
                  Colors.amber,
                  Colors.deepOrange,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'color': selectedColor,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      }),
    ).then((result) {
      if (result != null) {
        setState(() {
          categories.add(Category(
            name: result['name'],
            color: result['color'],
          ));
          // TODO: Save categories to persistent storage
          _saveCategories();
        });
      }
    });
  }

  void _editCategory(int index) async {
    final categoryToEdit = categories[index];

    final TextEditingController _editCategoryController =
        TextEditingController();
    _editCategoryController.text = categoryToEdit.name;
    Color selectedColor = categoryToEdit.color;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField for editing the category name
                TextField(
                  controller: _editCategoryController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 20),
                const Text('Select Color:'),
                const SizedBox(height: 10),

                // Color Picker
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.orange,
                    Colors.yellow,
                    Colors.purple,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                    Colors.cyan,
                    Colors.amber,
                    Colors.deepOrange,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor.value == color.value
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              // Save button
              ElevatedButton(
                onPressed: () {
                  final newCategoryName = _editCategoryController.text.trim();
                  if (newCategoryName.isNotEmpty &&
                      (newCategoryName != categoryToEdit.name ||
                          selectedColor != categoryToEdit.color)) {
                    // Update the category's name and color in the provider (update related transactions)
                    Provider.of<TransactionProvider>(context, listen: false)
                        .updateTransactionsByCategory(
                            categoryToEdit.name, newCategoryName);

                    setState(() {
                      categoryToEdit.name = newCategoryName; // Update the name
                      categoryToEdit.color = selectedColor; // Update the color
                    });

                    _saveCategories(); // Save the updated categories list to persistent storage
                  }
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCategory(int index) {
    final categoryToDelete = categories[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content:
            Text('Are you sure you want to delete "${categoryToDelete.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove all transactions related to this category
              Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransactionsByCategory(categoryToDelete);

              setState(() {
                categories.removeAt(index);
              });

              _saveCategories(); // Save the updated categories list
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveCategories() {
    // TODO: Implement saving categories to SharedPreferences or other storage
    // Example implementation with shared_preferences:
    //
    // final prefs = await SharedPreferences.getInstance();
    // final categoriesJson = categories.map((c) => c.toJson()).toList();
    // await prefs.setString('categories', jsonEncode(categoriesJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Theme Section
            const Text('App Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickColor,
              icon: const Icon(Icons.color_lens, color: Colors.white),
              label: const Text('Change App Color',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 32),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Categories',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addNewCategory,
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label:
                      const Text('Add', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.primaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Categories List
            Expanded(
              child: categories.isEmpty
                  ? const Center(child: Text('No categories added yet.'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: categories[index].color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              categories[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _editCategory(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteCategory(index),
                                ),
                              ],
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
