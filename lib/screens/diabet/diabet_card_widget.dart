import 'package:flutter/material.dart';
import 'package:diyabet/models/med_model.dart';

class MedicationCard extends StatelessWidget {
  final MedModel medication;
  final VoidCallback onTap;

  const MedicationCard({Key? key, required this.medication, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görsel (Varsa)
              medication.med3 != null && medication.med3!.isNotEmpty
                  ? Center(
                child: Image.asset(
                  'assets/medicine.png',
                  height: 60,
                  width: 60,
                ),
              )
                  : Container(),
              const SizedBox(height: 10),
              // İlaç İsmi
              Text(
                medication.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(19, 69, 122, 1.0),
                ),
              ),
              const SizedBox(height: 8),
              // Kullanıcı ilaç detayları
              if (medication.med1.isNotEmpty)
                Text(
                  'Doz: ${medication.med1}',
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              if (medication.med2.isNotEmpty)
                Text(
                  'Sıklık: ${medication.med2}',
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              if (medication.med3 != null && medication.med3!.isNotEmpty)
                Text(
                  'Not: ${medication.med3}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              if (medication.med4 != null && medication.med4!.isNotEmpty)
                Text(
                  'Not 2: ${medication.med4}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              if (medication.med5 != null && medication.med5!.isNotEmpty)
                Text(
                  'Not 3: ${medication.med5}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
