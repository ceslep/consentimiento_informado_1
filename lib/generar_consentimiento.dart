// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:consentimiento_informado_1/configuracion.dart';
import 'package:consentimiento_informado_1/confirm_dialog.dart';
import 'package:consentimiento_informado_1/date_picker.dart';
import 'package:consentimiento_informado_1/paciente_model.dart';
import 'package:consentimiento_informado_1/representacion.dart';
import 'package:consentimiento_informado_1/signature.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:snack/snack.dart';

import 'texto.dart';

class GenerarConsentimiento extends StatefulWidget {
  final Paciente paciente;

  const GenerarConsentimiento({super.key, required this.paciente});

  @override
  State<GenerarConsentimiento> createState() => _GenerarConsentimientoState();
}

class _GenerarConsentimientoState extends State<GenerarConsentimiento> {
  String firma = '';
  String url = "";
  bool generando = false;
  bool inicio = true;
  final TextEditingController _fechaController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  late List<Map<String, String>> representacion;
  final bar = const SnackBar(
    content: Text(
      'Configuración guardada!',
      style: TextStyle(color: Colors.lime),
    ),
  );
  List<Map<String, String>> configuracion = [
    {"profesional": ""},
    {"direccion": ""},
    {"telefono": ""}
  ];

  Future<String> loadData(
    String key,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<List<Map<String, String>>> getConfiguracion() async {
    List<Map<String, String>> configuracion = [];
    configuracion.add({'profesional': await loadData('profesional')});
    configuracion.add({'direccion': await loadData('direccion')});
    configuracion.add({'telefono': await loadData('telefono')});
    configuracion.add({'firma': await loadData('firma')});
    url = await loadData('url');
    return configuracion;
  }

  Future<bool> launchInBrowser(Uri url) async {
    bool result = false;
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      result = false;
      throw Exception('Could not launch $url');
    } else {
      result = true;
    }
    return result;
  }

