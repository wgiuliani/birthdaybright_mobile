import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/birthday_provider.dart';
import '../models/birthday.dart';
import 'add_birthday_screen.dart';

class BirthdayDetailsScreen extends StatefulWidget {
  final Birthday birthday;

  const BirthdayDetailsScreen({
    super.key,
    required this.birthday,
  });

  @override
  State<BirthdayDetailsScreen> createState() => _BirthdayDetailsScreenState();
}

class _BirthdayDetailsScreenState extends State<BirthdayDetailsScreen> {
  bool _isLoadingSuggestions = false;
  bool _isGeneratingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadGiftSuggestions();
  }

  Future<void> _loadGiftSuggestions() async {
    setState(() => _isLoadingSuggestions = true);
    try {
      await context
          .read<BirthdayProvider>()
          .fetchGiftSuggestions(widget.birthday.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load gift suggestions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  Future<void> _generateGiftSuggestions() async {
    setState(() => _isGeneratingSuggestions = true);
    try {
      await context
          .read<BirthdayProvider>()
          .generateGiftSuggestions(widget.birthday.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate gift suggestions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSuggestions = false);
      }
    }
  }

  Future<void> _deleteBirthday() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Birthday'),
        content: const Text('Are you sure you want to delete this birthday?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<BirthdayProvider>().deleteBirthday(widget.birthday.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete birthday: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftSuggestions() {
    final birthdayId = widget.birthday.id;
    final suggestions = context.watch<BirthdayProvider>().giftSuggestions[birthdayId] ?? [];

    // Debugging logs
    print("Birthday ID: $birthdayId");
    print("Gift Suggestions: ${context.read<BirthdayProvider>().giftSuggestions}");
    print("Suggestions for this birthday: $suggestions");

    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No gift suggestions yet'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isGeneratingSuggestions ? null : _generateGiftSuggestions,
              icon: _isGeneratingSuggestions
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lightbulb_outline),
              label: const Text('Generate Suggestions'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        FilledButton.icon(
          onPressed: _isGeneratingSuggestions ? null : _generateGiftSuggestions,
          icon: _isGeneratingSuggestions
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh),
          label: const Text('Generate New Suggestions'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Card(
                child: ListTile(
                  title: Text(suggestion.suggestion),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        suggestion.reasoning,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (suggestion.price != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Estimated price: \$${suggestion.price!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysUntil = widget.birthday.daysUntilBirthday;
    final age = widget.birthday.age;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.birthday.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddBirthdayScreen(
                      birthday: widget.birthday,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteBirthday,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Gift Ideas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Details Tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birthday in ${daysUntil == 0 ? "Today!" : "$daysUntil days"}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Turning ${age + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Birthday', _formatDate(widget.birthday.date)),
                        _buildInfoRow(
                          'Relationship',
                          widget.birthday.relationship[0].toUpperCase() +
                              widget.birthday.relationship.substring(1),
                        ),
                        if (widget.birthday.gender != null)
                          _buildInfoRow(
                            'Gender',
                            widget.birthday.gender![0].toUpperCase() +
                                widget.birthday.gender!.substring(1),
                          ),
                        if (widget.birthday.budget != null)
                          _buildInfoRow(
                            'Budget',
                            '\$${widget.birthday.budget!.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.birthday.interests.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Interests',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.birthday.interests.map((interest) {
                              return Chip(label: Text(interest));
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.birthday.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.birthday.notes!),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // Gift Ideas Tab
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGiftSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
} 