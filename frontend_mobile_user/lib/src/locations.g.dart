// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) {
  return LatLng(
      lat: (json['lat'] as num)?.toDouble(),
      lng: (json['lng'] as num)?.toDouble());
}

Map<String, dynamic> _$LatLngToJson(LatLng instance) =>
    <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

Region _$RegionFromJson(Map<String, dynamic> json) {
  return Region(
      coords: json['coords'] == null
          ? null
          : LatLng.fromJson(json['coords'] as Map<String, dynamic>),
      id: json['id'] as String,
      name: json['name'] as String,
      zoom: (json['zoom'] as num)?.toDouble());
}

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
      'coords': instance.coords,
      'id': instance.id,
      'name': instance.name,
      'zoom': instance.zoom
    };

DrugStore _$DrugStoreFromJson(Map<String, dynamic> json) {
  return DrugStore(
      address: json['address'] as String,
      id: json['id'] as String,
      image: json['image'] as String,
      lat: (json['lat'] as num)?.toDouble(),
      lng: (json['lng'] as num)?.toDouble(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      region: json['region'] as String,
      numberFaceMask: json['numberFaceMask'] as int);
}

Map<String, dynamic> _$DrugStoreToJson(DrugStore instance) => <String, dynamic>{
      'address': instance.address,
      'id': instance.id,
      'image': instance.image,
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
      'phone': instance.phone,
      'region': instance.region,
      'numberFaceMask': instance.numberFaceMask
    };

Locations _$LocationsFromJson(Map<String, dynamic> json) {
  return Locations(
      drugStores: (json['drugStores'] as List)
          ?.map((e) =>
              e == null ? null : DrugStore.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      regions: (json['regions'] as List)
          ?.map((e) =>
              e == null ? null : Region.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'drugStores': instance.drugStores,
      'regions': instance.regions
    };
