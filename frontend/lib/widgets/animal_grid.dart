import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/handling_flag.dart';
import '../theme/ara_theme.dart';

enum AnimalFilter { all, careRequired, inTreatment }

class AnimalFilterRow extends StatelessWidget {
  final AnimalFilter activeFilter;
  final ValueChanged<AnimalFilter> onChanged;
  final VoidCallback onMoreFilters;

  const AnimalFilterRow({
    super.key,
    required this.activeFilter,
    required this.onChanged,
    required this.onMoreFilters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: activeFilter == AnimalFilter.all,
            onSelected: () => onChanged(AnimalFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Care required',
            isSelected: activeFilter == AnimalFilter.careRequired,
            onSelected: () => onChanged(AnimalFilter.careRequired),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'In treatment',
            isSelected: activeFilter == AnimalFilter.inTreatment,
            onSelected: () => onChanged(AnimalFilter.inTreatment),
          ),
          const SizedBox(width: 8),
          _FilterIconButton(onPressed: onMoreFilters),
        ],
      ),
    );
  }
}

class AnimalGrid extends StatelessWidget {
  final List<Animal> animals;
  final Color accentColor;
  final Color accentSoft;
  final bool showCautionIcons;
  final bool Function(Animal) needsCaution;
  final void Function(Animal) onTap;

  const AnimalGrid({
    super.key,
    required this.animals,
    required this.accentColor,
    required this.accentSoft,
    required this.showCautionIcons,
    required this.needsCaution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        return _AnimalGridCard(
          animal: animal,
          accentColor: accentColor,
          accentSoft: accentSoft,
          showCautionIcon: showCautionIcons && needsCaution(animal),
          onTap: () => onTap(animal),
        );
      },
    );
  }
}

class _AnimalGridCard extends StatelessWidget {
  final Animal animal;
  final Color accentColor;
  final Color accentSoft;
  final bool showCautionIcon;
  final VoidCallback onTap;

  const _AnimalGridCard({
    required this.animal,
    required this.accentColor,
    required this.accentSoft,
    required this.showCautionIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ARAColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ARAColors.surfaceWarmTint),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _AnimalPhoto(
                      photoBytes: animal.photoBytes,
                      accentColor: accentColor,
                      accentSoft: accentSoft,
                    ),
                  ),
                  if (showCautionIcon)
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: _CautionBadge(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                animal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ARAColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 26,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: animal.flags.isEmpty
                      ? const SizedBox()
                      : _FlagRow(flags: animal.flags),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalPhoto extends StatelessWidget {
  final Uint8List? photoBytes;
  final Color accentColor;
  final Color accentSoft;

  const _AnimalPhoto({
    required this.photoBytes,
    required this.accentColor,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    if (photoBytes != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Image.memory(
          photoBytes!,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        gradient: ARAColors.softBackgroundGradient,
      ),
      child: Center(
        child: CircleAvatar(
          radius: 28,
          backgroundColor: accentSoft.withValues(alpha: 0.5),
          child: Icon(Icons.pets, color: accentColor, size: 28),
        ),
      ),
    );
  }
}

class _CautionBadge extends StatelessWidget {
  const _CautionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: ARAColors.cardBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ARAColors.careful.withValues(alpha: 0.4)),
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: ARAColors.careful,
        size: 16,
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  final Set<HandlingFlag> flags;

  const _FlagRow({required this.flags});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: flags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final flag = flags.elementAt(index);
          return _FlagPill(flag: flag);
        },
      ),
    );
  }
}

class _FlagPill extends StatelessWidget {
  final HandlingFlag flag;

  const _FlagPill({required this.flag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: flag.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: flag.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(flag.icon, size: 14, color: flag.color),
          const SizedBox(width: 4),
          Text(
            flag.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ARAColors.inkStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isSelected ? ARAColors.ink : ARAColors.subInk,
      ),
      backgroundColor: ARAColors.surfaceWarm,
      selectedColor: ARAColors.cardBg,
      side: BorderSide(
        color: isSelected ? ARAColors.brand : ARAColors.surfaceWarmTint,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FilterIconButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ARAColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ARAColors.surfaceWarmTint),
      ),
      child: IconButton(
        icon: const Icon(Icons.tune, size: 18),
        onPressed: onPressed,
        color: ARAColors.subInk,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        splashRadius: 20,
      ),
    );
  }
}
