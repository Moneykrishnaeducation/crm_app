part of '../main.dart';

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AppHeader({
    required this.title,
    required this.showMenu,
    required this.onMenu,
  });

  final String title;
  final bool showMenu;
  final VoidCallback onMenu;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: showMenu ? 52 : 0,
      leading: showMenu
          ? IconButton(
              onPressed: onMenu,
              tooltip: 'Open navigation',
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
            )
          : null,
      titleSpacing: showMenu ? 4 : 20,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final compact = MediaQuery.sizeOf(context).width < 480;
          if (compact) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/vtindex_logo.png',
                width: constraints.maxWidth.clamp(90.0, 150.0).toDouble(),
                height: 36,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                semanticLabel: 'VT Index',
              ),
            );
          }
          return Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
      actions: [
        if (MediaQuery.sizeOf(context).width >= 480) ...[
          const _LiveBadge(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none, color: _muted, size: 21),
          ),
        ],
        const Padding(
          padding: EdgeInsetsDirectional.only(end: 14),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: _panelLight,
            child: Icon(Icons.person_outline, size: 18, color: _gold),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 0.7, color: _border),
      ),
    );
  }
}
