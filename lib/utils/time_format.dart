/// Lightweight timestamp formatting for order times — no external deps.
///
/// Backend `created_at` arrives as an ISO-8601 UTC string (e.g.
/// "2026-06-08T07:32:10.000Z"). We parse, convert to local time, and render.
library;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime? _parseLocal(dynamic raw) {
  if (raw == null) return null;
  final dt = DateTime.tryParse(raw.toString());
  return dt?.toLocal();
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Absolute date + time, e.g. "8 Jun 2026, 14:32".
String formatDateTime(dynamic raw) {
  final dt = _parseLocal(raw);
  if (dt == null) return '—';
  return '${dt.day} ${_months[dt.month - 1]} ${dt.year}, ${_two(dt.hour)}:${_two(dt.minute)}';
}

/// Relative age, e.g. "just now", "5m ago", "2h ago", "3d ago".
/// Falls back to an absolute date for anything older than a week.
String timeAgo(dynamic raw) {
  final dt = _parseLocal(raw);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDateTime(raw);
}
