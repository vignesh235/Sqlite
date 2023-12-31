import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';
import 'package:local_db/DB/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:local_db/contents.dart';
import 'package:local_db/controller/dp_helper.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All data
  List<Map<String, dynamic>> myData = [];
  List<Map<String, dynamic>> offlinedata = [];
  DatabaseHelper_ databaseHelper = DatabaseHelper_();
  String base64string = "";
  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await DatabaseHelper.getItems2();
    final item_ = await databaseHelper.getItems();
    setState(() {
      myData = data;
      offlinedata = item_;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _refreshData(); // Loading the data when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String base64Image = "";
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void showMyForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['salary'];
      _descriptionController.text = existingData['number'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new data

                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      print(
                          "[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]][]]]]]]");
                      print(connectivityResult.toString());
                      if (connectivityResult != ConnectivityResult.none) {
                        print("pppppppppppppppppppppppppppppppppp");
                        if (id == null) {
                          await addItem();
                        }

                        if (id != null) {
                          await updateItem(id);
                        }

                        // Clear the text fields
                        _titleController.text = '';
                        _descriptionController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                        print(myData);
                      } else {
                        const baseUrl =
                            "https://smb.thirvusoft.co.in/api/method/ssm_bore_wells.ssm_bore_wells.utlis.api.sales_order";
                        print(myData);
                        for (var item in myData) {
                          final salary = item['salary'];
                          final item_ = item['item_'];
                          const number = "2023-10-20";

                          print(item['salary']);
                          print(item['item_']);

                          final response = await http.get(Uri.parse(
                              '$baseUrl?cus_name=$salary&due_date=$number&items=$item_'));
                          print(response.body);
                          if (response.statusCode == 200) {
                            print(item['id']);
                            await DatabaseHelper.deleteItem2(item['id']);
                            _refreshData();

                            print("Response data: ${response.body}");
                          } else {
                            print(
                                "Failed to fetch data. Status code: ${response.statusCode}");
                          }
                        }
                      }
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new data to the database
  Future<void> addItem() async {
    await DatabaseHelper.createItem2(
        _titleController.text, _descriptionController.text, base64Image);
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem2(
        id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await DatabaseHelper.deleteItem2(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.green));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            databaseHelper.pickImage();

            // print(databaseHelper.selectedImagePath);

            File imagefile = File(databaseHelper.selectedImagePath
                .toString()); //convert Path to File
            Uint8List imagebytes =
                await imagefile.readAsBytes(); //convert to bytes
            setState(() {
              base64string = base64.encode(imagebytes);
            });
            //convert bytes to base64 string

            // print('------------------------base644444---------------');
            // print(base64string);
          },
          icon: const HeroIcon(
            HeroIcons.camera,
            color: Colors.black,
            size: 25,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Get.toNamed('/Item');
              // String customer = "John Doe";
              // String base64Image = "your_base64_image_data";
              // String item = "Your Item Name";

              // await databaseHelper.createItem(customer, base64Image, item);

              // var item_ = await databaseHelper.getItems();
              // print(item_);

              // print("teststststststststtstststs");
              // http.Response response = await http.get(Uri.parse(
              //     'https://cdn-images-1.medium.com/max/1200/1*5-aoK8IBmXve5whBQM90GA.png'));

              // Uint8List imageBytes = response.bodyBytes; // your image data

              // setState(() {
              //   base64Image = base64Encode(imageBytes);
              // });

              // print("teststststststststtstststs");
              // print(base64Image);
            },
            child: const Text(
              'Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        title: const Text('Sqlite CRUD'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : selectedItem.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                      child: Image.memory(base64.decode(base64string))))
              : Column(
                  children: [
                    const Text("Customer Name: Gowtham"),
                    SizedBox(
                      height: selectedItem.length * 60,
                      child: ListView.builder(
                        itemCount: selectedItem.length,
                        itemBuilder: (context, index) {
                          if (!selectedItem[index]
                              .containsKey('rate_controller')) {
                            selectedItem[index]['rate_controller'] =
                                TextEditingController();
                          } else {
                            print("elslelelslslelslslelslse");
                            selectedItem[index]['rate_controller'].value =
                                TextEditingValue(
                                    text: selectedItem[index]['rate_controller']
                                        .text,
                                    selection: TextSelection.collapsed(
                                        offset: selectedItem[index]
                                                ['rate_controller']
                                            .text
                                            .toString()
                                            .length));

                            print(selectedItem[index]['rate_controller']);
                          }

                          return Card(
                              color: index % 2 == 0
                                  ? Colors.green
                                  : Colors.green[200],
                              // margin: const EdgeInsets.all(15),
                              child: ListTile(
                                title: Text(selectedItem[index]["item_name"]
                                    .toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 45,
                                      child: TextField(
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        textAlign: TextAlign.start,
                                        controller: selectedItem[index]
                                            ['rate_controller'],
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedItem[index]['rate'] =
                                                selectedItem[index]
                                                        ['rate_controller']
                                                    .text;
                                          });
                                          print("muruhaaaasasasas");
                                          print(selectedItem);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedItem.removeAt(index);
                                        });
                                      },
                                      icon: const HeroIcon(
                                        HeroIcons.trash,
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              )

                              // ListTile(
                              //     title: Text(myData[index]["salary"].toString()),
                              //     subtitle:
                              //         Text(myData[index]['number'].toString()),
                              //     trailing: SizedBox(
                              //       width: 100,
                              //       child: Row(
                              //         children: [
                              //           IconButton(
                              //             icon: const Icon(Icons.edit),
                              //             onPressed: () =>
                              //                 showMyForm(myData[index]['id']),
                              //           ),
                              //           IconButton(
                              //             icon: const Icon(Icons.delete),
                              //             onPressed: () =>
                              //                 deleteItem(myData[index]['id']),
                              //           ),
                              //         ],
                              //       ),
                              //     )),
                              );
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        for (var item in selectedItem) {
                          item.remove(
                              'rate_controller'); // Remove the 'rate_controller' key from the item
                        }
                        var connectivityResult =
                            await (Connectivity().checkConnectivity());
                        print(connectivityResult);
                        if (connectivityResult == ConnectivityResult.none) {
                          print(selectedItem);
                          print(jsonEncode(selectedItem));
                          await databaseHelper.createItem(
                              "Gowtham",
                              "base64Image",
                              jsonEncode(selectedItem).toString());

                          var item_ = await databaseHelper.getItems();
                          print(item_);
                        } else {
                          print("connected");
                          const baseUrl =
                              "https://smb.thirvusoft.co.in/api/method/ssm_bore_wells.ssm_bore_wells.utlis.api.sales_order";
                          var item_ = await databaseHelper.getItems();
                          setState(() {
                            offlinedata = item_;
                          });
                          for (var item in offlinedata) {
                            final salary = item['customer'];
                            final item_ = item['item'];
                            const number = "2023-10-26";

                            final response = await http.get(Uri.parse(
                                '$baseUrl?cus_name=$salary&due_date=$number&items=$item_'));
                            print(response.body);
                            if (response.statusCode == 200) {
                              print(item['id']);
                              await databaseHelper.deleteItem(item['id']);

                              print("Response data: ${response.body}");
                            } else {
                              print(
                                  "Failed to fetch data. Status code: ${response.statusCode}");
                            }
                            var item__ = await databaseHelper.getItems();
                            print(
                                "-------------------------------after-------delection");
                            print(item__);
                          }
                        }
                      },
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          print(selectedItem);

          // showMyForm(null);
        },
      ),
    );
  }
}
