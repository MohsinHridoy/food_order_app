import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;

  final String supabaseUrl = 'https://ibzfbxearwtcqiaawuen.supabase.co';
  final String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliemZieGVhcnd0Y3FpYWF3dWVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDYzMDksImV4cCI6MjA2MzA4MjMwOX0.FJejHUbOZM-GvN-20Ttufp5i0wolFqwAFf4_MVlGTFw';
  final String bucketName = 'foods';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadFood() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (_imageFile == null || name.isEmpty || priceText.isEmpty) {
      _showSnackBar("Please fill all fields and select an image.");
      return;
    }

    double? price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showSnackBar("Enter a valid price.");
      return;
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(_imageFile!.path)}';
    final storageUrl = '$supabaseUrl/storage/v1/object/$bucketName/$fileName';

    try {
      // Upload image
      final imageUploadRes = await http.post(
        Uri.parse(storageUrl),
        headers: {
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/octet-stream',
          'x-upsert': 'true',
        },
        body: await _imageFile!.readAsBytes(),
      );

      if (imageUploadRes.statusCode != 200) {
        // Print the error response from Supabase for debugging
        print("Error uploading image: ${imageUploadRes.body}");
        throw Exception('Failed to upload image: ${imageUploadRes.body}');
      }

      final publicUrl = '$supabaseUrl/storage/v1/object/public/$bucketName/$fileName';

      // Upload food data
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/food_items'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode({
          'name': name,
          'price': price,
          'image_url': publicUrl,
        }),
      );

      if (response.statusCode != 201) {
        // Print the error response from Supabase for debugging
        print("Error uploading food data: ${response.body}");
        throw Exception('Failed to save food data: ${response.body}');
      }

      _showSnackBar('Food uploaded successfully!');
      _resetForm();
    } catch (e) {
      _showSnackBar('Error: $e');
      print("Error: $e");  // This will print the error in the console
    }
  }
  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Upload Food',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.deepOrange,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orangeAccent, width: 2),
                          image: _imageFile != null
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                          color: Colors.orange[50],
                        ),
                        child: _imageFile == null
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.orange),
                              SizedBox(height: 8),
                              Text('Tap to upload image', style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        prefixIcon: const Icon(Icons.fastfood),
                        filled: true,
                        fillColor: Colors.orange[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Colors.orange[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadFood,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Food'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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
