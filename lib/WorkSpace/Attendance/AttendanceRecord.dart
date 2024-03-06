import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sucsa_app/main.dart';


class AttendanceRecordPage extends StatefulWidget {
  const AttendanceRecordPage({super.key});

  @override
  State<AttendanceRecordPage> createState() => AttendanceRecordPageState();
}

class User{
  int userId;
  String userName;
  int score;

  User({
    required this.userId,
    required this.userName,
    required this.score,
  });
}

class Activity {
  int activityId;
  String activityName;
  String activityDate;
  List<User> userList;

  bool selected;

  Activity({
    required this.activityId,
    required this.activityName,
    required this.activityDate,
    required this.userList,

    this.selected = false,
  });

}

class AttendanceRecordPageState extends State<AttendanceRecordPage> {

  bool runFutureBuilder = true;  //控制UI是否刷新

  String token = getToken();

  String? department;

  List departmentList = [
    {"id": 1, "name": "行政部"},
    {"id": 3, "name": "财务部"},  //部门ID似乎没有为2的
    {"id": 4, "name": "市场部"},
    {"id": 5, "name": "新媒体运营部"},
    {"id": 6, "name": "设计部"},
    {"id": 7, "name": "文艺部"},
    {"id": 8, "name": "生活娱乐部"},
    {"id": 9, "name": "学业与职业规划部"},
    {"id": 10, "name": "国际交流部"},
    {"id": 11, "name": "主席团"},
    {"id": 12, "name": "荣誉顾问团"},];

  String? semester;

  List semesterList = [
    {"id": -7, "name": "2014年S1学期"},
    {"id": -6, "name": "2014年S2学期"},
    {"id": -5, "name": "2015年S1学期"},
    {"id": -4, "name": "2015年S2学期"},
    {"id": -3, "name": "2016年S1学期"},
    {"id": -2, "name": "2016年S2学期"},
    {"id": -1, "name": "2017年S1学期"},
    {"id": 0, "name": "2017年S2学期"},
    {"id": 1, "name": "2018年S1学期"},
    {"id": 2, "name": "2018年S2学期"},
    {"id": 3, "name": "2019年S1学期"},
    {"id": 4, "name": "2019年S2学期"},
    {"id": 5, "name": "2020年S1学期"},
    {"id": 6, "name": "2020年S2学期"},
    {"id": 7, "name": "2021年S1学期"},
    {"id": 8, "name": "2021年S2学期"},
    {"id": 9, "name": "2022年S1学期"},
    {"id": 10, "name": "2022年S2学期"},
    {"id": 11, "name": "2023年S1学期"},
    {"id": 12, "name": "2023年S2学期"},
    {"id": 13, "name": "2024年S1学期"},
    {"id": 14, "name": "2024年S2学期"},];

  List<int> creditList = List<int>.generate(30, (i) => i);
  
  String? activityName;

  String? activityDate;

  Activity? updatedActivity;

  List<Activity> insideActivityList = [];

  List<Activity> outsideActivityList = [];

