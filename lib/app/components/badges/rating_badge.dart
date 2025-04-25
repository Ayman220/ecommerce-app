import 'package:flutter/material.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final bool showCount;
  final Color backgroundColor;
  final double iconSize;
  final double fontSize;
  
  const RatingBadge({
    Key? key,
    required this.rating,
    this.reviewCount,
    this.showCount = false,
    this.backgroundColor = Colors.black54,
    this.iconSize = 14,
    this.fontSize = 12,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: iconSize,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showCount && reviewCount != null) ...[
            const SizedBox(width: 2),
            Text(
              '($reviewCount)',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize - 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}