import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../../helper/loading_screen.dart';
import '../../helper/alert_messages.dart';
import 'package:diyabet/screens/Intro/intro_screen.dart';

import 'login_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  DateTime? _birthdate;
  String? _gender;

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        LoadingDialog.show(context, message: 'Kaydediliyor...');
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          UserProfile profile = UserProfile(
            uid: user.uid,
            name: _nameController.text,
            surname: _surnameController.text,
            birthdate: _birthdate!,
            gender: _gender!,
            weight: _weightController.text,
            height: _heightController.text,
            first: false,
          );
          await UserProfile.saveProfile(profile);
          LoadingDialog.hide(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => IntroScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        LoadingDialog.hide(context);
        AlertMessages.showBasicError(
            context, title: 'Hata', message: "Veriler yüklenirken hata oluştu");
      }
    }
  }

  Future<void> _logOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş Hatası, Tekrar Deneyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF4A90E2),
        title: const Text(
          'Başlamadan Önce',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'UbuntuSans',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _logOut,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Adı Soyadı..',
                  validatorMessage: 'Lütfen adınızı girin',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _surnameController,
                  hintText: 'Soyadı..',
                  validatorMessage: 'Lütfen soyadınızı girin',
                ),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weightController,
                  hintText: 'Kilo',
                  keyboardType: TextInputType.number,
                  validatorMessage: 'Lütfen kilonuzu girin',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _heightController,
                  hintText: 'Boy',
                  keyboardType: TextInputType.number,
                  validatorMessage: 'Lütfen boyunuzu girin',
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black38,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'UbuntuSans',
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFamily: 'UbuntuSans',
        ),
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFamily: 'UbuntuSans',
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54), // Seçili değilken gri
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Seçiliyken beyaz
        ),
      ),
      style: const TextStyle(
        color: Colors.white, // Metin rengi beyaz
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFamily: 'UbuntuSans',
      ),
      cursorColor: Colors.white, // İmleç rengi beyaz
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _birthdate = pickedDate;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: _birthdate == null
                ? 'Doğum tarihi (Yıl / Ay / Gün)'
                : 'Doğum Tarihi: ${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
            labelStyle: TextStyle(
              color: _birthdate == null ? Colors.white54 : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'UbuntuSans',
            ),
            hintStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'UbuntuSans',
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white54), // Seçili değilken gri
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white), // Seçiliyken beyaz
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: 'UbuntuSans',
          ),
          cursorColor: Colors.white,
          validator: (value) {
            if (_birthdate == null) {
              return 'Lütfen doğum tarihinizi seçin';
            }
            return null;
          },
        ),
      ),
    );
  }


  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      hint: const Text('Cinsiyet',
      style: TextStyle(color: Colors.white54),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _gender = newValue;
        });
      },
      items: <String>['Erkek', 'Kadın', 'Diğer']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'UbuntuSans',
            ),
          ),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Cinsiyet',
        labelStyle: TextStyle(
          color: Colors.white54,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFamily: 'UbuntuSans',
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54), // Seçili değilken gri
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Seçiliyken beyaz
        ),
      ),
      dropdownColor: Colors.blueAccent.shade100,
      iconEnabledColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.normal,
        fontFamily: 'UbuntuSans',
      ),
      validator: (value) {
        if (value == null) {
          return 'Lütfen cinsiyetinizi seçin';
        }
        return null;
      },
    );
  }
}
