import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawpaw_admin/main.dart';

void main() {
  testWidgets('PawPaw Admin smoke test', (WidgetTester tester) async {
    dotenv.loadFromString(
      envString: 'BASE_URL=http://localhost:3001/api/\nAPI_KEY=test_key\n',
    );
    await tester.pumpWidget(const PawPawAdminApp());
    expect(find.text('Masuk ke Console'), findsOneWidget);
  });
}
