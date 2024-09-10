import 'package:consentimiento_informado_1/generar_consentimiento.dart';
import 'package:consentimiento_informado_1/paciente_model.dart';
import 'package:flutter/material.dart';

String title = "Consentimiento Informado";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: GenerarConsentimiento(
        paciente: Paciente(),
      ),
    );
  }
}
