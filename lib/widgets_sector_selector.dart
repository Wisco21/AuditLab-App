import 'package:auditlab/models_sector.dart';
import 'package:flutter/material.dart';

class SectorSelector extends StatelessWidget {
  final List<Sector> selectedSectors;
  final List<String> unavailableSectorCodes;
  final Function(List<Sector>) onChanged;
  final bool isAccountant;
  final String? validator;

  const SectorSelector({
    super.key,
    required this.selectedSectors,
    required this.unavailableSectorCodes,
    required this.onChanged,
    required this.isAccountant,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Sector Assignment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isAccountant
                    ? 'Select ONE sector (Accountants can only manage one sector)'
                    : 'Select one or more sectors you will work with',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),

              // Selected sectors chips
              if (selectedSectors.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedSectors.map((sector) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.green.shade700,
                        child: Text(
                          sector.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      label: Text(sector.name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        final updated = List<Sector>.from(selectedSectors);
                        updated.remove(sector);
                        onChanged(updated);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Add sector button
              OutlinedButton.icon(
                onPressed: () => _showSectorPicker(context),
                icon: const Icon(Icons.add),
                label: Text(
                  isAccountant && selectedSectors.isNotEmpty
                      ? 'Change Sector'
                      : 'Add Sector',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade700),
                ),
              ),

              // Validation error
              if (validator != null) ...[
                const SizedBox(height: 8),
                Text(
                  validator!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showSectorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Sector',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: Sector.allSectors.length,
                  itemBuilder: (context, index) {
                    final sector = Sector.allSectors[index];
                    final isSelected = selectedSectors.contains(sector);
                    final isUnavailable =
                        isAccountant &&
                        unavailableSectorCodes.contains(sector.code);
                    final canSelect =
                        !isUnavailable &&
                        (!isAccountant || selectedSectors.isEmpty);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSelected
                          ? Colors.green.shade50
                          : (isUnavailable
                                ? Colors.grey.shade100
                                : Colors.white),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Colors.green.shade700
                              : (isUnavailable
                                    ? Colors.grey
                                    : Colors.green.shade200),
                          child: Text(
                            sector.code,
                            style: TextStyle(
                              color: isSelected || isUnavailable
                                  ? Colors.white
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          sector.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isUnavailable ? Colors.grey : Colors.black87,
                          ),
                        ),
                        subtitle: isUnavailable
                            ? Text(
                                'Already assigned to another Accountant',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                              )
                            : (isUnavailable
                                  ? Icon(Icons.lock, color: Colors.grey)
                                  : null),
                        enabled: canSelect || isSelected,
                        onTap: () {
                          if (!canSelect && !isSelected) return;

                          final updated = List<Sector>.from(selectedSectors);
                          if (isSelected) {
                            updated.remove(sector);
                          } else {
                            if (isAccountant) {
                              // Accountants can only have one sector
                              updated.clear();
                            }
                            updated.add(sector);
                          }
                          onChanged(updated);

                          // Close modal if accountant selected their sector
                          if (isAccountant && updated.isNotEmpty) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
