import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function(int) onPageSelected;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.onNext,
    required this.onPrevious,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.deepSeaLight,
        border: Border(
          top: BorderSide(color: AppColors.deepSea, width: 1),
        ),
      ),
      child: SafeArea( // Penting untuk HP layar poni/notch bawah
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Page $currentPage of $totalPages',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Prev Button
                _PageButton(
                  icon: Icons.chevron_left,
                  onPressed: hasPrevious ? onPrevious : null,
                ),
                
                const SizedBox(width: 8),
                
                // Page Numbers - Scrollable horizontal for safety on small screens
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildPageNumbers(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Next Button
                _PageButton(
                  icon: Icons.chevron_right,
                  onPressed: hasNext ? onNext : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageButtons = [];
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - 4).clamp(1, totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        GestureDetector(
          onTap: i != currentPage ? () => onPageSelected(i) : null,
          child: Container(
            width: 36, // Ukuran touch target yang nyaman
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == currentPage ? AppColors.orangeSport : AppColors.deepSea,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: i == currentPage ? AppColors.orangeSport : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  color: i == currentPage ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: i == currentPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return pageButtons;
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? AppColors.orangeSport : AppColors.deepSea,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero, // Icon only agar muat
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: onPressed != null ? 2 : 0,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}