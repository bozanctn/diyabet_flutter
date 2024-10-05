import 'package:flutter/material.dart';

const kBottomContainerHeight = 80.0;

// Arkaplana uygun aktif ve inaktif kart renkleri
const kActiveCardColour = Color(0xFF255784); // Açık mavi tonlu aktif kart rengi
const kInactiveCardColour = Color(0xFF1D4C73); // Daha koyu mavi tonlu inaktif kart rengi

// Alt bölümdeki buton rengini arkaplana uyacak şekilde düzenledim
const kBottomContainerColour = Color(0xFF1C5DA1); // Alt buton rengi (Arkaplan rengine uyumlu)

const kLabelTextStyle = TextStyle(
  fontSize: 18.0,
  color: Color(0xFFB0C4DE), // Açık mavi tonlu yazı rengi
);

const kNumberTextStyle = TextStyle(
  fontSize: 50.0,
  fontWeight: FontWeight.w900,
  color: Colors.white, // Kart üzerindeki sayılar için beyaz renk
);

const kLargeButtonTextStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  color: Colors.white, // Büyük buton yazısı için beyaz
);

const kTitleTextStyle = TextStyle(
  fontSize: 50.0,
  fontWeight: FontWeight.bold,
  color: Colors.white, // Başlık yazıları için beyaz
);

const kResultTextStyle = TextStyle(
  color: Color(0xFF24D876), // Sonuç bölümünde kullanılan yeşil renk (Doğru bir değer)
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

const kBMITextStyle = TextStyle(
  fontSize: 100.0,
  fontWeight: FontWeight.bold,
  color: Colors.white, // BMI sonucu için beyaz renk
);

const kBodyTextStyle = TextStyle(
  fontSize: 22.0,
  color: Colors.white, // Açıklama metni için beyaz renk
);
