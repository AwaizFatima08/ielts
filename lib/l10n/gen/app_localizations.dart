import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'English Language Test Simulator'**
  String get appTitle;

  /// No description provided for @academicShort.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academicShort;

  /// No description provided for @generalShort.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalShort;

  /// No description provided for @answerTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Answer time left {time}'**
  String answerTimeLeft(String time);

  /// No description provided for @attemptKind.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, full{Full test} listening{Listening} reading{Reading} writing{Writing} speaking{Speaking} other{Test}}'**
  String attemptKind(String kind);

  /// No description provided for @audioPending.
  ///
  /// In en, this message translates to:
  /// **'Recording not available yet — a silent gap of the same length is used. Read the transcript afterwards in the review.'**
  String get audioPending;

  /// No description provided for @bestBand.
  ///
  /// In en, this message translates to:
  /// **'Best overall band {band}'**
  String bestBand(String band);

  /// No description provided for @changeModule.
  ///
  /// In en, this message translates to:
  /// **'Switch Academic / General Training'**
  String get changeModule;

  /// No description provided for @checkAnswers.
  ///
  /// In en, this message translates to:
  /// **'Check answers'**
  String get checkAnswers;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @criteria.
  ///
  /// In en, this message translates to:
  /// **'Criteria'**
  String get criteria;

  /// No description provided for @cueCardNotes.
  ///
  /// In en, this message translates to:
  /// **'Your notes (1 minute)'**
  String get cueCardNotes;

  /// No description provided for @cueCardYouShouldSay.
  ///
  /// In en, this message translates to:
  /// **'You should say:'**
  String get cueCardYouShouldSay;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Independent practice app by HomiLabs. Not affiliated with or endorsed by IELTS, the British Council, IDP or Cambridge University Press & Assessment. All questions are original.'**
  String get disclaimer;

  /// No description provided for @drill.
  ///
  /// In en, this message translates to:
  /// **'Drill'**
  String get drill;

  /// No description provided for @drillAudioHint.
  ///
  /// In en, this message translates to:
  /// **'Listen once, then answer. Use the transcript only after checking.'**
  String get drillAudioHint;

  /// No description provided for @drillScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score} / {total}'**
  String drillScore(int score, int total);

  /// No description provided for @essayHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here…'**
  String get essayHint;

  /// No description provided for @essayWords.
  ///
  /// In en, this message translates to:
  /// **'Task 1: {task1} words · Task 2: {task2} words'**
  String essayWords(int task1, int task2);

  /// No description provided for @estimateNote.
  ///
  /// In en, this message translates to:
  /// **'Bands are estimates. Listening and Reading use typical conversion tables; Writing and Speaking come from your own self-check against the criteria.'**
  String get estimateNote;

  /// No description provided for @fullTest.
  ///
  /// In en, this message translates to:
  /// **'Full test'**
  String get fullTest;

  /// No description provided for @fullTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listening (≈30 min) → Reading (60 min) → Writing (60 min) → Speaking (11–14 min). No breaks, as on test day.'**
  String get fullTestSubtitle;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @hideTranscript.
  ///
  /// In en, this message translates to:
  /// **'Hide transcript'**
  String get hideTranscript;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @instructionsToCandidates.
  ///
  /// In en, this message translates to:
  /// **'INSTRUCTIONS TO CANDIDATES'**
  String get instructionsToCandidates;

  /// No description provided for @keepWorking.
  ///
  /// In en, this message translates to:
  /// **'Keep working'**
  String get keepWorking;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers in this section will be lost.'**
  String get leaveBody;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the test?'**
  String get leaveTitle;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get listening;

  /// No description provided for @listeningCheckTime.
  ///
  /// In en, this message translates to:
  /// **'You now have 2 minutes to check your answers.'**
  String get listeningCheckTime;

  /// No description provided for @listeningIntro1.
  ///
  /// In en, this message translates to:
  /// **'There are four parts and 40 questions. Each part is heard ONCE only.'**
  String get listeningIntro1;

  /// No description provided for @listeningIntro2.
  ///
  /// In en, this message translates to:
  /// **'Use the time before each part to read the questions. Type answers as you listen.'**
  String get listeningIntro2;

  /// No description provided for @listeningIntro3.
  ///
  /// In en, this message translates to:
  /// **'The recording cannot be paused. Wear headphones and find a quiet place.'**
  String get listeningIntro3;

  /// No description provided for @listeningIntro4.
  ///
  /// In en, this message translates to:
  /// **'At the end you have 2 minutes to check your answers. Answers are case-insensitive but spelling counts.'**
  String get listeningIntro4;

  /// No description provided for @listeningPart.
  ///
  /// In en, this message translates to:
  /// **'Listening — Part {part}'**
  String listeningPart(int part);

  /// No description provided for @listeningPause.
  ///
  /// In en, this message translates to:
  /// **'Reading time: {note}'**
  String listeningPause(String note);

  /// No description provided for @listeningPlaying.
  ///
  /// In en, this message translates to:
  /// **'Recording playing — Part {part}'**
  String listeningPlaying(int part);

  /// No description provided for @listeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4 parts · 40 questions · about 30 minutes'**
  String get listeningSubtitle;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading this content ({code}).'**
  String loadError(String code);

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was refused, so your answers will not be recorded. Allow it in system settings to record.'**
  String get micDenied;

  /// No description provided for @modelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Model answer (Band {band})'**
  String modelAnswer(int band);

  /// No description provided for @modelAnswers.
  ///
  /// In en, this message translates to:
  /// **'Model answers'**
  String get modelAnswers;

  /// No description provided for @modelBand.
  ///
  /// In en, this message translates to:
  /// **'Band {band} model'**
  String modelBand(int band);

  /// No description provided for @moduleAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get moduleAcademic;

  /// No description provided for @moduleAcademicHint.
  ///
  /// In en, this message translates to:
  /// **'For university study and professional registration.'**
  String get moduleAcademicHint;

  /// No description provided for @moduleGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Training'**
  String get moduleGeneral;

  /// No description provided for @moduleGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'For work, training and migration.'**
  String get moduleGeneralHint;

  /// No description provided for @navigatorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {number}{answered, plural, =0{, not answered} other{, answered}}{flagged, plural, =0{} other{, flagged}}. Long-press to flag.'**
  String navigatorQuestion(int number, int answered, int flagged);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noAttempts.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet. Start a test or a single section from the Tests tab.'**
  String get noAttempts;

  /// No description provided for @noRecordings.
  ///
  /// In en, this message translates to:
  /// **'No recordings were saved for this attempt.'**
  String get noRecordings;

  /// No description provided for @notAttempted.
  ///
  /// In en, this message translates to:
  /// **'Not attempted yet'**
  String get notAttempted;

  /// No description provided for @noText.
  ///
  /// In en, this message translates to:
  /// **'(no text)'**
  String get noText;

  /// No description provided for @notTaken.
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get notTaken;

  /// No description provided for @overallBand.
  ///
  /// In en, this message translates to:
  /// **'Overall band'**
  String get overallBand;

  /// No description provided for @overallPending.
  ///
  /// In en, this message translates to:
  /// **'Rate your Writing and Speaking below to see your overall band.'**
  String get overallPending;

  /// No description provided for @partShort.
  ///
  /// In en, this message translates to:
  /// **'Part {part}'**
  String partShort(int part);

  /// No description provided for @passageShort.
  ///
  /// In en, this message translates to:
  /// **'Passage {number}'**
  String passageShort(int number);

  /// No description provided for @passageTab.
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get passageTab;

  /// No description provided for @pickModuleBody.
  ///
  /// In en, this message translates to:
  /// **'Which IELTS test are you preparing for? You can switch at any time.'**
  String get pickModuleBody;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @prepTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Preparation time left {time}'**
  String prepTimeLeft(String time);

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// No description provided for @questionsRange.
  ///
  /// In en, this message translates to:
  /// **'Questions {from}–{to}'**
  String questionsRange(int from, int to);

  /// No description provided for @questionsTab.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questionsTab;

  /// No description provided for @rateAllCriteria.
  ///
  /// In en, this message translates to:
  /// **'Rate every criterion to save'**
  String get rateAllCriteria;

  /// No description provided for @rateSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Rate my speaking'**
  String get rateSpeaking;

  /// No description provided for @rateWriting.
  ///
  /// In en, this message translates to:
  /// **'Rate my writing'**
  String get rateWriting;

  /// No description provided for @rawScore.
  ///
  /// In en, this message translates to:
  /// **'{score} / 40 correct'**
  String rawScore(int score);

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @readingAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic Reading'**
  String get readingAcademic;

  /// No description provided for @readingGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Training Reading'**
  String get readingGeneral;

  /// No description provided for @readingIntro1.
  ///
  /// In en, this message translates to:
  /// **'There are 40 questions. You have 60 minutes, with no extra time to transfer answers.'**
  String get readingIntro1;

  /// No description provided for @readingIntro2.
  ///
  /// In en, this message translates to:
  /// **'Switch between texts with the bar at the bottom. Long-press a question number to flag it.'**
  String get readingIntro2;

  /// No description provided for @readingIntro3.
  ///
  /// In en, this message translates to:
  /// **'Answers are case-insensitive but spelling counts. Keep to the word limit.'**
  String get readingIntro3;

  /// No description provided for @readingPassageTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading — Text {number}'**
  String readingPassageTitle(int number);

  /// No description provided for @readingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 sections · 40 questions · 60 minutes'**
  String get readingSubtitle;

  /// No description provided for @recordingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording} other{{count} recordings}}'**
  String recordingsCount(int count);

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test report'**
  String get resultsTitle;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAnswers;

  /// No description provided for @reviewBlank.
  ///
  /// In en, this message translates to:
  /// **'no answer'**
  String get reviewBlank;

  /// No description provided for @reviewCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get reviewCorrect;

  /// No description provided for @reviewIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {given} · Correct: {accepted}'**
  String reviewIncorrect(String given, String accepted);

  /// No description provided for @reviewListening.
  ///
  /// In en, this message translates to:
  /// **'Listening — answers'**
  String get reviewListening;

  /// No description provided for @reviewRating.
  ///
  /// In en, this message translates to:
  /// **'Edit rating'**
  String get reviewRating;

  /// No description provided for @reviewReading.
  ///
  /// In en, this message translates to:
  /// **'Reading — answers'**
  String get reviewReading;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get saveError;

  /// No description provided for @saveRating.
  ///
  /// In en, this message translates to:
  /// **'Save rating'**
  String get saveRating;

  /// No description provided for @sectionText.
  ///
  /// In en, this message translates to:
  /// **'S{part} · T{number}'**
  String sectionText(int part, int number);

  /// No description provided for @selfCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'Compare your answer with the model answer, then choose the band whose description fits best for each criterion. Be honest — examiners are strict.'**
  String get selfCheckHelp;

  /// No description provided for @showPassage.
  ///
  /// In en, this message translates to:
  /// **'Show passage'**
  String get showPassage;

  /// No description provided for @singleSection.
  ///
  /// In en, this message translates to:
  /// **'Or practise one section, timed'**
  String get singleSection;

  /// No description provided for @skillOverview.
  ///
  /// In en, this message translates to:
  /// **'About the test'**
  String get skillOverview;

  /// No description provided for @skillVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get skillVocabulary;

  /// No description provided for @speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get speaking;

  /// No description provided for @speakingIntro1.
  ///
  /// In en, this message translates to:
  /// **'The test has three parts, like a face-to-face interview. Each answer is recorded.'**
  String get speakingIntro1;

  /// No description provided for @speakingIntro2.
  ///
  /// In en, this message translates to:
  /// **'Part 1: short questions about familiar topics. Tap Next when you finish an answer.'**
  String get speakingIntro2;

  /// No description provided for @speakingIntro3.
  ///
  /// In en, this message translates to:
  /// **'Part 2: one minute to make notes, then speak for up to two minutes.'**
  String get speakingIntro3;

  /// No description provided for @speakingIntro4.
  ///
  /// In en, this message translates to:
  /// **'Part 3: a discussion of wider ideas. Speak naturally; do not memorise answers.'**
  String get speakingIntro4;

  /// No description provided for @speakingPart.
  ///
  /// In en, this message translates to:
  /// **'Speaking — Part {part}'**
  String speakingPart(int part);

  /// No description provided for @speakingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 parts · 11–14 minutes · recorded'**
  String get speakingSubtitle;

  /// No description provided for @speakingTopic.
  ///
  /// In en, this message translates to:
  /// **'Let\'s talk about {topic}.'**
  String speakingTopic(String topic);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @startSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Start speaking'**
  String get startSpeaking;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Submit this section? You cannot come back to it.} =1{1 question is unanswered. Submit anyway?} other{{count} questions are unanswered. Submit anyway?}}'**
  String submitBody(int count);

  /// No description provided for @submitTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish section?'**
  String get submitTitle;

  /// No description provided for @tabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tabPractice;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tabTests;

  /// No description provided for @taskWordCount.
  ///
  /// In en, this message translates to:
  /// **'Task {task} · {words} words'**
  String taskWordCount(int task, int words);

  /// No description provided for @testsIntro.
  ///
  /// In en, this message translates to:
  /// **'Each test runs exactly like the real exam: timed sections, audio heard once, and a band score at the end.'**
  String get testsIntro;

  /// No description provided for @testTitle.
  ///
  /// In en, this message translates to:
  /// **'Test {number}'**
  String testTitle(int number);

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes left'**
  String timeLeft(int minutes);

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @underLength.
  ///
  /// In en, this message translates to:
  /// **'Under {words} words — this lowers your Task Achievement / Response band.'**
  String underLength(int words);

  /// No description provided for @unfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished — tap to continue'**
  String get unfinished;

  /// No description provided for @unitCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String unitCount(int count);

  /// No description provided for @usefulLanguage.
  ///
  /// In en, this message translates to:
  /// **'Useful language'**
  String get usefulLanguage;

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String wordCount(int count);

  /// No description provided for @wordLimit.
  ///
  /// In en, this message translates to:
  /// **'Write {limit} for each answer.'**
  String wordLimit(String limit);

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writing;

  /// No description provided for @writingAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic Writing'**
  String get writingAcademic;

  /// No description provided for @writingGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Training Writing'**
  String get writingGeneral;

  /// No description provided for @writingIntro1.
  ///
  /// In en, this message translates to:
  /// **'There are two tasks. Task 2 counts twice as much as Task 1.'**
  String get writingIntro1;

  /// No description provided for @writingIntro2.
  ///
  /// In en, this message translates to:
  /// **'Spend about 20 minutes on Task 1 and 40 minutes on Task 2. The timer covers both.'**
  String get writingIntro2;

  /// No description provided for @writingIntro3.
  ///
  /// In en, this message translates to:
  /// **'Spell-check and autocorrect are off, as in the computer-delivered test.'**
  String get writingIntro3;

  /// No description provided for @writingMinWords.
  ///
  /// In en, this message translates to:
  /// **'Write at least {words} words.'**
  String writingMinWords(int words);

  /// No description provided for @writingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'2 tasks · 60 minutes'**
  String get writingSubtitle;

  /// No description provided for @writingTask.
  ///
  /// In en, this message translates to:
  /// **'Task {task}'**
  String writingTask(int task);

  /// No description provided for @writingTimeAdvice.
  ///
  /// In en, this message translates to:
  /// **'You should spend about {minutes} minutes on this task.'**
  String writingTimeAdvice(int minutes);

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @yourRecordings.
  ///
  /// In en, this message translates to:
  /// **'Your recordings'**
  String get yourRecordings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
