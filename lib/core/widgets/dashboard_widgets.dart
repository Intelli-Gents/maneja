import 'package:flutter/material.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBg,
    this.iconColor,
    this.pillText,
    this.pillBg,
    this.pillFg,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconBg;
  final Color? iconColor;

  final String? pillText;
  final Color? pillBg;
  final Color? pillFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor ?? const Color(0xFF111827)),
              ),
              const Spacer(),
              if (pillText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillBg ?? const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pillText!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: pillFg ?? const Color(0xFF111827),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9AA3B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.actionColor,
    this.onTap,
  });

  final String title;
  final String? actionText;
  final Color? actionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Color(0xFF374151),
          ),
        ),
        const Spacer(),
        if (actionText != null)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                actionText!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: actionColor ?? const Color(0xFF111827),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class NotebookListCard extends StatelessWidget {
  const NotebookListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class NotebookEntryRowData {
  const NotebookEntryRowData({
    required this.leadingIcon,
    required this.leadingBg,
    this.leadingIconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.trailingIsLink = false,
  });

  final IconData? leadingIcon;
  final Color leadingBg;
  final Color? leadingIconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final bool trailingIsLink;
}

class NotebookEntryRow extends StatelessWidget {
  const NotebookEntryRow({
    super.key,
    required this.data,
    required this.showDivider,
  });

  final NotebookEntryRowData data;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.leadingBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: data.leadingIcon != null
                    ? Icon(
                        data.leadingIcon,
                        color: data.leadingIconColor ?? const Color(0xFF111827),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data.trailing,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: data.trailingIsLink
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 78,
            endIndent: 16,
            color: Color(0xFFF3F4F6),
          ),
      ],
    );
  }
}

