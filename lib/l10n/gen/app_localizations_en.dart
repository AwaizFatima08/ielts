// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IELTS Simulator';

  @override
  String get academicShort => 'Academic';

  @override
  String get generalShort => 'General';

  @override
  String answerTimeLeft(String time) {
    return 'Answer time left $time';
  }

  @override
  String attemptKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(
      kind,
      {
        'full': 'Full test',
        'listening': 'Listening',
        'reading': 'Reading',
        'writing': 'Writing',
        'speaking': 'Speaking',
        'other': 'Test',
      },
    );
    return '$_temp0';
  }

  @override
  String get audioPending =>
      'Recording not available yet — a silent gap of the same length is used. Read the transcript afterwards in the review.';

  @override
  String bestBand(String band) {
    return 'Best overall band $band';
  }

  @override
  String get changeModule => 'Switch Academic / General Training';

  @override
  String get checkAnswers => 'Check answers';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get criteria => 'Criteria';

  @override
  String get cueCardNotes => 'Your notes (1 minute)';

  @override
  String get cueCardYouShouldSay => 'You should say:';

  @override
  String get disclaimer =>
      'Independent practice app by HomiLabs. Not affiliated with or endorsed by IELTS, the British Council, IDP or Cambridge University Press & Assessment. All questions are original.';

  @override
  String get drill => 'Drill';

  @override
  String get drillAudioHint => 'Listen once, then answer. Use the transcript only after checking.';

  @override
  String drillScore(int score, int total) {
    return 'Score: $score / $total';
  }

  @override
  String get essayHint => 'Type your answer here…';

  @override
  String essayWords(int task1, int task2) {
    return 'Task 1: $task1 words · Task 2: $task2 words';
  }

  @override
  String get estimateNote =>
      'Bands are estimates. Listening and Reading use typical conversion tables; Writing and Speaking come from your own self-check against the criteria.';

  @override
  String get fullTest => 'Full test';

  @override
  String get fullTestSubtitle =>
      'Listening (≈30 min) → Reading (60 min) → Writing (60 min) → Speaking (11–14 min). No breaks, as on test day.';

  @override
  String get guide => 'Guide';

  @override
  String get hideTranscript => 'Hide transcript';

  @override
  String get home => 'Home';

  @override
  String get instructionsToCandidates => 'INSTRUCTIONS TO CANDIDATES';

  @override
  String get keepWorking => 'Keep working';

  @override
  String get leave => 'Leave';

  @override
  String get leaveBody => 'Your answers in this section will be lost.';

  @override
  String get leaveTitle => 'Leave the test?';

  @override
  String get listening => 'Listening';

  @override
  String get listeningCheckTime => 'You now have 2 minutes to check your answers.';

  @override
  String get listeningIntro1 =>
      'There are four parts and 40 questions. Each part is heard ONCE only.';

  @override
  String get listeningIntro2 =>
      'Use the time before each part to read the questions. Type answers as you listen.';

  @override
  String get listeningIntro3 =>
      'The recording cannot be paused. Wear headphones and find a quiet place.';

  @override
  String get listeningIntro4 =>
      'At the end you have 2 minutes to check your answers. Answers are case-insensitive but spelling counts.';

  @override
  String listeningPart(int part) {
    return 'Listening — Part $part';
  }

  @override
  String listeningPause(String note) {
    return 'Reading time: $note';
  }

  @override
  String listeningPlaying(int part) {
    return 'Recording playing — Part $part';
  }

  @override
  String get listeningSubtitle => '4 parts · 40 questions · about 30 minutes';

  @override
  String loadError(String code) {
    return 'Something went wrong loading this content ($code).';
  }

  @override
  String get micDenied =>
      'Microphone access was refused, so your answers will not be recorded. Allow it in system settings to record.';

  @override
  String modelAnswer(int band) {
    return 'Model answer (Band $band)';
  }

  @override
  String get modelAnswers => 'Model answers';

  @override
  String modelBand(int band) {
    return 'Band $band model';
  }

  @override
  String get moduleAcademic => 'Academic';

  @override
  String get moduleAcademicHint => 'For university study and professional registration.';

  @override
  String get moduleGeneral => 'General Training';

  @override
  String get moduleGeneralHint => 'For work, training and migration.';

  @override
  String navigatorQuestion(int number, int answered, int flagged) {
    String _temp0 = intl.Intl.pluralLogic(
      answered,
      locale: localeName,
      other: ', answered',
      zero: ', not answered',
    );
    String _temp1 = intl.Intl.pluralLogic(
      flagged,
      locale: localeName,
      other: ', flagged',
      zero: '',
    );
    return 'Question $number$_temp0$_temp1. Long-press to flag.';
  }

  @override
  String get next => 'Next';

  @override
  String get noAttempts => 'No attempts yet. Start a test or a single section from the Tests tab.';

  @override
  String get noRecordings => 'No recordings were saved for this attempt.';

  @override
  String get notAttempted => 'Not attempted yet';

  @override
  String get noText => '(no text)';

  @override
  String get notTaken => 'Not taken';

  @override
  String get overallBand => 'Overall band';

  @override
  String get overallPending => 'Rate your Writing and Speaking below to see your overall band.';

  @override
  String partShort(int part) {
    return 'Part $part';
  }

  @override
  String passageShort(int number) {
    return 'Passage $number';
  }

  @override
  String get passageTab => 'Passage';

  @override
  String get pickModuleBody =>
      'Which IELTS test are you preparing for? You can switch at any time.';

  @override
  String get play => 'Play';

  @override
  String prepTimeLeft(String time) {
    return 'Preparation time left $time';
  }

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String questionsRange(int from, int to) {
    return 'Questions $from–$to';
  }

  @override
  String get questionsTab => 'Questions';

  @override
  String get rateAllCriteria => 'Rate every criterion to save';

  @override
  String get rateSpeaking => 'Rate my speaking';

  @override
  String get rateWriting => 'Rate my writing';

  @override
  String rawScore(int score) {
    return '$score / 40 correct';
  }

  @override
  String get reading => 'Reading';

  @override
  String get readingAcademic => 'Academic Reading';

  @override
  String get readingGeneral => 'General Training Reading';

  @override
  String get readingIntro1 =>
      'There are 40 questions. You have 60 minutes, with no extra time to transfer answers.';

  @override
  String get readingIntro2 =>
      'Switch between texts with the bar at the bottom. Long-press a question number to flag it.';

  @override
  String get readingIntro3 =>
      'Answers are case-insensitive but spelling counts. Keep to the word limit.';

  @override
  String readingPassageTitle(int number) {
    return 'Reading — Text $number';
  }

  @override
  String get readingSubtitle => '3 sections · 40 questions · 60 minutes';

  @override
  String recordingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    return '$_temp0';
  }

  @override
  String get resultsTitle => 'Test report';

  @override
  String get reviewAnswers => 'Review';

  @override
  String get reviewBlank => 'no answer';

  @override
  String get reviewCorrect => 'Correct';

  @override
  String reviewIncorrect(String given, String accepted) {
    return 'Your answer: $given · Correct: $accepted';
  }

  @override
  String get reviewListening => 'Listening — answers';

  @override
  String get reviewRating => 'Edit rating';

  @override
  String get reviewReading => 'Reading — answers';

  @override
  String get saveError => 'Could not save. Please try again.';

  @override
  String get saveRating => 'Save rating';

  @override
  String sectionText(int part, int number) {
    return 'S$part · T$number';
  }

  @override
  String get selfCheckHelp =>
      'Compare your answer with the model answer, then choose the band whose description fits best for each criterion. Be honest — examiners are strict.';

  @override
  String get showPassage => 'Show passage';

  @override
  String get singleSection => 'Or practise one section, timed';

  @override
  String get skillOverview => 'About the test';

  @override
  String get skillVocabulary => 'Vocabulary';

  @override
  String get speaking => 'Speaking';

  @override
  String get speakingIntro1 =>
      'The test has three parts, like a face-to-face interview. Each answer is recorded.';

  @override
  String get speakingIntro2 =>
      'Part 1: short questions about familiar topics. Tap Next when you finish an answer.';

  @override
  String get speakingIntro3 =>
      'Part 2: one minute to make notes, then speak for up to two minutes.';

  @override
  String get speakingIntro4 =>
      'Part 3: a discussion of wider ideas. Speak naturally; do not memorise answers.';

  @override
  String speakingPart(int part) {
    return 'Speaking — Part $part';
  }

  @override
  String get speakingSubtitle => '3 parts · 11–14 minutes · recorded';

  @override
  String speakingTopic(String topic) {
    return 'Let\'s talk about $topic.';
  }

  @override
  String get start => 'Start';

  @override
  String get startSpeaking => 'Start speaking';

  @override
  String get stay => 'Stay';

  @override
  String get stop => 'Stop';

  @override
  String get submit => 'Submit';

  @override
  String submitBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions are unanswered. Submit anyway?',
      one: '1 question is unanswered. Submit anyway?',
      zero: 'Submit this section? You cannot come back to it.',
    );
    return '$_temp0';
  }

  @override
  String get submitTitle => 'Finish section?';

  @override
  String get tabPractice => 'Practice';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabTests => 'Tests';

  @override
  String taskWordCount(int task, int words) {
    return 'Task $task · $words words';
  }

  @override
  String get testsIntro =>
      'Each test runs exactly like the real exam: timed sections, audio heard once, and a band score at the end.';

  @override
  String testTitle(int number) {
    return 'Test $number';
  }

  @override
  String timeLeft(int minutes) {
    return '$minutes minutes left';
  }

  @override
  String get transcript => 'Transcript';

  @override
  String get tryAgain => 'Try again';

  @override
  String underLength(int words) {
    return 'Under $words words — this lowers your Task Achievement / Response band.';
  }

  @override
  String get unfinished => 'Unfinished — tap to continue';

  @override
  String unitCount(int count) {
    return '$count units';
  }

  @override
  String get usefulLanguage => 'Useful language';

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String wordLimit(String limit) {
    return 'Write $limit for each answer.';
  }

  @override
  String get writing => 'Writing';

  @override
  String get writingAcademic => 'Academic Writing';

  @override
  String get writingGeneral => 'General Training Writing';

  @override
  String get writingIntro1 => 'There are two tasks. Task 2 counts twice as much as Task 1.';

  @override
  String get writingIntro2 =>
      'Spend about 20 minutes on Task 1 and 40 minutes on Task 2. The timer covers both.';

  @override
  String get writingIntro3 =>
      'Spell-check and autocorrect are off, as in the computer-delivered test.';

  @override
  String writingMinWords(int words) {
    return 'Write at least $words words.';
  }

  @override
  String get writingSubtitle => '2 tasks · 60 minutes';

  @override
  String writingTask(int task) {
    return 'Task $task';
  }

  @override
  String writingTimeAdvice(int minutes) {
    return 'You should spend about $minutes minutes on this task.';
  }

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get yourRecordings => 'Your recordings';
}
