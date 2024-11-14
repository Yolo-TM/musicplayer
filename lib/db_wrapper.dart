import 'db/cookies.dart';
import 'db/database.dart';

Stream<String> Initialize() async* {
  yield 'Initializing database...';
  await Saver().initialize();
  yield 'Database initialized';
  yield 'Initializing cookies...';
  await Cookies().initialize();
  yield 'Cookies initialized';
}
