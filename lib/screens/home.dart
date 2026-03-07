import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tabIndex = 0;

  
  final String kioskName = "Amos Merch";
  final String dateText = "Wed, 24 May";

  final recentSales = const [
    _EntryRowData(
      
      icon: "assets/img/bread-2.png",
      iconBg: Color(0xFFF4F6F9),
      title: "Bread (Supaloaf)",
      subtitle: "10:42 AM • 2 items",
      trailing: "6,000",
    ),
    _EntryRowData(
      icon: "assets/img/milk.png",
      iconBg: Color(0xFFF4F6F9),
      title: "Milk (Jesa)",
      subtitle: "10:15 AM • 1 item",
      trailing: "2,500",
    ),
    _EntryRowData(
      icon: "assets/img/book.png",
      iconBg: Color(0xFFF4F6F9),
      title: "96 page book",
      subtitle: "09:58 AM • 3 items",
      trailing: "2,500",
    ),
  ];

  final stockIn = const [
    _EntryRowData(
      icon: "assets/img/bread.png",
      iconBg: Color(0xFFEAF1FF),
      iconColor: Color(0xFF2563EB),
      title: "Bread Delivery",
      subtitle: "08:30 AM • 12 loaves",
      trailing: "Restock",
      trailingIsLink: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // My colour palette
    const pageBg = Color(0xFFF8F9FC);
    const textDark = Color(0xFF111827);
    const textMuted = Color(0xFF6B7280);
    const green = Color(0xFF34C77B); 

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pageBg,
        surfaceTintColor: pageBg,
        toolbarHeight: 70,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$dateText • $kioskName",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
        actions: [
          _IconCircleButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: const DecorationImage(
                    
                    image: NetworkImage(
                        "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?q=80&w=100&auto=format&fit=crop"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: const [
                  Expanded(
                    child: _KpiCard(
                      title: "Sales Today",
                      value: "245K",
                      unit: "UGX",
                      icon: Icons.monetization_on_rounded,
                      iconBg: Color(0xFFE5F8ED),
                      iconColor: Color(0xFF18A665),
                      pillText: "+12%",
                      pillBg: Color(0xFFE5F8ED),
                      pillFg: Color(0xFF18A665),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _KpiCard(
                      title: "Est. Profit",
                      value: "42K",
                      unit: "UGX",
                      icon: Icons.show_chart_rounded,
                      iconColor: Color(0xFF4A85F6),
                      iconBg: Color(0xFFEAF1FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                    child: _KpiCard(
                      title: "Low Stock",
                      value: "5",
                      unit: "Items",
                      icon: Icons.inventory_2_rounded,
                      iconBg: Color(0xFFFFF2E4),
                      iconColor: Color(0xFFE07A25),
                      pillText: "Action",
                      pillBg: Color(0xFFFFF2E4),
                      pillFg: Color(0xFFE07A25),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _KpiCard(
                      title: "Debts",
                      value: "3",
                      unit: "People",
                      icon: Icons.account_balance_wallet_rounded,
                      iconBg: Color(0xFFFCE8E8),
                      iconColor: Color(0xFFD95050),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              
              _SectionHeader(
                title: "RECENT SALES",
                actionText: "View All",
                actionColor: green,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _NotebookListCard(
                children: recentSales
                    .map((e) => _EntryRow(
                          data: e,
                          showDivider: e != recentSales.last,
                        ))
                    .toList(),
              ),

              const SizedBox(height: 28),

              
              const _SectionHeader(
                title: "STOCK IN",
              ),
              const SizedBox(height: 12),
              _NotebookListCard(
                children: stockIn
                    .map((e) => _EntryRow(
                          data: e,
                          showDivider: e != stockIn.last,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),

      // Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add_rounded, size: 32),
      ),

      // Bottom Nav
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          height: 75,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: const Color(0xFFEAF1FF),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.today_rounded), label: "Today"),
            NavigationDestination(icon: Icon(Icons.point_of_sale_rounded), label: "Quick Sell"),
            NavigationDestination(icon: Icon(Icons.notifications_rounded), label: "Alerts"),
            NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: "Reports"),
            NavigationDestination(icon: Icon(Icons.settings_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }
}



class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 22),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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

class _NotebookListCard extends StatelessWidget {
  const _NotebookListCard({required this.children});

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

class _EntryRowData {
  const _EntryRowData({
    required this.icon,
    required this.iconBg,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.trailingIsLink = false,
  });

  final String icon;
  final Color iconBg;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final bool trailingIsLink;
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.data, required this.showDivider});

  final _EntryRowData data;
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
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(padding: EdgeInsetsGeometry.all(5), child: Image.asset(data.icon)),
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
                  color: data.trailingIsLink ? const Color(0xFF2563EB) : const Color(0xFF111827),
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