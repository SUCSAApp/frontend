import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeleteProductPage extends StatefulWidget {
  @override
  _DeleteProductPageState createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  List<Map<String, dynamic>> apiItems = [];
  List<int> selectedItems = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    final response = await http.get(
      Uri.parse('http://cms.sucsa.org:8005/api/items'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> fetchedItems = json.decode(responseBody);

      setState(() {
        apiItems = fetchedItems.map((item) => {
          'name': item['itemName'] ?? 'Unnamed Item',
          'id': item['itemId'].toString(),
          'stockQuantity': item['stockQuantity'].toString(),
          'category': item['category'] ?? 'No Category',
        }).toList();
      });
    } else {
      print('Failed to load items from API');
    }
  }
  Future<void> deleteItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }
    await Future.wait(selectedItems.map((itemId) async {
      try {
        final response = await http.delete(
          Uri.parse('http://cms.sucsa.org:8005/api/items/$itemId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          print('Item with ID $itemId deleted successfully.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item delete successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {

          print('Failed to delete item with ID $itemId. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          if (response.statusCode == 400) {
            final responseBody = json.decode(response.body);
            if (responseBody['message'].contains('DataIntegrityViolationException')) {
              print('Item with ID $itemId cannot be deleted due to database constraints.');
            } else if (responseBody['message'].contains('No class org.sucsa.cms.entity.Item entity with id')) {
              print('Item with ID $itemId does not exist.');
            }
          }
        }
      } catch (e) {
        print('Exception occurred while trying to delete item with ID $itemId: $e');
      }
    }));
    setState(() {
      selectedItems.clear();
      fetchItems();
    });
  }



  Future<void> updateItem(int itemId, String name, String description) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    final response = await http.put(
      Uri.parse('http://cms.sucsa.org:8005/api/items/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      print('Item with ID $itemId updated successfully.');
      fetchItems();
    } else {
      print('Failed to update item with ID $itemId');
    }
  }





  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物品列表', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), backgroundColor: Color.fromRGBO(29,32,136,1.0),),

      body: SingleChildScrollView(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Stock Quantity')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Select')),
              ],
              rows: apiItems.map((item) {
                final itemId = int.tryParse(item['id'] ?? '') ?? -1;

                return DataRow(
                  cells: [
                    DataCell(Text(item['name'])),
                    DataCell(Text(item['stockQuantity'])),
                    DataCell(Text(item['category'])),
                    DataCell(
                      Checkbox(
                        value: selectedItems.contains(itemId),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedItems.contains(itemId)) {
                                selectedItems.add(itemId);
                              }
                            } else {
                              selectedItems.remove(itemId);
                            }
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedItems.isNotEmpty ? deleteItems : null,
        tooltip: 'Delete Selected Items',
        child: Icon(Icons.delete), backgroundColor: Colors.red,
      ),
    );
  }

}
