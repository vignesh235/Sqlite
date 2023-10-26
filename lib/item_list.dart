import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_db/contents.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item list"),
      ),  
      body: ListView.builder(
          itemCount: listOfDictionaries.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                onTap: () {
                  var temp = {};
                  print(listOfDictionaries[index]["item_name"]);
                  temp["item_name"] = listOfDictionaries[index]["item_name"];
                  temp["item_code"] = listOfDictionaries[index]["item_code"];
                  // temp["rate_controller"] = "1";

                  setState(() {
                    selectedItem.add(temp);
                  });
                  Get.toNamed('/homepage');
                },
                leading: const Icon(Icons.list),
                trailing: Text(
                  listOfDictionaries[index]["qty"].toString(),
                  style: const TextStyle(color: Colors.green, fontSize: 15),
                ),
                title: Text(listOfDictionaries[index]["item_name"]));
          }),
    );
  }
}
