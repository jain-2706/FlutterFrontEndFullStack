import 'package:flutter/material.dart';
import 'package:http/http.dart' as hty;
import 'dart:convert';

class FormClass extends StatefulWidget {
  const FormClass({super.key});

  @override
  State<FormClass> createState() => _FormClassState();
}

class _FormClassState extends State<FormClass> {
  List<Map<String, dynamic>> data = [
    {"Message": "No data is Available"},
  ];
  String username = "";
  String email = "";
  final _key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    gettingMessage();
  }

  void gettingMessage() async {
    var response = await hty.get(Uri.parse("http://192.168.1.20:1234/project"));
    if (response.statusCode == 200) {
      var resp = response.body;
      var responseBody = List<Map<String, dynamic>>.from(json.decode(resp));
      setState(() {
        data = responseBody;
      });
    }
  }

  void saveUsername(String newValue) {
    setState(() {
      username = newValue;
    });
  }

  void saveEmail(String newValue) {
    setState(() {
      email = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form Validation")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Enter Your Username"),
                  validator: (value) {
                    if (value!.isEmpty || value.length <= 2) {
                      return "Username must be 2 characters long";
                    }
                    return null;
                  },

                  onSaved: (newValue) => {saveUsername(newValue!)},
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: "Enter Your Email"),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@gmail.com")) {
                      return "Pls Enter a valid Email";
                    }
                    return null;
                  },
                  onSaved: (newValue) => {saveEmail(newValue!)},
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,

                            child: Text(
                              data[index].toString(),
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      _key.currentState!.save();
                      final ans = await hty.post(
                        Uri.parse("http://192.168.1.20:1234/post"),
                        headers: {'Content-Type': "application/json"},
                        body: json.encode({
                          "username": username,
                          "email": email,
                        }),
                      );
                      if (ans.statusCode == 201) {
                        var again = await hty.get(
                          Uri.parse("http://192.168.1.20:1234/project"),
                        );

                        if (again.statusCode == 200) {
                          setState(() {
                            data = json.decode(again.body);
                          });
                        }

                        print("Created The User");
                        print(ans.body);
                      } else {
                        print("Problem Appears");
                      }
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
