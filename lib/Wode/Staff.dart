import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sucsa_app/WorkSpace/Warehouse/ProductManage.dart';
import 'package:sucsa_app/WorkSpace/Warehouse/ReturnRequest.dart';

import '../WorkSpace/Attendance/AttendanceRecord.dart';
import '../WorkSpace/Attendance/PersonnelManagement.dart';
import '../WorkSpace/Warehouse/PickupRequest.dart';
import '../WorkSpace/Warehouse/WarehouseApprove.dart';
import '../WorkSpace/reimburse/ReimbursementApproval.dart';
import '../WorkSpace/reimburse/ReimbursementRequest.dart';
import '../Wode/Setting.dart';
import 'package:http/http.dart' as http;



class StaffPage extends StatefulWidget {
  const StaffPage({Key? key}) : super(key: key);

  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  bool hasNewWarehouseRequest = false;


  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((_) {
      if (page is WarehouseapprovePage) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('hasNewWarehouseRequest', false);
          checkForNewRequests();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkForNewRequests();
  }


  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Setting(),
          ),
        );
      },
    );
  }

  void checkForNewRequests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasNew = prefs.getBool('hasNewWarehouseRequest') ?? false;
    setState(() {
      hasNewWarehouseRequest = hasNew;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset('lib/assets/membercard.png', width: double.infinity),
            const SizedBox(height: 2),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Section(
                      title: '考勤管理',
                      icons: [Icons.history, Icons.people],
                      labels: ['考勤记录', '人员管理'],
                      onTapCallbacks: [
                            () => navigateTo(context, AttendanceRecordPage()),
                            () => navigateTo(context, PersonnelManagementPage()),
                      ],
                    ),
                    const Divider(),
                    Section(
                      title: '学联仓库',
                      icons: [Icons.car_rental, Icons.inventory, FontAwesomeIcons.file, FontAwesomeIcons.box],
                      labels: ['仓库审批', '申请取货', '物品归还', '物品管理'],
                      onTapCallbacks: [
                            () => navigateTo(context, WarehouseapprovePage()),
                            () => navigateTo(context, PickupRequestPage()),
                            () => navigateTo(context, ReturnRequestPage()),
                            () => navigateTo(context, ProductManagePage()),
                      ],
                      hasNewRequest: hasNewWarehouseRequest,
                    ),
                    const Divider(),
                    Section(
                      title: '报销',
                      icons: [FontAwesomeIcons.stamp, Icons.file_copy],
                      labels: ['报销审批', '申请报销'],
                      onTapCallbacks: [
                            () => navigateTo(context, ReimbursementApprovalPage()),
                            () => navigateTo(context, ReimbursementRequestPage()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
                ),
                onPressed: () => _showSettingsBottomSheet(context),
                child: Text('设置', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<IconData> icons;
  final List<String> labels;
  final List<VoidCallback> onTapCallbacks;
  final bool hasNewRequest;
  final double iconSize;
  final Color iconColor;

  const Section({
    Key? key,
    required this.title,
    required this.icons,
    required this.labels,
    required this.onTapCallbacks,
    this.hasNewRequest = false,
    this.iconSize = 60.0,
    this.iconColor = const Color.fromRGBO(29, 32, 136, 1.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromRGBO(29, 32, 136, 1.0),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 40,
          children: List.generate(icons.length, (index) {
            return GestureDetector(
              onTap: onTapCallbacks[index],
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(icons[index], size: iconSize, color: iconColor),
                      Text(labels[index]),
                    ],
                  ),
                  if (hasNewRequest && labels[index] == '仓库审批')
                    Positioned(
                      top: -5,
                      right: -10,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}



