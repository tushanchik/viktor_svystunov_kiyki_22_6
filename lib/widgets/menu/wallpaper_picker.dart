import 'package:flutter/material.dart';

class WallpaperPicker extends StatelessWidget {
  final List<String> wallpaperAssets;
  final List<Color> solidColors;
  final String? currentImage;
  final Color? currentColor;
  final void Function(String?) onImageSelected;
  final void Function(Color?) onColorSelected;

  const WallpaperPicker({
    super.key,
    required this.wallpaperAssets,
    required this.solidColors,
    required this.currentImage,
    required this.currentColor,
    required this.onImageSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Background',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text('Images', style: TextStyle(color: textColor.withOpacity(0.7))),
          const SizedBox(height: 8),

          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: wallpaperAssets.length,
              itemBuilder: (context, index) {
                final assetPath = wallpaperAssets[index];
                return GestureDetector(
                  onTap: () {
                    onImageSelected(assetPath);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: currentImage == assetPath
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      image: DecorationImage(
                        image: AssetImage(assetPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Solid Colors',
            style: TextStyle(color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: solidColors.length,
              itemBuilder: (context, index) {
                final color = solidColors[index];
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: currentColor == color
                          ? Border.all(color: Colors.white, width: 3)
                          : Border.all(color: Colors.grey, width: 1),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
