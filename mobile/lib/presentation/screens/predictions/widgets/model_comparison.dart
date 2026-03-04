import 'package:flutter/material.dart';

class ModelComparison extends StatelessWidget {
  final String activeModel;
  final List<Map<String, dynamic>> models;

  const ModelComparison({
    super.key,
    required this.activeModel,
    this.models = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Default models if none provided
    final displayModels = models.isEmpty
        ? [
            {'name': 'Chronos', 'accuracy': 92.5, 'type': 'HuggingFace'},
            {'name': 'Prophet', 'accuracy': 88.3, 'type': 'Facebook'},
            {'name': 'Linear Regression', 'accuracy': 78.0, 'type': 'Classic'},
            {'name': 'Moving Average', 'accuracy': 72.1, 'type': 'Classic'},
          ]
        : models;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Comparison',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...displayModels.map((model) {
          final name = model['name'] as String;
          final accuracy = (model['accuracy'] as num).toDouble();
          final type = model['type'] as String? ?? '';
          final isActive = name.toLowerCase() == activeModel.toLowerCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF10b77f).withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? const Color(0xFF10b77f) : Colors.grey.shade200,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.model_training,
                  color: isActive ? const Color(0xFF10b77f) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10b77f),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ],
                      ),
                      Text(type, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${accuracy.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('accuracy', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
