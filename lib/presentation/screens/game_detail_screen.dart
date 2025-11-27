import 'package:flutter/material.dart';

class GameDetailScreen extends StatelessWidget {
  final int gameId;
  
  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Juego')),
      body: Center(child: Text('Detalle del juego ID: $gameId')),
    );
  }
}