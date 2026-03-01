import 'dart:convert';
import 'dart:typed_data';

import '../models/animal.dart';
import '../models/handling_flag.dart';
import '../widgets/animal_grid.dart';
import 'api_client.dart';

class AnimalsService {
  AnimalsService(this._client);

  final ApiClient _client;

  Future<List<Animal>> getAnimals({
    required String species,
    required AnimalFilter filter,
    String? search,
    String? token,
  }) async {
    final normalizedSpecies =
        species.trim().toLowerCase() == 'cat' ? 'Cat' : 'Dog';
    final filterValue = switch (filter) {
      AnimalFilter.all => 'All',
      AnimalFilter.careRequired => 'CareRequired',
      AnimalFilter.inTreatment => 'InTreatment',
    };

    final query = StringBuffer(
      '/api/animals?species=$normalizedSpecies&filter=$filterValue',
    );
    if (search != null && search.trim().isNotEmpty) {
      query.write('&search=${Uri.encodeQueryComponent(search.trim())}');
    }

    final data = await _client.getAny(query.toString(), token: token);
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(_mapListItemToAnimal)
        .toList(growable: false);
  }

  Future<Animal> getAnimalById(String id, {String? token}) async {
    final data = await _client.getJson('/api/animals/$id', token: token);
    return _mapDetailsToAnimal(data);
  }

  Future<String> createAnimal({
    required Animal animal,
    required String token,
  }) async {
    final res = await _client.postAny(
      '/api/animals',
      token: token,
      body: _toCreatePayload(animal),
    );
    return res?.toString() ?? '';
  }

  Future<void> updateAnimal({
    required Animal animal,
    required String token,
  }) async {
    await _client.putJson(
      '/api/animals/${animal.id}',
      token: token,
      body: _toUpdatePayload(animal),
    );
  }

  Future<void> deleteAnimal({
    required String id,
    required String token,
  }) async {
    await _client.deleteJson('/api/animals/$id', token: token);
  }

