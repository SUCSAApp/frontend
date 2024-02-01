import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sucsa_app/WorkSpace/Warehouse/NewProducts.dart';
import 'package:sucsa_app/WorkSpace/Warehouse/ReturnRequest.dart';

import '../WorkSpace/Attendance/AttendanceRecord.dart';
import '../WorkSpace/Attendance/PersonnelManagement.dart';
import '../WorkSpace/Warehouse/PickupRequest.dart';
import '../WorkSpace/Warehouse/PickupApprove.dart';
import '../WorkSpace/reimburse/ReimbursementApproval.dart';
import '../WorkSpace/reimburse/ReimbursementRequest.dart';



class StaffPage extends StatelessWidget {
  const StaffPage({Key? key}) : super(key: key);

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset('lib/assets/membercard.png', width: double.infinity),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      labels: ['取货审批', '申请取货', '物品归还', '新品入库'],
                      onTapCallbacks: [
                            () => navigateTo(context, PickupApprovalPage()),
                            () => navigateTo(context, PickupRequestPage()),
                            () => navigateTo(context, ReturnRequestPage()),
                            () => navigateTo(context, NewProductsPage()),
                      ],
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
  final double iconSize;
  final Color iconColor;


  const Section({
    Key? key,
    required this.title,
    required this.icons,
    required this.labels,
    required this.onTapCallbacks,
    this.iconSize = 60.0,
    this.iconColor = const Color.fromRGBO(29,32,136,1.0),}) : super(key: key);

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
            color: Color.fromRGBO(29,32,136,1.0),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 40,
          children: List.generate(icons.length, (index) {
            return GestureDetector(
              onTap: onTapCallbacks[index],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icons[index], size: iconSize, color: iconColor),
                  Text(labels[index]),
                ],
              ),
            );
          }),
        ),

      ],
    );
  }
}

// Define the pages that these sections will navigate to:










// Don't forget to replace 'assets/header_image.png' with the actual path to your header image

