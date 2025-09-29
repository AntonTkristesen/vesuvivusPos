import 'package:flutter/material.dart';

class HomeConstants {
    static const double defaultPadding = 16.0;
    static const double spacingSmall = 8.0;
    static const double spacingMedium = 12.0;
    static const double spacingLarge = 24.0;
    static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

    static const String appTitle = 'Vesuvivus — Bord';
    static const String logoutTooltip = 'Log ud';
    static const String tableNumberLabel = 'Bordnummer';
    static const String openContinueLabel = 'Åbn / Fortsæt';
    static const String invalidTableMessage = 'Indtast et gyldigt bordnummer';
    static const String helpText =
        'Indtast et bordnummer and press "Åbn / Fortsæt". '
        'På næste skærm kan du tilføje menupunkter og markere ordren som betalt.';
    static const String orderIdLabel = 'Ordre ID: ';
    static const String statusLabel = ' - Status: ';
    static const String tableLabel = 'Bord ';
    static const String errorOpeningOrder = 'Fejl: ';
}