  Widget topMenu(){
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: 150,
            padding: const EdgeInsets.only(left:20, right: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 220, 217, 217),
              borderRadius: BorderRadius.circular(50),
            ),
            child: DropdownButton(
            dropdownColor: const Color.fromARGB(255, 220, 217, 217),
            value: semester, style: const TextStyle(fontSize: 15, color: Colors.black),
            hint: const Text("选择学期", style: TextStyle(fontSize: 15),),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: semesterList.map((items) { 
                return DropdownMenuItem( 
                  value: items["name"].toString(), 
                  child: Text(items["name"]), 
                ); 
              }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                semester = newValue!;
                runFutureBuilder = true;
              });
            },),
          ),

          Container(
            width: 150,
            padding: const EdgeInsets.only(left:20, right: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 220, 217, 217),
              borderRadius: BorderRadius.circular(50),
            ),
            child: DropdownButton(
            dropdownColor: const Color.fromARGB(255, 220, 217, 217),
            value: department, style: const TextStyle(fontSize: 15, color: Colors.black),
            hint: const Text("选择部门", style: TextStyle(fontSize: 15),),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: departmentList.map((items) { 
                return DropdownMenuItem( 
                  value: items["id"].toString(), 
                  child: Text(items["name"]), 
                ); 
              }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                department = newValue!;
                runFutureBuilder = true;
              });
            },),
          )
        ],
      ),
    );

  }

  Widget divider(){
    return const Divider(
      height: 1.0,
      color: Colors.grey,
    );
  }

  Widget insideActivityButton(){
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 150,
            margin: const EdgeInsets.only(left: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
              ),
              child: const Text("创建内部活动"),
              onPressed: (){
                if(semester != null && department != null){
                  dialogBuilder(context, true, true);
                }
              },),
          ),

          Container(
            width: 100,
            margin: const EdgeInsets.only(left: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
              ),
              child: const Text("修改活动"),
              onPressed: (){
                if(semester != null && department != null){
                  int count = 0;
                  for(int i = 0; i < insideActivityList.length; i ++){
                    if(insideActivityList[i].selected == true){
                      count += 1;
                      updatedActivity = insideActivityList[i];
                      if(count > 1){
                        alertDialog(context);
                      }
                    }
                  }
                  if(count == 1){
                    dialogBuilder(context, true, false);
                  }
                }
              },),
          ),

        ],
      ),
    );
  }

  

  Widget outsideActivityButton(){
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 150,
            margin: const EdgeInsets.only(left: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
              ),
              child: const Text("创建外部活动"),
              onPressed: (){
                if(semester != null && department != null){
                  dialogBuilder(context, false, true);
                }
              },),
          ),

          Container(
            width: 100,
            margin: const EdgeInsets.only(left: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
              ),
              child: const Text("修改活动"),
              onPressed: (){
                if(semester != null && department != null){
                  int count = 0;
                  for(int i = 0; i < outsideActivityList.length; i ++){
                    if(outsideActivityList[i].selected == true){
                      count += 1;
                      updatedActivity = outsideActivityList[i];
                      if(count > 1){
                        alertDialog(context);
                      }
                    }
                  }
                  if(count == 1){
                    dialogBuilder(context, false, false);
                  }
                }
              },),
          ),

        ],
      ),
    );
  }

  Widget activityView(bool isInternal){
    if(department == null || semester == null){
      return Container();
    }
    
    if(isInternal){
      return FutureBuilder<List<Activity>>(
        future: runFutureBuilder? getInternalActivity() : null,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            insideActivityList = snapshot.data!;
          }
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: insideActivityList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 1.0),
                    ),
                  ],
                ),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: CheckboxListTile(
                                side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(width: 1.0, color: Colors.black)),
                                checkColor: Colors.blue,
                                title: Text("活动名：${insideActivityList[index].activityName}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                value: insideActivityList[index].selected,
                                onChanged: (value) {
                                  setState(() {
                                    runFutureBuilder = false;
                                    insideActivityList[index].selected = value!;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(10),
                        childAspectRatio: (1 / 0.2),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        children: [
                          for(int i = 0; i < insideActivityList[index].userList.length; i ++)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(insideActivityList[index].userList[i].userName, style: const TextStyle(fontSize: 15),),
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.only(left: 45, right: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 220, 217, 217),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: DropdownButton(
                                    dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                                    value: insideActivityList[index].userList[i].score, style: const TextStyle(fontSize: 15, color: Colors.black),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: creditList.map((items) { 
                                        return DropdownMenuItem( 
                                          value: items, 
                                          child: Text(items.toString()), 
                                        ); 
                                      }).toList(),
                                    onChanged: (int? value) {
                                      setState(() {
                                        runFutureBuilder = false;
                                        insideActivityList[index].userList[i].score = value!;
                                        updateCredit(insideActivityList[index].activityId, insideActivityList[index].userList[i].userId, insideActivityList[index].userList[i].score);
                                      });
                                    },
                                  )
                                )
                              ],
                            ),
                        ],
                      )
                    ],
                  ),
                )
              );
            },
          );
        },
      );
    }else{
      return FutureBuilder<List<Activity>>(
        future: runFutureBuilder? getExternalActivity() : null,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            outsideActivityList = snapshot.data!;
          }
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: outsideActivityList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 1.0),
                    ),
                  ],
                ),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: CheckboxListTile(
                                side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(width: 1.0, color: Colors.black)),
                                checkColor: Colors.blue,
                                title: Text("活动名：${outsideActivityList[index].activityName}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                value: outsideActivityList[index].selected,
                                onChanged: (value) {
                                  setState(() {
                                    runFutureBuilder = false;
                                    outsideActivityList[index].selected = value!;          
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(10),
                        childAspectRatio: (1 / 0.2),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        children: [
                          for(int i = 0; i < outsideActivityList[index].userList.length; i ++)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(outsideActivityList[index].userList[i].userName, style: const TextStyle(fontSize: 15),),
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.only(left: 45, right: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 220, 217, 217),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: DropdownButton(
                                    dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                                    value: outsideActivityList[index].userList[i].score, style: const TextStyle(fontSize: 15, color: Colors.black),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: creditList.map((items) { 
                                        return DropdownMenuItem( 
                                          value: items, 
                                          child: Text(items.toString()), 
                                        ); 
                                      }).toList(),
                                    onChanged: (int? value) {
                                      setState(() {
                                        runFutureBuilder = false;
                                        outsideActivityList[index].userList[i].score = value!;
                                        updateCredit(outsideActivityList[index].activityId, outsideActivityList[index].userList[i].userId, outsideActivityList[index].userList[i].score);
                                      });
                                    },
                                  )
                                )
                              ],
                            ),
                        ],
                      )
                    ],
                  ),
                )
              );
            },
          );
        },
      );
    }
  }

  Future<void> alertDialog(BuildContext context){
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("修改活动提醒"),
          content: const Text("一次只能选择一个活动进行编辑"),
          actions: [
            TextButton(
              child: const Text("OK", style: TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
        title: const Text(
          "考勤记录",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      body: Center(
        child: ListView(
          children: [
            topMenu(),
            divider(),
            insideActivityButton(),
            activityView(true),
            outsideActivityButton(),
            activityView(false),
          ],
        ),
      ),
    );
  }


  Future<void> dialogBuilder(BuildContext context, bool isInternal, bool isCreate){
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 400,
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTextInput("活动名", "请输入活动名", isCreate? "" : updatedActivity!.activityName),
                dialogDateInput("活动日期", "请选择日期", isCreate? "" : updatedActivity!.activityDate),
                dialogButtons(isInternal, isCreate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dialogTextInput(String defaultInfo1, String defaultInfo2, String name){
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
            width: 200,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 220, 217, 217),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              onChanged: (value) {
                name == ""? activityName = value : updatedActivity!.activityName = value;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: name == ""? defaultInfo2: name, hintStyle: const TextStyle(fontSize: 15),
              ),
            ),
          )
      ],
    ),
    );
  }

  Widget dialogDateInput(String defaultInfo1, String defaultInfo2, String date){
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
            width: 200,
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 220, 217, 217),
              borderRadius: BorderRadius.circular(50),
            ),
            child: DateTimePicker(
              dateMask: "yyyy-MM-dd",
              initialValue: "",
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: date == ""? defaultInfo2 : date, hintStyle: const TextStyle(fontSize: 15),
              ),
              onChanged: (value) => date == ""? activityDate = value : updatedActivity!.activityDate = value,
              validator: (value) => date == ""? activityDate = value : updatedActivity!.activityDate = value!,
              onSaved: (newValue) => date == ""? activityDate = newValue : updatedActivity!.activityDate = newValue!,
            ),
          )
        ],
      ),
    );
  }

  Widget dialogButtons(bool isInternal, bool isCreate){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
            ),
            child: const Text("确认"),
            onPressed: (){
              runFutureBuilder = true;
              if(isInternal && isCreate){
                setState(() {
                  Navigator.of(context).pop();
                  createInternalActivity();
                });
              }else if(!isInternal && isCreate){
                setState(() {
                  Navigator.of(context).pop();
                  createExternalActivity();
                });
              }else{
                setState(() {
                  Navigator.of(context).pop();
                  updateActivity();
                });
              }
            },),
        ),
    
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(29, 32, 136, 1.0)),
            ),
            child: const Text("取消"),
            onPressed: (){
              Navigator.of(context).pop();
            },),
        ),
    
      ],
    );
  }

  Future<void> createInternalActivity() async{
    String url = "http://cms.sucsa.org:8005/api/department/createActivity";
    final response = await http.post(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      body: jsonEncode(<String, dynamic>{
        "departmentId": int.parse(department!),
        "semester": semester,
        "activityName": activityName,
        "activityDate": DateTime.parse("$activityDate 00:00:00+0800").toIso8601String(),
      }));

      print(response.body);
  }

  Future<void> createExternalActivity() async{
    String url = "http://cms.sucsa.org:8005/api/department/createOutActivity";
    final response = await http.post(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      body: jsonEncode(<String, dynamic>{
        "departmentId": int.parse(department!),
        "semester": semester,
        "activityName": activityName,
        "activityDate": DateTime.parse("${activityDate!.substring(0,10)} 00:00:00+1000").toIso8601String(),
      }));

      print(response.body);
  }

  Future<void> updateActivity() async{
    String url = "http://cms.sucsa.org:8005/api/department/updateActivity";
    final response = await http.post(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      body: jsonEncode(<String, dynamic>{
        "id": updatedActivity!.activityId,
        "activityName": updatedActivity!.activityName,
        "activityDate": DateTime.parse("${updatedActivity!.activityDate.substring(0,10)} 00:00:00+1000").toIso8601String(),
      }));

      print(response.body);
  }

  Future<List<Activity>> getInternalActivity() async{
    var uri = "http://cms.sucsa.org:8005/api/department/searchActivity?departmentId=$department&semester=$semester";
    var encoded = Uri.encodeFull(uri);
    final response = await http.get(Uri.parse(encoded), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      );
    
    List<dynamic> message = json.decode(utf8.decode(response.bodyBytes))['result'];

    List<Activity> result = [];

    message.forEach((element) {
      int activityId = element["id"];
      String activityName = element["activityName"] ?? "";
      String activityDate = element["activityDate"] ?? "";

      List<dynamic> users = element["department"]["users"];
      List<User> userList = [];
      users.forEach((element2) {
        int userId = element2["userId"];
        String userName = element2["username"];
        userList.add(User(userId: userId, userName: userName, score: 0));
      });

      List<dynamic> credit = element["creditList"];
      credit.forEach((element3) {
        int userId = element3["user"]["userId"];
        int score = element3["score"];
        for(User user in userList){
          if(user.userId == userId){
            user.score = score;
          }
        }
      });

      result.add(Activity(activityId: activityId, activityName: activityName, activityDate: activityDate, userList: userList));
    });

    return result;

  }

  Future<List<Activity>> getExternalActivity() async{
    var uri = "http://cms.sucsa.org:8005/api/department/searchOutActivity?departmentId=$department&semester=$semester";
    var encoded = Uri.encodeFull(uri);
    final response = await http.get(Uri.parse(encoded), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      );
    
    List<dynamic> message = json.decode(utf8.decode(response.bodyBytes))['result'];

    List<Activity> result = [];

    message.forEach((element) {
      int activityId = element["id"];
      String activityName = element["activityName"] ?? "";
      String activityDate = element["activityDate"] ?? "";

      List<dynamic> users = element["department"]["users"];
      List<User> userList = [];
      users.forEach((element2) {
        int userId = element2["userId"];
        String userName = element2["username"];
        userList.add(User(userId: userId, userName: userName, score: 0));
      });

      List<dynamic> credit = element["creditList"];
      credit.forEach((element3) {
        int userId = element3["user"]["userId"];
        int score = element3["score"];
        for(User user in userList){
          if(user.userId == userId){
            user.score = score;
          }
        }
      });

      result.add(Activity(activityId: activityId, activityName: activityName, activityDate: activityDate, userList: userList));
    });

    return result;
  }

  Future<void> updateCredit(int activityId, int userId, int score) async{
    String url = "http://cms.sucsa.org:8005/api/department/updateCredit";
    final response = await http.post(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      body: jsonEncode(<String, dynamic>{
        "activityId": activityId,
        "userId": userId,
        "value": score,
      }));
  }


}