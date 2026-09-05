import '../../core/api/models.dart';

/// Pure conversions between the two frames of reference an audiobook's
/// position lives in: Grimmory's progress API and bookmarks use a
/// **book-wide** millisecond offset across every track (matching
/// [AudiobookTrack.cumulativeStartMs]), while just_audio's position and
/// `initialPosition` are **relative to the current track** of a
/// folder-based book. A single-stream book has one timeline, so both
/// functions pass the position through unchanged for it.

/// Book-wide → track-relative. Out-of-range or missing [trackIndex] falls
/// back to treating [positionMs] as already relative (matches the old
/// pre-track behaviour rather than seeking somewhere invented); a position
/// before the track's own start clamps to 0 instead of going negative.
int trackRelativeMs({
  required int positionMs,
  required int? trackIndex,
  required List<AudiobookTrack> tracks,
  required bool folderBased,
}) {
  if (!folderBased || trackIndex == null) return positionMs;
  if (trackIndex < 0 || trackIndex >= tracks.length) return positionMs;
  final relative = positionMs - tracks[trackIndex].cumulativeStartMs;
  return relative < 0 ? 0 : relative;
}

/// Track-relative → book-wide; the inverse of [trackRelativeMs], with the
/// same pass-through for a missing or out-of-range [trackIndex].
int absoluteMs({
  required int trackPositionMs,
  required int? trackIndex,
  required List<AudiobookTrack> tracks,
  required bool folderBased,
}) {
  if (!folderBased) return trackPositionMs;
  if (trackIndex == null || trackIndex < 0 || trackIndex >= tracks.length) {
    return trackPositionMs;
  }
  return tracks[trackIndex].cumulativeStartMs + trackPositionMs;
}

/// 0-100, rounded to one decimal like Grimmory's own player — its
/// READING/READ thresholds (0.1 / 99.5) are on this scale, so a 0-1
/// fraction here left every book UNREAD until 10% in and never READ.
/// Clamped, since a position can briefly overshoot a duration that was
/// itself only estimated from the file headers.
double audiobookPercentage({
  required int positionMs,
  required int totalDurationMs,
}) {
  if (totalDurationMs <= 0) return 0;
  final raw = (positionMs / totalDurationMs * 100).clamp(0.0, 100.0);
  return (raw * 10).round() / 10;
}
