import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../medication_provider.dart';
import '../medication_model.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Medications'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.medications.isEmpty) {
            return const Center(
              child: Text(
                'No medications added yet.',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.medications.length,
            itemBuilder: (context, index) {
              final med = provider.medications[index];
              return Card(
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.deepPurple),
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor: ${med.doctor}'),
                      Text('Times per day: ${med.timesPerDay}'),
                      Text('Times: ${med.times.map((t) => t.format(context)).join(", ")}'),
                      Text('Start: ${med.startDate.toLocal().toString().split(' ')[0]}'),
                      Text('End: ${med.endDate.toLocal().toString().split(' ')[0]}'),
                      if (med.symptoms.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Symptoms/Notes: ${med.symptoms}'),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.deleteMedication(med.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final doctorController = TextEditingController();
    final symptomsController = TextEditingController();
    int timesPerDay = 1;
    List<TimeOfDay> times = [TimeOfDay.now()];
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Medication Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(labelText: 'Prescribing Doctor'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Times per day:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: timesPerDay,
                      items: List.generate(6, (i) => i + 1)
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            timesPerDay = v;
                            if (times.length < v) {
                              times.addAll(List.generate(v - times.length, (_) => TimeOfDay.now()));
                            } else if (times.length > v) {
                              times = times.sublist(0, v);
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(timesPerDay, (i) => Row(
                    children: [
                      Text('Time ${i + 1}: '),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: times[i],
                          );
                          if (picked != null) {
                            setState(() => times[i] = picked);
                          }
                        },
                        child: Text(times[i].format(context)),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Start Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                        }
                      },
                      child: Text(startDate.toLocal().toString().split(' ')[0]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('End Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: Text(endDate.toLocal().toString().split(' ')[0]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symptomsController,
                  decoration: const InputDecoration(labelText: 'Symptoms/Notes'),
                  maxLines: 2,
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  setState(() => errorMessage = 'Please enter medication name');
                  return;
                }
                if (doctorController.text.isEmpty) {
                  setState(() => errorMessage = 'Please enter doctor name');
                  return;
                }
                final med = Medication(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  timesPerDay: timesPerDay,
                  times: List<TimeOfDay>.from(times),
                  startDate: startDate,
                  endDate: endDate,
                  doctor: doctorController.text,
                  symptoms: symptomsController.text,
                );
                Provider.of<MedicationProvider>(context, listen: false).addMedication(med);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
} 