  Future<void> generarConsentimiento(String json) async {
    Uri urlpdf = Uri.parse("${url}generacons.php");
    var jsond = jsonDecode(json);
    String bodyData = jsonEncode(jsond);
    try {
      final response = await http.post(urlpdf, body: bodyData);
      if (response.statusCode == 200) {
        print("php=>${jsonDecode(response.body)}");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("error en f $e");
      showbar('$e');
    }
  }

  void showbar(String text) {
    SnackBar(
        content: Text(
      text,
      style: const TextStyle(color: Colors.lime),
    )).show(context);
  }

  @override
  void initState() {
    super.initState();
    if (inicio) {
      inicio = false;
      representacion = [
        {"identificacionPaciente": ""},
        {"nombresPaciente": ""},
        {"idRepresentante": ""},
        {"nombresRepresentante": ""},
        {"direccionRepresentante": ""},
        {"telefonoRepresentante": ""},
        {"eps": ""},
        {"prepagada": ""},
        {"tratamiento": ""},
        {"lesiones": "Hábitos Caries Dental,Enfermedad Peridontal"},
        {
          "medicamentos":
              "Implementos de higiene oral, cepillo, crema dental, enjuague, enhebradores"
        },
        {
          "consecuencias":
              "No alacanzar los objetivos planteados al inicio del tratamiento y una mal oclusión peor a la persentada"
        },
        {"alternativas": "Minitornillos, aparatos removibles, retenedores"},
        {"testigo": ""},
        {"direccionTestigo": ""},
        {"telefonoTestigo": ""},
        {"personaAcontactar": ""},
        {"telefonoContacto": ""},
        {"profesional": ""},
        {"direccionProfesional": ""},
        {"telefonoProfesional": ""},
        {"firma": ""},
        {"firmaProfesional": ""},
        {"fecha": _fechaController.text}
      ];
      /*  representacion = [
        {"identificacionPaciente": "1010125403"},
        {"nombresPaciente": "Yenifer Idarraga Gutierrez"},
        {"idRepresentante": "9695141"},
        {"nombresRepresentante": "César Leandro Patiño Vélez"},
        {"direccionRepresentante": "Guatica Risaralda"},
        {"telefonoRepresentante": "3218552353"},
        {"eps": "Fiduprevisora"},
        {"prepagada": "N/A"},
        {"tratamiento": "Ortodoncia con Brackets Cerámicos"},
        {"lesiones": "Daños en las encias y en los dientes"},
        {"medicamentos": "Acetaminofen, Ibuprofeno, Naproxeno"},
        {"consecuencias": "Alteración de la mordida"},
        {"alternativas": "Retratamiento Odontológico"},
        {"testigo": "César leandro Patiño Vélez"},
        {"direccionTestigo": "Guatica Risaralda"},
        {"telefonoTestigo": "3218552353"},
        {"personaAcontactar": "César leandro Patiño Vélez"},
        {"telefonoContacto": "3218552353"},
        {"profesional": ""},
        {"direccionProfesional": ""},
        {"telefonoProfesional": ""},
        {"firma": ""},
        {"firmaProfesional": ""},
        {"fecha": _fechaController.text},
      ]; */
    }
    reconfigura();
  }

  void reconfigura() {
    getConfiguracion().then((value) {
      configuracion = value;
      representacion[18]["profesional"] = configuracion[0]["profesional"]!;
      representacion[19]["direccionProfesional"] =
          configuracion[1]["direccion"]!;
      representacion[20]["telefonoProfesional"] = configuracion[2]["telefono"]!;
      representacion[22]["firmaProfesional"] = configuracion[3]["firma"]!;
      setState(() {});
    });
  }

  void showFirmaAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmDialog(
          title: 'Falta la Firma',
          content: 'El paciente debe firmar antes de generar',
          cancelText: 'Cancelar',
          confirmText: 'OK',
        );
      },
    ).then((confirmed) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Generar Consentimiento',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: !generando
                ? IconButton(
                    onPressed: () async {
                      if (firma == "") {
                        showFirmaAlert(context);
                        return;
                      }
                      setState(() => generando = !generando);
                      String json = "";
                      for (var dato in representacion) {
                        String key = dato.keys.first.toString();
                        String value = dato.values.first.toString();
                        json += '"$key":"$value",';
                      }
                      json = json.substring(0, json.length - 1);
                      json = "{$json}";
                      await generarConsentimiento(json);
                      showbar('Consentimiento generado');
                      String ucons =
                          "${url}consentimientos/consentimiento_${representacion[0]["identificacionPaciente"]}.pdf";
                      await launchInBrowser(Uri.parse(ucons));
                      setState(() => generando = !generando);
                    },
                    icon: const Icon(Icons.document_scanner_sharp,
                        color: Color.fromARGB(255, 199, 237, 255)),
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Configuracion()),
                );
                reconfigura();
              },
              icon: const Icon(Icons.settings, color: Colors.yellowAccent),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: IconButton(
              onPressed: () async {
                var sfirma = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Signature(),
                    ));
                print(sfirma);
                if (sfirma != null) {
                  print(sfirma);
                  firma = sfirma;
                  if (sfirma != '') {
                    representacion[21]['firma'] = sfirma;
                    setState(() => firma = sfirma);
                  }
                }
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.yellowAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1.0, right: 6),
            child: IconButton(
              onPressed: () async {
                var rep = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Representacion(
                      representacion: representacion,
                    ),
                  ),
                );
                print(rep);
                representacion = [...rep];
                reconfigura();
                print(representacion);
                setState(() {});
              },
              icon: const Icon(
                Icons.person,
                color: Colors.yellowAccent,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildDatePicker(context, _fechaController, 'Fecha'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Texto(
                configuracion: configuracion,
                paciente: widget.paciente,
                fecha: _fechaController.text,
                representacion: representacion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
