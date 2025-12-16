import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/app_state.dart';
import '../models/meal_entry.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final _nameController = TextEditingController();
  int? _hungerBefore;
  EatingReason? _eatingReason;
  MealRating _rating = MealRating.none;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ny måltid'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Namn på måltiden
            _buildNameSection(),
            const SizedBox(height: 24),

            // Ta bild
            _buildPhotoSection(),
            const SizedBox(height: 24),
            
            // Hunger före måltid
            _buildHungerSection(),
            const SizedBox(height: 24),

            // Betyg
            _buildRatingSection(),
            const SizedBox(height: 32),
            
            // Spara-knapp
            _buildSaveButton(),
            
            const SizedBox(height: 24),
            
            // Info-text
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vad åt du?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'T.ex. Lunch, Frukost, Mellanmål...',
            prefixIcon: const Icon(Icons.restaurant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 8),
        // Snabbval från tidigare måltider
        _buildQuickMealSuggestions(),
      ],
    );
  }

  Widget _buildQuickMealSuggestions() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // Hämta unika måltidsnamn från tidigare
        final previousNames = state.mealEntries
            .where((m) => m.name != null && m.name!.isNotEmpty)
            .map((m) => m.name!)
            .toSet()
            .take(5)
            .toList();

        if (previousNames.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: previousNames.map((name) => GestureDetector(
            onTap: () => _nameController.text = name,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ta en bild (valfritt)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.neutralGray.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: _imagePath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_imagePath!),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _imagePath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tryck för att ta bild',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ta bild'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (photo != null) {
                  await _saveImage(photo);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Välj från galleri'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 80,
                );
                if (photo != null) {
                  await _saveImage(photo);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(XFile photo) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(photo.path).copy('${directory.path}/$fileName');
    setState(() => _imagePath = savedImage.path);
  }

  Widget _buildHungerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hur känns kroppen just nu? (valfritt)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Hunger före måltid',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        
        // Hunger-skala
        _buildScaleSelector(
          value: _hungerBefore,
          onChanged: (val) => setState(() => _hungerBefore = val),
          getDescription: MealEntry.hungerDescription,
        ),
        
        const SizedBox(height: 24),
        
        // Valfritt: Anledning till att äta
        Text(
          'Äter av (valfritt)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildEatingReasonSelector(),
      ],
    );
  }

  Widget _buildScaleSelector({
    required int? value,
    required Function(int) onChanged,
    required String Function(int) getDescription,
  }) {
    return Column(
      children: [
        // Visuell skala med stora knappar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(10, (index) {
            final level = index + 1;
            final isSelected = value == level;
            
            return GestureDetector(
              onTap: () => onChanged(level),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.neutralGray.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 16),
        
        // Beskrivning
        if (value != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              getDescription(value),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildEatingReasonSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EatingReason.values.map((reason) {
        final isSelected = _eatingReason == reason;
        
        return GestureDetector(
          onTap: () => setState(() {
            _eatingReason = isSelected ? null : reason;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.neutralGray.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              MealEntry.eatingReasonText(reason),
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hur kändes måltiden? (valfritt)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRatingButton(MealRating.bronze, '🥉', 'Okej'),
            _buildRatingButton(MealRating.silver, '🥈', 'Bra'),
            _buildRatingButton(MealRating.gold, '🥇', 'Riktigt bra'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingButton(MealRating rating, String emoji, String label) {
    final isSelected = _rating == rating;
    
    return GestureDetector(
      onTap: () => setState(() {
        _rating = isSelected ? MealRating.none : rating;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? _getRatingColor(rating).withValues(alpha: 0.15)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? _getRatingColor(rating) 
                : AppTheme.neutralGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? _getRatingColor(rating) : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(MealRating rating) {
    switch (rating) {
      case MealRating.bronze:
        return AppTheme.bronzeColor;
      case MealRating.silver:
        return AppTheme.silverColor;
      case MealRating.gold:
        return AppTheme.goldColor;
      case MealRating.none:
        return AppTheme.neutralGray;
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveMeal,
        child: const Text('Spara måltid'),
      ),
    );
  }

  void _saveMeal() {
    final entry = MealEntry(
      timestamp: DateTime.now(),
      name: _nameController.text.isEmpty ? null : _nameController.text,
      imagePath: _imagePath,
      hungerBefore: _hungerBefore,
      eatingReason: _eatingReason,
      rating: _rating,
    );

    context.read<AppState>().addMealEntry(entry);
    
    // Schemalägga påminnelse om mättnad efter 25 minuter
    NotificationService().scheduleSatietyReminder(
      mealId: entry.id,
      mealName: _nameController.text,
      delayMinutes: 25,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Måltid sparad - påminnelse om mättnad om 25 min'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
    
    Navigator.pop(context);
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutralGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mättnad efter måltiden kan du lägga till senare genom att trycka på måltiden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
