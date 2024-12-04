import 'package:flutter/material.dart';
import 'package:diyabet/screens/calculator/constants.dart';
import 'package:diyabet/screens/calculator/components/reusable_card.dart';
import 'package:diyabet/screens/calculator/components/bottom_button.dart';

class ResultsPage extends StatelessWidget {
  ResultsPage({
    required this.interpretation,
    required this.bmiResult,
    required this.resultText,
  });

  final String bmiResult;
  final String resultText;
  final String interpretation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // Arkaplan rengi
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0), // AppBar rengi
        centerTitle: true,
        title: const Text(
          'VKİ Sonucu',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              alignment: Alignment.center,
              child: const Text(
                'Sonucunuz',
                style: kTitleTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ReusableCard(
              colour: kActiveCardColour, // Aktif kart rengi
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    resultText.toUpperCase(),
                    style: kResultTextStyle, // Yeşil renk sonucu belirten yazı
                  ),
                  Text(
                    bmiResult,
                    style: kBMITextStyle, // BMI sonucu için beyaz renk
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      interpretation,
                      textAlign: TextAlign.center,
                      style: kBodyTextStyle, // Açıklama metni için beyaz renk
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomButton(
            buttonTitle: 'TEKRAR HESAPLA',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
