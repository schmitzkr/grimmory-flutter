import 'package:flutter_test/flutter_test.dart';

import 'package:grimmory/core/api/models.dart';
import 'package:grimmory/features/player/track_timeline.dart';

const _tracks = [
  AudiobookTrack(
    index: 0,
    fileName: '1.mp3',
    title: 'One',
    durationMs: 1000,
    cumulativeStartMs: 0,
  ),
  AudiobookTrack(
    index: 1,
    fileName: '2.mp3',
    title: 'Two',
    durationMs: 2000,
    cumulativeStartMs: 1000,
  ),
  AudiobookTrack(
    index: 2,
    fileName: '3.mp3',
    title: 'Three',
    durationMs: 3000,
    cumulativeStartMs: 3000,
  ),
];

void main() {
  group('trackRelativeMs', () {
    test('subtracts the track start for a folder-based book', () {
      expect(
        trackRelativeMs(
          positionMs: 3500,
          trackIndex: 2,
          tracks: _tracks,
          folderBased: true,
        ),
        500,
      );
    });

    test('passes through for a single-stream book or unknown track', () {
      expect(
        trackRelativeMs(
          positionMs: 3500,
          trackIndex: 2,
          tracks: _tracks,
          folderBased: false,
        ),
        3500,
      );
      expect(
        trackRelativeMs(
          positionMs: 3500,
          trackIndex: null,
          tracks: _tracks,
          folderBased: true,
        ),
        3500,
      );
      expect(
        trackRelativeMs(
          positionMs: 3500,
          trackIndex: 7,
          tracks: _tracks,
          folderBased: true,
        ),
        3500,
      );
    });

    test('clamps a position before the track start to 0', () {
      expect(
        trackRelativeMs(
          positionMs: 900,
          trackIndex: 1,
          tracks: _tracks,
          folderBased: true,
        ),
        0,
      );
    });
  });

  group('absoluteMs', () {
    test('adds the track start for a folder-based book', () {
      expect(
        absoluteMs(
          trackPositionMs: 500,
          trackIndex: 2,
          tracks: _tracks,
          folderBased: true,
        ),
        3500,
      );
    });

    test('is the inverse of trackRelativeMs', () {
      for (var index = 0; index < _tracks.length; index++) {
        final relative = trackRelativeMs(
          positionMs: 3200,
          trackIndex: index,
          tracks: _tracks,
          folderBased: true,
        );
        final absolute = absoluteMs(
          trackPositionMs: relative,
          trackIndex: index,
          tracks: _tracks,
          folderBased: true,
        );
        // Only exact for the track that actually contains 3200ms; earlier
        // tracks clamp at their own start, which is the documented intent.
        expect(absolute, index == 2 ? 3200 : _tracks[index].cumulativeStartMs);
      }
    });

    test('passes through for a single-stream book or unknown track', () {
      expect(
        absoluteMs(
          trackPositionMs: 500,
          trackIndex: 2,
          tracks: _tracks,
          folderBased: false,
        ),
        500,
      );
      expect(
        absoluteMs(
          trackPositionMs: 500,
          trackIndex: null,
          tracks: _tracks,
          folderBased: true,
        ),
        500,
      );
      expect(
        absoluteMs(
          trackPositionMs: 500,
          trackIndex: -1,
          tracks: _tracks,
          folderBased: true,
        ),
        500,
      );
    });
  });

  group('audiobookPercentage', () {
    test('is on a 0-100 scale rounded to one decimal', () {
      expect(
        audiobookPercentage(positionMs: 1234, totalDurationMs: 10000),
        12.3,
      );
      expect(audiobookPercentage(positionMs: 1, totalDurationMs: 3), 0.0);
      expect(audiobookPercentage(positionMs: 5, totalDurationMs: 6), 83.3);
    });

    test('clamps overshoot and guards a zero duration', () {
      expect(
        audiobookPercentage(positionMs: 11000, totalDurationMs: 10000),
        100.0,
      );
      expect(audiobookPercentage(positionMs: 500, totalDurationMs: 0), 0.0);
    });
  });
}
