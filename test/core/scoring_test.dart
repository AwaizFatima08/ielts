import 'package:flutter_test/flutter_test.dart';
import 'package:ielts_simulator/core/scoring.dart';

void main() {
  group('answers', () {
    test('ignore case, outer punctuation and extra spaces', () {
      expect(isAnswerCorrect('  Okafor. ', ['okafor']), isTrue);
      expect(isAnswerCorrect('city   centre', ['City Centre']), isTrue);
      expect(isAnswerCorrect('', ['x']), isFalse);
      expect(isAnswerCorrect('centre', ['city centre']), isFalse);
    });

    test('word count', () {
      expect(countWords(''), 0);
      expect(countWords('  one two\nthree  '), 3);
      expect(countWords('well-known fact'), 2);
    });
  });

  group('bands', () {
    test('listening table edges', () {
      expect(listeningBand(40), 9);
      expect(listeningBand(30), 7);
      expect(listeningBand(29), 6.5);
      expect(listeningBand(0), 0);
    });

    test('reading uses the module table', () {
      expect(readingBand(30, ReadingModule.academic), 7);
      expect(readingBand(30, ReadingModule.general), 6);
      expect(readingBand(34, ReadingModule.general), 7);
    });

    test('overall rounds .25 up to .5 and .75 up to the next band', () {
      expect(overallBand([6.5, 6.5, 5, 7]), 6.5); // 6.25
      expect(overallBand([7, 7, 6.5, 6.5]), 7); // 6.75
      expect(overallBand([6, 6, 6, 6.5]), 6); // 6.125
      expect(overallBand([6, 6, null, 6]), isNull);
    });

    test('writing weights Task 2 double', () {
      expect(writingBand([6, 6, 6, 6], [7, 7, 7, 7]), 6.5); // 6.67 → 6.5
      expect(writingBand([], [7]), isNull);
    });

    test('speaking averages criteria and rounds down', () {
      expect(speakingBand([7, 7, 6, 6]), 6.5);
      expect(speakingBand([7, 6, 6, 6]), 6); // 6.25
    });
  });
}
