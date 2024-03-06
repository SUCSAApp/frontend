import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sucsa_app/WorkSpace/Attendance/PersonnelManagement.dart';
import 'package:http/http.dart' as http;
import 'package:sucsa_app/main.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:intl/intl.dart';


class UserUpdatePage extends StatefulWidget {
  const UserUpdatePage({super.key, this.people,});

  final People? people;

  @override
  State<UserUpdatePage> createState() => UserUpdatePageState();
}

class UserUpdatePageState extends State<UserUpdatePage> {

  String token = getToken();

  String id = "";
  String username = "";
  String sur = "";
  String name = "";
  String? sex;
  String phone = "";
  String email = "";
  String? degree;
  String major = "";
  String usu = "";
  String sid = "";
  String? begin;
  String? end;
  String date = "";
  String? department;

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
    {"id": 14, "name": "2024年S2学期"},
    {"id": 15, "name": "2025年S1学期"},
    {"id": 16, "name": "2025年S2学期"},];

  List sexList = [
    {"id": 1, "sex": "男"},
    {"id": 2, "sex": "女"},];

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

  List<String> degreeList = ["Bachelor", "Master(Coursework)", "Master(Research)", "Phd"];

  final myControllerUsername = TextEditingController();
  final myControllerSur = TextEditingController();
  final myControllerName= TextEditingController();
  final myControllerPhone = TextEditingController();
  final myControllerEmail = TextEditingController();
  final myControllerMajor = TextEditingController();
  final myControllerUSU = TextEditingController();
  final myControllerSID = TextEditingController();

  @override
  void initState(){
    super.initState();
    id = widget.people!.id.toString();
    username = widget.people!.username;
    sur = widget.people!.sur;
    name = widget.people!.name;
    sex = widget.people!.sex.toString();
    phone = widget.people!.phone;
    email = widget.people!.email;
    degree = widget.people!.degree;
    major = widget.people!.major;
    usu = widget.people!.usu;
    sid = widget.people!.sid;
    begin = widget.people!.begin.toString();
    end = widget.people!.end.toString();
    date = widget.people!.date;
    department = widget.people!.departmentId.toString();
  }

  Widget inputContents(){
    return ListView(
      children: [
        textInput("用户名", myControllerUsername),
        textInput("姓", myControllerSur),
        textInput("名", myControllerName),
        sexDropDownButton("性别"),
        textInput("电话", myControllerPhone),
        textInput("邮箱", myControllerEmail),
        degreeDropDownButton("学位"),
        textInput("专业", myControllerMajor),
        semesterDropDownButton("加入学联学期"),
        semesterDropDownButton("毕业学期"),
        textInput("USU Number", myControllerUSU),
        dateDropDownButton("USU到期日", date),
        textInput("SID", myControllerSID),
        departmentDropDownButton("部门"),
        twoButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
        title: const Text(
          "更新用户",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      body: inputContents(),
      
    );
  }

Widget textInput(String defaultInfo1, TextEditingController myController){
  switch(defaultInfo1){
    case "用户名": myControllerUsername.text = widget.people!.username; break;
    case "姓": myControllerSur.text = widget.people!.sur; break;
    case "名":myControllerName.text = widget.people!.name; break;
    case "电话":myControllerPhone.text = widget.people!.phone; break;
    case "邮箱":myControllerEmail.text = widget.people!.email; break;
    case "专业":myControllerMajor.text = widget.people!.major; break;
    case "USU Number": myControllerUSU.text = widget.people!.usu; break;
    case "SID": myControllerSID.text = widget.people!.sid; break;
  }

  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
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
                controller: myController,
                onChanged: (value) {
                  switch(defaultInfo1){
                    case "用户名": username = value; break;
                    case "姓": sur = value; break;
                    case "名": name = value; break;
                    case "电话": phone = value; break;
                    case "邮箱": email = value; break;
                    case "专业": major = value; break;
                    case "USU Number": usu = value; break;
                    case "SID": sid = value; break;
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
            ),
            )
      ],
    ),
  );
}

Widget semesterDropDownButton(String defaultInfo1){
  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
              width: 200,
              padding: const EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 217, 217),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButton(
                dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                value: defaultInfo1 == "加入学联学期"? begin : end, style: const TextStyle(fontSize: 15, color: Colors.black),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: semesterList.map((items) { 
                    return DropdownMenuItem( 
                      value: items["id"].toString(), 
                      child: Text(items["name"]), 
                    ); 
                  }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    switch(defaultInfo1){
                      case "加入学联学期": begin = value; break;
                      case "毕业学期": end = value; break;
                    }
                  });
                },)
            )
      ],
    ),
  );
}

Widget sexDropDownButton(String defaultInfo1){
  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
              width: 200,
              padding: const EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 217, 217),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButton(
                dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                value: sex, style: const TextStyle(fontSize: 15, color: Colors.black),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: sexList.map((items) { 
                    return DropdownMenuItem( 
                      value: items["id"].toString(), 
                      child: Text(items["sex"]), 
                    ); 
                  }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    sex = value;
                  });
                },)
            )
      ],
    ),
  );
}

Widget degreeDropDownButton(String defaultInfo1){
  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
              width: 200,
              padding: const EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 217, 217),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButton(
                dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                value: degree, style: const TextStyle(fontSize: 15, color: Colors.black),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: degreeList.map((String items) { 
                    return DropdownMenuItem( 
                      value: items, 
                      child: Text(items), 
                    ); 
                  }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    degree = value;
                  });
                },)
            )
      ],
    ),
  );
}

Widget dateDropDownButton(String defaultInfo1, String initial){
  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
              width: 200,
              padding: const EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 217, 217),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DateTimePicker(
                dateMask: "yyyy-MM-dd",
                initialValue: initial,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) => date = value,
                validator: (value) => date = value!,
                onSaved: (newValue) => date = newValue!,
              )
            )
      ],
    ),
  );
}

Widget departmentDropDownButton(String defaultInfo1){
  return Container(
    margin: const EdgeInsets.only(left: 30, top: 10, right: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("$defaultInfo1 :", style: const TextStyle(fontSize: 18),),
        Container(
              width: 200,
              padding: const EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 220, 217, 217),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButton(
                dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                value: department, style: const TextStyle(fontSize: 15, color: Colors.black),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: departmentList.map((items) { 
                    return DropdownMenuItem( 
                      value: items["id"].toString(), 
                      child: Text(items["name"]), 
                    ); 
                  }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    department = value;
                  });
                },)
            )
      ],
    ),
  );
}

Widget twoButtons(){
    return Container(
      margin: const EdgeInsets.all(30.0),
      child: Row(
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
              onPressed: (){updateUser(); Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonnelManagementPage()),);},),
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
              onPressed: (){Navigator.of(context).pop();},),
          ),

        ],
      ),
    );
  }

  Future<void> updateUser() async{
    String url = "http://cms.sucsa.org:8005/api/user/update";
    final response = await http.post(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",},
      body: jsonEncode(<String, dynamic>{
        "userId": int.parse(id),
        "username": username,
        "firstname": name,
        "lastname": sur,
        "sex": int.parse(sex!),
        "phone": phone,
        "email": email,
        "beginSemester": {"id": int.parse(begin!)},
        "endSemester": {"id": int.parse(end!)},
        "degree": degree,
        "major": major,
        "usuExpiry": DateTime.parse("${date.substring(0,10)} 00:00:00+1000").toIso8601String(),
        "usuNumber": usu,
        "sid": sid,
        "department": {"id": int.parse(department!)},
      }));

      print(response.body);
  }



}