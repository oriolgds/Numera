import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/analysis_result_card.dart';

class AnalysisPage extends StatefulWidget {
  final String imagePath;

  const AnalysisPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().analyzeImage(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
        actions: [
          Consumer<AnalysisProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.result == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveResult(context, provider),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Resultados
            Consumer<AnalysisProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analizando imagen...'),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error en el análisis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(provider.error!),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.result != null) {
                  return AnalysisResultCard(result: provider.result!);
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveResult(BuildContext context, AnalysisProvider provider) {
    // TODO: Implementar guardado en historial
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado guardado en el historial'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
