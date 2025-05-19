import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodMenuPage extends StatefulWidget {
  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  final String supabaseUrl = 'https://ibzfbxearwtcqiaawuen.supabase.co';
  final String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliemZieGVhcnd0Y3FpYWF3dWVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1MDYzMDksImV4cCI6MjA2MzA4MjMwOX0.FJejHUbOZM-GvN-20Ttufp5i0wolFqwAFf4_MVlGTFw';
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    final url = Uri.parse('$supabaseUrl/rest/v1/food_items?select=*&order=created_at.desc');
    try {
      final response = await http.get(
        url,
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          foodItems = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to fetch: ${response.body}");
      }
    } catch (e) {
      print("Error fetching food items: $e");
    }
  }

  void _orderFood(BuildContext context, Map<String, dynamic> food) async {
    int quantity = 1;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Select Quantity", style: TextStyle(color: Colors.orange)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.orange),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                  ),
                  Text(quantity.toString(), style: TextStyle(fontSize: 18, color: Colors.black)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.orange),
                    onPressed: () {
                      setState(() => quantity++);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _sendWhatsAppOrder(food, quantity);
              },
              child: Text("Order", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Check if profile is complete
  Future<bool> _isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final address = prefs.getString('address');

    return name != null && name.isNotEmpty && address != null && address.isNotEmpty;
  }

  void _sendWhatsAppOrder(Map<String, dynamic> food, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('name') ?? 'N/A';
    final userAddress = prefs.getString('address') ?? 'N/A';

    final name = food['name'] ?? 'Unknown';
    final price = double.tryParse(food['price'].toString()) ?? 0;
    final imageUrl = food['image_url'] ?? '';
    final total = (price * quantity).toStringAsFixed(2);

    final message = Uri.encodeComponent(
        "🛒 *Food Order*\n\n"
            "🍽️ *Food:* $name\n"
            "💵 *Price:* \$$price\n"
            "🔢 *Quantity:* $quantity\n"
            "🧾 *Total:* \$$total\n"
            "📍 *Customer Name:* $userName\n"
            "🏠 *Address:* $userAddress\n"
            "🖼️ *Image:* $imageUrl"
    );

    final whatsappUrl = "https://wa.me/+8801782595673?text=$message";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WhatsApp not installed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("🍴 Food Menu", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        elevation: 10,
      ),
      body: foodItems.isEmpty
          ? Center(child: Text('No food items right now. Please check back later.', style: TextStyle(fontSize: 18, color: Colors.grey,),textAlign: TextAlign.center,))
          : ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final food = foodItems[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      food['image_url'] ?? '',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'] ?? 'No name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            overflow: TextOverflow.ellipsis
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "tk ${food['price']}",
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),

                        ElevatedButton.icon(
                          onPressed: () => _orderFood(context, food),
                          icon: Icon(Icons.shopping_cart),
                          label: Text("Order Now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
