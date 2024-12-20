import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mbileprogrammingproject/main.dart';
import 'package:mbileprogrammingproject/signup.dart';
import 'package:mbileprogrammingproject/login.dart';

void main()
{
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Sign Up and Login Flow with Password Length Validation', (WidgetTester tester) async {



    await tester.pumpWidget(MaterialApp(home: SignUpPage()));


    await tester.enterText(find.byType(TextField).at(0), 'John Doe');  // Name
    await tester.enterText(find.byType(TextField).at(1), 'john.doe@example.com'); // Email
    await tester.enterText(find.byType(TextField).at(2), '12345'); // Password (less than 6 characters)
    await tester.enterText(find.byType(TextField).at(3), '12345'); // Confirm Password


    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();


    expect(find.text('Password must be at least 6 characters'), findsOneWidget);


    await tester.enterText(find.byType(TextField).at(2), 'Password123');  // Valid password
    await tester.enterText(find.byType(TextField).at(3), 'Password123');  // Confirm password


    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();


    expect(find.byType(LoginPage), findsOneWidget);


    await tester.pumpWidget(MaterialApp(home: LoginPage()));


    await tester.enterText(find.byType(TextField).at(0), 'john.doe@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'Password123');


    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();


    expect(find.byType(MainView), findsOneWidget);
  });
}
