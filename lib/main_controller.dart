import 'package:flutter/foundation.dart';

typedef Test = ({String A, String Q, String T});

class MainController extends ValueNotifier {
  //the variables
  int amountOfTests = 10;
  late int poseThisManyQuestions;
  bool preferTestsOverAmountOfQuestions = true;
  bool shuffle = false;
  bool reverse = false;
  bool flipTheOrder = false;
  bool keepTillRightOnFirstTry = true;
  bool shrink = true;
  int multipleChoice = 2;
  late List<Test> tests;
  late List<Test> originalTests;
  late int _maxPicks;
  int get maxPicks => preferTestsOverAmountOfQuestions == true
      ? originalTests.length
      : poseThisManyQuestions;
  MainController(super._value) {
    loadPrefs();
  }
  loadPrefs() {
    poseThisManyQuestions = amountOfTests * 2;
    //here we load the tests from the database
    tests = List<Test>.generate(
        amountOfTests,
        (index) =>
            (A: "A${index + 1}", Q: "Q${index + 1}", T: "T${index + 1}"));
    originalTests = tests.toList();

    _maxPicks = preferTestsOverAmountOfQuestions == true
        ? originalTests.length
        : poseThisManyQuestions;
  }

  List<Test> pickTheAlternatives(List<Test> originalTests, Test pickedTest) {
    var alternatives =
        (originalTests.where((test) => test != pickedTest).toList()..shuffle())
            .take(multipleChoice > 1 ? multipleChoice : 0)
            .toList();

    return alternatives;
  }

  //int next = 0;
  //Test? previousTest;
  (Test, int) pickTheTest(List<Test> tests, int next, Test? previousTest) {
    tests.isEmpty ? tests = originalTests : null;

    Test pickedTest; //= (A: "", Q: '', T: "");
    reverse == true ? tests.reversed : tests;
//     print(previousTest);
    do {
      shuffle == true ? tests.shuffle() : tests;
      shrink == true ? pickedTest = tests[0] : pickedTest = tests[next];
//       print( pickedTest);
    } while (previousTest == pickedTest && tests.length > 1);
    shrink == true ? tests.remove(pickedTest) : tests;
    next++;
    next == tests.length ? next = 0 : null;
    tests.isEmpty ? tests = originalTests : null;
    previousTest = pickedTest;
    return (pickedTest, next);
  }

//for every case there should be a flutter widget that shows the question and the answer and the alternatives and the widget should be clickable to get the good answer
  askTheTest(Test t, List<Test> a) {
    switch (multipleChoice) {
      case 0:
        if (kDebugMode) {
          print("this is the question ${flipTheOrder == true ? t.A : t.Q}");
        }
        if (kDebugMode) {
          print("and this is the answer ${flipTheOrder == true ? t.Q : t.A}");
        }
      case 1:
        if (kDebugMode) {
          print("this is the question ${flipTheOrder == true ? t.A : t.Q}");
        }
        if (kDebugMode) {
          print("and tap to check the answer in your head");
        }
        if (kDebugMode) {
          print("${flipTheOrder == true ? t.Q : t.A}\t");
        }
      default:
        if (kDebugMode) {
          print("this is the question ${flipTheOrder == true ? t.A : t.Q}");
        }
        if (kDebugMode) {
          print("and these are your MultipleChoices...");
        }

        a.shuffle();
        String altString = "";
        for (var alt in a) {
          altString += "${flipTheOrder == true ? alt.Q : alt.A}\t";
        }
        if (kDebugMode) {
          print(
              altString); // this string holds the possible answers so split this up in clickable listtitles
        }
    }
  }

  doTheAnswer(Test t, List<Test> a) {
    Test iPick; //this is the answer make it available
    int tries = 0;
    do {
      //here you pick the answer
      iPick = (a..shuffle()).first;
      if (kDebugMode) {
        print("I pick ${flipTheOrder == true ? iPick.Q : iPick.A}");
      }
      a.remove(iPick);
      tries++;
    } while (iPick != t);
    return tries;
  }

  void mainLoop() {
    if (keepTillRightOnFirstTry == false) {
      if (kDebugMode) {
        print("keeprightOnFirstTryIsFlase");
      }
      int next = 0;
      Test? previousTest;
      Test t;
      for (var i = 0; i < maxPicks; i++) {
        (t, next) = pickTheTest(tests, next, previousTest);
        List<Test> a = pickTheAlternatives(originalTests, t);
        a.add(t);

        askTheTest(t, a);
        doTheAnswer(t, a);
      }
    } else {
      if (kDebugMode) {
        print("going for first right");
      }
      while (tests.isNotEmpty) {
        int next = 0;
        Test? previousTest;
        Test t;
        (t, next) = pickTheTest(tests, next, previousTest);
        List<Test> a = pickTheAlternatives(originalTests, t);
        a.add(t);

        askTheTest(t, a);

        int tries = doTheAnswer(t, a);

        tries > 1 ? tests.add(t) : null;
        if (kDebugMode) {
          print("testslength:${tests.length}");
        }
      }
    }
  }
}
