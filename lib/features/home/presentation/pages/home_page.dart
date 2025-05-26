import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../widgets/home_action_button.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
import '../../../analysis/presentation/providers/analysis_provider.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Numera',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador de estado del modelo
            Consumer<AnalysisProvider>(
              builder: (context, provider, _) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.isModelInitialized
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.isModelInitialized
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.isModelInitialized
                            ? Icons.check_circle_outline
                            : Icons.hourglass_empty,
                        size: 16,
                        color: provider.isModelInitialized
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isModelInitialized
                            ? 'IA lista para uso'
                            : 'Inicializando IA...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: provider.isModelInitialized
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.camera_alt_outlined,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 32),
            Text(
              'Cuenta objetos con IA',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Toma una foto o carga una imagen para contar y clasificar objetos automáticamente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            HomeActionButton(
              icon: Icons.camera_alt,
              label: 'Tomar foto',
              onPressed: () => _pickImage(context, ImageSource.camera),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            HomeActionButton(
              icon: Icons.photo_library,
              label: 'Cargar imagen',
              onPressed: () => _pickImage(context, ImageSource.gallery),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisPage(imagePath: image.path),
        ),
      );
    }
  }
}
