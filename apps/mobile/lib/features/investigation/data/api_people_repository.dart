import 'dart:convert';
import 'dart:typed_data';

import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/events/data/api_event_repository.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/people_repository.dart';

/// Reads and changes saved people and face clusters on the server.
class ApiPeopleRepository implements PeopleRepository {
  /// Creates the repository over [client]; [baseUrl] reads the server address.
  ApiPeopleRepository(this.client, this.baseUrl);

  /// The generated API.
  final api.SurveillanceApi client;

  /// Reads the server address.
  final String Function() baseUrl;

  /// The page size used to read whole lists.
  static const pageSize = 200;

  /// The colour of a person the server gave none.
  static const defaultColor = 0xFF0090FF;

  /// Reads a JSON object.
  static Map<String, Object?> objectOf(Object? value) =>
      value is Map ? value.cast<String, Object?>() : const <String, Object?>{};

  /// Reads the time of a JSON field as local time.
  static DateTime timeOf(Object? value) =>
      DateTime.tryParse(value as String? ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  /// Writes [color] as #RRGGBB.
  static String colorHex(int color) => '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Returns the picture of the face sample [sampleId].
  MediaSource crop(String sampleId) => NetworkMedia(
    '${baseUrl()}/api/v1/people/samples/$sampleId/crop',
    cacheKey: 'sample-$sampleId',
  );

  /// Converts a face sample as the server writes it in JSON to the app's [FaceSample].
  FaceSample sampleOf(Map<String, Object?> json) => FaceSample(
    id: json['uuid']! as String,
    source: json['source'] == 'upload' ? SampleSource.upload : SampleSource.event,
    quality: (json['quality'] as num?)?.toDouble() ?? 0,
    seenAt: timeOf(json['seen_at']),
    cameraName: json['camera_name'] as String?,
    viewName: json['view_name'] as String?,
    eventId: json['event_uuid'] as String?,
    crop: crop(json['uuid']! as String),
  );

  /// Converts a sighting as the server writes it in JSON to the app's [Sighting].
  Sighting sightingOf(Map<String, Object?> json) => Sighting(
    eventId: json['event_uuid'] as String?,
    sampleId: json['sample_uuid']! as String,
    cameraName: json['camera_name'] as String?,
    viewName: json['view_name'] as String?,
    seenAt: timeOf(json['seen_at']),
    confidence: (json['confidence'] as num?)?.toDouble(),
    crop: crop(json['sample_uuid']! as String),
  );

  /// Converts a person as the server writes it in JSON to the app's [Person].
  Person personOf(Map<String, Object?> json) => Person(
    id: json['uuid']! as String,
    name: json['name'] as String? ?? '',
    notes: json['notes'] as String?,
    color: ApiEventRepository.colorOf(json['color']) ?? defaultColor,
    samples: [
      for (final item in json['samples'] as List<Object?>? ?? const <Object?>[])
        sampleOf(objectOf(item)),
    ],
    lastSeenAt: json['last_seen_at'] == null ? null : timeOf(json['last_seen_at']),
    sightings: [
      for (final item in json['sightings'] as List<Object?>? ?? const <Object?>[])
        sightingOf(objectOf(item)),
    ],
  );

  /// Converts a cluster as the server writes it in JSON to the app's [FaceCluster].
  FaceCluster clusterOf(Map<String, Object?> json) => FaceCluster(
    id: json['uuid']! as String,
    number: (json['number'] as num?)?.toInt() ?? 0,
    label: json['label'] as String? ?? '',
    seenCount: (json['seen_count'] as num?)?.toInt() ?? 0,
    firstSeenAt: timeOf(json['first_seen_at']),
    lastSeenAt: timeOf(json['last_seen_at']),
    samples: [
      for (final item in json['samples'] as List<Object?>? ?? const <Object?>[])
        sampleOf(objectOf(item)),
    ],
    sightings: [
      for (final item in json['sightings'] as List<Object?>? ?? const <Object?>[])
        sightingOf(objectOf(item)),
    ],
  );

  /// Returns the image type of [bytes] from its first bytes.
  static String mimeOf(Uint8List bytes) {
    if (bytes.length > 4 && bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
    if (bytes.length > 12 && bytes[8] == 0x57 && bytes[9] == 0x45) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Future<List<Person>> people(String organisationId) async {
    final result = <Person>[];
    for (var page = 1; ; page++) {
      final list = await guarded(() => client.people.listPeople(page: page, pageSize: pageSize));
      final json = list.toJson();
      final items = json['items'] as List<Object?>? ?? const <Object?>[];
      result.addAll([for (final item in items) personOf(objectOf(item))]);
      if (items.isEmpty || result.length >= list.total) return result;
    }
  }

  @override
  Future<Person> person(String personId) async =>
      personOf((await guarded(() => client.people.getPerson(uuid: personId))).toJson());

  @override
  Future<Person> createPerson(String organisationId, {required String name, String? notes}) async {
    final body = api.PersonCreate.fromJson({'name': name, 'notes': ?notes});
    return personOf((await guarded(() => client.people.createPerson(body: body))).toJson());
  }

  @override
  Future<Person> updatePerson(Person person) async {
    final body = api.PersonUpdate.fromJson({
      'name': person.name,
      'notes': person.notes,
      'color': colorHex(person.color),
    });
    return personOf(
      (await guarded(() => client.people.updatePerson(uuid: person.id, body: body))).toJson(),
    );
  }

  @override
  Future<void> deletePerson(String personId) =>
      guarded(() => client.people.deletePerson(uuid: personId));

  @override
  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos) async {
    final body = api.PhotoUploadRequest.fromJson({
      'photos': [
        for (var i = 0; i < photos.length; i++)
          {
            'name': 'photo-${i + 1}',
            'data': 'data:${mimeOf(photos[i])};base64,${base64Encode(photos[i])}',
          },
      ],
    });
    final result = await guarded(() => client.people.addPhotos(uuid: personId, body: body));
    final json = result.toJson();
    return PhotoResult(
      added: (json['added'] as List<Object?>? ?? const <Object?>[]).length,
      rejected: [
        for (final item in json['rejected'] as List<Object?>? ?? const <Object?>[])
          objectOf(item)['name'] as String? ?? '',
      ],
    );
  }

  @override
  Future<void> deleteSample(String personId, String sampleId) =>
      guarded(() => client.people.deleteSample(uuid: personId, sampleUuid: sampleId));

  @override
  Future<void> mergePerson(String personId, String intoId) async {
    final body = api.PersonMerge.fromJson({'into': intoId});
    await guarded(() => client.people.mergePerson(uuid: personId, body: body));
  }

  @override
  Future<List<FaceCluster>> clusters(String organisationId) async {
    final result = <FaceCluster>[];
    for (var page = 1; ; page++) {
      final list = await guarded(() => client.people.listClusters(page: page, pageSize: pageSize));
      final items = list.toJson()['items'] as List<Object?>? ?? const <Object?>[];
      result.addAll([for (final item in items) clusterOf(objectOf(item))]);
      if (items.isEmpty || result.length >= list.total) return result;
    }
  }

  @override
  Future<FaceCluster> cluster(String clusterId) async {
    for (final cluster in await clusters('')) {
      if (cluster.id == clusterId) return cluster;
    }
    throw const ApiFailure(FailureKind.notFound, 'cluster');
  }

  @override
  Future<Person> nameCluster(String clusterId, {String? personId, String? name}) async {
    final body = api.ClusterName.fromJson({
      'person': ?personId,
      if (personId == null) 'name': ?name,
    });
    return personOf(
      (await guarded(() => client.people.nameCluster(uuid: clusterId, body: body))).toJson(),
    );
  }

  @override
  Future<void> deleteCluster(String clusterId) =>
      guarded(() => client.people.deleteCluster(uuid: clusterId));
}
