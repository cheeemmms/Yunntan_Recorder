import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/trip.dart';

typedef RegisterCloseCallback = void Function(VoidCallback close);

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final GlobalKey cardKey;
  final RegisterCloseCallback? registerClose;

  const TripCard({
    super.key,
    required this.trip,
    required this.onEdit,
    required this.onDelete,
    required this.cardKey,
    this.registerClose,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late SlidableController _slidableController;
  bool _slidableIsOpen = false;

  Trip get trip => widget.trip;

  String get _dateStr {
    final d = trip.departureTime;
    return '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get _timeStr {
    final d = trip.departureTime;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get _arrivalTimeStr {
    if (trip.arrivalTime == null) return '';
    final d = trip.arrivalTime!;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  int? get _dayOffset {
    if (trip.arrivalTime == null) return null;
    final dep = DateTime(
      trip.departureTime.year,
      trip.departureTime.month,
      trip.departureTime.day,
    );
    final arr = DateTime(
      trip.arrivalTime!.year,
      trip.arrivalTime!.month,
      trip.arrivalTime!.day,
    );
    return arr.difference(dep).inDays;
  }

  String? get _durationLabel {
    if (trip.arrivalTime == null) return null;
    final diff = trip.arrivalTime!.difference(trip.departureTime);
    final totalMinutes = diff.inMinutes;
    if (totalMinutes < 0) return null;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}小时${minutes}分钟';
    if (hours > 0) return '${hours}小时';
    return '${minutes}分钟';
  }

  String get _fullDateStr {
    final d = trip.departureTime;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get _route {
    final board = trip.boardStation.isNotEmpty ? trip.boardStation : '?';
    final alight = trip.alightStation.isNotEmpty ? trip.alightStation : '?';
    return '$board → $alight';
  }

  String get _trainModelLabel {
    final parts = <String>[];
    if (trip.trainPlatformKey != null) parts.add(trip.trainPlatformKey!);
    if (trip.trainSeriesKey != null) parts.add(trip.trainSeriesKey!);
    if (trip.trainVariant != null) parts.add(trip.trainVariant!);
    return parts.isNotEmpty ? parts.join(' ') : '';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slidableController = SlidableController(this);
    _slidableController.animation.addListener(_onSlidableAnimation);
  }

  void _onSlidableAnimation() {
    final value = _slidableController.animation.value;
    final isOpen = value != 0.0;
    if (isOpen && !_slidableIsOpen) {
      _slidableIsOpen = true;
      widget.registerClose?.call(closeSlidable);
    } else if (!isOpen && _slidableIsOpen) {
      _slidableIsOpen = false;
    }
  }

  @override
  void dispose() {
    _slidableController.animation.removeListener(_onSlidableAnimation);
    _animController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _openTicket() {
    final renderBox =
        widget.cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final sourceRect = Rect.fromPoints(
      renderBox.localToGlobal(Offset.zero),
      renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero)),
    );

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _TicketOverlay(
        trip: trip,
        controller: _animController,
        sourceRect: sourceRect,
        trainModelLabel: _trainModelLabel,
        fullDateStr: _fullDateStr,
        timeStr: _timeStr,
        arrivalTimeStr: _arrivalTimeStr,
        dayOffset: _dayOffset,
        durationLabel: _durationLabel,
        dateStr: _dateStr,
        route: _route,
        onClose: _closeTicket,
      ),
    );

    overlay.insert(_overlayEntry!);
    _animController.forward();
  }

  void _closeTicket() {
    _animController.reverse().then((_) {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void closeSlidable() {
    _slidableController.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        controller: _slidableController,
        key: ValueKey(trip.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (_) => widget.onDelete(),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.delete_outline, size: 24),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            CustomSlidableAction(
              onPressed: (_) => widget.onEdit(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.edit_outlined, size: 24),
            ),
          ],
        ),
        child: Card(
          key: widget.cardKey,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          elevation: 0,
          child: InkWell(
            onTap: _openTicket,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCompact(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final hasArrival = trip.arrivalTime != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: hasArrival ? 56 : 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _dateStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              Text(
                _timeStr,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              if (hasArrival) ...[
                Center(
                  widthFactor: 1,
                  child: Icon(
                    Icons.south,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                _buildArrivalTimeInline(theme, colorScheme),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    trip.trainNo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  if (trip.trainType.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.trainType,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasArrival) SizedBox(height: 14),
              Text(
                _route,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (_trainModelLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _trainModelLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildArrivalTimeInline(ThemeData theme, ColorScheme cs) {
    final offset = _dayOffset;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _arrivalTimeStr,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (offset != null && offset > 0)
          Text(
            '+$offset',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: cs.onSurfaceVariant.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _TicketOverlay extends StatelessWidget {
  final Trip trip;
  final AnimationController controller;
  final Rect sourceRect;
  final String trainModelLabel;
  final String fullDateStr;
  final String timeStr;
  final String arrivalTimeStr;
  final int? dayOffset;
  final String? durationLabel;
  final String dateStr;
  final String route;
  final VoidCallback onClose;

  const _TicketOverlay({
    required this.trip,
    required this.controller,
    required this.sourceRect,
    required this.trainModelLabel,
    required this.fullDateStr,
    required this.timeStr,
    required this.arrivalTimeStr,
    required this.dayOffset,
    required this.durationLabel,
    required this.dateStr,
    required this.route,
    required this.onClose,
  });

  double _bgProgress(double t) {
    final raw = (t * 500 / 300).clamp(0.0, 1.0);
    return Curves.easeOut.transform(raw);
  }

  double _floatProgress(double t) {
    final raw = (t * 500 / 300).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  double _fadeProgress(double t) {
    final raw = (t * 500 / 300).clamp(0.0, 1.0);
    return Curves.easeOut.transform(raw);
  }

  double _expandProgress(double t) {
    return Curves.easeOutCubic.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final bg = _bgProgress(t);
        final fp = _floatProgress(t);
        final fade = _fadeProgress(t);
        final ep = _expandProgress(t);

        final screenSize = MediaQuery.of(context).size;
        final statusBarTop = MediaQuery.of(context).padding.top;
        final targetWidth = screenSize.width * 0.88;
        final targetLeft = (screenSize.width - targetWidth) / 2;

        final floatUp = lerpDouble(0, 10, fp)!;
        var currentTop = sourceRect.top - floatUp;

        final minTop = statusBarTop + 16;
        if (currentTop < minTop) {
          currentTop = minTop;
        }

        final currentLeft = lerpDouble(sourceRect.left, targetLeft, ep)!;
        final currentWidth = lerpDouble(sourceRect.width, targetWidth, ep)!;
        final currentRadius = lerpDouble(16, 24, ep)!;

        return Stack(
          children: [
            GestureDetector(
              onTap: onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8 * bg, sigmaY: 8 * bg),
                child: Container(
                  color: Colors.black.withOpacity(0.15 * bg),
                  constraints: BoxConstraints.expand(),
                ),
              ),
            ),
            Positioned(
              left: currentLeft,
              top: currentTop,
              width: currentWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(currentRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25 * ep),
                      blurRadius: 20 * ep,
                      offset: Offset(0, 6 * ep),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _TicketContent(
                  trip: trip,
                  fadeProgress: fade,
                  trainModelLabel: trainModelLabel,
                  fullDateStr: fullDateStr,
                  timeStr: timeStr,
                  arrivalTimeStr: arrivalTimeStr,
                  dayOffset: dayOffset,
                  durationLabel: durationLabel,
                  dateStr: dateStr,
                  route: route,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TicketContent extends StatelessWidget {
  final Trip trip;
  final double fadeProgress;
  final String trainModelLabel;
  final String fullDateStr;
  final String timeStr;
  final String arrivalTimeStr;
  final int? dayOffset;
  final String? durationLabel;
  final String dateStr;
  final String route;

  const _TicketContent({
    required this.trip,
    required this.fadeProgress,
    required this.trainModelLabel,
    required this.fullDateStr,
    required this.timeStr,
    required this.arrivalTimeStr,
    required this.dayOffset,
    required this.durationLabel,
    required this.dateStr,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Opacity(
        opacity: fadeProgress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, cs),
            const SizedBox(height: 14),
            _buildDivider(cs),
            const SizedBox(height: 10),
            _buildRouteSection(theme, cs),
            const SizedBox(height: 10),
            _buildDivider(cs),
            const SizedBox(height: 10),
            _buildInfoGrid(theme, cs),
            if (trip.remarks.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDivider(cs),
              const SizedBox(height: 6),
              _buildRemarks(theme, cs),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    trip.trainNo,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (trip.trainType.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.trainType,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onPrimaryContainer,
                          height: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (trainModelLabel.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    trainModelLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              fullDateStr,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
            if (arrivalTimeStr.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      '→',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        arrivalTimeStr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                          height: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (dayOffset != null && dayOffset! > 0)
                        Text(
                          '+$dayOffset',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (durationLabel != null)
                Text(
                  durationLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurfaceVariant,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
            ] else ...[
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildRouteSection(ThemeData theme, ColorScheme cs) {
    final board = trip.boardStation.isNotEmpty ? trip.boardStation : '—';
    final alight = trip.alightStation.isNotEmpty ? trip.alightStation : '—';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '出发',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  board,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Icon(Icons.train, color: cs.primary, size: 18),
              Container(width: 40, height: 1, color: cs.outlineVariant),
              Icon(Icons.location_on, color: cs.error, size: 18),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '到达',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  alight,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(ThemeData theme, ColorScheme cs) {
    final items = <_InfoItem>[];

    if (trip.price > 0) {
      items.add(
        _InfoItem(
          Icons.payments_outlined,
          '票价',
          '¥${trip.price.toStringAsFixed(trip.price.truncateToDouble() == trip.price ? 0 : 2)}',
        ),
      );
    }

    if (trip.originStation.isNotEmpty || trip.destStation.isNotEmpty) {
      final origin = trip.originStation.isNotEmpty ? trip.originStation : '?';
      final dest = trip.destStation.isNotEmpty ? trip.destStation : '?';
      items.add(_InfoItem(Icons.route_outlined, '全程', '$origin → $dest'));
    }

    items.add(
      _InfoItem(
        Icons.airline_seat_recline_normal_outlined,
        '席位',
        '${trip.seatCategory} · ${trip.seatType}',
      ),
    );

    if (trip.bureauKey != null) {
      final bureau = trip.sectionName != null
          ? '${trip.bureauKey} ${trip.sectionName}'
          : trip.bureauKey!;
      items.add(_InfoItem(Icons.badge_outlined, '担当', bureau));
    }

    final leftItems = <_InfoItem>[];
    final rightItems = <_InfoItem>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        leftItems.add(items[i]);
      } else {
        rightItems.add(items[i]);
      }
    }

    final maxRows = leftItems.length > rightItems.length
        ? leftItems.length
        : rightItems.length;

    return Column(
      children: List.generate(maxRows, (row) {
        final left = row < leftItems.length ? leftItems[row] : null;
        final right = row < rightItems.length ? rightItems[row] : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: left != null
                    ? _buildInfoItem(theme, cs, left)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: right != null
                    ? _buildInfoItem(theme, cs, right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoItem(ThemeData theme, ColorScheme cs, _InfoItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 15, color: cs.onSurfaceVariant),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                color: cs.onSurfaceVariant,
                height: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              item.value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
                height: 1.2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 14,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.constrainWidth() / 8).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return Container(
                    width: 4,
                    height: 1,
                    color: cs.outlineVariant,
                  );
                }),
              );
            },
          ),
        ),
        Container(
          width: 8,
          height: 14,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarks(ThemeData theme, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备注',
          style: TextStyle(
            fontSize: 10,
            color: cs.onSurfaceVariant,
            height: 1.2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            trip.remarks,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface,
              height: 1.3,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}
