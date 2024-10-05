import 'package:flutter/material.dart';
import 'package:diyabet/models/med_model.dart';

class DiabetResultPage extends StatelessWidget {
  final MedModel medication;

  const DiabetResultPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // Arka plan rengi uygulama temasına uygun hale getirildi
      appBar: AppBar(
        title: const Text(
          'İlaçlarım',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Başlık metni düzenlendi
        ),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // AppBar arkaplan rengi
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // İlaç Görseli
            Center(
              child: Image.asset(
                'assets/medicine.png',
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),

            // İlaç İsmi
            Text(
              medication.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Başlık metni beyaz
              ),
            ),
            const SizedBox(height: 30),

            // Diğer ilaç bilgilerini göstermek için kart yapısı
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Doz:', medication.med1),
                    _buildDetailRow('Sıklık:', medication.med2),
                    if (medication.med3 != null && medication.med3!.isNotEmpty)
                      _buildDetailRow('Not 3:', medication.med3!),
                    if (medication.med4 != null && medication.med4!.isNotEmpty)
                      _buildDetailRow('Not 4:', medication.med4!),
                    if (medication.med5 != null && medication.med5!.isNotEmpty)
                      _buildDetailRow('Not 5:', medication.med5!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bilgi satırı widget'ı
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(19, 69, 122, 1.0), // Başlık rengi uygulama rengi
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
