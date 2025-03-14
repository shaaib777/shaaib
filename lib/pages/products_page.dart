// products_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_page.dart'; // استيراد صفحة الخريطة

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    var url = "http://192.168.0.90:8080/project/apii.php";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // التحقق من نوع البيانات
        if (data is Map<String, dynamic>) {
          if (data.containsKey('status') && data['status'] == 'error') {
            throw Exception(data['message'] ?? 'Unknown error from API');
          }

          // البحث عن القائمة داخل المفتاح "data" أو "products"
          List<dynamic>? productList;
          if (data.containsKey('data') && data['data'] is List) {
            productList = data['data'];
          } else if (data.containsKey('products') && data['products'] is List) {
            productList = data['products'];
          } else {
            throw Exception('Unexpected data format: Missing "data" or "products" key.');
          }

          setState(() {
            products = productList!;
          });
        } else if (data is List<dynamic>) {
          setState(() {
            products = data;
          });
        } else {
          throw Exception('Unexpected data format: Data is neither a Map nor a List.');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  Future<void> _addProduct(String name, double price) async {
    var url = "http://192.168.0.90:8080/project/apii.php";
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "price": price}),
    );
    if (response.statusCode == 200) {
      await fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product!')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    var url = "http://192.168.0.90:8080/project/apii.php?id=$productId";
    var response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        products.removeWhere((product) => product['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product!')),
      );
    }
  }

  Future<void> _editProduct(String productId, String name, double price) async {
    var url = "http://192.168.0.90:8080/project/apii.php?id=$productId";
    var response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": productId, "name": name, "price": price}),
    );
    if (response.statusCode == 200) {
      await fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update product!')),
      );
    }
  }

  void _showAddProductDialog() {
    String name = '';
    String price = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && price.isNotEmpty) {
                  double parsedPrice = double.tryParse(price) ?? 0.0;
                  _addProduct(name, parsedPrice);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(String productId, String currentName, double currentPrice) {
    String name = currentName;
    String price = currentPrice.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: currentName),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: price),
                onChanged: (value) {
                  price = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && price.isNotEmpty) {
                  double parsedPrice = double.tryParse(price) ?? 0.0;
                  _editProduct(productId, name, parsedPrice);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المنتجات',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // قائمة المنتجات
          ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // ✨ تغيير لون خلفية المنتج إلى الأبيض
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // ظل خفيف للخلفية
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      products[i]['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    subtitle: Text(
                      'Price: \$${products[i]['price'] ?? 'No Price'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            _showEditProductDialog(
                              products[i]['id'],
                              products[i]['name'],
                              double.parse(products[i]['price'].toString()),
                            );
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 5,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: () {
                            _confirmDeleteProduct(products[i]['id']);
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 5,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.redAccent, Colors.red],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MapPage()),
                            );
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 5,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.green, Colors.teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}