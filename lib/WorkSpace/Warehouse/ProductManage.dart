import 'package:flutter/material.dart';

import '../Warehouse/NewProducts.dart';
import 'DeleteProduct.dart';

class ProductManagePage extends StatelessWidget {
  const ProductManagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('物品管理', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), backgroundColor: Color.fromRGBO(29,32,136,1.0),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewProductsPage()),
                );
              },
              child: Text('新品入库',style: TextStyle(fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(29,32,136,1.0),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform another action or navigate to a different page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteProductPage()),
                );
              },
              child: Text('删除物品', style: TextStyle(fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(29,32,136,1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
