import 'package:flutter/material.dart';

class AppMenuButton extends StatelessWidget {
  final VoidCallback onWallpaperTap;
  final VoidCallback onThemeTap;

  const AppMenuButton({
    super.key,
    required this.onWallpaperTap,
    required this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      color: Theme.of(context).cardColor,
      onSelected: (value) {
        if (value == 'wallpaper') {
          onWallpaperTap();
        } else if (value == 'theme') {
          onThemeTap();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'wallpaper',
          child: ListTile(
            leading: Icon(Icons.wallpaper, color: iconColor),
            title: Text('Change Wallpaper', style: TextStyle(color: iconColor)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem<String>(
          value: 'theme',
          child: ListTile(
            leading: Icon(Icons.palette, color: iconColor),
            title: Text('Change Theme', style: TextStyle(color: iconColor)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
