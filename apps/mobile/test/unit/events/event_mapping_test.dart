import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/features/events/data/api_event_repository.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

/// An event as the server writes it, with every optional part filled in.
Map<String, Object?> eventJson() => {
  'uuid': 'event-1',
  'camera_uuid': 'camera-1',
  'camera_name': 'Front door',
  'view_uuid': 'view-1',
  'kind': 'line_crossing',
  'source': 'analytics',
  'label': 'person',
  'alert': true,
  'acknowledged_at': '2026-03-14T10:05:00Z',
  'started_at': '2026-03-14T10:00:00Z',
  'ended_at': '2026-03-14T10:00:12Z',
  'ongoing': false,
  'has_snapshot': true,
  'has_clip': true,
  'details': {
    'view_name': 'Entrance',
    'zone_name': 'Porch',
    'line_name': 'Gate line',
    'direction': 'in',
    'count': 3,
    'profile': 'people',
    'plate_status': 'read',
    'boxes': [
      {
        'object': 7,
        'label': 'person',
        'box': [0.1, 0.2, 0.4, 0.8],
        'at': 1.5,
      },
      {
        'object': 8,
        'label': 'person',
        'box': [0.9, 0.9, 0.6, 0.5],
      },
      {
        'object': 9,
        'label': 'person',
        'box': [0.1, 0.2, 0.3],
      },
    ],
    'plates': [
      {'text': 'A000AA', 'display': 'A 000 AA', 'format': 'sample', 'score': 0.41, 'reads': 2},
      {'text': 'B111BB', 'score': 0.93},
      {'display': 'no text'},
    ],
  },
  'face': {
    'status': 'known',
    'person_uuid': 'person-1',
    'person_name': 'Sample Person',
    'person_color': '#0090FF',
    'cluster_uuid': 'cluster-1',
    'cluster_label': 'Cluster 1',
    'confidence': 0.87,
    'has_crop': true,
    'sample_uuid': 'sample-1',
  },
};

/// Runs the event mapping tests.
void main() {
  group('eventOf', () {
    final event = ApiEventRepository.eventOf(eventJson(), 'site-1');

    test('reads the identity and flags', () {
      expect(event.id, 'event-1');
      expect(event.siteId, 'site-1');
      expect(event.cameraId, 'camera-1');
      expect(event.cameraName, 'Front door');
      expect(event.viewId, 'view-1');
      expect(event.viewName, 'Entrance');
      expect(event.kind, EventKind.lineCrossing);
      expect(event.source, EventSource.analytics);
      expect(event.label, 'person');
      expect(event.alert, isTrue);
      expect(event.acknowledged, isTrue);
      expect(event.hasSnapshot, isTrue);
      expect(event.hasClip, isTrue);
      expect(event.ongoing, isFalse);
    });

    test('reads the times', () {
      expect(event.startedAt.toUtc(), DateTime.utc(2026, 3, 14, 10));
      expect(event.endedAt!.toUtc(), DateTime.utc(2026, 3, 14, 10, 0, 12));
    });

    test('reads the analytics details', () {
      expect(event.zoneName, 'Porch');
      expect(event.lineName, 'Gate line');
      expect(event.direction, 'in');
      expect(event.count, 3);
      expect(event.profile, 'people');
      expect(event.plateStatus, 'read');
    });

    test('reads normalised boxes and orders their corners', () {
      expect(event.boxes, hasLength(2));
      expect(event.boxes.first.box, const Rect.fromLTRB(0.1, 0.2, 0.4, 0.8));
      expect(event.boxes.first.object, 7);
      expect(event.boxes.first.at, 1.5);
      expect(event.boxes.last.box, const Rect.fromLTRB(0.6, 0.5, 0.9, 0.9));
      expect(event.boxes.last.at, 0);
    });

    test('reads plates and sorts them by score', () {
      expect(event.plates.map((p) => p.text), ['B111BB', 'A000AA']);
      expect(event.plates.first.display, 'B111BB');
      expect(event.plates.first.reads, 1);
      expect(event.plates.last.display, 'A 000 AA');
      expect(event.plates.last.format, 'sample');
      expect(event.plates.last.reads, 2);
    });

    test('reads the face', () {
      final face = event.face!;
      expect(face.status, FaceStatus.known);
      expect(face.personId, 'person-1');
      expect(face.personName, 'Sample Person');
      expect(face.personColor, 0xFF0090FF);
      expect(face.clusterId, 'cluster-1');
      expect(face.confidence, 0.87);
      expect(face.sampleId, 'sample-1');
    });

    test('defaults a sparse event', () {
      final sparse = ApiEventRepository.eventOf({
        'uuid': 'event-2',
        'camera_uuid': 'camera-2',
        'kind': 'unheard_of',
        'source': 'camera',
        'started_at': '2026-03-14T11:00:00Z',
      }, 'site-1');
      expect(sparse.kind, EventKind.motion);
      expect(sparse.source, EventSource.camera);
      expect(sparse.cameraName, '');
      expect(sparse.alert, isFalse);
      expect(sparse.acknowledged, isFalse);
      expect(sparse.endedAt, isNull);
      expect(sparse.boxes, isEmpty);
      expect(sparse.plates, isEmpty);
      expect(sparse.face, isNull);
    });

    test('hides the sample of a face without a crop', () {
      final json = eventJson()
        ..['face'] = {'status': 'unknown', 'sample_uuid': 's', 'has_crop': false};
      final face = ApiEventRepository.eventOf(json, 'site-1').face!;
      expect(face.status, FaceStatus.unknown);
      expect(face.sampleId, isNull);
    });
  });

  group('colorOf', () {
    test('reads #RRGGBB as an opaque colour', () {
      expect(ApiEventRepository.colorOf('#0090FF'), 0xFF0090FF);
    });

    test('rejects other shapes', () {
      expect(ApiEventRepository.colorOf('0090FF'), isNull);
      expect(ApiEventRepository.colorOf('#09F'), isNull);
      expect(ApiEventRepository.colorOf('#GG90FF'), isNull);
      expect(ApiEventRepository.colorOf(null), isNull);
    });
  });

  group('event kinds', () {
    test('round trip through the wire name', () {
      for (final kind in EventKind.values) {
        expect(ApiEventRepository.kindOf(ApiEventRepository.wireKind(kind)), kind);
      }
    });

    test('use snake case on the wire', () {
      expect(ApiEventRepository.wireKind(EventKind.lineCrossing), 'line_crossing');
      expect(ApiEventRepository.wireKind(EventKind.faceUnknown), 'face_unknown');
      expect(ApiEventRepository.wireKind(EventKind.motion), 'motion');
      expect(ApiEventRepository.kindOf('object_left'), EventKind.objectLeft);
      expect(ApiEventRepository.kindOf('nothing'), isNull);
    });
  });

  group('helpers', () {
    test('iso writes UTC', () {
      expect(ApiEventRepository.iso(DateTime.utc(2026, 3, 14, 10)), '2026-03-14T10:00:00.000Z');
      expect(ApiEventRepository.iso(null), isNull);
    });

    test('text drops empty and non-string values', () {
      expect(ApiEventRepository.text(''), isNull);
      expect(ApiEventRepository.text(5), isNull);
      expect(ApiEventRepository.text('a'), 'a');
    });
  });
}
