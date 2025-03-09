import 'package:flutter/material.dart';
import 'utils/color_utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void _pickColor() async {
    Color? newColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Primary Color'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.yellow,
                  Colors.purple,
                  Colors.teal,
                  Colors.black,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(color); //TODO MEGH SAVE COLOR IN JSON
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );

    if (newColor != null) {
      setState(() {
        ColorUtils.setPrimaryColor(newColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: ColorUtils.primaryColor,
        elevation: 1,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Account Page Content'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickColor,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.primaryColor,
              ),
              child: const Text('Pick Primary Color', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
