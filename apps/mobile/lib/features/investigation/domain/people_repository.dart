import 'dart:typed_data';

import 'package:smart_surveillance/features/investigation/domain/models.dart';
abstract interface class PeopleRepository {
  Future<List<Person>> people(String organisationId);

  Future<Person> person(String personId);

  Future<Person> createPerson(String organisationId, {required String name, String? notes});

  Future<Person> updatePerson(Person person);

  Future<void> deletePerson(String personId);

  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos);

  Future<void> deleteSample(String personId, String sampleId);

  Future<void> mergePerson(String personId, String intoId);

  Future<List<FaceCluster>> clusters(String organisationId);

  Future<FaceCluster> cluster(String clusterId);

  Future<Person> nameCluster(String clusterId, {String? personId, String? name});

  Future<void> deleteCluster(String clusterId);
}
