import 'dart:typed_data';

import 'package:smart_surveillance/features/investigation/domain/models.dart';
/// The source of saved people and unnamed face clusters.
abstract interface class PeopleRepository {
  /// Returns the saved people of the organisation [organisationId].
  Future<List<Person>> people(String organisationId);

  /// Returns the person [personId].
  Future<Person> person(String personId);

  /// Creates a person called [name], with optional [notes], and returns it.
  Future<Person> createPerson(String organisationId, {required String name, String? notes});

  /// Saves the changes to [person] and returns the stored person.
  Future<Person> updatePerson(Person person);

  /// Deletes the person [personId].
  Future<void> deletePerson(String personId);

  /// Adds [photos] as face samples of the person [personId] and reports how many were accepted.
  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos);

  /// Deletes the face sample [sampleId] of the person [personId].
  Future<void> deleteSample(String personId, String sampleId);

  /// Merges the person [personId] into the person [intoId].
  Future<void> mergePerson(String personId, String intoId);

  /// Returns the face clusters of the organisation [organisationId].
  Future<List<FaceCluster>> clusters(String organisationId);

  /// Returns the face cluster [clusterId].
  Future<FaceCluster> cluster(String clusterId);

  /// Names the cluster [clusterId] as the person [personId] or as a new person called [name].
  Future<Person> nameCluster(String clusterId, {String? personId, String? name});

  /// Deletes the face cluster [clusterId].
  Future<void> deleteCluster(String clusterId);
}
