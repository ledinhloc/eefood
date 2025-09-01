//ValueNotifier : hold the data
//ValueListenableBuilder : listen to the data ( don't need the setState)
import 'package:flutter/cupertino.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);