import 'package:flutter/material.dart';
import 'package:diyabet/helper/custom_textfield.dart';

class MedicineFormWidget extends StatelessWidget {
  final TextEditingController doseController;
  final List<TextEditingController> otherMedControllers;
  final String selectedMedicine;
  final String selectedFrequency;
  final ValueChanged<String> onMedicineChanged;
  final ValueChanged<String> onFrequencyChanged;
  final VoidCallback onSave;

  const MedicineFormWidget({
    Key? key,
    required this.selectedMedicine,
    required this.doseController,
    required this.otherMedControllers,
    required this.selectedFrequency,
    required this.onMedicineChanged,
    required this.onFrequencyChanged,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedMedicine,
          decoration: _inputDecoration('İlaç Seçin'),
          items: const [
            DropdownMenuItem(value: 'Humulin-R', child: Text('Humulin-R')),
            DropdownMenuItem(value: 'Actrapid', child: Text('Actrapid')),
            DropdownMenuItem(value: 'Humalog', child: Text('Humalog')),
            DropdownMenuItem(value: 'Novorapid', child: Text('Novorapid')),
            DropdownMenuItem(value: 'Humulin N', child: Text('Humulin N')),
            DropdownMenuItem(value: 'İnsülatard', child: Text('İnsülatard')),
            DropdownMenuItem(value: 'Novomiks', child: Text('Novomiks')),
            DropdownMenuItem(value: 'Humulin M', child: Text('Humulin M')),
            DropdownMenuItem(value: 'Humalog-Mix 25', child: Text('Humalog-Mix 25')),
            DropdownMenuItem(value: 'Novomix 30', child: Text('Novomix 30')),
            DropdownMenuItem(value: 'Lantus', child: Text('Lantus')),
            DropdownMenuItem(value: 'Levemir', child: Text('Levemir')),
          ],
          onChanged: (String? value) {
            if (value != null) {
              onMedicineChanged(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen ilaç seçin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: selectedFrequency,
          decoration: _inputDecoration('Günde Kaç Kere Kullanılıyor'),
          items: const [
            DropdownMenuItem(value: 'Günde 1 kere', child: Text('Günde 1 kere')),
            DropdownMenuItem(value: 'Günde 2 kere', child: Text('Günde 2 kere')),
            DropdownMenuItem(value: 'Günde 3 kere', child: Text('Günde 3 kere')),
            DropdownMenuItem(value: 'Günde 4 kere', child: Text('Günde 4 kere')),
          ],
          onChanged: (String? value) {
            if (value != null) {
              onFrequencyChanged(value);
            }
          },
        ),
        const SizedBox(height: 16.0),
        ...otherMedControllers.map((controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomTextFormField(
              controller: controller,
              hintText: 'Diğer İlaç Bilgisi (Opsiyonel)',
              validator: (value) => null, // Opsiyonel olduğundan doğrulama yapılmasın
            ),
          );
        }).toList(),
        const SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24D876), // Modern yeşil renk
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'İlaç Ekle',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}
