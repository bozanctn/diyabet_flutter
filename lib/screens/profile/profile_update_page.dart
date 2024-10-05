import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  DateTime _selectedDate = DateTime(2000, 1, 1);
  String _gender = "Erkek";
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await _firestore.collection('Users').doc(user.uid).get();
      Map<String, dynamic>? myData = documentSnapshot.data() as Map<String, dynamic>?;

      setState(() {
        _nameController.text = myData?['username'] ?? "";
        _phoneController.text = myData?['phone'] ?? "";
        _locationController.text = myData?['location'] ?? "";
        _aboutMeController.text = myData?['aboutMe'] ?? "";
        _gender = myData?['gender'] ?? "Erkek";

        if (myData?['dateOfBirth'] != null) {
          _selectedDate = DateTime.parse(myData!['dateOfBirth']);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Kırp',
            toolbarColor: const Color.fromRGBO(19, 69, 122, 1.0), // Diyabet uygulama rengi
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
        ],
      );

      if (cropped != null) {
        setState(() {
          _profileImage = File(cropped.path);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _locationController.text.isEmpty || _aboutMeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tüm alanları doldurmalısınız.")));
      return;
    }

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String? imageUrl;
        if (_profileImage != null) {
          final ref = _storage.ref().child('media/${user.uid}.jpg');
          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        }

        await _firestore.collection('Users').doc(user.uid).update({
          'username': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'aboutMe': _aboutMeController.text,
          'gender': _gender,
          'dateOfBirth': _selectedDate.toIso8601String(),
          if (imageUrl != null) 'pictureUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profiliniz kaydedildi.")));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil kaydedilirken bir hata oluştu: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // Diyabet uygulaması arka plan rengi
      appBar: AppBar(
        title: const Text('Profil Düzenle'),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Adı Soyadı', _nameController),
            const SizedBox(height: 16),
            _buildGenderSelector(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTextField('Cep Telefonu', _phoneController, keyboardType: TextInputType.phone, maxLength: 11),
            const SizedBox(height: 16),
            _buildTextField('İkametgah Adresi', _locationController),
            const SizedBox(height: 16),
            _buildTextField('Hakkında', _aboutMeController, maxLines: 4, maxLength: 200),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24D876), // Diyabet uygulaması yeşil buton rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: const Text(
                'Profili Kaydet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String labelText,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        int? maxLength,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white), // Yazı rengi beyaz
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF24D876), width: 2.0), // Yeşil odak rengi
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildGenderOption('Erkek', Icons.male),
        const SizedBox(width: 10),
        _buildGenderOption('Kadın', Icons.female),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData iconData) {
    final bool isSelected = _gender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C5DA1) : Colors.grey[300], // Seçili olan için mavi, diğerleri gri
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(iconData, size: 30, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 5),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1950),
          lastDate: DateTime(DateTime.now().year),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Doğum Tarihi',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF24D876), width: 2.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                style: const TextStyle(color: Colors.white)),
            const Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
