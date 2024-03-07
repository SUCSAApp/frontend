import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class NewProductsPage extends StatefulWidget {
  @override
  _NewProductsPageState createState() => _NewProductsPageState();
}

class _NewProductsPageState extends State<NewProductsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token == null) {
        print("Token not found. User might not be logged in.");
        return;
      }
      Uri getAllItemsUrl = Uri.parse('http://cms.sucsa.org:8005/api/items');
      try {
        final allItemsResponse = await http.get(
          getAllItemsUrl,
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          },
        );
        if (allItemsResponse.statusCode == 200) {
          final List<dynamic> items = jsonDecode(allItemsResponse.body);

          final existingItem = items.firstWhere(
                (item) => item['itemName'].toString().toLowerCase() == _nameController.text.toLowerCase(),
            orElse: () => null,
          );
          if (existingItem != null) {
            Uri updateUrl = Uri.parse('http://cms.sucsa.org:8005/api/items/${existingItem['id']}');
            final updateResponse = await http.put(
              updateUrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(<String, dynamic>{
                'itemName': existingItem['itemName'],
                'description': existingItem['description'],
                'category': _selectedCategory,
                'stockQuantity': (int.parse(existingItem['stockQuantity']) + int.parse(_quantityController.text)).toString(),
              }),
            );
            if (updateResponse.statusCode == 200) {
              print('Item updated successfully');
            } else {
              print('Failed to update item');
            }
          } else {
            Uri addItemUrl = Uri.parse('http://cms.sucsa.org:8005/api/items');
            final addItemResponse = await http.post(
              addItemUrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(<String, dynamic>{
                'itemName': _nameController.text,
                'description': 'Description for ${_nameController.text}',
                'category': _selectedCategory,
                'stockQuantity': _quantityController.text,
              }),
            );
            if (addItemResponse.statusCode == 200) {
              print('Item added successfully');
              _formKey.currentState!.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
              print(addItemResponse.body);
            } else {
              print('Failed to add item');
            }
          }
        } else {
          print('Failed to get items');
        }
      } catch (exception) {
        print('Failed to call API: $exception');
      }
    }
  }



  final List<String> _categories = ['学联常用', '学联非常用'];
  String? _selectedCategory;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新品入库', style: const TextStyle(color: Colors.white) ,), backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            SizedBox(height: 16),
            Text(
              '物品名称',
              style: TextStyle(fontSize: 16),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '请输入物品名称',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              cursorColor: Colors.blue,
              cursorWidth: 2.0,
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入物品名称';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Text(
              '物品分类',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请选择分类',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              value: _selectedCategory,
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) => value == null ? '请选择物品分类' : null,
            ),
            SizedBox(height: 16),
            Text(
              '物品数量',
              style: TextStyle(fontSize: 16),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                hintText: '请输入物品数量',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              cursorColor: Colors.blue,
              cursorWidth: 2.0,
              validator: (value) {
                if (value!.isEmpty) {
                  return '请输入物品数量';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('提交'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
