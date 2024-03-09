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
  List<dynamic> approvedOrRejectedRequests = [];
  List<dynamic> expenseRequests = [];

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
        pendingRequests = decodedResponse.where((r) => r['status'] == 'PENDING').toList();
        approvedOrRejectedRequests = decodedResponse.where((r) => r['status'] != 'PENDING').toList();
      });
      print('Fetched expense requests: ${response.body}');
    } else {
      print('Failed to load expense requests: ${response.body}');
    }
  }

  void showExpenseRequestDetailsDialog(dynamic request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        String formattedActivityDate = 'Unknown Date';
        if (request['eventDate'] != null) {
          DateTime activityDate = DateTime.parse(request['eventDate']);
          formattedActivityDate = DateFormat('yyyy-MM-dd').format(activityDate);
        }

        String requesterName = 'Unknown';
        if (request['requesterName'] != null) {
          requesterName = request['requesterName'];
        }

        return AlertDialog(
          title: Text('Expense Request Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Event Name: ${request['eventName']}'),
                Text('Applicant: ${requesterName}'),
                Text('Department: ${request['organizingDept']['name']}'),
                Text('Event Date: ${formattedActivityDate}'),
                ...request['expenseItems'].map<Widget>((item) => Text('${item['name']}: ${item['amount']}')).toList(),
                Text('Total Amount: ${request['amount']}'),
                Text('Status: ${request['status']}'),
                // Add more details as needed
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildPageButton(String title, bool isApprovedPage) {
  //   bool isSelected = _showApproved == isApprovedPage;
  //   return ElevatedButton(
  //     onPressed: () {
  //       setState(() {
  //         _showApproved = isApprovedPage;
  //       });
  //     },
  //     child: Text(
  //       title,
  //       style: TextStyle(
  //         color: isSelected ? Colors.white : Color.fromRGBO(29, 32, 136, 1.0),
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     style: ButtonStyle(
  //       backgroundColor: MaterialStateProperty.resolveWith<Color>(
  //             (states) {
  //           if (states.contains(MaterialState.pressed) || isSelected) {
  //             return Color.fromRGBO(29, 32, 136, 1.0);
  //           }
  //           return Colors.white;
  //         },
  //       ),
  //       side: MaterialStateProperty.all<BorderSide>(
  //         BorderSide(color: Color.fromRGBO(29, 32, 136, 1.0)),
  //       ),
  //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  //       ),
  //       elevation: MaterialStateProperty.all(0),
  //       overlayColor: MaterialStateProperty.all(Colors.transparent),
  //     ),
  //   );
  // }

  Widget buildRequestList(List<dynamic> requests, RequestStatus status) {
    // Filter requests based on status
    var filteredRequests = requests.where((request) => request['status'] == status.value).toList();

    return ListView.builder(
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        var request = filteredRequests[index];

        return ListTile(
          title: Text('Request ID: ${request['id']}'),
          subtitle: Text('Applicant: ${request['applicant']}'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                // Your dialog content based on the request details goes here
                return AlertDialog(
                  title: Text('Details for Request ID: ${request['id']}'),
                  // ... other dialog content ...
                );
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Requests')),
      body: ListView.builder(
        itemCount: expenseRequests.length,
        itemBuilder: (context, index) {
          var request = expenseRequests[index];
          return Card(
            child: ListTile(
              title: Text(request['eventName']),
              trailing: Chip(
                label: Text(request['eventDate']),
                backgroundColor: request['status'] == 'PENDING' ? Colors.orange : (request['status'] == 'APPROVED' ? Colors.green : Colors.red),
              ),
              onTap: () => showExpenseRequestDetailsDialog(request),
            ),
          );
        },
      ),
    );
  }
}