  Animal _mapListItemToAnimal(Map<String, dynamic> json) {
    final handlingFlags = _asInt(json['handlingFlags']);
    final requiresCare = _asBool(json['requiresCare']);
    final inTreatment = _asBool(json['inTreatment']);

    return Animal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      species: _speciesToUi(json['species']),
      personality: '',
      isDangerous: requiresCare,
      isInTreatment: inTreatment,
      photoBytes: _pictureToBytes(json['picture']),
      age: '',
      breed: '',
      gender: '',
      description: '',
      history: '',
      zone: '',
      flags: _flagsFromMask(handlingFlags),
    );
  }

  Animal _mapDetailsToAnimal(Map<String, dynamic> json) {
    final species = _speciesToUi(json['species']);
    final dogZone = json['dogZone'];
    final catZone = json['catZone'];
    final zoneLabel = species == 'cat'
        ? _catZoneToUi(catZone)
        : _dogZoneToUi(dogZone);
    return Animal(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      species: species,
      personality: '',
      isDangerous: _asBool(json['requiresCare']),
      isInTreatment: _asBool(json['inTreatment']),
      photoBytes: _pictureToBytes(json['picture']),
      age: _intToString(json['age']),
      breed: json['breed']?.toString() ?? '',
      gender: _genderToUi(json['gender']),
      description: json['handlingNotes']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      flags: _flagsFromMask(_asInt(json['handlingFlags'])),
      zone: zoneLabel,
      kennel: '',
    );
  }

  Map<String, dynamic> _toCreatePayload(Animal animal) {
    final species = _speciesToApi(animal.species);
    return {
      'name': animal.name.trim(),
      'species': species,
      'gender': _genderToApi(animal.gender),
      'handlingLevel': _handlingLevelToApi(animal),
      'handlingFlags': _flagsToMask(animal.flags),
      'requiresCare': animal.isDangerous,
      'inTreatment': animal.isInTreatment,
      'dogZone': species == 0 ? _dogZoneToApi(animal.zone) : null,
      'catZone': species == 1 ? _catZoneToApi(animal.zone) : null,
      'picture': _pictureToApi(animal.photoBytes),
      'age': _ageToApi(animal.age),
      'breed': _nullableText(animal.breed),
      'history': _nullableText(animal.history),
      'handlingNotes': _nullableText(animal.description),
    };
  }

  Map<String, dynamic> _toUpdatePayload(Animal animal) {
    final species = _speciesToApi(animal.species);
    return {
      'name': animal.name.trim(),
      'gender': _genderToApi(animal.gender),
      'handlingLevel': _handlingLevelToApi(animal),
      'handlingFlags': _flagsToMask(animal.flags),
      'requiresCare': animal.isDangerous,
      'inTreatment': animal.isInTreatment,
      'dogZone': species == 0 ? _dogZoneToApi(animal.zone) : null,
      'catZone': species == 1 ? _catZoneToApi(animal.zone) : null,
      'picture': _pictureToApi(animal.photoBytes),
      'age': _ageToApi(animal.age),
      'breed': _nullableText(animal.breed),
      'history': _nullableText(animal.history),
      'handlingNotes': _nullableText(animal.description),
    };
  }

  int _speciesToApi(String species) {
    return species.trim().toLowerCase() == 'cat' ? 1 : 0;
  }

  String _speciesToUi(dynamic raw) {
    if (raw is String) return raw.trim().toLowerCase() == 'cat' ? 'cat' : 'dog';
    return _asInt(raw) == 1 ? 'cat' : 'dog';
  }

  String _genderToUi(dynamic raw) {
    if (raw is String) return raw.trim().toLowerCase() == 'female' ? 'Female' : 'Male';
    return _asInt(raw) == 0 ? 'Female' : 'Male';
  }

  int _genderToApi(String gender) {
    return gender.trim().toLowerCase() == 'female' ? 0 : 1;
  }

  String _dogZoneToUi(dynamic raw) {
    final value = raw is String ? raw.trim() : _asInt(raw).toString();
    return switch (value.toUpperCase()) {
      'A' || '1' => 'Zone A',
      'B' || '2' => 'Zone B',
      'C' || '3' => 'Zone C',
      _ => '',
    };
  }

  String _catZoneToUi(dynamic raw) {
    if (raw is String) {
      final lowered = raw.toLowerCase();
      if (lowered == 'acattery') return 'A cattery';
      if (lowered == 'adultcattery') return 'Adult side cattery';
      if (lowered == 'poolcattery') return 'Pool side cattery';
    }
    return switch (_asInt(raw)) {
      0 => 'A cattery',
      1 => 'Adult side cattery',
      2 => 'Pool side cattery',
      _ => '',
    };
  }

  int? _dogZoneToApi(String zone) {
    final normalized = zone.trim().toLowerCase();
    if (normalized.endsWith('a')) return 1;
    if (normalized.endsWith('b')) return 2;
    if (normalized.endsWith('c')) return 3;
    return null;
  }

  int? _catZoneToApi(String zone) {
    final normalized = zone.trim().toLowerCase();
    if (normalized.startsWith('a cattery')) return 0;
    if (normalized.startsWith('adult side cattery')) return 1;
    if (normalized.startsWith('pool side cattery')) return 2;
    return null;
  }

  String _intToString(dynamic value) {
    final n = _asIntOrNull(value);
    return n?.toString() ?? '';
  }

  int? _ageToApi(String age) {
    final trimmed = age.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _pictureToApi(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return null;
    return base64Encode(bytes);
  }

  Uint8List? _pictureToBytes(dynamic raw) {
    if (raw is! String) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;

    final marker = 'base64,';
    final markerIndex = value.indexOf(marker);
    if (markerIndex >= 0) {
      value = value.substring(markerIndex + marker.length);
    }

    try {
      return base64Decode(value);
    } on FormatException {
      return null;
    }
  }

  int _handlingLevelToApi(Animal animal) {
    if (animal.isDangerous) return 1;
    return 0;
  }

  int _flagsToMask(Set<HandlingFlag> flags) {
    var mask = 0;
    if (flags.contains(HandlingFlag.doubleLeash)) mask |= 1;
    if (flags.contains(HandlingFlag.muzzle)) mask |= 2;
    if (flags.contains(HandlingFlag.experiencedHandler)) mask |= 4;
    if (flags.contains(HandlingFlag.noPark)) mask |= 8;
    if (flags.contains(HandlingFlag.quarantine)) mask |= 16;
    return mask;
  }

  Set<HandlingFlag> _flagsFromMask(int mask) {
    final flags = <HandlingFlag>{};
    if ((mask & 1) != 0) flags.add(HandlingFlag.doubleLeash);
    if ((mask & 2) != 0) flags.add(HandlingFlag.muzzle);
    if ((mask & 4) != 0) flags.add(HandlingFlag.experiencedHandler);
    if ((mask & 8) != 0) flags.add(HandlingFlag.noPark);
    if ((mask & 16) != 0) flags.add(HandlingFlag.quarantine);
    return flags;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int? _asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
