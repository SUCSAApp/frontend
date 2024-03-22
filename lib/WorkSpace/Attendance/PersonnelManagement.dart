import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sucsa_app/WorkSpace/Attendance/UserCreate.dart';
import 'package:sucsa_app/WorkSpace/Attendance/UserUpdate.dart';

class PersonnelManagementPage extends StatefulWidget {
  const PersonnelManagementPage({super.key});

  @override
  State<PersonnelManagementPage> createState() => PersonnelManagementPageState();
}

class Department{
  int id;
  String name;

  Department({
    required this.id,
    required this.name,
  });

}

class People {
  int id;
  String username;
  String sur;
  String name;
  int sex;
  String phone;
  String email;
  String degree;
  String major;
  int begin;
  int end;
  String usu;
  String date;
  String sid;
  String department;
  int departmentId;
  bool selected;

  People({
    required this.id,
    required this.username,
    required this.sur,
    required this.name,
    required this.sex,
    required this.phone,
    required this.email,
    required this.degree,
    required this.major,
    required this.begin,
    required this.end,
    required this.usu,
    required this.date,
    required this.sid,
    required this.department,
    required this.departmentId,
    this.selected = false,
  });

}

class PersonnelManagementPageState extends State<PersonnelManagementPage> {

  bool runFutureBuilder = true;

  String? dropdownvalue;

  People? updatedPeople;

  List<Department> departments = [];

  List<People> members = [];

  Widget topMenu(){
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text("选择部门", style: TextStyle(fontSize: 18)),
          ),

          FutureBuilder<List<Department>>(
              future: getAllDepartments(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  departments = snapshot.data!;
                }
                return Container(
                  width: 400,
                  padding: const EdgeInsets.only(left:20, right: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 220, 217, 217),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: DropdownButton(
                    dropdownColor: const Color.fromARGB(255, 220, 217, 217),
                    value: dropdownvalue, style: const TextStyle(fontSize: 15, color: Colors.black),
                    hint: const Text("部门名称", style: TextStyle(fontSize: 15),),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: departments.map((Department items) {
                      return DropdownMenuItem(
                        value: items.name,
                        child: Text(items.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        runFutureBuilder = true;
                        dropdownvalue = newValue!;
                      });
                    },),
                );
              })

        ],
      ),
    );

  }

  Widget threeButtons(){
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              child: const Text("添加用户"),
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCreatePage()),);},),
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
              child: const Text("编辑用户"),
              onPressed: (){
                int count = 0;
                for(int i = 0; i < members.length; i ++){
                  if(members[i].selected == true){
                    count += 1;
                    updatedPeople = members[i];
                    if(count > 1){
                      dialogBuilder(context);
                    }
                  }
                }

                if(count == 1){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserUpdatePage(people: updatedPeople,)),);
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
              child: const Text("删除用户"),
              onPressed: (){setState(() {
                runFutureBuilder = true;
                deleteUser();
              });},),
          ),



        ],
      ),
    );
  }

  Widget dataTable(){
    return FutureBuilder<List<People>>(
        future: runFutureBuilder? getAllMembers() : null,
        builder: (context, snapshot){
          if(snapshot.hasData){
            members = snapshot.data!;
          }
          List<DataRow> dataRows = [];
          for(int i = 0; i < members.length; i ++){
            if(dropdownvalue == null){
              dataRows.add(DataRow(
                cells: [
                  DataCell(Text(members[i].department)),
                  DataCell(Text(members[i].sur)),
                  DataCell(Text(members[i].name)),
                ],
                selected: members[i].selected,
                onSelectChanged: (value){
                  setState(() {
                    runFutureBuilder = false;
                    members[i].selected = value!;
                  });
                },
              ));
            }else{
              if(dropdownvalue == members[i].department){
                dataRows.add(DataRow(
                  cells: [
                    DataCell(Text(members[i].department)),
                    DataCell(Text(members[i].sur)),
                    DataCell(Text(members[i].name)),
                  ],
                  selected: members[i].selected,
                  onSelectChanged: (value){
                    setState(() {
                      runFutureBuilder = false;
                      members[i].selected = value!;
                    });
                  },
                ));
              }
            }
          }

          return DataTable(
            columns: const [
              DataColumn(label: Text("部门", style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text("姓", style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text("名", style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
            rows: dataRows, showBottomBorder: true,
          );
        });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
            title: const Text(
              "人员管理",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        body: ListView(
          children: [
            topMenu(),
            threeButtons(),
            dataTable(),
          ],
        ),
      ),


    );
  }

  Future<void> deleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    String url = "http://cms.sucsa.org:8005/api/user/deleteUser";

    bool success = false;

    int i = 0;
    while (i < members.length) {
      if (members[i].selected) {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(<String, dynamic>{
            "userId": members[i].id,
          }),
        );


        if (response.statusCode == 200) {
          print("User deleted successfully");
          members.removeAt(i);
          success = true;
          continue;
        } else {
          print("Failed to delete user: ${response.body}");
        }
      }
      i++;
    }

    if (success) {
      showSuccessDialog();
    }
  }

  Future<void> showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('User(s) deleted successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  runFutureBuilder = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogBuilder(BuildContext context){
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("编辑用户提醒"),
          content: const Text("一次只能选择一个用户进行编辑"),
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




  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  Future<List<Department>> getAllDepartments() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    List<Department> data = [];

    String url = "http://cms.sucsa.org:8005/api/department/list";
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",});

    List<dynamic> message = json.decode(utf8.decode(response.bodyBytes))['result'];
    message.forEach((element) {
      var department = Department(id: element["id"], name: element["name"]);
      data.add(department);
    });

    return data;

  }

  Future<List<People>> getAllMembers() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    List<People> data = [];

    String url = "http://cms.sucsa.org:8005/api/department/list";
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token",});

    List<dynamic> message = json.decode(utf8.decode(response.bodyBytes))['result'];
    message.forEach((element) {
      String myDepartment = element["name"] ?? "";
      int myDepartmentId = element["id"] ?? 1;
      List<dynamic> users = element["users"];
      users.forEach((element2) {
        var people = People(
            id: element2["userId"] ?? 0,
            username: element2["username"] ?? "",
            sur: element2["lastname"] ?? "",
            name: element2["firstname"] ?? "",
            sex: element2["sex"] ?? 1,
            phone: element2["phone"] ?? "",
            email: element2["email"] ?? "",
            degree: element2["degree"] ?? "",
            major: element2["major"] ?? "",
            begin: element2["beginSemester"]["id"] ?? 0,
            end: element2["endSemester"]["id"] ?? 0,
            usu: element2["usuNumber"] ?? "",
            date: element2["usuExpiry"] ?? "",
            sid: element2["sid"] ?? "",
            department: myDepartment,
            departmentId: myDepartmentId);
        data.add(people);
      });
    });

    data.forEach((people) {
      print(people.id);
    });

    return data;

  }


}
