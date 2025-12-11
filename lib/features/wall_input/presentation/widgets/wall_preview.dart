/// Wall Preview Widget
///
/// Displays a real-time visual preview of the retaining wall design
/// based on the current input parameters.
///
/// Usage:
/// ```dart
/// WallPreview(
///   input: currentInput,
///   isLoading: false,
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/retaining_wall_input.dart';

/// Visual preview of the retaining wall design.
class WallPreview extends StatelessWidget {
  /// Current wall input parameters.
  final RetainingWallInput input;

  /// Whether preview is loading/updating.
  final bool isLoading;

  /// Error message to display, if any.
  final String? error;

  const WallPreview({
    super.key,
    required this.input,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewHeader(input: input),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _ErrorDisplay(error: error!)
                    : _WallVisualization(input: input),
          ),
          _SpecificationsSummary(input: input),
        ],
      ),
    );
  }
}

/// Header showing wall dimensions and price.
class _PreviewHeader extends StatelessWidget {
  final RetainingWallInput input;

  const _PreviewHeader({required this.input});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.preview),
          const SizedBox(width: 8),
          Text(
            'Wall Preview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${input.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error display when preview fails.
class _ErrorDisplay extends StatelessWidget {
  final String error;

  const _ErrorDisplay({required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Preview Error',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painted wall visualization.
class _WallVisualization extends StatelessWidget {
  final RetainingWallInput input;

  const _WallVisualization({required this.input});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _WallPainter(
              input: input,
              primaryColor: colorScheme.primary,
              surfaceColor: colorScheme.surfaceContainerHighest,
              outlineColor: colorScheme.outline,
              textColor: colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for the wall visualization.
class _WallPainter extends CustomPainter {
  final RetainingWallInput input;
  final Color primaryColor;
  final Color surfaceColor;
  final Color outlineColor;
  final Color textColor;

  _WallPainter({
    required this.input,
    required this.primaryColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Calculate scale - map 144 inches to 70% of available height
    final scale = (size.height * 0.7) / WallConstraints.maxHeight;
    final wallHeight = input.height * scale;
    final wallWidth = 30 * scale; // Base wall width
    final footingHeight = 12 * scale;
    final toeLength = input.toe * scale;
    final toppingHeight = input.topping * scale;

    // Center point
    final centerX = size.width / 2;
    final bottomY = size.height - 30;

    // Draw ground line
    paint.color = surfaceColor;
    canvas.drawRect(
      Rect.fromLTWH(0, bottomY - footingHeight, size.width, footingHeight + 30),
      paint,
    );

    // Draw footing
    paint.color = _getWallColor();
    final footingRect = Rect.fromLTWH(
      centerX - wallWidth - toeLength,
      bottomY - footingHeight,
      wallWidth * 2 + toeLength,
      footingHeight,
    );
    canvas.drawRect(footingRect, paint);

    // Draw wall
    final wallRect = Rect.fromLTWH(
      centerX - wallWidth / 2,
      bottomY - footingHeight - wallHeight,
      wallWidth,
      wallHeight,
    );
    canvas.drawRect(wallRect, paint);

    // Draw slab if present
    if (input.hasSlab) {
      paint.color = surfaceColor;
      final slabRect = Rect.fromLTWH(
        centerX + wallWidth / 2,
        bottomY - footingHeight - 8 * scale,
        60 * scale,
        8 * scale,
      );
      canvas.drawRect(slabRect, paint);
    }

    // Draw topping if present
    if (input.topping > 0) {
      paint.color = Colors.brown.shade300;
      final toppingRect = Rect.fromLTWH(
        centerX - wallWidth - toeLength - 20 * scale,
        bottomY - footingHeight - wallHeight - toppingHeight,
        wallWidth / 2 + toeLength + 20 * scale,
        toppingHeight,
      );
      canvas.drawRect(toppingRect, paint);
    }

    // Draw surcharge slope if not flat
    if (input.surcharge != SurchargeType.flat) {
      paint.color = Colors.brown.shade200;
      final path = Path();
      path.moveTo(centerX - wallWidth / 2, bottomY - footingHeight - wallHeight);

      double slopeRatio;
      switch (input.surcharge) {
        case SurchargeType.slope1to1:
          slopeRatio = 1.0;
          break;
        case SurchargeType.slope1to2:
          slopeRatio = 0.5;
          break;
        case SurchargeType.slope1to4:
          slopeRatio = 0.25;
          break;
        default:
          slopeRatio = 0.0;
      }

      final slopeHeight = 40 * scale;
      final slopeWidth = slopeHeight / slopeRatio;

      path.lineTo(
        centerX - wallWidth / 2 - slopeWidth,
        bottomY - footingHeight - wallHeight - slopeHeight,
      );
      path.lineTo(
        centerX - wallWidth / 2 - slopeWidth - 30 * scale,
        bottomY - footingHeight - wallHeight - slopeHeight,
      );
      path.lineTo(
        centerX - wallWidth / 2 - 30 * scale,
        bottomY - footingHeight - wallHeight,
      );
      path.close();
      canvas.drawPath(path, paint);
    }

    // Draw dimension lines
    _drawDimensionLine(
      canvas,
      Offset(centerX + wallWidth / 2 + 20, bottomY - footingHeight - wallHeight),
      Offset(centerX + wallWidth / 2 + 20, bottomY - footingHeight),
      '${input.height.toStringAsFixed(0)}"',
    );

    // Draw outline
    paint.color = outlineColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(wallRect, paint);
    canvas.drawRect(footingRect, paint);

    // Draw material label
    _drawLabel(
      canvas,
      Offset(centerX, bottomY - footingHeight - wallHeight / 2),
      input.material == WallMaterialType.cmu ? 'CMU' : 'CONCRETE',
    );
  }

  Color _getWallColor() {
    if (input.material == WallMaterialType.cmu) {
      return Colors.grey.shade400;
    } else {
      return Colors.grey.shade600;
    }
  }

  void _drawDimensionLine(
    Canvas canvas,
    Offset start,
    Offset end,
    String label,
  ) {
    final paint = Paint()
      ..color = textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw main line
    canvas.drawLine(start, end, paint);

    // Draw end caps
    canvas.drawLine(
      Offset(start.dx - 5, start.dy),
      Offset(start.dx + 5, start.dy),
      paint,
    );
    canvas.drawLine(
      Offset(end.dx - 5, end.dy),
      Offset(end.dx + 5, end.dy),
      paint,
    );

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final midY = (start.dy + end.dy) / 2 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(start.dx + 8, midY));
  }

  void _drawLabel(Canvas canvas, Offset position, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _WallPainter oldDelegate) {
    return oldDelegate.input != input;
  }
}

/// Summary of specifications at the bottom of preview.
class _SpecificationsSummary extends StatelessWidget {
  final RetainingWallInput input;

  const _SpecificationsSummary({required this.input});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _SpecChip(
            icon: Icons.height,
            label: '${input.height.toStringAsFixed(0)}" (${input.heightInFeet.toStringAsFixed(1)} ft)',
          ),
          _SpecChip(
            icon: Icons.category,
            label: input.materialLabel,
          ),
          _SpecChip(
            icon: Icons.terrain,
            label: input.surchargeLabel,
          ),
          _SpecChip(
            icon: Icons.foundation,
            label: input.soilStiffnessLabel,
          ),
          if (input.hasSlab)
            const _SpecChip(
              icon: Icons.layers,
              label: 'With Slab',
            ),
        ],
      ),
    );
  }
}

/// Specification chip widget.
class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
