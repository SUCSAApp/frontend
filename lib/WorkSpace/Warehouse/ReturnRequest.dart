import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReturnRequestPage extends StatefulWidget {
  @override
  _ReturnRequestPageState createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _applicantNameController = TextEditingController();
  final TextEditingController _departmentNameController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();




  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(29, 32, 136, 1.0),
            hintColor: const Color.fromRGBO(29, 32, 136, 1.0),
            colorScheme: ColorScheme.light(primary: const Color.fromRGBO(29, 32, 136, 1.0)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
          'id': item['itemId'] ?? 0,
          'stockQuantity': item['stockQuantity'] ?? 0, // Corrected field name
        }).toList();
      });

    } else {
      print('Failed to load items from API');
    }
  }


  List<Map<String, dynamic>> apiItems = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
    loadUsername();
  }

  void loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username != null) {
      try {
        final String decodedUsername = utf8.decode(latin1.encode(username));
        setState(() {
          _applicantNameController.text = decodedUsername;
        });
      } catch (e) {
        setState(() {
          _applicantNameController.text = username;
        });
        print('Error decoding username: $e');
      }
    }
  }

  void _addItemField() {
    setState(() {
      _items.add({'name': '', 'quantity': 0});
    });
  }


  Future<void> createReturnRequest() async {
    var url = Uri.parse('http://cms.sucsa.org:8005/api/return-requests');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found. Cannot submit request.");
      return;
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    List<Map<String, dynamic>> returnItemRequests = _items.map((item) {
      int itemId = item['id'];
      int requestedQuantity = int.tryParse(item['stockQuantity'].toString()) ?? 0;

      return {
        "item": {"itemId": itemId},
        "name": item['name'],
        "requestedQuantity": requestedQuantity
      };
    }).toList();

    Map<String, dynamic> requestBody = {
      "returnItemRequests": returnItemRequests,
      "activityName": _eventNameController.text,
      "activityDate": _eventDateController.text,
      "requesterName": _applicantNameController.text,
      "returnDate": _returnDateController.text,
    };

    print(requestBody);

    var body = json.encode(requestBody);


    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Return request submitted successfully');
        print(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('提示',style: TextStyle(color: Color.fromRGBO(29,32,136,1.0), fontWeight: FontWeight.bold)),
              content: Text('归还申请提交成功', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              actions: <Widget>[
                TextButton(
                  child: Text('确定', style: TextStyle(color: Color.fromRGBO(29,32,136,1.0), fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Optionally, navigate back or to another page
                  },
                ),
              ],
            );
          },
        );
        _formKey.currentState!.reset();
        _items.clear();
      } else {
        print('Failed to submit return request: ${response.body}');
      }
    } catch (e) {
      print('An error occurred while submitting the return request: $e');
    }
  }







  Widget _buildStyledTextFieldWithLabel({
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    void Function(String?)? onSaved,
    VoidCallback? onTap, required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          cursorColor: Colors.blue,
          cursorWidth: 2.0,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          onTap: onTap,
          readOnly: onTap != null,
        ),
        SizedBox(height: 16),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('归还申请表', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), backgroundColor: Color.fromRGBO(29,32,136,1.0),),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 100.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16.0),
                _buildStyledTextFieldWithLabel(
                  label: '活动名称',
                  hintText: '请输入活动名称',
                  controller: _eventNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入活动名称';
                    }
                    return null;
                  },
                ),
                _buildStyledTextFieldWithLabel(
                  label: '申请人',
                  hintText: '请输入申请人姓名',
                  controller: _applicantNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入申请人姓名';
                    }
                    return null;
                  },
                ),
                _buildStyledTextFieldWithLabel(
                  label: '所在部门',
                  hintText: '请输入所在部门',
                  controller: _departmentNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入所在部门';
                    }
                    return null;
                  },
                ),
                _buildDateField(context, '活动日期', _eventDateController),
                _buildDateField(context, '归还日期', _returnDateController),
                ..._items.asMap().entries.map((entry) {
                  return _buildItemQuantityField(entry.value, entry.key);
                }).toList(),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: _addItemField,
                  icon: Icon(Icons.add),
                  label: Text('添加物品'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      createReturnRequest();
                    }
                  },
                  child: Text('提交'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29,32,136,1.0),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text(
            controller.text.isEmpty ? '选择日期' : controller.text,
            style: TextStyle(fontSize: 16),
          ),
          trailing: Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, controller),
        ),
        Divider(color: Colors.grey),
      ],
    );
  }

  Widget _buildItemQuantityField(Map<String, dynamic> item, int index) {
    Future<void> _showItemPicker() async {
      if (apiItems.isNotEmpty) {
        final Map<String, dynamic>? selectedItem = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('请选择物品'),
              children: apiItems.map((Map<String, dynamic> item) {
                String displayText = '${item['name']} (库存: ${item['stockQuantity'].toString()})';
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, item);
                  },
                  child: Text(displayText),
                );
              }).toList(),
            );
          },
        );
        if (selectedItem != null) {
          setState(() {
            _items[index]['name'] = selectedItem['name'];
            _items[index]['id'] = selectedItem['id'];
          });
        }
      } else {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('当前没有可选的物品。'),
              actions: <Widget>[
                TextButton(
                  child: const Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }




    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: item['name']),
                readOnly: true,
                onTap: _showItemPicker,
                decoration: InputDecoration(
                  labelText: '物品',
                  border: OutlineInputBorder(),
                  hintText: '请选择物品',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: item['quantity'].toString(),
                decoration: InputDecoration(
                  labelText: '数量',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _items[index]['quantity'] = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => _items.removeAt(index)),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }



}
