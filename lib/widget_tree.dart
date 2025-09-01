// import 'package:eefood/pages/home_page.dart';
// import 'package:eefood/pages/my_recipe_page.dart';
// import 'package:eefood/pages/profile_page.dart';
// import 'package:eefood/pages/search_page.dart';
// import 'package:eefood/pages/shopping_list_page.dart';
// import 'package:flutter/material.dart';
//
// import '../data/notifiers.dart';
//
// List<Widget> pages = [HomePage(), SearchPage(), MyRecipe(), ShoppingListPage(), ProfilePage()];
//
// class WidgetTree extends StatelessWidget {
//   const WidgetTree({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               isDarkModeNotifier.value = !isDarkModeNotifier.value;
//             },
//             icon: ValueListenableBuilder(
//               valueListenable: isDarkModeNotifier,
//               builder: (context, value, child) {
//                 return Icon( value
//                     ? Icons.light_mode
//                     : Icons.dark_mode
//                 );
//               },),
//           ),
//
//         ],
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: selectedPageNotifier,
//         builder: (context, value, child) {
//           return pages.elementAt(value);
//         },
//       ),
//       bottomNavigationBar: NavbarWidget(),
//     );
//   }
// }
//
