import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ongkir_providers.dart';
import 'pages/cek_ongkir.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OngkirProvider(),
      child: MaterialApp(
        title: 'Cek Ongkir',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CekOngkirScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
