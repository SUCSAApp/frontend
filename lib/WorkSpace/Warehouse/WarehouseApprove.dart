import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

class WarehouseapprovePage extends StatefulWidget {
  @override
  _WarehouseapprovePageState createState() => _WarehouseapprovePageState();
}

class _WarehouseapprovePageState extends State<WarehouseapprovePage> with TickerProviderStateMixin {
  List<dynamic> approvedwarehouseRequests = [];
  List<dynamic> approvedreturnRequests = [];
  List<dynamic> pendingRequests = [];
  List<dynamic> Warehouseapproves = [];
  List<dynamic> returnRequests = [];
  List<dynamic> rejectedWareHouseRequests = [];
  List<dynamic> rejectedReturnRequests = [];

  int selectedPageIndex = 0;
  bool _showApproved = true;

  @override
  void initState() {
    super.initState();
    fetchWarehouseapproves();
    fetchReturnRequests();
    fetchAllRequests();
  }




  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchWarehouseapproves() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    var url = Uri.parse('http://cms.sucsa.org:8005/api/warehouse-requests');
    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      bool hasPending = decodedResponse.any((r) => r['status'] == 'PENDING');
      await prefs.setBool('hasNewWarehouseRequest', hasPending);

      setState(() {
        Warehouseapproves = decodedResponse;
        approvedwarehouseRequests = Warehouseapproves.where((r) => r['status'] == 'APPROVED').toList();
        rejectedWareHouseRequests = Warehouseapproves.where((r) => r['status'] == 'REJECTED').toList();
        pendingRequests = Warehouseapproves.where((r) => r['status'] == 'PENDING').toList();
      });
    } else {
      print('Failed to load warehouse requests: ${response.body}');
    }
  }

  Future<void> fetchAllRequests() async {
    await fetchWarehouseapproves();
    await fetchReturnRequests();
    List<dynamic> combinedPendingRequests = [
      ...Warehouseapproves.where((request) => request['status'] == 'PENDING'),
      ...returnRequests.where((request) => request['status'] == 'PENDING'),
    ];
    print(Warehouseapproves.last);

    setState(() {
      pendingRequests = combinedPendingRequests;
    });
  }

  Future<void> fetchReturnRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    var url = Uri.parse('http://cms.sucsa.org:8005/api/return-requests');
    var response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);

      decodedResponse.forEach((r) {
        if (r['status'] == null) {
          r['status'] = 'PENDING';
        }
      });

      setState(() {
        returnRequests = decodedResponse;
        approvedreturnRequests = returnRequests.where((r) => r['status'] == 'APPROVED').toList();
        rejectedReturnRequests = returnRequests.where((r) => r['status'] == 'REJECTED').toList();
        pendingRequests = returnRequests.where((r) => r['status'] == 'PENDING').toList();
      });
      print(returnRequests.last);
    } else {
      print('Failed to load return requests: ${response.body}');
    }
  }

  Future<void> auditWarehouseRequest(int requestId, RequestStatus status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }

    final String apiUrl = 'http://cms.sucsa.org:8005/api/warehouse-requests/$requestId/audit';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> requestBody = {
      'status': status.value,
    };
    final String jsonBody = json.encode(requestBody);


    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: jsonBody);


      if (response.statusCode == 200) {
        print('Warehouse request audited successfully.');
        setState(() {
          pendingRequests.removeWhere((r) => r['requestId'] == requestId);
          if (status != RequestStatus.PENDING) {
            var auditedRequest = Warehouseapproves.firstWhere((r) => r['requestId'] == requestId);
            auditedRequest['status'] = status.value;
            approvedwarehouseRequests.add(auditedRequest);
          }
        });
      } else {
        print('Failed to audit warehouse request: ${response.body}');
      }
    } catch (e) {
      print('An error occurred while auditing warehouse request: $e');
    }
  }

  Future<void> auditReturnRequest(int requestId, RequestStatus status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      print("Token not found. User might not be logged in.");
      return;
    }
    String apiUrl = 'http://cms.sucsa.org:8005/api/return-requests/$requestId/audit';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status.value}),
      );

      if (response.statusCode == 200) {
        print('Return request audited successfully.');
        setState(() {
          pendingRequests.removeWhere((r) => r['id'] == requestId);
          if (status != RequestStatus.PENDING) {
            var auditedRequest = returnRequests.firstWhere((r) => r['id'] == requestId);
            auditedRequest['status'] = status.value;
            approvedreturnRequests.add(auditedRequest);
          }
        });
      } else {
        print('Failed to audit return request: ${response.body}');
      }
    } catch (e) {
      print('An error occurred while auditing return request: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('仓库审批', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPageButton('待审批', 0),
              _buildPageButton('已审批', 1),
            ],
          ),
          Expanded(
            child: selectedPageIndex == 0 ? buildPendingRequestsList() : buildReviewedRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget buildPendingRequestsList() {
    // Build the list of pending requests
    return buildRequestList(pendingRequests, true);
  }

  Widget buildReviewedRequestsList() {

    List<dynamic> reviewedRequests = [
      ...approvedwarehouseRequests,
...rejectedWareHouseRequests,
      ...approvedreturnRequests,
...rejectedReturnRequests,
    ];
    return buildRequestList(reviewedRequests, false);
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

  Widget buildRequestList(List<dynamic> requests, bool isPending) {
    if (requests.isEmpty) {
      return Center(child: Text('No requests found'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        var request = requests[index];
        bool isReturnRequest = request['returnItemRequests'] != null;
        String requestType = isReturnRequest ? 'Return Request' : 'Pickup Request';

        String requesterName = 'Unknown';
        if (request['requesterName'] != null) {
          List<int> nameBytes = (request['requesterName'] as String).runes.toList();
          requesterName = utf8.decode(nameBytes);
        }

        String formattedActivityDate = request['activityDate'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(request['activityDate']))
            : 'Unknown Date';

        int? requestId = isReturnRequest ? request['id'] : request['requestId'];

        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              if (isReturnRequest) {
                showReturnRequestDetailsDialog(context, request);
              } else {
                showRequestDetailsDialog(context, request);
              }
            },
            child: ListTile(
              title: Text('$requesterName\'s $requestType #${requestId ?? "Unknown"}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态: ${request['status']}'),
                  Text('活动日期: $formattedActivityDate'),
                ],
              ),
              trailing: isPending ? buildTrailingIcons(isReturnRequest, requestId, context) : null,
            ),
          ),
        );
      },
    );
  }

  Widget buildTrailingIcons(bool isReturnRequest, int? requestId, BuildContext context) {
    if (requestId == null) {
      // Handle the null case.
      print("Request ID is null");
      return SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: () {
            if (isReturnRequest) {
              auditReturnRequest(requestId, RequestStatus.APPROVED);
            } else {
              auditWarehouseRequest(requestId, RequestStatus.APPROVED);
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () {
            if (isReturnRequest) {
              auditReturnRequest(requestId, RequestStatus.REJECTED);
            } else {
              auditWarehouseRequest(requestId, RequestStatus.REJECTED);
            }
          },
        ),
      ],
    );
  }

  Widget buildReturnRequestItem(dynamic request) {
    return ListTile(
      title: Text('Return Request #${request['id']}'),
      subtitle: Text('Status: ${request['status']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () => auditReturnRequest(request['id'], RequestStatus.APPROVED),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => auditReturnRequest(request['id'], RequestStatus.REJECTED),
          ),
        ],
      ),
    );
  }

  void showRequestDetailsDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String formattedActivityDate = 'Unknown Date';
        if (request['activityDate'] != null) {
          DateTime activityDate = DateTime.parse(request['activityDate']);
          formattedActivityDate = DateFormat('yyyy-MM-dd').format(activityDate);
        }

        String requesterName = 'Unknown';
        if (request['requesterName'] != null) {
          List<int> nameBytes = (request['requesterName'] as String).runes.toList();
          requesterName = utf8.decode(nameBytes);
        }

        String activityName = 'Unknown';
        if (request['activityName'] != null) {
          List<int> nameBytes = (request['activityName'] as String).runes.toList();
          activityName = utf8.decode(nameBytes);
        }

        List<TableRow> itemRows = [
          TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('物品名称', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('请求数量', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('类别', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ];

        itemRows.addAll(request['itemRequests'].map<TableRow>((itemRequest) {
          String decodedItemName = utf8.decode(itemRequest['item']['itemName'].runes.toList());
          String decodedCategory = utf8.decode(itemRequest['item']['category'].runes.toList());
          return TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(decodedItemName ?? "Unknown"),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('${itemRequest['requestedQuantity']}'),
            ),
            Padding(padding: EdgeInsets.all(8.0), child: Text(decodedCategory ?? "Unknown")),
          ]);
        }).toList());

        return AlertDialog(
          title: Text('活动名称: $activityName'),
          content: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('活动日期: $formattedActivityDate'),
                  Text('申请人: $requesterName'),
                  Text('取货日期: ${request['pickupDate'] ?? 'Unknown'}'),
                  Text('使用日期: ${request['usageDate'] ?? 'Unknown'}'),
                  Table(children: itemRows),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('关闭'),
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29,32,136,1.0),
              ),
            ),
          ],
        );
      },
    );
  }

  void showReturnRequestDetailsDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String formattedActivityDate = 'Unknown Date';
        if (request['activityDate'] != null) {
          DateTime activityDate = DateTime.parse(request['activityDate']);
          formattedActivityDate = DateFormat('yyyy-MM-dd').format(activityDate);
        }

        String requesterName = 'Unknown';
        if (request['requesterName'] != null) {
          List<int> nameBytes = (request['requesterName'] as String).runes.toList();
          requesterName = utf8.decode(nameBytes);
        }

        String activityName = 'Unknown';
        if (request['activityName'] != null) {
          List<int> nameBytes = (request['activityName'] as String).runes.toList();
          activityName = utf8.decode(nameBytes);
        }

        List<TableRow> itemRows = [
          TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('物品名称', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('请求数量', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('类别', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ];

        itemRows.addAll(request['returnItemRequests'].map<TableRow>((itemRequest) {
          String decodedItemName = utf8.decode(itemRequest['item']['itemName'].runes.toList());
          String decodedCategory = utf8.decode(itemRequest['item']['category'].runes.toList());
          return TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(decodedItemName ?? "Unknown"),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('${itemRequest['requestedQuantity']}'),
            ),
            Padding(padding: EdgeInsets.all(8.0), child: Text(decodedCategory ?? "Unknown")),
          ]);
        }).toList());




        return AlertDialog(
          title: Text('归还申请详情'),
          content: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('活动名称: $activityName'),
                Text('活动日期: $formattedActivityDate'),
                Text('申请人: $requesterName'),
                Table(children: itemRows),
              ],
            ),
          ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromRGBO(29,32,136,1.0),
              ),
            ),
          ],

        );
      },
    );
  }

}
