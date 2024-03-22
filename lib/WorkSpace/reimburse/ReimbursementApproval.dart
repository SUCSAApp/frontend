import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


enum RequestStatus { APPROVED, REJECTED, PENDING }

extension RequestStatusExtension on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.APPROVED:
        return 'APPROVED';
      case RequestStatus.REJECTED:
        return 'REJECTED';
      case RequestStatus.PENDING:
      default:
        return 'PENDING';
    }
  }
}

class ReimbursementApprovalPage extends StatefulWidget {
  @override
  _ExpenseRequestPageState createState() => _ExpenseRequestPageState();
}

class _ExpenseRequestPageState extends State<ReimbursementApprovalPage> {
  List<dynamic> pendingRequests = [];
  List<dynamic> auditedRequests = [];
  List<dynamic> expenseRequests = [];
  int selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchExpenseRequests();
  }

  Future<void> fetchExpenseRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    var url = Uri.parse('http://cms.sucsa.org:8005/api/expense-requests');
    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);

      setState(() {
        expenseRequests = decodedResponse;
        auditedRequests = decodedResponse.where((r) => r['status'] == 'APPROVED' || r['status'] == 'REJECTED').toList();
        pendingRequests = decodedResponse.where((r) => r['status'] == 'PENDING').toList();
      });
      print('Fetched expense requests: ${response.body}');
    } else {
      print('Failed to load expense requests: ${response.body}');
    }
  }


  Future<void> auditRequest(int requestId, RequestStatus status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    print('Auditing request: $requestId with status: ${status.value}');

    var response = await http.post(
      Uri.parse('http://cms.sucsa.org:8005/api/expense-requests/$requestId/${status == RequestStatus.APPROVED ? 'approve' : 'reject'}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var updatedRequest = json.decode(response.body);
      setState(() {
        pendingRequests.removeWhere((r) => r['requestId'] == requestId);
        auditedRequests.add(updatedRequest);
      });
    } else {
      print('Failed to audit request: ${response.body}');
    }

  }

  Widget buildRequestList(List<dynamic> requests, {bool isPending = false}) {
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (BuildContext context, int index) {
        var request = requests[index];
        String applicantName = request['applicant'] != null
            ? utf8.decode((request['applicant'] as String).runes.toList())
            : 'Unknown Applicant';

        String title = "$applicantName's 报销申请";

        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${request['status']}'),
            onTap: () => showRequestDetailsDialog(context, request),
            trailing: isPending
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => auditRequest(request['requestId'], RequestStatus.APPROVED),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => auditRequest(request['requestId'], RequestStatus.REJECTED),
                ),
              ],
            )
                : null,
          ),
        );
      },
    );
  }


  void showRequestDetailsDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String formattedEventDate = 'Unknown Date';
        if (request['eventDate'] != null) {
          DateTime eventDate = DateTime.parse(request['eventDate']);
          formattedEventDate = DateFormat('yyyy-MM-dd').format(eventDate);
        }

        String eventName = request['eventName'] != null ? utf8.decode(request['eventName'].runes.toList()) : 'Unknown Event';
        String organizingDeptName = request['organizingDept'] != null ? utf8.decode(request['organizingDept']['name'].runes.toList()) : 'Unknown Department';

        List<Widget> expenseItemsWidgets = request['expenseItems'] != null
            ? (request['expenseItems'] as List).map((item) {
          return Text('${item['item']}: ${item['amount']}');
        }).toList()
            : [Text('No expense items')];

        List<Widget> invoicesWidgets = request['invoices'] != null
            ? (request['invoices'] as List).map((invoice) {
          return GestureDetector(
            onTap: () => _showImageDialog(context, 'http://cms.sucsa.org/static/upload/$invoice'),
            child: Text(invoice),
          );
        }).toList()
            : [Text('No invoices')];

        List<Widget> screenshotsWidgets = request['screenshots'] != null
            ? (request['screenshots'] as List).map((screenshot) {
          return GestureDetector(
            onTap: () => _showImageDialog(context, 'http://cms.sucsa.org/static/upload/$screenshot'),
            child: Text(screenshot),
          );
        }).toList()
            : [Text('No screenshots')];

        List<Widget> accountInfoWidgets = [];
        if (request['reimbursementMethod'] == 'AUD') {
          accountInfoWidgets.addAll([
            Text('Account Name: ${request['accountName'] ?? 'Not provided'}'),
            Text('BSB: ${request['bsb'] ?? 'Not provided'}'),
            Text('Account Number: ${request['accountNumber'] ?? 'Not provided'}'),
          ]);
        } else if (request['reimbursementMethod'] == 'CNY') {
          accountInfoWidgets.addAll([
            Text('Account Name: ${request['accountName'] ?? 'Not provided'}'),
            Text('Account Number: ${request['accountNumber'] ?? 'Not provided'}'),
          ]);
        }

        return AlertDialog(
          title: Text('Request Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('活动名: $eventName'),
                Text('所在部门: $organizingDeptName'),
                Text('活动日期: $formattedEventDate'),
                Text('申请人: ${request['applicant']}'),
                Text('Reimbursement Method: ${request['reimbursementMethod']}'),
                Divider(),
                Text('报销项目:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...expenseItemsWidgets,
                Text('总金额: ${request['amount']}'),
                Divider(),
                Text('Invoices:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...invoicesWidgets,
                Divider(),
                Text('付款截图:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...screenshotsWidgets,
                Divider(),
                if (accountInfoWidgets.isNotEmpty) ...[
                  Text('Account Information:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...accountInfoWidgets,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('报销审批', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildPageButton('待审核', 0),
                  _buildPageButton('已审核', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: selectedPageIndex == 0
                ? buildRequestList(pendingRequests, isPending: true)
                : buildRequestList(auditedRequests),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(String title, int index) {
    bool isSelected = selectedPageIndex == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedPageIndex = index;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Color.fromRGBO(29, 32, 136, 1.0),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.pressed) || isSelected) {
              return Color.fromRGBO(29, 32, 136, 1.0);
            }
            return Colors.white;
          },
        ),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: Color.fromRGBO(29, 32, 136, 1.0)),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        elevation: MaterialStateProperty.all(0),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }
}


