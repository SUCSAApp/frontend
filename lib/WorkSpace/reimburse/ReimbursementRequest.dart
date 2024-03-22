import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReimbursementRequestPage extends StatefulWidget {
  @override
  _ReimbursementRequestPageState createState() => _ReimbursementRequestPageState();
}

class _ReimbursementRequestPageState extends State<ReimbursementRequestPage> {

  List<String> invoiceImagePaths = [];
  List<String> screenshotImagePaths = [];

  List departmentList = [
    {"id": 1, "name": "行政部"},
    {"id": 3, "name": "财务部"},
    {"id": 4, "name": "市场部"},
    {"id": 5, "name": "新媒体运营部"},
    {"id": 6, "name": "设计部"},
    {"id": 7, "name": "文艺部"},
    {"id": 8, "name": "生活娱乐部"},
    {"id": 9, "name": "学业与职业规划部"},
    {"id": 10, "name": "国际交流部"},
    {"id": 11, "name": "主席团"},
    {"id": 12, "name": "荣誉顾问团"},];

  List<String> currencyList =[
    'CNY',
    'AUD',
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _applicantController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final List<Map<String, dynamic>> _expenseItems = [];
  final TextEditingController _expenseMethodController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _bsbController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  String? selectedDepartment;
  String? selectedCurrency;
  double? totalAmount;
  String? invoiceImagePath;
  String? screenshotImagePath;
  String? departmentId;
  String? departmentName;
  List<String> invoiceFileNames = [];
  List<String> screenshotFileNames = [];

  @override
  void initState() {
    super.initState();
    _applicantController;
    _departmentController;
    _eventNameController;
    _eventDateController;
    _currencyController;
    _totalAmountController;
    _expenseMethodController;
    _accountNameController;
    _bsbController;
    _accountNumberController;
    loadUsername();
  }

  @override
  void dispose() {
    _applicantController.dispose();
    _departmentController.dispose();
    _eventNameController.dispose();
    _eventDateController.dispose();
    _currencyController.dispose();
    _totalAmountController.dispose();
    _expenseMethodController.dispose();
    _accountNameController.dispose();
    _bsbController.dispose();
    _accountNumberController.dispose();
    _expenseItems.forEach((item) {
      item['nameController'].dispose();
      item['amountController'].dispose();
    });
    super.dispose();
  }

  void loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    if (username != null) {
      try {
        final String decodedUsername = utf8.decode(latin1.encode(username));
        setState(() {
          _applicantController.text = decodedUsername;
        });
        print('Username: $decodedUsername');
      } catch (e) {
        setState(() {
          _applicantController.text = username;
        });
        print('Error decoding username: $e');
      }
    }
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields correctly.')),
      );
      return;
    }
    _formKey.currentState!.save();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token not found. Please login again.')),
      );
      return;
    }

    const String apiUrl = 'http://cms.sucsa.org:8005/api/expense-requests';

    Map<String, dynamic> departmentData = {
      "id": int.parse(selectedDepartment!),
      "name": departmentList.firstWhere((dept) => dept['id'].toString() == selectedDepartment)['name'],
    };

    double totalAmount = _expenseItems.fold(0.0, (sum, item) => sum + (item['amount'] as double));


    Map<String, dynamic> requestData = {
      "eventName": _eventNameController.text,
      "organizingDept": departmentData,
      "eventDate": _eventDateController.text,
      "applicant": _applicantController.text,
      "currency": selectedCurrency,
      "expenseItems": _expenseItems.map((item) {
        // Only include the text values, not the controllers
        return {
          "item": item['nameController'].text,
          "amount": double.tryParse(item['amountController'].text) ?? 0.00,
        };
      }).toList(),
      "invoices": invoiceFileNames,
      "screenshots": screenshotFileNames,
      "reimbursementMethod": selectedCurrency,
      "amount": totalAmount,
      "accountName": _accountNameController.text,
      "bsb": _bsbController.text,
      "accountNumber": _accountNumberController.text,
      "status": "PENDING",
    };


    print(requestData);

    if (selectedCurrency == 'AUD') {
      requestData.addAll({
        "accountName": _accountNameController.text,
        "bsb": _bsbController.text,
        "accountNumber": _accountNumberController.text,
      });
    } else if (selectedCurrency == 'CNY') {
      requestData.addAll({
        "accountName": _accountNameController.text,
        "accountNumber": _accountNumberController.text,
      });
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('提示', style: TextStyle(color: Color.fromRGBO(29,32,136,1.0), fontWeight: FontWeight.bold)),
              content: Text('报销申请提交成功', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              actions: <Widget>[
                TextButton(
                  child: Text('确定', style: TextStyle(color: Color.fromRGBO(29,32,136,1.0), fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        _formKey.currentState!.reset();

      } else {
        print('Failed to submit request: ${response.statusCode}' + response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request.')),
        );
      }
    } catch (e) {
      print('Error submitting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while submitting the request.')),
      );
    }
  }

  Future<String?> uploadFile(File file) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      print("Token not found. Cannot upload file.");
      return null;
    }

    var uri = Uri.parse('http://cms.sucsa.org:8005/api/files/upload');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var decoded = json.decode(responseString);
      return decoded['filename'];
    } else {
      print('Failed to upload file: ${response.statusCode}');
      return null;
    }
  }

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
        controller.text = DateFormat('yyyy-MM-dd').format(picked); // ISO 8601 format
      });
    }
  }

  Future<void> _selectDepartment(BuildContext context) async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('选择部门'),
          children: departmentList.map<SimpleDialogOption>((dept) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, dept['name']);
              },
              child: Text(dept['name']),
            );
          }).toList(),
        );
      },
    );
    if (picked != null && picked != _departmentController.text) {
      setState(() {
        _departmentController.text = picked;
        selectedDepartment = departmentList.firstWhere((dept) => dept['name'] == picked)['id'].toString();
      });
    }
  }

  Widget _buildStyledTextFieldWithLabel({
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    void Function(String?)? onSaved,
    VoidCallback? onTap,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller, // Assign the controller here
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(29,32,136,1.0), width: 2.0),
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


  void _addExpenseItem() {
    setState(() {
      TextEditingController nameController = TextEditingController();
      TextEditingController amountController = TextEditingController();
      _expenseItems.add({
        "id": _expenseItems.length + 1,
        "nameController": nameController,
        "amountController": amountController,
      });
    });
  }

  Widget _buildExpenseItemField(Map<String, dynamic> item, int index) {
    TextEditingController nameController = item['nameController'];
    TextEditingController amountController = item['amountController'];

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(hintText: '费用名称'),
            onChanged: (value) {
              item['name'] = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入费用名称';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: '金额'),
            onChanged: (value) {
              item['amount'] = double.tryParse(value) ?? 0.00;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入金额';
              }
              if (double.tryParse(value) == null) {
                return '请输入有效的金额';
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _expenseItems.remove(item);
              item['nameController'].dispose();
              item['amountController'].dispose();
            });
          },
        )
      ],
    );
  }

  Future<void> _pickAndUploadImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      for (XFile image in images) {
        String? fileName = await uploadFile(File(image.path));
        if (fileName != null) {
          setState(() {
            if (type == 'invoice') {
              invoiceImagePaths.add(image.path);
              invoiceFileNames.add(fileName);
            } else {
              screenshotImagePaths.add(image.path);
              screenshotFileNames.add(fileName);
            }
          });
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Images uploaded successfully')),
      );
    } else {
      print('No images were selected.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '申请报销',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStyledTextFieldWithLabel(
                label: '活动名称',
                controller: _eventNameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入活动名称';
                  }
                  return null;
                }, hintText: '请输入活动名称',
              ),
              InkWell(
                onTap: () => _selectDepartment(context),
                child: IgnorePointer(
                  child: _buildStyledTextFieldWithLabel(
                    label: '活动主办部门',
                    controller: _departmentController,
                    hintText: '请选择部门',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请选择部门';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              InkWell(
                onTap: () => _selectDate(context, _eventDateController),
                child: IgnorePointer(
                  child: _buildStyledTextFieldWithLabel(
                    label: '活动日期',
                    controller: _eventDateController,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请选择日期';
                      }
                      return null;
                    },
                    hintText: '选择日期',
                  ),
                ),
              ),
              _buildStyledTextFieldWithLabel(
                label: '申请人',
                controller: _applicantController,
                hintText: '请输入申请人姓名',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入申请人姓名';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14),
              ..._expenseItems.asMap().entries.map((entry) {
                return _buildExpenseItemField(entry.value, entry.key);
              }).toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _addExpenseItem,
                    child: Text('添加报销项'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              _buildCurrencyDropdown(),
              SizedBox(height: 10),
              if (selectedCurrency == 'AUD') _buildAUDForm(),
              if (selectedCurrency == 'CNY') _buildCNYForm(),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (invoiceImagePaths.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: invoiceImagePaths.length,
                          itemBuilder: (context, index) {
                            return _buildImagePreview(invoiceImagePaths[index], 'Invoice');
                          },
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => _pickAndUploadImage('invoice'),
                    child: Text('上传Invoice'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (screenshotImagePaths.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: screenshotImagePaths.length,
                          itemBuilder: (context, index) {
                            return _buildImagePreview(screenshotImagePaths[index], 'Screenshot');
                          },
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => _pickAndUploadImage('screenshot'),
                    child: Text('付款截图'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
                    ),
                  ),
                ],
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    submitRequest();
                  },
                  child: Text('提交报销'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 1,
          child: Text('报销币种', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Flexible(
          child: Container(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: selectedCurrency,
              onChanged: (newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
              },
              items: currencyList.map<DropdownMenuItem<String>>((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择报销币种';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAUDForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyledTextFieldWithLabel(
          label: 'Account Name',
          hintText: 'Account Name',
          controller: _accountNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入申请人姓名';
            }
            return null;
          },
        ),
        _buildStyledTextFieldWithLabel(
          label: 'BSB',
          hintText: 'BSB',
          controller: _bsbController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入BSB';
            }
            return null;
          },
        ),
        _buildStyledTextFieldWithLabel(
          label: 'Acc Number',
          hintText: 'Acc #',
          controller: _accountNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入BSB';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCNYForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyledTextFieldWithLabel(
          label: 'Acc Name（支付宝）',
          hintText: 'Acc Name',
          controller: _accountNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入BSB';
            }
            return null;
          },
        ),
        _buildStyledTextFieldWithLabel(
          label: 'Acc Number',
          hintText: 'Acc #',
          controller: _accountNumberController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入BSB';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImagePreview(String? imagePath, String label) {
    return Row(
      children: [
        if (imagePath != null)
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Image.file(File(imagePath)),
                ),
              );
            },
            child: Image.file(
              File(imagePath),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        Text(label),
      ],
    );
  }


}

