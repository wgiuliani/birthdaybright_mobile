import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../screens/birthday_details_screen.dart';

class BirthdayListItem extends StatelessWidget {
  final Birthday birthday;

  const BirthdayListItem({
    super.key,
    required this.birthday,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final daysUntil = birthday.daysUntilBirthday;
    final age = birthday.age;

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BirthdayDetailsScreen(birthday: birthday),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            birthday.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(birthday.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(birthday.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Turning ${age + 1}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              daysUntil == 0
                  ? 'Today!'
                  : daysUntil == 1
                      ? 'Tomorrow!'
                      : 'In $daysUntil days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: daysUntil <= 7
                        ? Theme.of(context).colorScheme.error
                        : daysUntil <= 30
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    fontWeight:
                        daysUntil <= 30 ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            if (birthday.budget != null) ...[
              const SizedBox(height: 2),
              Text(
                '\$${birthday.budget!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 