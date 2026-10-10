import 'dart:math';
import 'app_constants.dart';

class RaceTextItem {
  final String text;
  final TextCategory category;
  final TextDifficulty difficulty;
  final String authorOrSource;

  const RaceTextItem({
    required this.text,
    required this.category,
    required this.difficulty,
    this.authorOrSource = 'General',
  });
}

class SampleTexts {
  static const List<RaceTextItem> allTexts = [
    // --- FUN FACTS ---
    RaceTextItem(
      text: "Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over three thousand years old and still perfectly edible.",
      category: TextCategory.funFacts,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Food Science",
    ),
    RaceTextItem(
      text: "Octopuses have three hearts and blue blood. Two hearts pump blood to the gills, while the third circulates blood to the rest of the body.",
      category: TextCategory.funFacts,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Marine Biology",
    ),
    RaceTextItem(
      text: "Bananas are curved because they grow towards the sun against gravity, a strange phenomenon known scientifically as negative geotropism.",
      category: TextCategory.funFacts,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Botanical Trivia",
    ),
    RaceTextItem(
      text: "A day on Venus is longer than a year on Venus. It takes Venus 243 Earth days to rotate once on its axis, but only 225 Earth days to orbit the Sun completely.",
      category: TextCategory.funFacts,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Astronomy",
    ),
    RaceTextItem(
      text: "Wombat poop is cubic! This unique shape prevents the scat from rolling away and marks their territory effectively.",
      category: TextCategory.funFacts,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Wildlife Facts",
    ),

    // --- TECH & CODING ---
    RaceTextItem(
      text: "Talk is cheap. Show me the code. Clean architecture and efficient algorithms turn ideas into digital reality.",
      category: TextCategory.techCoding,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Linus Torvalds",
    ),
    RaceTextItem(
      text: "Programs must be written for people to read, and only incidentally for machines to execute. Simplicity is the soul of efficiency.",
      category: TextCategory.techCoding,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Harold Abelson",
    ),
    RaceTextItem(
      text: "In computer science, recursion occurs when a function calls itself directly or indirectly to solve smaller instances of the same problem with a well-defined base condition.",
      category: TextCategory.techCoding,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Algorithms",
    ),
    RaceTextItem(
      text: "Any fool can write code that a computer can understand. Good programmers write code that humans can understand.",
      category: TextCategory.techCoding,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Martin Fowler",
    ),
    RaceTextItem(
      text: "Flutter transforms the development process. Build, test, and deploy beautiful mobile, web, and desktop apps from a single codebase at maximum turbo speed!",
      category: TextCategory.techCoding,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Modern Dev",
    ),

    // --- MOVIES & POP ---
    RaceTextItem(
      text: "May the Force be with you, always. Do or do not, there is no try when navigating the cosmic galaxy.",
      category: TextCategory.moviesPop,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Star Wars",
    ),
    RaceTextItem(
      text: "Great Scott! If my calculations are correct, when this baby hits eighty-eight miles per hour, you are going to see some serious racing action!",
      category: TextCategory.moviesPop,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Back to the Future",
    ),
    RaceTextItem(
      text: "It is not our abilities that show what we truly are; it is our choices. Happiness can be found even in the darkest of times if one only remembers to turn on the light.",
      category: TextCategory.moviesPop,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Harry Potter",
    ),
    RaceTextItem(
      text: "I live my life a quarter mile at a time. Nothing else matters. For those ten seconds or less, I am free.",
      category: TextCategory.moviesPop,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Fast & Furious",
    ),

    // --- SPEED QUOTES ---
    RaceTextItem(
      text: "If everything seems under control, you're not going fast enough. Push the accelerator and claim victory!",
      category: TextCategory.speedQuotes,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Mario Andretti",
    ),
    RaceTextItem(
      text: "Speed has never killed anyone. Suddenly becoming stationary, that's what gets you. Keep your fingers blazing across the keyboard!",
      category: TextCategory.speedQuotes,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Jeremy Clarkson",
    ),
    RaceTextItem(
      text: "To achieve anything in racing, you must be prepared to dabble on the boundary of disaster. Focus your mind, sharpen your reflexes, and never lift off.",
      category: TextCategory.speedQuotes,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Stirling Moss",
    ),
    RaceTextItem(
      text: "Straight roads are for fast cars, turns are for fast drivers. Precision typing conquers the sharpest corners of the track.",
      category: TextCategory.speedQuotes,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Colin McRae",
    ),

    // --- SCIENCE & NATURE ---
    RaceTextItem(
      text: "Somewhere, something incredible is waiting to be known. The cosmos is within us. We are made of star-stuff.",
      category: TextCategory.scienceNature,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Carl Sagan",
    ),
    RaceTextItem(
      text: "Light travels through vacuum at approximately three hundred thousand kilometers per second, making it the universal cosmic speed limit of the universe.",
      category: TextCategory.scienceNature,
      difficulty: TextDifficulty.medium,
      authorOrSource: "Astrophysics",
    ),
    RaceTextItem(
      text: "Quantum entanglement demonstrates that pairs or groups of particles interact in ways such that the quantum state of each particle cannot be described independently of the others.",
      category: TextCategory.scienceNature,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Quantum Physics",
    ),

    // --- GENERAL KNOWLEDGE ---
    RaceTextItem(
      text: "The quick brown fox jumps over the lazy dog. A classic pangram containing every single letter of the English alphabet.",
      category: TextCategory.generalKnowledge,
      difficulty: TextDifficulty.easy,
      authorOrSource: "Typing Standard",
    ),
    RaceTextItem(
      text: "The Great Wall of China is the longest man-made structure in the world, stretching thousands of miles across rugged mountain ridges.",
      category: TextCategory.generalKnowledge,
      difficulty: TextDifficulty.medium,
      authorOrSource: "World History",
    ),
    RaceTextItem(
      text: "Mount Everest rises approximately 8,848 meters above sea level in the Himalayas, continuing to grow a few millimeters each year due to tectonic plate movement.",
      category: TextCategory.generalKnowledge,
      difficulty: TextDifficulty.hard,
      authorOrSource: "Geography",
    ),
  ];

  static RaceTextItem getRandomText({
    TextCategory? category,
    TextDifficulty? difficulty,
  }) {
    List<RaceTextItem> filtered = allTexts;
    if (category != null) {
      filtered = filtered.where((t) => t.category == category).toList();
    }
    if (difficulty != null) {
      final diffFiltered = filtered.where((t) => t.difficulty == difficulty).toList();
      if (diffFiltered.isNotEmpty) {
        filtered = diffFiltered;
      }
    }
    if (filtered.isEmpty) {
      filtered = allTexts;
    }
    return filtered[Random().nextInt(filtered.length)];
  }
}
