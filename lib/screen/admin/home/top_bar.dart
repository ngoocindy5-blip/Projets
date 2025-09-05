import 'package:flutter/material.dart';
import 'theme.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final bool isMobile;
  final VoidCallback? onMenuTap;
  final ValueChanged<String> onSearch;
  final String? greetingName;

  const AdminTopBar({
    super.key,
    required this.title,
    required this.isMobile,
    required this.onMenuTap,
    required this.onSearch,
    this.greetingName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 72 : 86,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 14),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(.92),
        boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(icon: const Icon(Icons.menu_rounded), onPressed: onMenuTap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: kTextDark)),
              Text(
                (greetingName != null && greetingName!.trim().isNotEmpty)
                    ? 'Bienvenue, ${greetingName!}'
                    : 'Bienvenue dans votre espace d’administration',
                style: const TextStyle(color: kTextLight, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          if (!isMobile) SizedBox(width: 360, child: _AdminSearchField(onChanged: onSearch)),
          const SizedBox(width: 12),
          const _AdminIconBadge(icon: Icons.notifications_rounded, count: '3', color: kWarningOrange),
          const SizedBox(width: 10),
          const _AdminIconBadge(icon: Icons.message_rounded, count: '12', color: kSuccessGreen),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 16, backgroundColor: kAccentBlue, child: Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
        ],
      ),
    );
  }
}

class _AdminSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _AdminSearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher…',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        isDense: true,
        filled: true,
        fillColor: kSoftGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}

class _AdminIconBadge extends StatelessWidget {
  final IconData icon; final String count; final Color color;
  const _AdminIconBadge({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: kCardShadow, blurRadius: 12)]),
          child: Icon(icon, color: kTextLight, size: 20),
        ),
        Positioned(
          right: -2, top: -2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 6)]),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
