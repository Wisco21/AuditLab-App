import 'package:flutter/material.dart';

// class RoleCard extends StatelessWidget {
//   final String role;
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const RoleCard({
//     super.key,
//     required this.role,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: color.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? color : Colors.black87,
//                           ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       description,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(
//                   Icons.check_circle,
//                   color: color,
//                   size: 28,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class RoleCard extends StatelessWidget {
  final String role;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showAdminBadge;

  const RoleCard({
    super.key,
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.showAdminBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : Colors.black87,
                              ),
                        ),
                        if (showAdminBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
