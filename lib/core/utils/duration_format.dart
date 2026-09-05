/// `H:MM:SS`, or `MM:SS` under an hour — shared by the player screen and
/// the bookmarks sheet.
String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// `1h 2m`, or `2m` under an hour — the coarse form for track/chapter
/// lists, where seconds are noise.
String formatDurationShort(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
}
