import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/birthday_provider.dart';
import '../models/birthday.dart';

class AddBirthdayScreen extends StatefulWidget {
  final Birthday? birthday;

  const AddBirthdayScreen({
    super.key,
    this.birthday,
  });

  @override
  State<AddBirthdayScreen> createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends State<AddBirthdayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedRelationship = 'friend';
  String? _selectedGender;
  List<String> _selectedInterests = [];

  bool _isLoading = false;

  static const _relationships = [
    'friend',
    'family',
    'partner',
    'colleague',
    'other',
  ];

  static const _genders = [
    'male',
    'female',
    'other',
  ];

  static const _interests = [
    'Reading',
    'Gaming',
    'Sports',
    'Music',
    'Art',
    'Technology',
    'Fashion',
    'Cooking',
    'Travel',
    'Movies',
    'Photography',
    'Fitness',
    'Nature',
    'Science',
    'Writing',
    'Dancing',
    'Cars',
    'Animals',
    'DIY',
    'Gardening',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.birthday != null) {
      _nameController.text = widget.birthday!.name;
      _notesController.text = widget.birthday!.notes ?? '';
      _budgetController.text = widget.birthday!.budget?.toString() ?? '';
      _selectedDate = widget.birthday!.date;
      _selectedRelationship = widget.birthday!.relationship;
      _selectedGender = widget.birthday!.gender;
      _selectedInterests = List.from(widget.birthday!.interests);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBirthday() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final birthdayData = {
        'id': widget.birthday?.id,
        'name': _nameController.text.trim(),
        'date': _selectedDate!.toIso8601String(),
        'notes': _notesController.text.trim(),
        'interests': _selectedInterests,
        'relationship': _selectedRelationship,
        'gender': _selectedGender,
        if (_budgetController.text.isNotEmpty)
          'budget': double.parse(_budgetController.text),
      };

      if (widget.birthday != null) {
        await context
            .read<BirthdayProvider>()
            .updateBirthday(widget.birthday!.id, birthdayData);
      } else {
        await context.read<BirthdayProvider>().addBirthday(birthdayData);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.birthday != null ? 'Edit Birthday' : 'Add Birthday'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  border: const OutlineInputBorder(),
                  errorText: _selectedDate == null ? 'Please select a date' : null,
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              items: _relationships.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(
                    relationship[0].toUpperCase() + relationship.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRelationship = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Not specified'),
                ),
                ..._genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(
                      gender[0].toUpperCase() + gender.substring(1),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gift Budget',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final budget = double.tryParse(value);
                  if (budget == null || budget <= 0) {
                    return 'Please enter a valid budget';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Interests',
                border: OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'Add any notes about gift preferences, sizes, etc.',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _saveBirthday,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.birthday != null ? 'Save Changes' : 'Add Birthday'),
            ),
          ],
        ),
      ),
    );
  }
} 