import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppMenuBar extends StatelessWidget {
  const new({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MenuBar(
                children: [
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.folder_open),
                        onPressed: () => debugPrint("ABRIR"),
                        child: const Text('Abrir ...'),
                      ),
                      const Divider(height: 1),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.exit_to_app),
                        onPressed: () => ServicesBinding.instance
                            .exitApplication(AppExitType.cancelable),
                        child: const Text('Sair'),
                      ),
                    ],
                    child: const Text("Arquivo"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
