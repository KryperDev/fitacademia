import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/firebase_options.dart';

const gymId = '4Q6viMiOBtW4L5LfZWmTrKZKwcs2'; // ID da sua academia

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Seed de exercícios padrão', () async {
    print('Iniciando seed de exercícios...');
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;
    final collection = firestore
        .collection('gyms')
        .doc(gymId)
        .collection('exercises');

    final exercises = [
      // PEITO
      {'name': 'Supino Reto com Barra', 'muscleGroups': ['Peito', 'Tríceps'], 'equipment': 'Barra'},
      {'name': 'Supino Inclinado com Halteres', 'muscleGroups': ['Peito', 'Ombro'], 'equipment': 'Halteres'},
      {'name': 'Crucifixo na Máquina', 'muscleGroups': ['Peito'], 'equipment': 'Máquina'},
      {'name': 'Flexão de Braço', 'muscleGroups': ['Peito', 'Tríceps'], 'equipment': 'Peso Corporal'},
      
      // COSTAS
      {'name': 'Puxada Frontal', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Polia'},
      {'name': 'Remada Baixa', 'muscleGroups': ['Costas'], 'equipment': 'Polia'},
      {'name': 'Remada Curvada', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Barra'},
      {'name': 'Barra Fixa', 'muscleGroups': ['Costas', 'Bíceps'], 'equipment': 'Peso Corporal'},
      {'name': 'Levantamento Terra', 'muscleGroups': ['Costas', 'Pernas'], 'equipment': 'Barra'},

      // PERNAS
      {'name': 'Agachamento Livre', 'muscleGroups': ['Quadríceps', 'Glúteos'], 'equipment': 'Barra'},
      {'name': 'Leg Press 45°', 'muscleGroups': ['Quadríceps', 'Glúteos'], 'equipment': 'Máquina'},
      {'name': 'Cadeira Extensora', 'muscleGroups': ['Quadríceps'], 'equipment': 'Máquina'},
      {'name': 'Cadeira Flexora', 'muscleGroups': ['Posterior de Coxa'], 'equipment': 'Máquina'},
      {'name': 'Stiff', 'muscleGroups': ['Posterior de Coxa', 'Glúteos'], 'equipment': 'Barra'},
      {'name': 'Panturrilha em Pé', 'muscleGroups': ['Panturrilha'], 'equipment': 'Máquina'},

      // OMBROS
      {'name': 'Desenvolvimento Militar', 'muscleGroups': ['Ombro', 'Tríceps'], 'equipment': 'Barra'},
      {'name': 'Elevação Lateral', 'muscleGroups': ['Ombro'], 'equipment': 'Halteres'},
      {'name': 'Elevação Frontal', 'muscleGroups': ['Ombro'], 'equipment': 'Halteres'},
      {'name': 'Remada Alta', 'muscleGroups': ['Ombro', 'Trapézio'], 'equipment': 'Barra'},

      // BÍCEPS
      {'name': 'Rosca Direta', 'muscleGroups': ['Bíceps'], 'equipment': 'Barra'},
      {'name': 'Rosca Alternada', 'muscleGroups': ['Bíceps'], 'equipment': 'Halteres'},
      {'name': 'Rosca Martelo', 'muscleGroups': ['Bíceps', 'Antebraço'], 'equipment': 'Halteres'},

      // TRÍCEPS
      {'name': 'Tríceps Testa', 'muscleGroups': ['Tríceps'], 'equipment': 'Barra'},
      {'name': 'Tríceps Corda', 'muscleGroups': ['Tríceps'], 'equipment': 'Polia'},
      {'name': 'Mergulho em Paralelas', 'muscleGroups': ['Tríceps', 'Peito'], 'equipment': 'Peso Corporal'},

      // ABDÔMEN
      {'name': 'Abdominal Crunch', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},
      {'name': 'Prancha Isométrica', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},
      {'name': 'Elevação de Pernas', 'muscleGroups': ['Abdômen'], 'equipment': 'Peso Corporal'},

      // CARDIO
      {'name': 'Esteira', 'muscleGroups': ['Cardio'], 'equipment': 'Máquina'},
      {'name': 'Bicicleta Ergométrica', 'muscleGroups': ['Cardio'], 'equipment': 'Máquina'},
    ];

    int count = 0;
    for (final ex in exercises) {
      await collection.add({
        'name': ex['name'],
        'muscleGroups': ex['muscleGroups'],
        'equipment': ex['equipment'],
        'description': 'Exercício padrão de academia.',
        'instructions': 'Execute com boa postura.',
        'mediaProvider': null,
        'mediaUrl': null,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      count++;
      print('  + ${ex['name']}');
    }

    print('\nConcluído! $count exercícios inseridos.');
  });
}
