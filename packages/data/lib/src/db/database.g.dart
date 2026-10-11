// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WaterSourcesTable extends WaterSources
    with TableInfo<$WaterSourcesTable, WaterSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMMeta = const VerificationMeta(
    'locationAccuracyM',
  );
  @override
  late final GeneratedColumn<double> locationAccuracyM =
      GeneratedColumn<double>(
        'location_accuracy_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _householdsServedMeta = const VerificationMeta(
    'householdsServed',
  );
  @override
  late final GeneratedColumn<int> householdsServed = GeneratedColumn<int>(
    'households_served',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionalStatusMeta = const VerificationMeta(
    'functionalStatus',
  );
  @override
  late final GeneratedColumn<String> functionalStatus = GeneratedColumn<String>(
    'functional_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('functional'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtDeviceMeta = const VerificationMeta(
    'updatedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtDevice =
      GeneratedColumn<DateTime>(
        'updated_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    villageId,
    code,
    name,
    sourceType,
    lat,
    lon,
    locationAccuracyM,
    householdsServed,
    functionalStatus,
    isActive,
    version,
    createdBy,
    createdAtDevice,
    updatedAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('location_accuracy_m')) {
      context.handle(
        _locationAccuracyMMeta,
        locationAccuracyM.isAcceptableOrUnknown(
          data['location_accuracy_m']!,
          _locationAccuracyMMeta,
        ),
      );
    }
    if (data.containsKey('households_served')) {
      context.handle(
        _householdsServedMeta,
        householdsServed.isAcceptableOrUnknown(
          data['households_served']!,
          _householdsServedMeta,
        ),
      );
    }
    if (data.containsKey('functional_status')) {
      context.handle(
        _functionalStatusMeta,
        functionalStatus.isAcceptableOrUnknown(
          data['functional_status']!,
          _functionalStatusMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('updated_at_device')) {
      context.handle(
        _updatedAtDeviceMeta,
        updatedAtDevice.isAcceptableOrUnknown(
          data['updated_at_device']!,
          _updatedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {villageId, code},
  ];
  @override
  WaterSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterSourceRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      villageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      locationAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy_m'],
      ),
      householdsServed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}households_served'],
      ),
      functionalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}functional_status'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      updatedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_device'],
      )!,
    );
  }

  @override
  $WaterSourcesTable createAlias(String alias) {
    return $WaterSourcesTable(attachedDatabase, alias);
  }
}

class WaterSourceRow extends DataClass implements Insertable<WaterSourceRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String villageId;
  final String code;
  final String? name;
  final String sourceType;
  final double? lat;
  final double? lon;
  final double? locationAccuracyM;
  final int? householdsServed;
  final String functionalStatus;
  final bool isActive;
  final int version;
  final String? createdBy;
  final DateTime createdAtDevice;
  final DateTime updatedAtDevice;
  const WaterSourceRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.villageId,
    required this.code,
    this.name,
    required this.sourceType,
    this.lat,
    this.lon,
    this.locationAccuracyM,
    this.householdsServed,
    required this.functionalStatus,
    required this.isActive,
    required this.version,
    this.createdBy,
    required this.createdAtDevice,
    required this.updatedAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['village_id'] = Variable<String>(villageId);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || locationAccuracyM != null) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM);
    }
    if (!nullToAbsent || householdsServed != null) {
      map['households_served'] = Variable<int>(householdsServed);
    }
    map['functional_status'] = Variable<String>(functionalStatus);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    map['updated_at_device'] = Variable<DateTime>(updatedAtDevice);
    return map;
  }

  WaterSourcesCompanion toCompanion(bool nullToAbsent) {
    return WaterSourcesCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      villageId: Value(villageId),
      code: Value(code),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sourceType: Value(sourceType),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      locationAccuracyM: locationAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracyM),
      householdsServed: householdsServed == null && nullToAbsent
          ? const Value.absent()
          : Value(householdsServed),
      functionalStatus: Value(functionalStatus),
      isActive: Value(isActive),
      version: Value(version),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAtDevice: Value(createdAtDevice),
      updatedAtDevice: Value(updatedAtDevice),
    );
  }

  factory WaterSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterSourceRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      villageId: serializer.fromJson<String>(json['village_id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String?>(json['name']),
      sourceType: serializer.fromJson<String>(json['source_type']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      locationAccuracyM: serializer.fromJson<double?>(
        json['location_accuracy_m'],
      ),
      householdsServed: serializer.fromJson<int?>(json['households_served']),
      functionalStatus: serializer.fromJson<String>(json['functional_status']),
      isActive: serializer.fromJson<bool>(json['is_active']),
      version: serializer.fromJson<int>(json['version']),
      createdBy: serializer.fromJson<String?>(json['created_by']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      updatedAtDevice: serializer.fromJson<DateTime>(json['updated_at_device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'village_id': serializer.toJson<String>(villageId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String?>(name),
      'source_type': serializer.toJson<String>(sourceType),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'location_accuracy_m': serializer.toJson<double?>(locationAccuracyM),
      'households_served': serializer.toJson<int?>(householdsServed),
      'functional_status': serializer.toJson<String>(functionalStatus),
      'is_active': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'created_by': serializer.toJson<String?>(createdBy),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'updated_at_device': serializer.toJson<DateTime>(updatedAtDevice),
    };
  }

  WaterSourceRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? villageId,
    String? code,
    Value<String?> name = const Value.absent(),
    String? sourceType,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<double?> locationAccuracyM = const Value.absent(),
    Value<int?> householdsServed = const Value.absent(),
    String? functionalStatus,
    bool? isActive,
    int? version,
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAtDevice,
    DateTime? updatedAtDevice,
  }) => WaterSourceRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    villageId: villageId ?? this.villageId,
    code: code ?? this.code,
    name: name.present ? name.value : this.name,
    sourceType: sourceType ?? this.sourceType,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    locationAccuracyM: locationAccuracyM.present
        ? locationAccuracyM.value
        : this.locationAccuracyM,
    householdsServed: householdsServed.present
        ? householdsServed.value
        : this.householdsServed,
    functionalStatus: functionalStatus ?? this.functionalStatus,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    updatedAtDevice: updatedAtDevice ?? this.updatedAtDevice,
  );
  WaterSourceRow copyWithCompanion(WaterSourcesCompanion data) {
    return WaterSourceRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      locationAccuracyM: data.locationAccuracyM.present
          ? data.locationAccuracyM.value
          : this.locationAccuracyM,
      householdsServed: data.householdsServed.present
          ? data.householdsServed.value
          : this.householdsServed,
      functionalStatus: data.functionalStatus.present
          ? data.functionalStatus.value
          : this.functionalStatus,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      updatedAtDevice: data.updatedAtDevice.present
          ? data.updatedAtDevice.value
          : this.updatedAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterSourceRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('householdsServed: $householdsServed, ')
          ..write('functionalStatus: $functionalStatus, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('updatedAtDevice: $updatedAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    villageId,
    code,
    name,
    sourceType,
    lat,
    lon,
    locationAccuracyM,
    householdsServed,
    functionalStatus,
    isActive,
    version,
    createdBy,
    createdAtDevice,
    updatedAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterSourceRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.villageId == this.villageId &&
          other.code == this.code &&
          other.name == this.name &&
          other.sourceType == this.sourceType &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.locationAccuracyM == this.locationAccuracyM &&
          other.householdsServed == this.householdsServed &&
          other.functionalStatus == this.functionalStatus &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.createdBy == this.createdBy &&
          other.createdAtDevice == this.createdAtDevice &&
          other.updatedAtDevice == this.updatedAtDevice);
}

class WaterSourcesCompanion extends UpdateCompanion<WaterSourceRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> villageId;
  final Value<String> code;
  final Value<String?> name;
  final Value<String> sourceType;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<double?> locationAccuracyM;
  final Value<int?> householdsServed;
  final Value<String> functionalStatus;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<String?> createdBy;
  final Value<DateTime> createdAtDevice;
  final Value<DateTime> updatedAtDevice;
  final Value<int> rowid;
  const WaterSourcesCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.villageId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.householdsServed = const Value.absent(),
    this.functionalStatus = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.updatedAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterSourcesCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String villageId,
    required String code,
    this.name = const Value.absent(),
    required String sourceType,
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.householdsServed = const Value.absent(),
    this.functionalStatus = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAtDevice,
    required DateTime updatedAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       villageId = Value(villageId),
       code = Value(code),
       sourceType = Value(sourceType),
       createdAtDevice = Value(createdAtDevice),
       updatedAtDevice = Value(updatedAtDevice);
  static Insertable<WaterSourceRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? villageId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? sourceType,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? locationAccuracyM,
    Expression<int>? householdsServed,
    Expression<String>? functionalStatus,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAtDevice,
    Expression<DateTime>? updatedAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (villageId != null) 'village_id': villageId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (sourceType != null) 'source_type': sourceType,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (locationAccuracyM != null) 'location_accuracy_m': locationAccuracyM,
      if (householdsServed != null) 'households_served': householdsServed,
      if (functionalStatus != null) 'functional_status': functionalStatus,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (updatedAtDevice != null) 'updated_at_device': updatedAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterSourcesCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? villageId,
    Value<String>? code,
    Value<String?>? name,
    Value<String>? sourceType,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<double?>? locationAccuracyM,
    Value<int?>? householdsServed,
    Value<String>? functionalStatus,
    Value<bool>? isActive,
    Value<int>? version,
    Value<String?>? createdBy,
    Value<DateTime>? createdAtDevice,
    Value<DateTime>? updatedAtDevice,
    Value<int>? rowid,
  }) {
    return WaterSourcesCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      code: code ?? this.code,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      locationAccuracyM: locationAccuracyM ?? this.locationAccuracyM,
      householdsServed: householdsServed ?? this.householdsServed,
      functionalStatus: functionalStatus ?? this.functionalStatus,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdBy: createdBy ?? this.createdBy,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      updatedAtDevice: updatedAtDevice ?? this.updatedAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (locationAccuracyM.present) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM.value);
    }
    if (householdsServed.present) {
      map['households_served'] = Variable<int>(householdsServed.value);
    }
    if (functionalStatus.present) {
      map['functional_status'] = Variable<String>(functionalStatus.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (updatedAtDevice.present) {
      map['updated_at_device'] = Variable<DateTime>(updatedAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterSourcesCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('householdsServed: $householdsServed, ')
          ..write('functionalStatus: $functionalStatus, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('updatedAtDevice: $updatedAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestSessionsTable extends TestSessions
    with TableInfo<$TestSessionsTable, TestSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES water_sources (id)',
    ),
  );
  static const VerificationMeta _calibrationIdMeta = const VerificationMeta(
    'calibrationId',
  );
  @override
  late final GeneratedColumn<String> calibrationId = GeneratedColumn<String>(
    'calibration_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testerProfileIdMeta = const VerificationMeta(
    'testerProfileId',
  );
  @override
  late final GeneratedColumn<String> testerProfileId = GeneratedColumn<String>(
    'tester_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceStandardIdMeta =
      const VerificationMeta('referenceStandardId');
  @override
  late final GeneratedColumn<String> referenceStandardId =
      GeneratedColumn<String>(
        'reference_standard_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _calibratedMeta = const VerificationMeta(
    'calibrated',
  );
  @override
  late final GeneratedColumn<bool> calibrated = GeneratedColumn<bool>(
    'calibrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("calibrated" IN (0, 1))',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMMeta = const VerificationMeta(
    'locationAccuracyM',
  );
  @override
  late final GeneratedColumn<double> locationAccuracyM =
      GeneratedColumn<double>(
        'location_accuracy_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _distanceFromSourceMMeta =
      const VerificationMeta('distanceFromSourceM');
  @override
  late final GeneratedColumn<double> distanceFromSourceM =
      GeneratedColumn<double>(
        'distance_from_source_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _distanceOverrideReasonMeta =
      const VerificationMeta('distanceOverrideReason');
  @override
  late final GeneratedColumn<String> distanceOverrideReason =
      GeneratedColumn<String>(
        'distance_override_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testedAtDeviceMeta = const VerificationMeta(
    'testedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> testedAtDevice =
      GeneratedColumn<DateTime>(
        'tested_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    calibrationId,
    testerProfileId,
    referenceStandardId,
    calibrated,
    lat,
    lon,
    locationAccuracyM,
    distanceFromSourceM,
    distanceOverrideReason,
    notes,
    testedAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('calibration_id')) {
      context.handle(
        _calibrationIdMeta,
        calibrationId.isAcceptableOrUnknown(
          data['calibration_id']!,
          _calibrationIdMeta,
        ),
      );
    }
    if (data.containsKey('tester_profile_id')) {
      context.handle(
        _testerProfileIdMeta,
        testerProfileId.isAcceptableOrUnknown(
          data['tester_profile_id']!,
          _testerProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('reference_standard_id')) {
      context.handle(
        _referenceStandardIdMeta,
        referenceStandardId.isAcceptableOrUnknown(
          data['reference_standard_id']!,
          _referenceStandardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceStandardIdMeta);
    }
    if (data.containsKey('calibrated')) {
      context.handle(
        _calibratedMeta,
        calibrated.isAcceptableOrUnknown(data['calibrated']!, _calibratedMeta),
      );
    } else if (isInserting) {
      context.missing(_calibratedMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('location_accuracy_m')) {
      context.handle(
        _locationAccuracyMMeta,
        locationAccuracyM.isAcceptableOrUnknown(
          data['location_accuracy_m']!,
          _locationAccuracyMMeta,
        ),
      );
    }
    if (data.containsKey('distance_from_source_m')) {
      context.handle(
        _distanceFromSourceMMeta,
        distanceFromSourceM.isAcceptableOrUnknown(
          data['distance_from_source_m']!,
          _distanceFromSourceMMeta,
        ),
      );
    }
    if (data.containsKey('distance_override_reason')) {
      context.handle(
        _distanceOverrideReasonMeta,
        distanceOverrideReason.isAcceptableOrUnknown(
          data['distance_override_reason']!,
          _distanceOverrideReasonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tested_at_device')) {
      context.handle(
        _testedAtDeviceMeta,
        testedAtDevice.isAcceptableOrUnknown(
          data['tested_at_device']!,
          _testedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_testedAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestSessionRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      calibrationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibration_id'],
      ),
      testerProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tester_profile_id'],
      ),
      referenceStandardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_standard_id'],
      )!,
      calibrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}calibrated'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      locationAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy_m'],
      ),
      distanceFromSourceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_from_source_m'],
      ),
      distanceOverrideReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_override_reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      testedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tested_at_device'],
      )!,
    );
  }

  @override
  $TestSessionsTable createAlias(String alias) {
    return $TestSessionsTable(attachedDatabase, alias);
  }
}

class TestSessionRow extends DataClass implements Insertable<TestSessionRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String sourceId;
  final String? calibrationId;
  final String? testerProfileId;
  final String referenceStandardId;
  final bool calibrated;
  final double? lat;
  final double? lon;
  final double? locationAccuracyM;
  final double? distanceFromSourceM;
  final String? distanceOverrideReason;
  final String? notes;
  final DateTime testedAtDevice;
  const TestSessionRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.sourceId,
    this.calibrationId,
    this.testerProfileId,
    required this.referenceStandardId,
    required this.calibrated,
    this.lat,
    this.lon,
    this.locationAccuracyM,
    this.distanceFromSourceM,
    this.distanceOverrideReason,
    this.notes,
    required this.testedAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || calibrationId != null) {
      map['calibration_id'] = Variable<String>(calibrationId);
    }
    if (!nullToAbsent || testerProfileId != null) {
      map['tester_profile_id'] = Variable<String>(testerProfileId);
    }
    map['reference_standard_id'] = Variable<String>(referenceStandardId);
    map['calibrated'] = Variable<bool>(calibrated);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || locationAccuracyM != null) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM);
    }
    if (!nullToAbsent || distanceFromSourceM != null) {
      map['distance_from_source_m'] = Variable<double>(distanceFromSourceM);
    }
    if (!nullToAbsent || distanceOverrideReason != null) {
      map['distance_override_reason'] = Variable<String>(
        distanceOverrideReason,
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tested_at_device'] = Variable<DateTime>(testedAtDevice);
    return map;
  }

  TestSessionsCompanion toCompanion(bool nullToAbsent) {
    return TestSessionsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      sourceId: Value(sourceId),
      calibrationId: calibrationId == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationId),
      testerProfileId: testerProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(testerProfileId),
      referenceStandardId: Value(referenceStandardId),
      calibrated: Value(calibrated),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      locationAccuracyM: locationAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracyM),
      distanceFromSourceM: distanceFromSourceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceFromSourceM),
      distanceOverrideReason: distanceOverrideReason == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceOverrideReason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      testedAtDevice: Value(testedAtDevice),
    );
  }

  factory TestSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestSessionRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['source_id']),
      calibrationId: serializer.fromJson<String?>(json['calibration_id']),
      testerProfileId: serializer.fromJson<String?>(json['tester_profile_id']),
      referenceStandardId: serializer.fromJson<String>(
        json['reference_standard_id'],
      ),
      calibrated: serializer.fromJson<bool>(json['calibrated']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      locationAccuracyM: serializer.fromJson<double?>(
        json['location_accuracy_m'],
      ),
      distanceFromSourceM: serializer.fromJson<double?>(
        json['distance_from_source_m'],
      ),
      distanceOverrideReason: serializer.fromJson<String?>(
        json['distance_override_reason'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      testedAtDevice: serializer.fromJson<DateTime>(json['tested_at_device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'source_id': serializer.toJson<String>(sourceId),
      'calibration_id': serializer.toJson<String?>(calibrationId),
      'tester_profile_id': serializer.toJson<String?>(testerProfileId),
      'reference_standard_id': serializer.toJson<String>(referenceStandardId),
      'calibrated': serializer.toJson<bool>(calibrated),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'location_accuracy_m': serializer.toJson<double?>(locationAccuracyM),
      'distance_from_source_m': serializer.toJson<double?>(distanceFromSourceM),
      'distance_override_reason': serializer.toJson<String?>(
        distanceOverrideReason,
      ),
      'notes': serializer.toJson<String?>(notes),
      'tested_at_device': serializer.toJson<DateTime>(testedAtDevice),
    };
  }

  TestSessionRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? sourceId,
    Value<String?> calibrationId = const Value.absent(),
    Value<String?> testerProfileId = const Value.absent(),
    String? referenceStandardId,
    bool? calibrated,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<double?> locationAccuracyM = const Value.absent(),
    Value<double?> distanceFromSourceM = const Value.absent(),
    Value<String?> distanceOverrideReason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? testedAtDevice,
  }) => TestSessionRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    calibrationId: calibrationId.present
        ? calibrationId.value
        : this.calibrationId,
    testerProfileId: testerProfileId.present
        ? testerProfileId.value
        : this.testerProfileId,
    referenceStandardId: referenceStandardId ?? this.referenceStandardId,
    calibrated: calibrated ?? this.calibrated,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    locationAccuracyM: locationAccuracyM.present
        ? locationAccuracyM.value
        : this.locationAccuracyM,
    distanceFromSourceM: distanceFromSourceM.present
        ? distanceFromSourceM.value
        : this.distanceFromSourceM,
    distanceOverrideReason: distanceOverrideReason.present
        ? distanceOverrideReason.value
        : this.distanceOverrideReason,
    notes: notes.present ? notes.value : this.notes,
    testedAtDevice: testedAtDevice ?? this.testedAtDevice,
  );
  TestSessionRow copyWithCompanion(TestSessionsCompanion data) {
    return TestSessionRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      calibrationId: data.calibrationId.present
          ? data.calibrationId.value
          : this.calibrationId,
      testerProfileId: data.testerProfileId.present
          ? data.testerProfileId.value
          : this.testerProfileId,
      referenceStandardId: data.referenceStandardId.present
          ? data.referenceStandardId.value
          : this.referenceStandardId,
      calibrated: data.calibrated.present
          ? data.calibrated.value
          : this.calibrated,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      locationAccuracyM: data.locationAccuracyM.present
          ? data.locationAccuracyM.value
          : this.locationAccuracyM,
      distanceFromSourceM: data.distanceFromSourceM.present
          ? data.distanceFromSourceM.value
          : this.distanceFromSourceM,
      distanceOverrideReason: data.distanceOverrideReason.present
          ? data.distanceOverrideReason.value
          : this.distanceOverrideReason,
      notes: data.notes.present ? data.notes.value : this.notes,
      testedAtDevice: data.testedAtDevice.present
          ? data.testedAtDevice.value
          : this.testedAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('calibrationId: $calibrationId, ')
          ..write('testerProfileId: $testerProfileId, ')
          ..write('referenceStandardId: $referenceStandardId, ')
          ..write('calibrated: $calibrated, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('distanceFromSourceM: $distanceFromSourceM, ')
          ..write('distanceOverrideReason: $distanceOverrideReason, ')
          ..write('notes: $notes, ')
          ..write('testedAtDevice: $testedAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    calibrationId,
    testerProfileId,
    referenceStandardId,
    calibrated,
    lat,
    lon,
    locationAccuracyM,
    distanceFromSourceM,
    distanceOverrideReason,
    notes,
    testedAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestSessionRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.calibrationId == this.calibrationId &&
          other.testerProfileId == this.testerProfileId &&
          other.referenceStandardId == this.referenceStandardId &&
          other.calibrated == this.calibrated &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.locationAccuracyM == this.locationAccuracyM &&
          other.distanceFromSourceM == this.distanceFromSourceM &&
          other.distanceOverrideReason == this.distanceOverrideReason &&
          other.notes == this.notes &&
          other.testedAtDevice == this.testedAtDevice);
}

class TestSessionsCompanion extends UpdateCompanion<TestSessionRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String?> calibrationId;
  final Value<String?> testerProfileId;
  final Value<String> referenceStandardId;
  final Value<bool> calibrated;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<double?> locationAccuracyM;
  final Value<double?> distanceFromSourceM;
  final Value<String?> distanceOverrideReason;
  final Value<String?> notes;
  final Value<DateTime> testedAtDevice;
  final Value<int> rowid;
  const TestSessionsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.calibrationId = const Value.absent(),
    this.testerProfileId = const Value.absent(),
    this.referenceStandardId = const Value.absent(),
    this.calibrated = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.distanceFromSourceM = const Value.absent(),
    this.distanceOverrideReason = const Value.absent(),
    this.notes = const Value.absent(),
    this.testedAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestSessionsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String sourceId,
    this.calibrationId = const Value.absent(),
    this.testerProfileId = const Value.absent(),
    required String referenceStandardId,
    required bool calibrated,
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.distanceFromSourceM = const Value.absent(),
    this.distanceOverrideReason = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime testedAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       referenceStandardId = Value(referenceStandardId),
       calibrated = Value(calibrated),
       testedAtDevice = Value(testedAtDevice);
  static Insertable<TestSessionRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? calibrationId,
    Expression<String>? testerProfileId,
    Expression<String>? referenceStandardId,
    Expression<bool>? calibrated,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? locationAccuracyM,
    Expression<double>? distanceFromSourceM,
    Expression<String>? distanceOverrideReason,
    Expression<String>? notes,
    Expression<DateTime>? testedAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (calibrationId != null) 'calibration_id': calibrationId,
      if (testerProfileId != null) 'tester_profile_id': testerProfileId,
      if (referenceStandardId != null)
        'reference_standard_id': referenceStandardId,
      if (calibrated != null) 'calibrated': calibrated,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (locationAccuracyM != null) 'location_accuracy_m': locationAccuracyM,
      if (distanceFromSourceM != null)
        'distance_from_source_m': distanceFromSourceM,
      if (distanceOverrideReason != null)
        'distance_override_reason': distanceOverrideReason,
      if (notes != null) 'notes': notes,
      if (testedAtDevice != null) 'tested_at_device': testedAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestSessionsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? sourceId,
    Value<String?>? calibrationId,
    Value<String?>? testerProfileId,
    Value<String>? referenceStandardId,
    Value<bool>? calibrated,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<double?>? locationAccuracyM,
    Value<double?>? distanceFromSourceM,
    Value<String?>? distanceOverrideReason,
    Value<String?>? notes,
    Value<DateTime>? testedAtDevice,
    Value<int>? rowid,
  }) {
    return TestSessionsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      calibrationId: calibrationId ?? this.calibrationId,
      testerProfileId: testerProfileId ?? this.testerProfileId,
      referenceStandardId: referenceStandardId ?? this.referenceStandardId,
      calibrated: calibrated ?? this.calibrated,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      locationAccuracyM: locationAccuracyM ?? this.locationAccuracyM,
      distanceFromSourceM: distanceFromSourceM ?? this.distanceFromSourceM,
      distanceOverrideReason:
          distanceOverrideReason ?? this.distanceOverrideReason,
      notes: notes ?? this.notes,
      testedAtDevice: testedAtDevice ?? this.testedAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (calibrationId.present) {
      map['calibration_id'] = Variable<String>(calibrationId.value);
    }
    if (testerProfileId.present) {
      map['tester_profile_id'] = Variable<String>(testerProfileId.value);
    }
    if (referenceStandardId.present) {
      map['reference_standard_id'] = Variable<String>(
        referenceStandardId.value,
      );
    }
    if (calibrated.present) {
      map['calibrated'] = Variable<bool>(calibrated.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (locationAccuracyM.present) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM.value);
    }
    if (distanceFromSourceM.present) {
      map['distance_from_source_m'] = Variable<double>(
        distanceFromSourceM.value,
      );
    }
    if (distanceOverrideReason.present) {
      map['distance_override_reason'] = Variable<String>(
        distanceOverrideReason.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (testedAtDevice.present) {
      map['tested_at_device'] = Variable<DateTime>(testedAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestSessionsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('calibrationId: $calibrationId, ')
          ..write('testerProfileId: $testerProfileId, ')
          ..write('referenceStandardId: $referenceStandardId, ')
          ..write('calibrated: $calibrated, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('distanceFromSourceM: $distanceFromSourceM, ')
          ..write('distanceOverrideReason: $distanceOverrideReason, ')
          ..write('notes: $notes, ')
          ..write('testedAtDevice: $testedAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_sessions (id)',
    ),
  );
  static const VerificationMeta _overallMeta = const VerificationMeta(
    'overall',
  );
  @override
  late final GeneratedColumn<String> overall = GeneratedColumn<String>(
    'overall',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _standardIdMeta = const VerificationMeta(
    'standardId',
  );
  @override
  late final GeneratedColumn<String> standardId = GeneratedColumn<String>(
    'standard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedByMeta = const VerificationMeta(
    'computedBy',
  );
  @override
  late final GeneratedColumn<String> computedBy = GeneratedColumn<String>(
    'computed_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('device'),
  );
  static const VerificationMeta _retestOfMeta = const VerificationMeta(
    'retestOf',
  );
  @override
  late final GeneratedColumn<String> retestOf = GeneratedColumn<String>(
    'retest_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amendmentOfMeta = const VerificationMeta(
    'amendmentOf',
  );
  @override
  late final GeneratedColumn<String> amendmentOf = GeneratedColumn<String>(
    'amendment_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amendmentReasonMeta = const VerificationMeta(
    'amendmentReason',
  );
  @override
  late final GeneratedColumn<String> amendmentReason = GeneratedColumn<String>(
    'amendment_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<String> flags = GeneratedColumn<String>(
    'flags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _limitationCodeMeta = const VerificationMeta(
    'limitationCode',
  );
  @override
  late final GeneratedColumn<String> limitationCode = GeneratedColumn<String>(
    'limitation_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    id,
    sessionId,
    overall,
    standardId,
    computedBy,
    retestOf,
    amendmentOf,
    amendmentReason,
    flags,
    limitationCode,
    createdAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('overall')) {
      context.handle(
        _overallMeta,
        overall.isAcceptableOrUnknown(data['overall']!, _overallMeta),
      );
    } else if (isInserting) {
      context.missing(_overallMeta);
    }
    if (data.containsKey('standard_id')) {
      context.handle(
        _standardIdMeta,
        standardId.isAcceptableOrUnknown(data['standard_id']!, _standardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_standardIdMeta);
    }
    if (data.containsKey('computed_by')) {
      context.handle(
        _computedByMeta,
        computedBy.isAcceptableOrUnknown(data['computed_by']!, _computedByMeta),
      );
    }
    if (data.containsKey('retest_of')) {
      context.handle(
        _retestOfMeta,
        retestOf.isAcceptableOrUnknown(data['retest_of']!, _retestOfMeta),
      );
    }
    if (data.containsKey('amendment_of')) {
      context.handle(
        _amendmentOfMeta,
        amendmentOf.isAcceptableOrUnknown(
          data['amendment_of']!,
          _amendmentOfMeta,
        ),
      );
    }
    if (data.containsKey('amendment_reason')) {
      context.handle(
        _amendmentReasonMeta,
        amendmentReason.isAcceptableOrUnknown(
          data['amendment_reason']!,
          _amendmentReasonMeta,
        ),
      );
    }
    if (data.containsKey('flags')) {
      context.handle(
        _flagsMeta,
        flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta),
      );
    }
    if (data.containsKey('limitation_code')) {
      context.handle(
        _limitationCodeMeta,
        limitationCode.isAcceptableOrUnknown(
          data['limitation_code']!,
          _limitationCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResultRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      overall: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall'],
      )!,
      standardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}standard_id'],
      )!,
      computedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computed_by'],
      )!,
      retestOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retest_of'],
      ),
      amendmentOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amendment_of'],
      ),
      amendmentReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amendment_reason'],
      ),
      flags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flags'],
      )!,
      limitationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limitation_code'],
      ),
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResultRow extends DataClass implements Insertable<TestResultRow> {
  final int? serverSeq;
  final String id;
  final String sessionId;
  final String overall;
  final String standardId;
  final String computedBy;
  final String? retestOf;
  final String? amendmentOf;
  final String? amendmentReason;

  /// JSON list, e.g. `["uncalibrated", "baseline_jump:tds"]`.
  final String flags;
  final String? limitationCode;
  final DateTime createdAtDevice;
  const TestResultRow({
    this.serverSeq,
    required this.id,
    required this.sessionId,
    required this.overall,
    required this.standardId,
    required this.computedBy,
    this.retestOf,
    this.amendmentOf,
    this.amendmentReason,
    required this.flags,
    this.limitationCode,
    required this.createdAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['overall'] = Variable<String>(overall);
    map['standard_id'] = Variable<String>(standardId);
    map['computed_by'] = Variable<String>(computedBy);
    if (!nullToAbsent || retestOf != null) {
      map['retest_of'] = Variable<String>(retestOf);
    }
    if (!nullToAbsent || amendmentOf != null) {
      map['amendment_of'] = Variable<String>(amendmentOf);
    }
    if (!nullToAbsent || amendmentReason != null) {
      map['amendment_reason'] = Variable<String>(amendmentReason);
    }
    map['flags'] = Variable<String>(flags);
    if (!nullToAbsent || limitationCode != null) {
      map['limitation_code'] = Variable<String>(limitationCode);
    }
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      sessionId: Value(sessionId),
      overall: Value(overall),
      standardId: Value(standardId),
      computedBy: Value(computedBy),
      retestOf: retestOf == null && nullToAbsent
          ? const Value.absent()
          : Value(retestOf),
      amendmentOf: amendmentOf == null && nullToAbsent
          ? const Value.absent()
          : Value(amendmentOf),
      amendmentReason: amendmentReason == null && nullToAbsent
          ? const Value.absent()
          : Value(amendmentReason),
      flags: Value(flags),
      limitationCode: limitationCode == null && nullToAbsent
          ? const Value.absent()
          : Value(limitationCode),
      createdAtDevice: Value(createdAtDevice),
    );
  }

  factory TestResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResultRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      overall: serializer.fromJson<String>(json['overall']),
      standardId: serializer.fromJson<String>(json['standard_id']),
      computedBy: serializer.fromJson<String>(json['computed_by']),
      retestOf: serializer.fromJson<String?>(json['retest_of']),
      amendmentOf: serializer.fromJson<String?>(json['amendment_of']),
      amendmentReason: serializer.fromJson<String?>(json['amendment_reason']),
      flags: serializer.fromJson<String>(json['flags']),
      limitationCode: serializer.fromJson<String?>(json['limitation_code']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'overall': serializer.toJson<String>(overall),
      'standard_id': serializer.toJson<String>(standardId),
      'computed_by': serializer.toJson<String>(computedBy),
      'retest_of': serializer.toJson<String?>(retestOf),
      'amendment_of': serializer.toJson<String?>(amendmentOf),
      'amendment_reason': serializer.toJson<String?>(amendmentReason),
      'flags': serializer.toJson<String>(flags),
      'limitation_code': serializer.toJson<String?>(limitationCode),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
    };
  }

  TestResultRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? sessionId,
    String? overall,
    String? standardId,
    String? computedBy,
    Value<String?> retestOf = const Value.absent(),
    Value<String?> amendmentOf = const Value.absent(),
    Value<String?> amendmentReason = const Value.absent(),
    String? flags,
    Value<String?> limitationCode = const Value.absent(),
    DateTime? createdAtDevice,
  }) => TestResultRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    overall: overall ?? this.overall,
    standardId: standardId ?? this.standardId,
    computedBy: computedBy ?? this.computedBy,
    retestOf: retestOf.present ? retestOf.value : this.retestOf,
    amendmentOf: amendmentOf.present ? amendmentOf.value : this.amendmentOf,
    amendmentReason: amendmentReason.present
        ? amendmentReason.value
        : this.amendmentReason,
    flags: flags ?? this.flags,
    limitationCode: limitationCode.present
        ? limitationCode.value
        : this.limitationCode,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
  );
  TestResultRow copyWithCompanion(TestResultsCompanion data) {
    return TestResultRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      overall: data.overall.present ? data.overall.value : this.overall,
      standardId: data.standardId.present
          ? data.standardId.value
          : this.standardId,
      computedBy: data.computedBy.present
          ? data.computedBy.value
          : this.computedBy,
      retestOf: data.retestOf.present ? data.retestOf.value : this.retestOf,
      amendmentOf: data.amendmentOf.present
          ? data.amendmentOf.value
          : this.amendmentOf,
      amendmentReason: data.amendmentReason.present
          ? data.amendmentReason.value
          : this.amendmentReason,
      flags: data.flags.present ? data.flags.value : this.flags,
      limitationCode: data.limitationCode.present
          ? data.limitationCode.value
          : this.limitationCode,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResultRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('overall: $overall, ')
          ..write('standardId: $standardId, ')
          ..write('computedBy: $computedBy, ')
          ..write('retestOf: $retestOf, ')
          ..write('amendmentOf: $amendmentOf, ')
          ..write('amendmentReason: $amendmentReason, ')
          ..write('flags: $flags, ')
          ..write('limitationCode: $limitationCode, ')
          ..write('createdAtDevice: $createdAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    id,
    sessionId,
    overall,
    standardId,
    computedBy,
    retestOf,
    amendmentOf,
    amendmentReason,
    flags,
    limitationCode,
    createdAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResultRow &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.overall == this.overall &&
          other.standardId == this.standardId &&
          other.computedBy == this.computedBy &&
          other.retestOf == this.retestOf &&
          other.amendmentOf == this.amendmentOf &&
          other.amendmentReason == this.amendmentReason &&
          other.flags == this.flags &&
          other.limitationCode == this.limitationCode &&
          other.createdAtDevice == this.createdAtDevice);
}

class TestResultsCompanion extends UpdateCompanion<TestResultRow> {
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> overall;
  final Value<String> standardId;
  final Value<String> computedBy;
  final Value<String?> retestOf;
  final Value<String?> amendmentOf;
  final Value<String?> amendmentReason;
  final Value<String> flags;
  final Value<String?> limitationCode;
  final Value<DateTime> createdAtDevice;
  final Value<int> rowid;
  const TestResultsCompanion({
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.overall = const Value.absent(),
    this.standardId = const Value.absent(),
    this.computedBy = const Value.absent(),
    this.retestOf = const Value.absent(),
    this.amendmentOf = const Value.absent(),
    this.amendmentReason = const Value.absent(),
    this.flags = const Value.absent(),
    this.limitationCode = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestResultsCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String id,
    required String sessionId,
    required String overall,
    required String standardId,
    this.computedBy = const Value.absent(),
    this.retestOf = const Value.absent(),
    this.amendmentOf = const Value.absent(),
    this.amendmentReason = const Value.absent(),
    this.flags = const Value.absent(),
    this.limitationCode = const Value.absent(),
    required DateTime createdAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       overall = Value(overall),
       standardId = Value(standardId),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<TestResultRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? overall,
    Expression<String>? standardId,
    Expression<String>? computedBy,
    Expression<String>? retestOf,
    Expression<String>? amendmentOf,
    Expression<String>? amendmentReason,
    Expression<String>? flags,
    Expression<String>? limitationCode,
    Expression<DateTime>? createdAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (overall != null) 'overall': overall,
      if (standardId != null) 'standard_id': standardId,
      if (computedBy != null) 'computed_by': computedBy,
      if (retestOf != null) 'retest_of': retestOf,
      if (amendmentOf != null) 'amendment_of': amendmentOf,
      if (amendmentReason != null) 'amendment_reason': amendmentReason,
      if (flags != null) 'flags': flags,
      if (limitationCode != null) 'limitation_code': limitationCode,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestResultsCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? overall,
    Value<String>? standardId,
    Value<String>? computedBy,
    Value<String?>? retestOf,
    Value<String?>? amendmentOf,
    Value<String?>? amendmentReason,
    Value<String>? flags,
    Value<String?>? limitationCode,
    Value<DateTime>? createdAtDevice,
    Value<int>? rowid,
  }) {
    return TestResultsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      overall: overall ?? this.overall,
      standardId: standardId ?? this.standardId,
      computedBy: computedBy ?? this.computedBy,
      retestOf: retestOf ?? this.retestOf,
      amendmentOf: amendmentOf ?? this.amendmentOf,
      amendmentReason: amendmentReason ?? this.amendmentReason,
      flags: flags ?? this.flags,
      limitationCode: limitationCode ?? this.limitationCode,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (overall.present) {
      map['overall'] = Variable<String>(overall.value);
    }
    if (standardId.present) {
      map['standard_id'] = Variable<String>(standardId.value);
    }
    if (computedBy.present) {
      map['computed_by'] = Variable<String>(computedBy.value);
    }
    if (retestOf.present) {
      map['retest_of'] = Variable<String>(retestOf.value);
    }
    if (amendmentOf.present) {
      map['amendment_of'] = Variable<String>(amendmentOf.value);
    }
    if (amendmentReason.present) {
      map['amendment_reason'] = Variable<String>(amendmentReason.value);
    }
    if (flags.present) {
      map['flags'] = Variable<String>(flags.value);
    }
    if (limitationCode.present) {
      map['limitation_code'] = Variable<String>(limitationCode.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('overall: $overall, ')
          ..write('standardId: $standardId, ')
          ..write('computedBy: $computedBy, ')
          ..write('retestOf: $retestOf, ')
          ..write('amendmentOf: $amendmentOf, ')
          ..write('amendmentReason: $amendmentReason, ')
          ..write('flags: $flags, ')
          ..write('limitationCode: $limitationCode, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings
    with TableInfo<$ReadingsTable, ReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_sessions (id)',
    ),
  );
  static const VerificationMeta _resultIdMeta = const VerificationMeta(
    'resultId',
  );
  @override
  late final GeneratedColumn<String> resultId = GeneratedColumn<String>(
    'result_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_results (id)',
    ),
  );
  static const VerificationMeta _parameterCodeMeta = const VerificationMeta(
    'parameterCode',
  );
  @override
  late final GeneratedColumn<String> parameterCode = GeneratedColumn<String>(
    'parameter_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedMeta = const VerificationMeta(
    'detected',
  );
  @override
  late final GeneratedColumn<bool> detected = GeneratedColumn<bool>(
    'detected',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("detected" IN (0, 1))',
    ),
  );
  static const VerificationMeta _acceptableMeta = const VerificationMeta(
    'acceptable',
  );
  @override
  late final GeneratedColumn<bool> acceptable = GeneratedColumn<bool>(
    'acceptable',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("acceptable" IN (0, 1))',
    ),
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDerivedMeta = const VerificationMeta(
    'isDerived',
  );
  @override
  late final GeneratedColumn<bool> isDerived = GeneratedColumn<bool>(
    'is_derived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_derived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceDeviceMeta = const VerificationMeta(
    'sourceDevice',
  );
  @override
  late final GeneratedColumn<String> sourceDevice = GeneratedColumn<String>(
    'source_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    id,
    sessionId,
    resultId,
    parameterCode,
    value,
    detected,
    acceptable,
    valueText,
    unit,
    result,
    isDerived,
    sourceDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('result_id')) {
      context.handle(
        _resultIdMeta,
        resultId.isAcceptableOrUnknown(data['result_id']!, _resultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resultIdMeta);
    }
    if (data.containsKey('parameter_code')) {
      context.handle(
        _parameterCodeMeta,
        parameterCode.isAcceptableOrUnknown(
          data['parameter_code']!,
          _parameterCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parameterCodeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('detected')) {
      context.handle(
        _detectedMeta,
        detected.isAcceptableOrUnknown(data['detected']!, _detectedMeta),
      );
    }
    if (data.containsKey('acceptable')) {
      context.handle(
        _acceptableMeta,
        acceptable.isAcceptableOrUnknown(data['acceptable']!, _acceptableMeta),
      );
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('is_derived')) {
      context.handle(
        _isDerivedMeta,
        isDerived.isAcceptableOrUnknown(data['is_derived']!, _isDerivedMeta),
      );
    }
    if (data.containsKey('source_device')) {
      context.handle(
        _sourceDeviceMeta,
        sourceDevice.isAcceptableOrUnknown(
          data['source_device']!,
          _sourceDeviceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      resultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_id'],
      )!,
      parameterCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameter_code'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      detected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}detected'],
      ),
      acceptable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}acceptable'],
      ),
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      isDerived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_derived'],
      )!,
      sourceDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_device'],
      ),
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class ReadingRow extends DataClass implements Insertable<ReadingRow> {
  final int? serverSeq;
  final String id;
  final String sessionId;
  final String resultId;
  final String parameterCode;
  final String? value;
  final bool? detected;
  final bool? acceptable;
  final String? valueText;
  final String? unit;
  final String result;
  final bool isDerived;
  final String? sourceDevice;
  const ReadingRow({
    this.serverSeq,
    required this.id,
    required this.sessionId,
    required this.resultId,
    required this.parameterCode,
    this.value,
    this.detected,
    this.acceptable,
    this.valueText,
    this.unit,
    required this.result,
    required this.isDerived,
    this.sourceDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['result_id'] = Variable<String>(resultId);
    map['parameter_code'] = Variable<String>(parameterCode);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || detected != null) {
      map['detected'] = Variable<bool>(detected);
    }
    if (!nullToAbsent || acceptable != null) {
      map['acceptable'] = Variable<bool>(acceptable);
    }
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['result'] = Variable<String>(result);
    map['is_derived'] = Variable<bool>(isDerived);
    if (!nullToAbsent || sourceDevice != null) {
      map['source_device'] = Variable<String>(sourceDevice);
    }
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      sessionId: Value(sessionId),
      resultId: Value(resultId),
      parameterCode: Value(parameterCode),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      detected: detected == null && nullToAbsent
          ? const Value.absent()
          : Value(detected),
      acceptable: acceptable == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptable),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      result: Value(result),
      isDerived: Value(isDerived),
      sourceDevice: sourceDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDevice),
    );
  }

  factory ReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      resultId: serializer.fromJson<String>(json['result_id']),
      parameterCode: serializer.fromJson<String>(json['parameter_code']),
      value: serializer.fromJson<String?>(json['value']),
      detected: serializer.fromJson<bool?>(json['detected']),
      acceptable: serializer.fromJson<bool?>(json['acceptable']),
      valueText: serializer.fromJson<String?>(json['value_text']),
      unit: serializer.fromJson<String?>(json['unit']),
      result: serializer.fromJson<String>(json['result']),
      isDerived: serializer.fromJson<bool>(json['is_derived']),
      sourceDevice: serializer.fromJson<String?>(json['source_device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'result_id': serializer.toJson<String>(resultId),
      'parameter_code': serializer.toJson<String>(parameterCode),
      'value': serializer.toJson<String?>(value),
      'detected': serializer.toJson<bool?>(detected),
      'acceptable': serializer.toJson<bool?>(acceptable),
      'value_text': serializer.toJson<String?>(valueText),
      'unit': serializer.toJson<String?>(unit),
      'result': serializer.toJson<String>(result),
      'is_derived': serializer.toJson<bool>(isDerived),
      'source_device': serializer.toJson<String?>(sourceDevice),
    };
  }

  ReadingRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? sessionId,
    String? resultId,
    String? parameterCode,
    Value<String?> value = const Value.absent(),
    Value<bool?> detected = const Value.absent(),
    Value<bool?> acceptable = const Value.absent(),
    Value<String?> valueText = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    String? result,
    bool? isDerived,
    Value<String?> sourceDevice = const Value.absent(),
  }) => ReadingRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    resultId: resultId ?? this.resultId,
    parameterCode: parameterCode ?? this.parameterCode,
    value: value.present ? value.value : this.value,
    detected: detected.present ? detected.value : this.detected,
    acceptable: acceptable.present ? acceptable.value : this.acceptable,
    valueText: valueText.present ? valueText.value : this.valueText,
    unit: unit.present ? unit.value : this.unit,
    result: result ?? this.result,
    isDerived: isDerived ?? this.isDerived,
    sourceDevice: sourceDevice.present ? sourceDevice.value : this.sourceDevice,
  );
  ReadingRow copyWithCompanion(ReadingsCompanion data) {
    return ReadingRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      resultId: data.resultId.present ? data.resultId.value : this.resultId,
      parameterCode: data.parameterCode.present
          ? data.parameterCode.value
          : this.parameterCode,
      value: data.value.present ? data.value.value : this.value,
      detected: data.detected.present ? data.detected.value : this.detected,
      acceptable: data.acceptable.present
          ? data.acceptable.value
          : this.acceptable,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
      unit: data.unit.present ? data.unit.value : this.unit,
      result: data.result.present ? data.result.value : this.result,
      isDerived: data.isDerived.present ? data.isDerived.value : this.isDerived,
      sourceDevice: data.sourceDevice.present
          ? data.sourceDevice.value
          : this.sourceDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('resultId: $resultId, ')
          ..write('parameterCode: $parameterCode, ')
          ..write('value: $value, ')
          ..write('detected: $detected, ')
          ..write('acceptable: $acceptable, ')
          ..write('valueText: $valueText, ')
          ..write('unit: $unit, ')
          ..write('result: $result, ')
          ..write('isDerived: $isDerived, ')
          ..write('sourceDevice: $sourceDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    id,
    sessionId,
    resultId,
    parameterCode,
    value,
    detected,
    acceptable,
    valueText,
    unit,
    result,
    isDerived,
    sourceDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingRow &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.resultId == this.resultId &&
          other.parameterCode == this.parameterCode &&
          other.value == this.value &&
          other.detected == this.detected &&
          other.acceptable == this.acceptable &&
          other.valueText == this.valueText &&
          other.unit == this.unit &&
          other.result == this.result &&
          other.isDerived == this.isDerived &&
          other.sourceDevice == this.sourceDevice);
}

class ReadingsCompanion extends UpdateCompanion<ReadingRow> {
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> resultId;
  final Value<String> parameterCode;
  final Value<String?> value;
  final Value<bool?> detected;
  final Value<bool?> acceptable;
  final Value<String?> valueText;
  final Value<String?> unit;
  final Value<String> result;
  final Value<bool> isDerived;
  final Value<String?> sourceDevice;
  final Value<int> rowid;
  const ReadingsCompanion({
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.resultId = const Value.absent(),
    this.parameterCode = const Value.absent(),
    this.value = const Value.absent(),
    this.detected = const Value.absent(),
    this.acceptable = const Value.absent(),
    this.valueText = const Value.absent(),
    this.unit = const Value.absent(),
    this.result = const Value.absent(),
    this.isDerived = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String id,
    required String sessionId,
    required String resultId,
    required String parameterCode,
    this.value = const Value.absent(),
    this.detected = const Value.absent(),
    this.acceptable = const Value.absent(),
    this.valueText = const Value.absent(),
    this.unit = const Value.absent(),
    required String result,
    this.isDerived = const Value.absent(),
    this.sourceDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       resultId = Value(resultId),
       parameterCode = Value(parameterCode),
       result = Value(result);
  static Insertable<ReadingRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? resultId,
    Expression<String>? parameterCode,
    Expression<String>? value,
    Expression<bool>? detected,
    Expression<bool>? acceptable,
    Expression<String>? valueText,
    Expression<String>? unit,
    Expression<String>? result,
    Expression<bool>? isDerived,
    Expression<String>? sourceDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (resultId != null) 'result_id': resultId,
      if (parameterCode != null) 'parameter_code': parameterCode,
      if (value != null) 'value': value,
      if (detected != null) 'detected': detected,
      if (acceptable != null) 'acceptable': acceptable,
      if (valueText != null) 'value_text': valueText,
      if (unit != null) 'unit': unit,
      if (result != null) 'result': result,
      if (isDerived != null) 'is_derived': isDerived,
      if (sourceDevice != null) 'source_device': sourceDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingsCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? resultId,
    Value<String>? parameterCode,
    Value<String?>? value,
    Value<bool?>? detected,
    Value<bool?>? acceptable,
    Value<String?>? valueText,
    Value<String?>? unit,
    Value<String>? result,
    Value<bool>? isDerived,
    Value<String?>? sourceDevice,
    Value<int>? rowid,
  }) {
    return ReadingsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      resultId: resultId ?? this.resultId,
      parameterCode: parameterCode ?? this.parameterCode,
      value: value ?? this.value,
      detected: detected ?? this.detected,
      acceptable: acceptable ?? this.acceptable,
      valueText: valueText ?? this.valueText,
      unit: unit ?? this.unit,
      result: result ?? this.result,
      isDerived: isDerived ?? this.isDerived,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (resultId.present) {
      map['result_id'] = Variable<String>(resultId.value);
    }
    if (parameterCode.present) {
      map['parameter_code'] = Variable<String>(parameterCode.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (detected.present) {
      map['detected'] = Variable<bool>(detected.value);
    }
    if (acceptable.present) {
      map['acceptable'] = Variable<bool>(acceptable.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (isDerived.present) {
      map['is_derived'] = Variable<bool>(isDerived.value);
    }
    if (sourceDevice.present) {
      map['source_device'] = Variable<String>(sourceDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('resultId: $resultId, ')
          ..write('parameterCode: $parameterCode, ')
          ..write('value: $value, ')
          ..write('detected: $detected, ')
          ..write('acceptable: $acceptable, ')
          ..write('valueText: $valueText, ')
          ..write('unit: $unit, ')
          ..write('result: $result, ')
          ..write('isDerived: $isDerived, ')
          ..write('sourceDevice: $sourceDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalibrationsTable extends Calibrations
    with TableInfo<$CalibrationsTable, CalibrationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalibrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testerSerialMeta = const VerificationMeta(
    'testerSerial',
  );
  @override
  late final GeneratedColumn<String> testerSerial = GeneratedColumn<String>(
    'tester_serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testerProfileIdMeta = const VerificationMeta(
    'testerProfileId',
  );
  @override
  late final GeneratedColumn<String> testerProfileId = GeneratedColumn<String>(
    'tester_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceStandardIdMeta =
      const VerificationMeta('referenceStandardId');
  @override
  late final GeneratedColumn<String> referenceStandardId =
      GeneratedColumn<String>(
        'reference_standard_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _buffersMeta = const VerificationMeta(
    'buffers',
  );
  @override
  late final GeneratedColumn<String> buffers = GeneratedColumn<String>(
    'buffers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
    'passed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("passed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _performedAtDeviceMeta = const VerificationMeta(
    'performedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> performedAtDevice =
      GeneratedColumn<DateTime>(
        'performed_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    testerSerial,
    testerProfileId,
    referenceStandardId,
    buffers,
    passed,
    performedAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calibrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalibrationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tester_serial')) {
      context.handle(
        _testerSerialMeta,
        testerSerial.isAcceptableOrUnknown(
          data['tester_serial']!,
          _testerSerialMeta,
        ),
      );
    }
    if (data.containsKey('tester_profile_id')) {
      context.handle(
        _testerProfileIdMeta,
        testerProfileId.isAcceptableOrUnknown(
          data['tester_profile_id']!,
          _testerProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('reference_standard_id')) {
      context.handle(
        _referenceStandardIdMeta,
        referenceStandardId.isAcceptableOrUnknown(
          data['reference_standard_id']!,
          _referenceStandardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceStandardIdMeta);
    }
    if (data.containsKey('buffers')) {
      context.handle(
        _buffersMeta,
        buffers.isAcceptableOrUnknown(data['buffers']!, _buffersMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    } else if (isInserting) {
      context.missing(_passedMeta);
    }
    if (data.containsKey('performed_at_device')) {
      context.handle(
        _performedAtDeviceMeta,
        performedAtDevice.isAcceptableOrUnknown(
          data['performed_at_device']!,
          _performedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalibrationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalibrationRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      testerSerial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tester_serial'],
      ),
      testerProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tester_profile_id'],
      ),
      referenceStandardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_standard_id'],
      )!,
      buffers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buffers'],
      ),
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}passed'],
      )!,
      performedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at_device'],
      )!,
    );
  }

  @override
  $CalibrationsTable createAlias(String alias) {
    return $CalibrationsTable(attachedDatabase, alias);
  }
}

class CalibrationRow extends DataClass implements Insertable<CalibrationRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String? testerSerial;
  final String? testerProfileId;
  final String referenceStandardId;

  /// JSON list, e.g. `[{"ph": "7.00", "read": "7.02"}]`.
  final String? buffers;
  final bool passed;
  final DateTime performedAtDevice;
  const CalibrationRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    this.testerSerial,
    this.testerProfileId,
    required this.referenceStandardId,
    this.buffers,
    required this.passed,
    required this.performedAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || testerSerial != null) {
      map['tester_serial'] = Variable<String>(testerSerial);
    }
    if (!nullToAbsent || testerProfileId != null) {
      map['tester_profile_id'] = Variable<String>(testerProfileId);
    }
    map['reference_standard_id'] = Variable<String>(referenceStandardId);
    if (!nullToAbsent || buffers != null) {
      map['buffers'] = Variable<String>(buffers);
    }
    map['passed'] = Variable<bool>(passed);
    map['performed_at_device'] = Variable<DateTime>(performedAtDevice);
    return map;
  }

  CalibrationsCompanion toCompanion(bool nullToAbsent) {
    return CalibrationsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      testerSerial: testerSerial == null && nullToAbsent
          ? const Value.absent()
          : Value(testerSerial),
      testerProfileId: testerProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(testerProfileId),
      referenceStandardId: Value(referenceStandardId),
      buffers: buffers == null && nullToAbsent
          ? const Value.absent()
          : Value(buffers),
      passed: Value(passed),
      performedAtDevice: Value(performedAtDevice),
    );
  }

  factory CalibrationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalibrationRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      testerSerial: serializer.fromJson<String?>(json['tester_serial']),
      testerProfileId: serializer.fromJson<String?>(json['tester_profile_id']),
      referenceStandardId: serializer.fromJson<String>(
        json['reference_standard_id'],
      ),
      buffers: serializer.fromJson<String?>(json['buffers']),
      passed: serializer.fromJson<bool>(json['passed']),
      performedAtDevice: serializer.fromJson<DateTime>(
        json['performed_at_device'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'tester_serial': serializer.toJson<String?>(testerSerial),
      'tester_profile_id': serializer.toJson<String?>(testerProfileId),
      'reference_standard_id': serializer.toJson<String>(referenceStandardId),
      'buffers': serializer.toJson<String?>(buffers),
      'passed': serializer.toJson<bool>(passed),
      'performed_at_device': serializer.toJson<DateTime>(performedAtDevice),
    };
  }

  CalibrationRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    Value<String?> testerSerial = const Value.absent(),
    Value<String?> testerProfileId = const Value.absent(),
    String? referenceStandardId,
    Value<String?> buffers = const Value.absent(),
    bool? passed,
    DateTime? performedAtDevice,
  }) => CalibrationRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    testerSerial: testerSerial.present ? testerSerial.value : this.testerSerial,
    testerProfileId: testerProfileId.present
        ? testerProfileId.value
        : this.testerProfileId,
    referenceStandardId: referenceStandardId ?? this.referenceStandardId,
    buffers: buffers.present ? buffers.value : this.buffers,
    passed: passed ?? this.passed,
    performedAtDevice: performedAtDevice ?? this.performedAtDevice,
  );
  CalibrationRow copyWithCompanion(CalibrationsCompanion data) {
    return CalibrationRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      testerSerial: data.testerSerial.present
          ? data.testerSerial.value
          : this.testerSerial,
      testerProfileId: data.testerProfileId.present
          ? data.testerProfileId.value
          : this.testerProfileId,
      referenceStandardId: data.referenceStandardId.present
          ? data.referenceStandardId.value
          : this.referenceStandardId,
      buffers: data.buffers.present ? data.buffers.value : this.buffers,
      passed: data.passed.present ? data.passed.value : this.passed,
      performedAtDevice: data.performedAtDevice.present
          ? data.performedAtDevice.value
          : this.performedAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalibrationRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('testerSerial: $testerSerial, ')
          ..write('testerProfileId: $testerProfileId, ')
          ..write('referenceStandardId: $referenceStandardId, ')
          ..write('buffers: $buffers, ')
          ..write('passed: $passed, ')
          ..write('performedAtDevice: $performedAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    testerSerial,
    testerProfileId,
    referenceStandardId,
    buffers,
    passed,
    performedAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalibrationRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.testerSerial == this.testerSerial &&
          other.testerProfileId == this.testerProfileId &&
          other.referenceStandardId == this.referenceStandardId &&
          other.buffers == this.buffers &&
          other.passed == this.passed &&
          other.performedAtDevice == this.performedAtDevice);
}

class CalibrationsCompanion extends UpdateCompanion<CalibrationRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String?> testerSerial;
  final Value<String?> testerProfileId;
  final Value<String> referenceStandardId;
  final Value<String?> buffers;
  final Value<bool> passed;
  final Value<DateTime> performedAtDevice;
  final Value<int> rowid;
  const CalibrationsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.testerSerial = const Value.absent(),
    this.testerProfileId = const Value.absent(),
    this.referenceStandardId = const Value.absent(),
    this.buffers = const Value.absent(),
    this.passed = const Value.absent(),
    this.performedAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalibrationsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    this.testerSerial = const Value.absent(),
    this.testerProfileId = const Value.absent(),
    required String referenceStandardId,
    this.buffers = const Value.absent(),
    required bool passed,
    required DateTime performedAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       referenceStandardId = Value(referenceStandardId),
       passed = Value(passed),
       performedAtDevice = Value(performedAtDevice);
  static Insertable<CalibrationRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? testerSerial,
    Expression<String>? testerProfileId,
    Expression<String>? referenceStandardId,
    Expression<String>? buffers,
    Expression<bool>? passed,
    Expression<DateTime>? performedAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (testerSerial != null) 'tester_serial': testerSerial,
      if (testerProfileId != null) 'tester_profile_id': testerProfileId,
      if (referenceStandardId != null)
        'reference_standard_id': referenceStandardId,
      if (buffers != null) 'buffers': buffers,
      if (passed != null) 'passed': passed,
      if (performedAtDevice != null) 'performed_at_device': performedAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalibrationsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String?>? testerSerial,
    Value<String?>? testerProfileId,
    Value<String>? referenceStandardId,
    Value<String?>? buffers,
    Value<bool>? passed,
    Value<DateTime>? performedAtDevice,
    Value<int>? rowid,
  }) {
    return CalibrationsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      testerSerial: testerSerial ?? this.testerSerial,
      testerProfileId: testerProfileId ?? this.testerProfileId,
      referenceStandardId: referenceStandardId ?? this.referenceStandardId,
      buffers: buffers ?? this.buffers,
      passed: passed ?? this.passed,
      performedAtDevice: performedAtDevice ?? this.performedAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (testerSerial.present) {
      map['tester_serial'] = Variable<String>(testerSerial.value);
    }
    if (testerProfileId.present) {
      map['tester_profile_id'] = Variable<String>(testerProfileId.value);
    }
    if (referenceStandardId.present) {
      map['reference_standard_id'] = Variable<String>(
        referenceStandardId.value,
      );
    }
    if (buffers.present) {
      map['buffers'] = Variable<String>(buffers.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (performedAtDevice.present) {
      map['performed_at_device'] = Variable<DateTime>(performedAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalibrationsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('testerSerial: $testerSerial, ')
          ..write('testerProfileId: $testerProfileId, ')
          ..write('referenceStandardId: $referenceStandardId, ')
          ..write('buffers: $buffers, ')
          ..write('passed: $passed, ')
          ..write('performedAtDevice: $performedAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, AlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES water_sources (id)',
    ),
  );
  static const VerificationMeta _triggerResultIdMeta = const VerificationMeta(
    'triggerResultId',
  );
  @override
  late final GeneratedColumn<String> triggerResultId = GeneratedColumn<String>(
    'trigger_result_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _triggerRuleMeta = const VerificationMeta(
    'triggerRule',
  );
  @override
  late final GeneratedColumn<String> triggerRule = GeneratedColumn<String>(
    'trigger_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('high'),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedAlertIdMeta = const VerificationMeta(
    'linkedAlertId',
  );
  @override
  late final GeneratedColumn<String> linkedAlertId = GeneratedColumn<String>(
    'linked_alert_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    triggerResultId,
    triggerRule,
    status,
    severity,
    openedAt,
    acknowledgedAt,
    closedAt,
    linkedAlertId,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('trigger_result_id')) {
      context.handle(
        _triggerResultIdMeta,
        triggerResultId.isAcceptableOrUnknown(
          data['trigger_result_id']!,
          _triggerResultIdMeta,
        ),
      );
    }
    if (data.containsKey('trigger_rule')) {
      context.handle(
        _triggerRuleMeta,
        triggerRule.isAcceptableOrUnknown(
          data['trigger_rule']!,
          _triggerRuleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerRuleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('linked_alert_id')) {
      context.handle(
        _linkedAlertIdMeta,
        linkedAlertId.isAcceptableOrUnknown(
          data['linked_alert_id']!,
          _linkedAlertIdMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {triggerResultId, triggerRule},
  ];
  @override
  AlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      triggerResultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_result_id'],
      ),
      triggerRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_rule'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      linkedAlertId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_alert_id'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class AlertRow extends DataClass implements Insertable<AlertRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String sourceId;
  final String? triggerResultId;
  final String triggerRule;
  final String status;
  final String severity;
  final DateTime openedAt;
  final DateTime? acknowledgedAt;
  final DateTime? closedAt;
  final String? linkedAlertId;
  final int version;
  const AlertRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.sourceId,
    this.triggerResultId,
    required this.triggerRule,
    required this.status,
    required this.severity,
    required this.openedAt,
    this.acknowledgedAt,
    this.closedAt,
    this.linkedAlertId,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || triggerResultId != null) {
      map['trigger_result_id'] = Variable<String>(triggerResultId);
    }
    map['trigger_rule'] = Variable<String>(triggerRule);
    map['status'] = Variable<String>(status);
    map['severity'] = Variable<String>(severity);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || linkedAlertId != null) {
      map['linked_alert_id'] = Variable<String>(linkedAlertId);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      sourceId: Value(sourceId),
      triggerResultId: triggerResultId == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerResultId),
      triggerRule: Value(triggerRule),
      status: Value(status),
      severity: Value(severity),
      openedAt: Value(openedAt),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      linkedAlertId: linkedAlertId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAlertId),
      version: Value(version),
    );
  }

  factory AlertRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['source_id']),
      triggerResultId: serializer.fromJson<String?>(json['trigger_result_id']),
      triggerRule: serializer.fromJson<String>(json['trigger_rule']),
      status: serializer.fromJson<String>(json['status']),
      severity: serializer.fromJson<String>(json['severity']),
      openedAt: serializer.fromJson<DateTime>(json['opened_at']),
      acknowledgedAt: serializer.fromJson<DateTime?>(json['acknowledged_at']),
      closedAt: serializer.fromJson<DateTime?>(json['closed_at']),
      linkedAlertId: serializer.fromJson<String?>(json['linked_alert_id']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'source_id': serializer.toJson<String>(sourceId),
      'trigger_result_id': serializer.toJson<String?>(triggerResultId),
      'trigger_rule': serializer.toJson<String>(triggerRule),
      'status': serializer.toJson<String>(status),
      'severity': serializer.toJson<String>(severity),
      'opened_at': serializer.toJson<DateTime>(openedAt),
      'acknowledged_at': serializer.toJson<DateTime?>(acknowledgedAt),
      'closed_at': serializer.toJson<DateTime?>(closedAt),
      'linked_alert_id': serializer.toJson<String?>(linkedAlertId),
      'version': serializer.toJson<int>(version),
    };
  }

  AlertRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? sourceId,
    Value<String?> triggerResultId = const Value.absent(),
    String? triggerRule,
    String? status,
    String? severity,
    DateTime? openedAt,
    Value<DateTime?> acknowledgedAt = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
    Value<String?> linkedAlertId = const Value.absent(),
    int? version,
  }) => AlertRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    triggerResultId: triggerResultId.present
        ? triggerResultId.value
        : this.triggerResultId,
    triggerRule: triggerRule ?? this.triggerRule,
    status: status ?? this.status,
    severity: severity ?? this.severity,
    openedAt: openedAt ?? this.openedAt,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    linkedAlertId: linkedAlertId.present
        ? linkedAlertId.value
        : this.linkedAlertId,
    version: version ?? this.version,
  );
  AlertRow copyWithCompanion(AlertsCompanion data) {
    return AlertRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      triggerResultId: data.triggerResultId.present
          ? data.triggerResultId.value
          : this.triggerResultId,
      triggerRule: data.triggerRule.present
          ? data.triggerRule.value
          : this.triggerRule,
      status: data.status.present ? data.status.value : this.status,
      severity: data.severity.present ? data.severity.value : this.severity,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      linkedAlertId: data.linkedAlertId.present
          ? data.linkedAlertId.value
          : this.linkedAlertId,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('triggerResultId: $triggerResultId, ')
          ..write('triggerRule: $triggerRule, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('openedAt: $openedAt, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('linkedAlertId: $linkedAlertId, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    triggerResultId,
    triggerRule,
    status,
    severity,
    openedAt,
    acknowledgedAt,
    closedAt,
    linkedAlertId,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.triggerResultId == this.triggerResultId &&
          other.triggerRule == this.triggerRule &&
          other.status == this.status &&
          other.severity == this.severity &&
          other.openedAt == this.openedAt &&
          other.acknowledgedAt == this.acknowledgedAt &&
          other.closedAt == this.closedAt &&
          other.linkedAlertId == this.linkedAlertId &&
          other.version == this.version);
}

class AlertsCompanion extends UpdateCompanion<AlertRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String?> triggerResultId;
  final Value<String> triggerRule;
  final Value<String> status;
  final Value<String> severity;
  final Value<DateTime> openedAt;
  final Value<DateTime?> acknowledgedAt;
  final Value<DateTime?> closedAt;
  final Value<String?> linkedAlertId;
  final Value<int> version;
  final Value<int> rowid;
  const AlertsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.triggerResultId = const Value.absent(),
    this.triggerRule = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.linkedAlertId = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String sourceId,
    this.triggerResultId = const Value.absent(),
    required String triggerRule,
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    required DateTime openedAt,
    this.acknowledgedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.linkedAlertId = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       triggerRule = Value(triggerRule),
       openedAt = Value(openedAt);
  static Insertable<AlertRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? triggerResultId,
    Expression<String>? triggerRule,
    Expression<String>? status,
    Expression<String>? severity,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? acknowledgedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? linkedAlertId,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (triggerResultId != null) 'trigger_result_id': triggerResultId,
      if (triggerRule != null) 'trigger_rule': triggerRule,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (openedAt != null) 'opened_at': openedAt,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (linkedAlertId != null) 'linked_alert_id': linkedAlertId,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? sourceId,
    Value<String?>? triggerResultId,
    Value<String>? triggerRule,
    Value<String>? status,
    Value<String>? severity,
    Value<DateTime>? openedAt,
    Value<DateTime?>? acknowledgedAt,
    Value<DateTime?>? closedAt,
    Value<String?>? linkedAlertId,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return AlertsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      triggerResultId: triggerResultId ?? this.triggerResultId,
      triggerRule: triggerRule ?? this.triggerRule,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      openedAt: openedAt ?? this.openedAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      closedAt: closedAt ?? this.closedAt,
      linkedAlertId: linkedAlertId ?? this.linkedAlertId,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (triggerResultId.present) {
      map['trigger_result_id'] = Variable<String>(triggerResultId.value);
    }
    if (triggerRule.present) {
      map['trigger_rule'] = Variable<String>(triggerRule.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (linkedAlertId.present) {
      map['linked_alert_id'] = Variable<String>(linkedAlertId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('triggerResultId: $triggerResultId, ')
          ..write('triggerRule: $triggerRule, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('openedAt: $openedAt, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('linkedAlertId: $linkedAlertId, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertEventsTable extends AlertEvents
    with TableInfo<$AlertEventsTable, AlertEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertIdMeta = const VerificationMeta(
    'alertId',
  );
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
    'alert_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES alerts (id)',
    ),
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtDeviceMeta = const VerificationMeta(
    'occurredAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtDevice =
      GeneratedColumn<DateTime>(
        'occurred_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    alertId,
    actorId,
    eventType,
    note,
    occurredAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alert_id')) {
      context.handle(
        _alertIdMeta,
        alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at_device')) {
      context.handle(
        _occurredAtDeviceMeta,
        occurredAtDevice.isAcceptableOrUnknown(
          data['occurred_at_device']!,
          _occurredAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertEventRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      alertId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_device'],
      )!,
    );
  }

  @override
  $AlertEventsTable createAlias(String alias) {
    return $AlertEventsTable(attachedDatabase, alias);
  }
}

class AlertEventRow extends DataClass implements Insertable<AlertEventRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String alertId;
  final String? actorId;
  final String eventType;
  final String? note;
  final DateTime occurredAtDevice;
  const AlertEventRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.alertId,
    this.actorId,
    required this.eventType,
    this.note,
    required this.occurredAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['alert_id'] = Variable<String>(alertId);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at_device'] = Variable<DateTime>(occurredAtDevice);
    return map;
  }

  AlertEventsCompanion toCompanion(bool nullToAbsent) {
    return AlertEventsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      alertId: Value(alertId),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      eventType: Value(eventType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAtDevice: Value(occurredAtDevice),
    );
  }

  factory AlertEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertEventRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      alertId: serializer.fromJson<String>(json['alert_id']),
      actorId: serializer.fromJson<String?>(json['actor_id']),
      eventType: serializer.fromJson<String>(json['event_type']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAtDevice: serializer.fromJson<DateTime>(
        json['occurred_at_device'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'alert_id': serializer.toJson<String>(alertId),
      'actor_id': serializer.toJson<String?>(actorId),
      'event_type': serializer.toJson<String>(eventType),
      'note': serializer.toJson<String?>(note),
      'occurred_at_device': serializer.toJson<DateTime>(occurredAtDevice),
    };
  }

  AlertEventRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? alertId,
    Value<String?> actorId = const Value.absent(),
    String? eventType,
    Value<String?> note = const Value.absent(),
    DateTime? occurredAtDevice,
  }) => AlertEventRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    alertId: alertId ?? this.alertId,
    actorId: actorId.present ? actorId.value : this.actorId,
    eventType: eventType ?? this.eventType,
    note: note.present ? note.value : this.note,
    occurredAtDevice: occurredAtDevice ?? this.occurredAtDevice,
  );
  AlertEventRow copyWithCompanion(AlertEventsCompanion data) {
    return AlertEventRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      alertId: data.alertId.present ? data.alertId.value : this.alertId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      note: data.note.present ? data.note.value : this.note,
      occurredAtDevice: data.occurredAtDevice.present
          ? data.occurredAtDevice.value
          : this.occurredAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertEventRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('actorId: $actorId, ')
          ..write('eventType: $eventType, ')
          ..write('note: $note, ')
          ..write('occurredAtDevice: $occurredAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    alertId,
    actorId,
    eventType,
    note,
    occurredAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertEventRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.alertId == this.alertId &&
          other.actorId == this.actorId &&
          other.eventType == this.eventType &&
          other.note == this.note &&
          other.occurredAtDevice == this.occurredAtDevice);
}

class AlertEventsCompanion extends UpdateCompanion<AlertEventRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> alertId;
  final Value<String?> actorId;
  final Value<String> eventType;
  final Value<String?> note;
  final Value<DateTime> occurredAtDevice;
  final Value<int> rowid;
  const AlertEventsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.alertId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertEventsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String alertId,
    this.actorId = const Value.absent(),
    required String eventType,
    this.note = const Value.absent(),
    required DateTime occurredAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       alertId = Value(alertId),
       eventType = Value(eventType),
       occurredAtDevice = Value(occurredAtDevice);
  static Insertable<AlertEventRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? alertId,
    Expression<String>? actorId,
    Expression<String>? eventType,
    Expression<String>? note,
    Expression<DateTime>? occurredAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (alertId != null) 'alert_id': alertId,
      if (actorId != null) 'actor_id': actorId,
      if (eventType != null) 'event_type': eventType,
      if (note != null) 'note': note,
      if (occurredAtDevice != null) 'occurred_at_device': occurredAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertEventsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? alertId,
    Value<String?>? actorId,
    Value<String>? eventType,
    Value<String?>? note,
    Value<DateTime>? occurredAtDevice,
    Value<int>? rowid,
  }) {
    return AlertEventsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      actorId: actorId ?? this.actorId,
      eventType: eventType ?? this.eventType,
      note: note ?? this.note,
      occurredAtDevice: occurredAtDevice ?? this.occurredAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAtDevice.present) {
      map['occurred_at_device'] = Variable<DateTime>(occurredAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertEventsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('actorId: $actorId, ')
          ..write('eventType: $eventType, ')
          ..write('note: $note, ')
          ..write('occurredAtDevice: $occurredAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SanitaryInspectionsTable extends SanitaryInspections
    with TableInfo<$SanitaryInspectionsTable, SanitaryInspectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SanitaryInspectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES water_sources (id)',
    ),
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inspectedAtDeviceMeta = const VerificationMeta(
    'inspectedAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> inspectedAtDevice =
      GeneratedColumn<DateTime>(
        'inspected_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    answers,
    inspectedAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sanitary_inspections';
  @override
  VerificationContext validateIntegrity(
    Insertable<SanitaryInspectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    } else if (isInserting) {
      context.missing(_answersMeta);
    }
    if (data.containsKey('inspected_at_device')) {
      context.handle(
        _inspectedAtDeviceMeta,
        inspectedAtDevice.isAcceptableOrUnknown(
          data['inspected_at_device']!,
          _inspectedAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectedAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SanitaryInspectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SanitaryInspectionRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      inspectedAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inspected_at_device'],
      )!,
    );
  }

  @override
  $SanitaryInspectionsTable createAlias(String alias) {
    return $SanitaryInspectionsTable(attachedDatabase, alias);
  }
}

class SanitaryInspectionRow extends DataClass
    implements Insertable<SanitaryInspectionRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String sourceId;

  /// JSON map of checklist item code → answer.
  final String answers;
  final DateTime inspectedAtDevice;
  const SanitaryInspectionRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.sourceId,
    required this.answers,
    required this.inspectedAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['answers'] = Variable<String>(answers);
    map['inspected_at_device'] = Variable<DateTime>(inspectedAtDevice);
    return map;
  }

  SanitaryInspectionsCompanion toCompanion(bool nullToAbsent) {
    return SanitaryInspectionsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      sourceId: Value(sourceId),
      answers: Value(answers),
      inspectedAtDevice: Value(inspectedAtDevice),
    );
  }

  factory SanitaryInspectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SanitaryInspectionRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['source_id']),
      answers: serializer.fromJson<String>(json['answers']),
      inspectedAtDevice: serializer.fromJson<DateTime>(
        json['inspected_at_device'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'source_id': serializer.toJson<String>(sourceId),
      'answers': serializer.toJson<String>(answers),
      'inspected_at_device': serializer.toJson<DateTime>(inspectedAtDevice),
    };
  }

  SanitaryInspectionRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? sourceId,
    String? answers,
    DateTime? inspectedAtDevice,
  }) => SanitaryInspectionRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    answers: answers ?? this.answers,
    inspectedAtDevice: inspectedAtDevice ?? this.inspectedAtDevice,
  );
  SanitaryInspectionRow copyWithCompanion(SanitaryInspectionsCompanion data) {
    return SanitaryInspectionRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      answers: data.answers.present ? data.answers.value : this.answers,
      inspectedAtDevice: data.inspectedAtDevice.present
          ? data.inspectedAtDevice.value
          : this.inspectedAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SanitaryInspectionRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('answers: $answers, ')
          ..write('inspectedAtDevice: $inspectedAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    sourceId,
    answers,
    inspectedAtDevice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SanitaryInspectionRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.answers == this.answers &&
          other.inspectedAtDevice == this.inspectedAtDevice);
}

class SanitaryInspectionsCompanion
    extends UpdateCompanion<SanitaryInspectionRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> answers;
  final Value<DateTime> inspectedAtDevice;
  final Value<int> rowid;
  const SanitaryInspectionsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.answers = const Value.absent(),
    this.inspectedAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SanitaryInspectionsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String sourceId,
    required String answers,
    required DateTime inspectedAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       answers = Value(answers),
       inspectedAtDevice = Value(inspectedAtDevice);
  static Insertable<SanitaryInspectionRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? answers,
    Expression<DateTime>? inspectedAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (answers != null) 'answers': answers,
      if (inspectedAtDevice != null) 'inspected_at_device': inspectedAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SanitaryInspectionsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? answers,
    Value<DateTime>? inspectedAtDevice,
    Value<int>? rowid,
  }) {
    return SanitaryInspectionsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      answers: answers ?? this.answers,
      inspectedAtDevice: inspectedAtDevice ?? this.inspectedAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (inspectedAtDevice.present) {
      map['inspected_at_device'] = Variable<DateTime>(inspectedAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SanitaryInspectionsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('answers: $answers, ')
          ..write('inspectedAtDevice: $inspectedAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdminUnitsTable extends AdminUnits
    with TableInfo<$AdminUnitsTable, AdminUnitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES admin_units (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, level, name, code, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminUnitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdminUnitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminUnitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $AdminUnitsTable createAlias(String alias) {
    return $AdminUnitsTable(attachedDatabase, alias);
  }
}

class AdminUnitRow extends DataClass implements Insertable<AdminUnitRow> {
  final String id;
  final String level;
  final String name;
  final String code;
  final String? parentId;
  const AdminUnitRow({
    required this.id,
    required this.level,
    required this.name,
    required this.code,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['level'] = Variable<String>(level);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  AdminUnitsCompanion toCompanion(bool nullToAbsent) {
    return AdminUnitsCompanion(
      id: Value(id),
      level: Value(level),
      name: Value(name),
      code: Value(code),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory AdminUnitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminUnitRow(
      id: serializer.fromJson<String>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      parentId: serializer.fromJson<String?>(json['parent_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'level': serializer.toJson<String>(level),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'parent_id': serializer.toJson<String?>(parentId),
    };
  }

  AdminUnitRow copyWith({
    String? id,
    String? level,
    String? name,
    String? code,
    Value<String?> parentId = const Value.absent(),
  }) => AdminUnitRow(
    id: id ?? this.id,
    level: level ?? this.level,
    name: name ?? this.name,
    code: code ?? this.code,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  AdminUnitRow copyWithCompanion(AdminUnitsCompanion data) {
    return AdminUnitRow(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminUnitRow(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, name, code, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminUnitRow &&
          other.id == this.id &&
          other.level == this.level &&
          other.name == this.name &&
          other.code == this.code &&
          other.parentId == this.parentId);
}

class AdminUnitsCompanion extends UpdateCompanion<AdminUnitRow> {
  final Value<String> id;
  final Value<String> level;
  final Value<String> name;
  final Value<String> code;
  final Value<String?> parentId;
  final Value<int> rowid;
  const AdminUnitsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdminUnitsCompanion.insert({
    required String id,
    required String level,
    required String name,
    required String code,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       level = Value(level),
       name = Value(name),
       code = Value(code);
  static Insertable<AdminUnitRow> custom({
    Expression<String>? id,
    Expression<String>? level,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdminUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? level,
    Value<String>? name,
    Value<String>? code,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return AdminUnitsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      name: name ?? this.name,
      code: code ?? this.code,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminUnitsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParameterCategoriesTable extends ParameterCategories
    with TableInfo<$ParameterCategoriesTable, ParameterCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParameterCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, name, displayOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parameter_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParameterCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ParameterCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParameterCategoryRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $ParameterCategoriesTable createAlias(String alias) {
    return $ParameterCategoriesTable(attachedDatabase, alias);
  }
}

class ParameterCategoryRow extends DataClass
    implements Insertable<ParameterCategoryRow> {
  final String code;
  final String name;
  final int displayOrder;
  const ParameterCategoryRow({
    required this.code,
    required this.name,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  ParameterCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ParameterCategoriesCompanion(
      code: Value(code),
      name: Value(name),
      displayOrder: Value(displayOrder),
    );
  }

  factory ParameterCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParameterCategoryRow(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      displayOrder: serializer.fromJson<int>(json['display_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'display_order': serializer.toJson<int>(displayOrder),
    };
  }

  ParameterCategoryRow copyWith({
    String? code,
    String? name,
    int? displayOrder,
  }) => ParameterCategoryRow(
    code: code ?? this.code,
    name: name ?? this.name,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  ParameterCategoryRow copyWithCompanion(ParameterCategoriesCompanion data) {
    return ParameterCategoryRow(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParameterCategoryRow(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, displayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParameterCategoryRow &&
          other.code == this.code &&
          other.name == this.name &&
          other.displayOrder == this.displayOrder);
}

class ParameterCategoriesCompanion
    extends UpdateCompanion<ParameterCategoryRow> {
  final Value<String> code;
  final Value<String> name;
  final Value<int> displayOrder;
  final Value<int> rowid;
  const ParameterCategoriesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParameterCategoriesCompanion.insert({
    required String code,
    required String name,
    required int displayOrder,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       displayOrder = Value(displayOrder);
  static Insertable<ParameterCategoryRow> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? displayOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (displayOrder != null) 'display_order': displayOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParameterCategoriesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<int>? displayOrder,
    Value<int>? rowid,
  }) {
    return ParameterCategoriesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParameterCategoriesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParameterDefinitionsTable extends ParameterDefinitions
    with TableInfo<$ParameterDefinitionsTable, ParameterDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParameterDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryCodeMeta = const VerificationMeta(
    'categoryCode',
  );
  @override
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
    'category_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parameter_categories (code)',
    ),
  );
  static const VerificationMeta _defaultUnitMeta = const VerificationMeta(
    'defaultUnit',
  );
  @override
  late final GeneratedColumn<String> defaultUnit = GeneratedColumn<String>(
    'default_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCoreMeta = const VerificationMeta('isCore');
  @override
  late final GeneratedColumn<bool> isCore = GeneratedColumn<bool>(
    'is_core',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_core" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plausibleMinMeta = const VerificationMeta(
    'plausibleMin',
  );
  @override
  late final GeneratedColumn<String> plausibleMin = GeneratedColumn<String>(
    'plausible_min',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plausibleMaxMeta = const VerificationMeta(
    'plausibleMax',
  );
  @override
  late final GeneratedColumn<String> plausibleMax = GeneratedColumn<String>(
    'plausible_max',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scopeAdminUnitIdMeta = const VerificationMeta(
    'scopeAdminUnitId',
  );
  @override
  late final GeneratedColumn<String> scopeAdminUnitId = GeneratedColumn<String>(
    'scope_admin_unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('approved'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    code,
    name,
    categoryCode,
    defaultUnit,
    valueType,
    isCore,
    displayOrder,
    plausibleMin,
    plausibleMax,
    isCustom,
    scopeAdminUnitId,
    reviewStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parameter_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParameterDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_code')) {
      context.handle(
        _categoryCodeMeta,
        categoryCode.isAcceptableOrUnknown(
          data['category_code']!,
          _categoryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryCodeMeta);
    }
    if (data.containsKey('default_unit')) {
      context.handle(
        _defaultUnitMeta,
        defaultUnit.isAcceptableOrUnknown(
          data['default_unit']!,
          _defaultUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultUnitMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('is_core')) {
      context.handle(
        _isCoreMeta,
        isCore.isAcceptableOrUnknown(data['is_core']!, _isCoreMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    if (data.containsKey('plausible_min')) {
      context.handle(
        _plausibleMinMeta,
        plausibleMin.isAcceptableOrUnknown(
          data['plausible_min']!,
          _plausibleMinMeta,
        ),
      );
    }
    if (data.containsKey('plausible_max')) {
      context.handle(
        _plausibleMaxMeta,
        plausibleMax.isAcceptableOrUnknown(
          data['plausible_max']!,
          _plausibleMaxMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('scope_admin_unit_id')) {
      context.handle(
        _scopeAdminUnitIdMeta,
        scopeAdminUnitId.isAcceptableOrUnknown(
          data['scope_admin_unit_id']!,
          _scopeAdminUnitIdMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ParameterDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParameterDefinitionRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_code'],
      )!,
      defaultUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_unit'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      isCore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_core'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      plausibleMin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plausible_min'],
      ),
      plausibleMax: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plausible_max'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      scopeAdminUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_admin_unit_id'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
    );
  }

  @override
  $ParameterDefinitionsTable createAlias(String alias) {
    return $ParameterDefinitionsTable(attachedDatabase, alias);
  }
}

class ParameterDefinitionRow extends DataClass
    implements Insertable<ParameterDefinitionRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String code;
  final String name;
  final String categoryCode;
  final String defaultUnit;
  final String valueType;
  final bool isCore;
  final int displayOrder;
  final String? plausibleMin;
  final String? plausibleMax;
  final bool isCustom;
  final String? scopeAdminUnitId;
  final String reviewStatus;
  const ParameterDefinitionRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.code,
    required this.name,
    required this.categoryCode,
    required this.defaultUnit,
    required this.valueType,
    required this.isCore,
    required this.displayOrder,
    this.plausibleMin,
    this.plausibleMax,
    required this.isCustom,
    this.scopeAdminUnitId,
    required this.reviewStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['category_code'] = Variable<String>(categoryCode);
    map['default_unit'] = Variable<String>(defaultUnit);
    map['value_type'] = Variable<String>(valueType);
    map['is_core'] = Variable<bool>(isCore);
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || plausibleMin != null) {
      map['plausible_min'] = Variable<String>(plausibleMin);
    }
    if (!nullToAbsent || plausibleMax != null) {
      map['plausible_max'] = Variable<String>(plausibleMax);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || scopeAdminUnitId != null) {
      map['scope_admin_unit_id'] = Variable<String>(scopeAdminUnitId);
    }
    map['review_status'] = Variable<String>(reviewStatus);
    return map;
  }

  ParameterDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ParameterDefinitionsCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      code: Value(code),
      name: Value(name),
      categoryCode: Value(categoryCode),
      defaultUnit: Value(defaultUnit),
      valueType: Value(valueType),
      isCore: Value(isCore),
      displayOrder: Value(displayOrder),
      plausibleMin: plausibleMin == null && nullToAbsent
          ? const Value.absent()
          : Value(plausibleMin),
      plausibleMax: plausibleMax == null && nullToAbsent
          ? const Value.absent()
          : Value(plausibleMax),
      isCustom: Value(isCustom),
      scopeAdminUnitId: scopeAdminUnitId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeAdminUnitId),
      reviewStatus: Value(reviewStatus),
    );
  }

  factory ParameterDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParameterDefinitionRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      categoryCode: serializer.fromJson<String>(json['category_code']),
      defaultUnit: serializer.fromJson<String>(json['default_unit']),
      valueType: serializer.fromJson<String>(json['value_type']),
      isCore: serializer.fromJson<bool>(json['is_core']),
      displayOrder: serializer.fromJson<int>(json['display_order']),
      plausibleMin: serializer.fromJson<String?>(json['plausible_min']),
      plausibleMax: serializer.fromJson<String?>(json['plausible_max']),
      isCustom: serializer.fromJson<bool>(json['is_custom']),
      scopeAdminUnitId: serializer.fromJson<String?>(
        json['scope_admin_unit_id'],
      ),
      reviewStatus: serializer.fromJson<String>(json['review_status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'category_code': serializer.toJson<String>(categoryCode),
      'default_unit': serializer.toJson<String>(defaultUnit),
      'value_type': serializer.toJson<String>(valueType),
      'is_core': serializer.toJson<bool>(isCore),
      'display_order': serializer.toJson<int>(displayOrder),
      'plausible_min': serializer.toJson<String?>(plausibleMin),
      'plausible_max': serializer.toJson<String?>(plausibleMax),
      'is_custom': serializer.toJson<bool>(isCustom),
      'scope_admin_unit_id': serializer.toJson<String?>(scopeAdminUnitId),
      'review_status': serializer.toJson<String>(reviewStatus),
    };
  }

  ParameterDefinitionRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? code,
    String? name,
    String? categoryCode,
    String? defaultUnit,
    String? valueType,
    bool? isCore,
    int? displayOrder,
    Value<String?> plausibleMin = const Value.absent(),
    Value<String?> plausibleMax = const Value.absent(),
    bool? isCustom,
    Value<String?> scopeAdminUnitId = const Value.absent(),
    String? reviewStatus,
  }) => ParameterDefinitionRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    code: code ?? this.code,
    name: name ?? this.name,
    categoryCode: categoryCode ?? this.categoryCode,
    defaultUnit: defaultUnit ?? this.defaultUnit,
    valueType: valueType ?? this.valueType,
    isCore: isCore ?? this.isCore,
    displayOrder: displayOrder ?? this.displayOrder,
    plausibleMin: plausibleMin.present ? plausibleMin.value : this.plausibleMin,
    plausibleMax: plausibleMax.present ? plausibleMax.value : this.plausibleMax,
    isCustom: isCustom ?? this.isCustom,
    scopeAdminUnitId: scopeAdminUnitId.present
        ? scopeAdminUnitId.value
        : this.scopeAdminUnitId,
    reviewStatus: reviewStatus ?? this.reviewStatus,
  );
  ParameterDefinitionRow copyWithCompanion(ParameterDefinitionsCompanion data) {
    return ParameterDefinitionRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      defaultUnit: data.defaultUnit.present
          ? data.defaultUnit.value
          : this.defaultUnit,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      isCore: data.isCore.present ? data.isCore.value : this.isCore,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      plausibleMin: data.plausibleMin.present
          ? data.plausibleMin.value
          : this.plausibleMin,
      plausibleMax: data.plausibleMax.present
          ? data.plausibleMax.value
          : this.plausibleMax,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      scopeAdminUnitId: data.scopeAdminUnitId.present
          ? data.scopeAdminUnitId.value
          : this.scopeAdminUnitId,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParameterDefinitionRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('valueType: $valueType, ')
          ..write('isCore: $isCore, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('plausibleMin: $plausibleMin, ')
          ..write('plausibleMax: $plausibleMax, ')
          ..write('isCustom: $isCustom, ')
          ..write('scopeAdminUnitId: $scopeAdminUnitId, ')
          ..write('reviewStatus: $reviewStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    code,
    name,
    categoryCode,
    defaultUnit,
    valueType,
    isCore,
    displayOrder,
    plausibleMin,
    plausibleMax,
    isCustom,
    scopeAdminUnitId,
    reviewStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParameterDefinitionRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.code == this.code &&
          other.name == this.name &&
          other.categoryCode == this.categoryCode &&
          other.defaultUnit == this.defaultUnit &&
          other.valueType == this.valueType &&
          other.isCore == this.isCore &&
          other.displayOrder == this.displayOrder &&
          other.plausibleMin == this.plausibleMin &&
          other.plausibleMax == this.plausibleMax &&
          other.isCustom == this.isCustom &&
          other.scopeAdminUnitId == this.scopeAdminUnitId &&
          other.reviewStatus == this.reviewStatus);
}

class ParameterDefinitionsCompanion
    extends UpdateCompanion<ParameterDefinitionRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> code;
  final Value<String> name;
  final Value<String> categoryCode;
  final Value<String> defaultUnit;
  final Value<String> valueType;
  final Value<bool> isCore;
  final Value<int> displayOrder;
  final Value<String?> plausibleMin;
  final Value<String?> plausibleMax;
  final Value<bool> isCustom;
  final Value<String?> scopeAdminUnitId;
  final Value<String> reviewStatus;
  final Value<int> rowid;
  const ParameterDefinitionsCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.defaultUnit = const Value.absent(),
    this.valueType = const Value.absent(),
    this.isCore = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.plausibleMin = const Value.absent(),
    this.plausibleMax = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.scopeAdminUnitId = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParameterDefinitionsCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String code,
    required String name,
    required String categoryCode,
    required String defaultUnit,
    required String valueType,
    this.isCore = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.plausibleMin = const Value.absent(),
    this.plausibleMax = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.scopeAdminUnitId = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       categoryCode = Value(categoryCode),
       defaultUnit = Value(defaultUnit),
       valueType = Value(valueType);
  static Insertable<ParameterDefinitionRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? categoryCode,
    Expression<String>? defaultUnit,
    Expression<String>? valueType,
    Expression<bool>? isCore,
    Expression<int>? displayOrder,
    Expression<String>? plausibleMin,
    Expression<String>? plausibleMax,
    Expression<bool>? isCustom,
    Expression<String>? scopeAdminUnitId,
    Expression<String>? reviewStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (categoryCode != null) 'category_code': categoryCode,
      if (defaultUnit != null) 'default_unit': defaultUnit,
      if (valueType != null) 'value_type': valueType,
      if (isCore != null) 'is_core': isCore,
      if (displayOrder != null) 'display_order': displayOrder,
      if (plausibleMin != null) 'plausible_min': plausibleMin,
      if (plausibleMax != null) 'plausible_max': plausibleMax,
      if (isCustom != null) 'is_custom': isCustom,
      if (scopeAdminUnitId != null) 'scope_admin_unit_id': scopeAdminUnitId,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParameterDefinitionsCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? code,
    Value<String>? name,
    Value<String>? categoryCode,
    Value<String>? defaultUnit,
    Value<String>? valueType,
    Value<bool>? isCore,
    Value<int>? displayOrder,
    Value<String?>? plausibleMin,
    Value<String?>? plausibleMax,
    Value<bool>? isCustom,
    Value<String?>? scopeAdminUnitId,
    Value<String>? reviewStatus,
    Value<int>? rowid,
  }) {
    return ParameterDefinitionsCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      code: code ?? this.code,
      name: name ?? this.name,
      categoryCode: categoryCode ?? this.categoryCode,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      valueType: valueType ?? this.valueType,
      isCore: isCore ?? this.isCore,
      displayOrder: displayOrder ?? this.displayOrder,
      plausibleMin: plausibleMin ?? this.plausibleMin,
      plausibleMax: plausibleMax ?? this.plausibleMax,
      isCustom: isCustom ?? this.isCustom,
      scopeAdminUnitId: scopeAdminUnitId ?? this.scopeAdminUnitId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
    }
    if (defaultUnit.present) {
      map['default_unit'] = Variable<String>(defaultUnit.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (isCore.present) {
      map['is_core'] = Variable<bool>(isCore.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (plausibleMin.present) {
      map['plausible_min'] = Variable<String>(plausibleMin.value);
    }
    if (plausibleMax.present) {
      map['plausible_max'] = Variable<String>(plausibleMax.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (scopeAdminUnitId.present) {
      map['scope_admin_unit_id'] = Variable<String>(scopeAdminUnitId.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParameterDefinitionsCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('defaultUnit: $defaultUnit, ')
          ..write('valueType: $valueType, ')
          ..write('isCore: $isCore, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('plausibleMin: $plausibleMin, ')
          ..write('plausibleMax: $plausibleMax, ')
          ..write('isCustom: $isCustom, ')
          ..write('scopeAdminUnitId: $scopeAdminUnitId, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TesterProfilesTable extends TesterProfiles
    with TableInfo<$TesterProfilesTable, TesterProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TesterProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tdsFactorMeta = const VerificationMeta(
    'tdsFactor',
  );
  @override
  late final GeneratedColumn<String> tdsFactor = GeneratedColumn<String>(
    'tds_factor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parametersMeta = const VerificationMeta(
    'parameters',
  );
  @override
  late final GeneratedColumn<String> parameters = GeneratedColumn<String>(
    'parameters',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    name,
    manufacturer,
    model,
    tdsFactor,
    parameters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tester_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<TesterProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('tds_factor')) {
      context.handle(
        _tdsFactorMeta,
        tdsFactor.isAcceptableOrUnknown(data['tds_factor']!, _tdsFactorMeta),
      );
    }
    if (data.containsKey('parameters')) {
      context.handle(
        _parametersMeta,
        parameters.isAcceptableOrUnknown(data['parameters']!, _parametersMeta),
      );
    } else if (isInserting) {
      context.missing(_parametersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TesterProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TesterProfileRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      tdsFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tds_factor'],
      ),
      parameters: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters'],
      )!,
    );
  }

  @override
  $TesterProfilesTable createAlias(String alias) {
    return $TesterProfilesTable(attachedDatabase, alias);
  }
}

class TesterProfileRow extends DataClass
    implements Insertable<TesterProfileRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String name;
  final String? manufacturer;
  final String? model;
  final String? tdsFactor;

  /// JSON list of `{parameter_code, unit}`.
  final String parameters;
  const TesterProfileRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.name,
    this.manufacturer,
    this.model,
    this.tdsFactor,
    required this.parameters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || tdsFactor != null) {
      map['tds_factor'] = Variable<String>(tdsFactor);
    }
    map['parameters'] = Variable<String>(parameters);
    return map;
  }

  TesterProfilesCompanion toCompanion(bool nullToAbsent) {
    return TesterProfilesCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      name: Value(name),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      tdsFactor: tdsFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsFactor),
      parameters: Value(parameters),
    );
  }

  factory TesterProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TesterProfileRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      tdsFactor: serializer.fromJson<String?>(json['tds_factor']),
      parameters: serializer.fromJson<String>(json['parameters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'tds_factor': serializer.toJson<String?>(tdsFactor),
      'parameters': serializer.toJson<String>(parameters),
    };
  }

  TesterProfileRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? name,
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> tdsFactor = const Value.absent(),
    String? parameters,
  }) => TesterProfileRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    model: model.present ? model.value : this.model,
    tdsFactor: tdsFactor.present ? tdsFactor.value : this.tdsFactor,
    parameters: parameters ?? this.parameters,
  );
  TesterProfileRow copyWithCompanion(TesterProfilesCompanion data) {
    return TesterProfileRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      tdsFactor: data.tdsFactor.present ? data.tdsFactor.value : this.tdsFactor,
      parameters: data.parameters.present
          ? data.parameters.value
          : this.parameters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TesterProfileRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('tdsFactor: $tdsFactor, ')
          ..write('parameters: $parameters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    name,
    manufacturer,
    model,
    tdsFactor,
    parameters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TesterProfileRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.tdsFactor == this.tdsFactor &&
          other.parameters == this.parameters);
}

class TesterProfilesCompanion extends UpdateCompanion<TesterProfileRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> tdsFactor;
  final Value<String> parameters;
  final Value<int> rowid;
  const TesterProfilesCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.tdsFactor = const Value.absent(),
    this.parameters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TesterProfilesCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String name,
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.tdsFactor = const Value.absent(),
    required String parameters,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       parameters = Value(parameters);
  static Insertable<TesterProfileRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? tdsFactor,
    Expression<String>? parameters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (tdsFactor != null) 'tds_factor': tdsFactor,
      if (parameters != null) 'parameters': parameters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TesterProfilesCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? manufacturer,
    Value<String?>? model,
    Value<String?>? tdsFactor,
    Value<String>? parameters,
    Value<int>? rowid,
  }) {
    return TesterProfilesCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      tdsFactor: tdsFactor ?? this.tdsFactor,
      parameters: parameters ?? this.parameters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (tdsFactor.present) {
      map['tds_factor'] = Variable<String>(tdsFactor.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(parameters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TesterProfilesCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('tdsFactor: $tdsFactor, ')
          ..write('parameters: $parameters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferenceProfilesTable extends ReferenceProfiles
    with TableInfo<$ReferenceProfilesTable, ReferenceProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenceProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorSnapshotMeta = const VerificationMeta(
    'collectorSnapshot',
  );
  @override
  late final GeneratedColumn<String> collectorSnapshot =
      GeneratedColumn<String>(
        'collector_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basedOnIdMeta = const VerificationMeta(
    'basedOnId',
  );
  @override
  late final GeneratedColumn<String> basedOnId = GeneratedColumn<String>(
    'based_on_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customReasonMeta = const VerificationMeta(
    'customReason',
  );
  @override
  late final GeneratedColumn<String> customReason = GeneratedColumn<String>(
    'custom_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isProvisionalMeta = const VerificationMeta(
    'isProvisional',
  );
  @override
  late final GeneratedColumn<bool> isProvisional = GeneratedColumn<bool>(
    'is_provisional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_provisional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentMeta = const VerificationMeta(
    'document',
  );
  @override
  late final GeneratedColumn<String> document = GeneratedColumn<String>(
    'document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    code,
    title,
    version,
    basedOnId,
    isCustom,
    customReason,
    isProvisional,
    publishedAt,
    document,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reference_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferenceProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    }
    if (data.containsKey('collector_snapshot')) {
      context.handle(
        _collectorSnapshotMeta,
        collectorSnapshot.isAcceptableOrUnknown(
          data['collector_snapshot']!,
          _collectorSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('based_on_id')) {
      context.handle(
        _basedOnIdMeta,
        basedOnId.isAcceptableOrUnknown(data['based_on_id']!, _basedOnIdMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('custom_reason')) {
      context.handle(
        _customReasonMeta,
        customReason.isAcceptableOrUnknown(
          data['custom_reason']!,
          _customReasonMeta,
        ),
      );
    }
    if (data.containsKey('is_provisional')) {
      context.handle(
        _isProvisionalMeta,
        isProvisional.isAcceptableOrUnknown(
          data['is_provisional']!,
          _isProvisionalMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('document')) {
      context.handle(
        _documentMeta,
        document.isAcceptableOrUnknown(data['document']!, _documentMeta),
      );
    } else if (isInserting) {
      context.missing(_documentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferenceProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenceProfileRow(
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      ),
      collectorSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_snapshot'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      basedOnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}based_on_id'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      customReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_reason'],
      ),
      isProvisional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_provisional'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      document: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document'],
      )!,
    );
  }

  @override
  $ReferenceProfilesTable createAlias(String alias) {
    return $ReferenceProfilesTable(attachedDatabase, alias);
  }
}

class ReferenceProfileRow extends DataClass
    implements Insertable<ReferenceProfileRow> {
  final String? installationId;
  final String? collectorKey;

  /// JSON copy of the collector profile at submission time.
  final String? collectorSnapshot;
  final int? serverSeq;
  final String id;
  final String code;
  final String title;
  final int version;
  final String? basedOnId;
  final bool isCustom;
  final String? customReason;
  final bool isProvisional;
  final DateTime? publishedAt;

  /// Full profile JSON as published (includes `limits`).
  final String document;
  const ReferenceProfileRow({
    this.installationId,
    this.collectorKey,
    this.collectorSnapshot,
    this.serverSeq,
    required this.id,
    required this.code,
    required this.title,
    required this.version,
    this.basedOnId,
    required this.isCustom,
    this.customReason,
    required this.isProvisional,
    this.publishedAt,
    required this.document,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || installationId != null) {
      map['installation_id'] = Variable<String>(installationId);
    }
    if (!nullToAbsent || collectorKey != null) {
      map['collector_key'] = Variable<String>(collectorKey);
    }
    if (!nullToAbsent || collectorSnapshot != null) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || basedOnId != null) {
      map['based_on_id'] = Variable<String>(basedOnId);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || customReason != null) {
      map['custom_reason'] = Variable<String>(customReason);
    }
    map['is_provisional'] = Variable<bool>(isProvisional);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['document'] = Variable<String>(document);
    return map;
  }

  ReferenceProfilesCompanion toCompanion(bool nullToAbsent) {
    return ReferenceProfilesCompanion(
      installationId: installationId == null && nullToAbsent
          ? const Value.absent()
          : Value(installationId),
      collectorKey: collectorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorKey),
      collectorSnapshot: collectorSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorSnapshot),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      code: Value(code),
      title: Value(title),
      version: Value(version),
      basedOnId: basedOnId == null && nullToAbsent
          ? const Value.absent()
          : Value(basedOnId),
      isCustom: Value(isCustom),
      customReason: customReason == null && nullToAbsent
          ? const Value.absent()
          : Value(customReason),
      isProvisional: Value(isProvisional),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      document: Value(document),
    );
  }

  factory ReferenceProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenceProfileRow(
      installationId: serializer.fromJson<String?>(json['installation_id']),
      collectorKey: serializer.fromJson<String?>(json['collector_key']),
      collectorSnapshot: serializer.fromJson<String?>(
        json['collector_snapshot'],
      ),
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      version: serializer.fromJson<int>(json['version']),
      basedOnId: serializer.fromJson<String?>(json['based_on_id']),
      isCustom: serializer.fromJson<bool>(json['is_custom']),
      customReason: serializer.fromJson<String?>(json['custom_reason']),
      isProvisional: serializer.fromJson<bool>(json['is_provisional']),
      publishedAt: serializer.fromJson<DateTime?>(json['published_at']),
      document: serializer.fromJson<String>(json['document']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'installation_id': serializer.toJson<String?>(installationId),
      'collector_key': serializer.toJson<String?>(collectorKey),
      'collector_snapshot': serializer.toJson<String?>(collectorSnapshot),
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'version': serializer.toJson<int>(version),
      'based_on_id': serializer.toJson<String?>(basedOnId),
      'is_custom': serializer.toJson<bool>(isCustom),
      'custom_reason': serializer.toJson<String?>(customReason),
      'is_provisional': serializer.toJson<bool>(isProvisional),
      'published_at': serializer.toJson<DateTime?>(publishedAt),
      'document': serializer.toJson<String>(document),
    };
  }

  ReferenceProfileRow copyWith({
    Value<String?> installationId = const Value.absent(),
    Value<String?> collectorKey = const Value.absent(),
    Value<String?> collectorSnapshot = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? code,
    String? title,
    int? version,
    Value<String?> basedOnId = const Value.absent(),
    bool? isCustom,
    Value<String?> customReason = const Value.absent(),
    bool? isProvisional,
    Value<DateTime?> publishedAt = const Value.absent(),
    String? document,
  }) => ReferenceProfileRow(
    installationId: installationId.present
        ? installationId.value
        : this.installationId,
    collectorKey: collectorKey.present ? collectorKey.value : this.collectorKey,
    collectorSnapshot: collectorSnapshot.present
        ? collectorSnapshot.value
        : this.collectorSnapshot,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    version: version ?? this.version,
    basedOnId: basedOnId.present ? basedOnId.value : this.basedOnId,
    isCustom: isCustom ?? this.isCustom,
    customReason: customReason.present ? customReason.value : this.customReason,
    isProvisional: isProvisional ?? this.isProvisional,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    document: document ?? this.document,
  );
  ReferenceProfileRow copyWithCompanion(ReferenceProfilesCompanion data) {
    return ReferenceProfileRow(
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      collectorSnapshot: data.collectorSnapshot.present
          ? data.collectorSnapshot.value
          : this.collectorSnapshot,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      version: data.version.present ? data.version.value : this.version,
      basedOnId: data.basedOnId.present ? data.basedOnId.value : this.basedOnId,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      customReason: data.customReason.present
          ? data.customReason.value
          : this.customReason,
      isProvisional: data.isProvisional.present
          ? data.isProvisional.value
          : this.isProvisional,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      document: data.document.present ? data.document.value : this.document,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceProfileRow(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('version: $version, ')
          ..write('basedOnId: $basedOnId, ')
          ..write('isCustom: $isCustom, ')
          ..write('customReason: $customReason, ')
          ..write('isProvisional: $isProvisional, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('document: $document')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    installationId,
    collectorKey,
    collectorSnapshot,
    serverSeq,
    id,
    code,
    title,
    version,
    basedOnId,
    isCustom,
    customReason,
    isProvisional,
    publishedAt,
    document,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenceProfileRow &&
          other.installationId == this.installationId &&
          other.collectorKey == this.collectorKey &&
          other.collectorSnapshot == this.collectorSnapshot &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.version == this.version &&
          other.basedOnId == this.basedOnId &&
          other.isCustom == this.isCustom &&
          other.customReason == this.customReason &&
          other.isProvisional == this.isProvisional &&
          other.publishedAt == this.publishedAt &&
          other.document == this.document);
}

class ReferenceProfilesCompanion extends UpdateCompanion<ReferenceProfileRow> {
  final Value<String?> installationId;
  final Value<String?> collectorKey;
  final Value<String?> collectorSnapshot;
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> code;
  final Value<String> title;
  final Value<int> version;
  final Value<String?> basedOnId;
  final Value<bool> isCustom;
  final Value<String?> customReason;
  final Value<bool> isProvisional;
  final Value<DateTime?> publishedAt;
  final Value<String> document;
  final Value<int> rowid;
  const ReferenceProfilesCompanion({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.version = const Value.absent(),
    this.basedOnId = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.customReason = const Value.absent(),
    this.isProvisional = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.document = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenceProfilesCompanion.insert({
    this.installationId = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.collectorSnapshot = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String id,
    required String code,
    required String title,
    required int version,
    this.basedOnId = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.customReason = const Value.absent(),
    this.isProvisional = const Value.absent(),
    this.publishedAt = const Value.absent(),
    required String document,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       title = Value(title),
       version = Value(version),
       document = Value(document);
  static Insertable<ReferenceProfileRow> custom({
    Expression<String>? installationId,
    Expression<String>? collectorKey,
    Expression<String>? collectorSnapshot,
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<int>? version,
    Expression<String>? basedOnId,
    Expression<bool>? isCustom,
    Expression<String>? customReason,
    Expression<bool>? isProvisional,
    Expression<DateTime>? publishedAt,
    Expression<String>? document,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (installationId != null) 'installation_id': installationId,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (collectorSnapshot != null) 'collector_snapshot': collectorSnapshot,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (version != null) 'version': version,
      if (basedOnId != null) 'based_on_id': basedOnId,
      if (isCustom != null) 'is_custom': isCustom,
      if (customReason != null) 'custom_reason': customReason,
      if (isProvisional != null) 'is_provisional': isProvisional,
      if (publishedAt != null) 'published_at': publishedAt,
      if (document != null) 'document': document,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenceProfilesCompanion copyWith({
    Value<String?>? installationId,
    Value<String?>? collectorKey,
    Value<String?>? collectorSnapshot,
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? code,
    Value<String>? title,
    Value<int>? version,
    Value<String?>? basedOnId,
    Value<bool>? isCustom,
    Value<String?>? customReason,
    Value<bool>? isProvisional,
    Value<DateTime?>? publishedAt,
    Value<String>? document,
    Value<int>? rowid,
  }) {
    return ReferenceProfilesCompanion(
      installationId: installationId ?? this.installationId,
      collectorKey: collectorKey ?? this.collectorKey,
      collectorSnapshot: collectorSnapshot ?? this.collectorSnapshot,
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      version: version ?? this.version,
      basedOnId: basedOnId ?? this.basedOnId,
      isCustom: isCustom ?? this.isCustom,
      customReason: customReason ?? this.customReason,
      isProvisional: isProvisional ?? this.isProvisional,
      publishedAt: publishedAt ?? this.publishedAt,
      document: document ?? this.document,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (collectorSnapshot.present) {
      map['collector_snapshot'] = Variable<String>(collectorSnapshot.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (basedOnId.present) {
      map['based_on_id'] = Variable<String>(basedOnId.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (customReason.present) {
      map['custom_reason'] = Variable<String>(customReason.value);
    }
    if (isProvisional.present) {
      map['is_provisional'] = Variable<bool>(isProvisional.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (document.present) {
      map['document'] = Variable<String>(document.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenceProfilesCompanion(')
          ..write('installationId: $installationId, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('collectorSnapshot: $collectorSnapshot, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('version: $version, ')
          ..write('basedOnId: $basedOnId, ')
          ..write('isCustom: $isCustom, ')
          ..write('customReason: $customReason, ')
          ..write('isProvisional: $isProvisional, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('document: $document, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponseCardsTable extends ResponseCards
    with TableInfo<$ResponseCardsTable, ResponseCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponseCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerRuleMeta = const VerificationMeta(
    'triggerRule',
  );
  @override
  late final GeneratedColumn<String> triggerRule = GeneratedColumn<String>(
    'trigger_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audienceMeta = const VerificationMeta(
    'audience',
  );
  @override
  late final GeneratedColumn<String> audience = GeneratedColumn<String>(
    'audience',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    id,
    triggerRule,
    audience,
    version,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'response_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResponseCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trigger_rule')) {
      context.handle(
        _triggerRuleMeta,
        triggerRule.isAcceptableOrUnknown(
          data['trigger_rule']!,
          _triggerRuleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerRuleMeta);
    }
    if (data.containsKey('audience')) {
      context.handle(
        _audienceMeta,
        audience.isAcceptableOrUnknown(data['audience']!, _audienceMeta),
      );
    } else if (isInserting) {
      context.missing(_audienceMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResponseCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResponseCardRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      triggerRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_rule'],
      )!,
      audience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $ResponseCardsTable createAlias(String alias) {
    return $ResponseCardsTable(attachedDatabase, alias);
  }
}

class ResponseCardRow extends DataClass implements Insertable<ResponseCardRow> {
  final int? serverSeq;
  final String id;
  final String triggerRule;
  final String audience;
  final int version;

  /// JSON: title, actions (list), reportTo (list). English only (ADR-007).
  final String content;
  const ResponseCardRow({
    this.serverSeq,
    required this.id,
    required this.triggerRule,
    required this.audience,
    required this.version,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['trigger_rule'] = Variable<String>(triggerRule);
    map['audience'] = Variable<String>(audience);
    map['version'] = Variable<int>(version);
    map['content'] = Variable<String>(content);
    return map;
  }

  ResponseCardsCompanion toCompanion(bool nullToAbsent) {
    return ResponseCardsCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      triggerRule: Value(triggerRule),
      audience: Value(audience),
      version: Value(version),
      content: Value(content),
    );
  }

  factory ResponseCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResponseCardRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      triggerRule: serializer.fromJson<String>(json['trigger_rule']),
      audience: serializer.fromJson<String>(json['audience']),
      version: serializer.fromJson<int>(json['version']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'trigger_rule': serializer.toJson<String>(triggerRule),
      'audience': serializer.toJson<String>(audience),
      'version': serializer.toJson<int>(version),
      'content': serializer.toJson<String>(content),
    };
  }

  ResponseCardRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? triggerRule,
    String? audience,
    int? version,
    String? content,
  }) => ResponseCardRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    triggerRule: triggerRule ?? this.triggerRule,
    audience: audience ?? this.audience,
    version: version ?? this.version,
    content: content ?? this.content,
  );
  ResponseCardRow copyWithCompanion(ResponseCardsCompanion data) {
    return ResponseCardRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      triggerRule: data.triggerRule.present
          ? data.triggerRule.value
          : this.triggerRule,
      audience: data.audience.present ? data.audience.value : this.audience,
      version: data.version.present ? data.version.value : this.version,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResponseCardRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('triggerRule: $triggerRule, ')
          ..write('audience: $audience, ')
          ..write('version: $version, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(serverSeq, id, triggerRule, audience, version, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponseCardRow &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.triggerRule == this.triggerRule &&
          other.audience == this.audience &&
          other.version == this.version &&
          other.content == this.content);
}

class ResponseCardsCompanion extends UpdateCompanion<ResponseCardRow> {
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> triggerRule;
  final Value<String> audience;
  final Value<int> version;
  final Value<String> content;
  final Value<int> rowid;
  const ResponseCardsCompanion({
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.triggerRule = const Value.absent(),
    this.audience = const Value.absent(),
    this.version = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResponseCardsCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String id,
    required String triggerRule,
    required String audience,
    required int version,
    required String content,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       triggerRule = Value(triggerRule),
       audience = Value(audience),
       version = Value(version),
       content = Value(content);
  static Insertable<ResponseCardRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? triggerRule,
    Expression<String>? audience,
    Expression<int>? version,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (triggerRule != null) 'trigger_rule': triggerRule,
      if (audience != null) 'audience': audience,
      if (version != null) 'version': version,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResponseCardsCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? triggerRule,
    Value<String>? audience,
    Value<int>? version,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return ResponseCardsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      triggerRule: triggerRule ?? this.triggerRule,
      audience: audience ?? this.audience,
      version: version ?? this.version,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (triggerRule.present) {
      map['trigger_rule'] = Variable<String>(triggerRule.value);
    }
    if (audience.present) {
      map['audience'] = Variable<String>(audience.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponseCardsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('triggerRule: $triggerRule, ')
          ..write('audience: $audience, ')
          ..write('version: $version, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponsibilitiesTable extends Responsibilities
    with TableInfo<$ResponsibilitiesTable, ResponsibilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponsibilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'responsibilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResponsibilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  ResponsibilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResponsibilityRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ResponsibilitiesTable createAlias(String alias) {
    return $ResponsibilitiesTable(attachedDatabase, alias);
  }
}

class ResponsibilityRow extends DataClass
    implements Insertable<ResponsibilityRow> {
  final String code;
  final String name;
  const ResponsibilityRow({required this.code, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    return map;
  }

  ResponsibilitiesCompanion toCompanion(bool nullToAbsent) {
    return ResponsibilitiesCompanion(code: Value(code), name: Value(name));
  }

  factory ResponsibilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResponsibilityRow(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
    };
  }

  ResponsibilityRow copyWith({String? code, String? name}) =>
      ResponsibilityRow(code: code ?? this.code, name: name ?? this.name);
  ResponsibilityRow copyWithCompanion(ResponsibilitiesCompanion data) {
    return ResponsibilityRow(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResponsibilityRow(')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponsibilityRow &&
          other.code == this.code &&
          other.name == this.name);
}

class ResponsibilitiesCompanion extends UpdateCompanion<ResponsibilityRow> {
  final Value<String> code;
  final Value<String> name;
  final Value<int> rowid;
  const ResponsibilitiesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResponsibilitiesCompanion.insert({
    required String code,
    required String name,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<ResponsibilityRow> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResponsibilitiesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ResponsibilitiesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponsibilitiesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigDocumentsTable extends ConfigDocuments
    with TableInfo<$ConfigDocumentsTable, ConfigDocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentMeta = const VerificationMeta(
    'document',
  );
  @override
  late final GeneratedColumn<String> document = GeneratedColumn<String>(
    'document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, document, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigDocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('document')) {
      context.handle(
        _documentMeta,
        document.isAcceptableOrUnknown(data['document']!, _documentMeta),
      );
    } else if (isInserting) {
      context.missing(_documentMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ConfigDocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigDocumentRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      document: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ConfigDocumentsTable createAlias(String alias) {
    return $ConfigDocumentsTable(attachedDatabase, alias);
  }
}

class ConfigDocumentRow extends DataClass
    implements Insertable<ConfigDocumentRow> {
  final String key;
  final String document;
  final int version;
  const ConfigDocumentRow({
    required this.key,
    required this.document,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['document'] = Variable<String>(document);
    map['version'] = Variable<int>(version);
    return map;
  }

  ConfigDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ConfigDocumentsCompanion(
      key: Value(key),
      document: Value(document),
      version: Value(version),
    );
  }

  factory ConfigDocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigDocumentRow(
      key: serializer.fromJson<String>(json['key']),
      document: serializer.fromJson<String>(json['document']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'document': serializer.toJson<String>(document),
      'version': serializer.toJson<int>(version),
    };
  }

  ConfigDocumentRow copyWith({String? key, String? document, int? version}) =>
      ConfigDocumentRow(
        key: key ?? this.key,
        document: document ?? this.document,
        version: version ?? this.version,
      );
  ConfigDocumentRow copyWithCompanion(ConfigDocumentsCompanion data) {
    return ConfigDocumentRow(
      key: data.key.present ? data.key.value : this.key,
      document: data.document.present ? data.document.value : this.document,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigDocumentRow(')
          ..write('key: $key, ')
          ..write('document: $document, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, document, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigDocumentRow &&
          other.key == this.key &&
          other.document == this.document &&
          other.version == this.version);
}

class ConfigDocumentsCompanion extends UpdateCompanion<ConfigDocumentRow> {
  final Value<String> key;
  final Value<String> document;
  final Value<int> version;
  final Value<int> rowid;
  const ConfigDocumentsCompanion({
    this.key = const Value.absent(),
    this.document = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigDocumentsCompanion.insert({
    required String key,
    required String document,
    required int version,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       document = Value(document),
       version = Value(version);
  static Insertable<ConfigDocumentRow> custom({
    Expression<String>? key,
    Expression<String>? document,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (document != null) 'document': document,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigDocumentsCompanion copyWith({
    Value<String>? key,
    Value<String>? document,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ConfigDocumentsCompanion(
      key: key ?? this.key,
      document: document ?? this.document,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (document.present) {
      map['document'] = Variable<String>(document.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigDocumentsCompanion(')
          ..write('key: $key, ')
          ..write('document: $document, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeedImportsTable extends SeedImports
    with TableInfo<$SeedImportsTable, SeedImportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeedImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, version, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seed_imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeedImportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SeedImportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeedImportRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $SeedImportsTable createAlias(String alias) {
    return $SeedImportsTable(attachedDatabase, alias);
  }
}

class SeedImportRow extends DataClass implements Insertable<SeedImportRow> {
  final String name;
  final int version;
  final DateTime importedAt;
  const SeedImportRow({
    required this.name,
    required this.version,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  SeedImportsCompanion toCompanion(bool nullToAbsent) {
    return SeedImportsCompanion(
      name: Value(name),
      version: Value(version),
      importedAt: Value(importedAt),
    );
  }

  factory SeedImportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeedImportRow(
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      importedAt: serializer.fromJson<DateTime>(json['imported_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'imported_at': serializer.toJson<DateTime>(importedAt),
    };
  }

  SeedImportRow copyWith({String? name, int? version, DateTime? importedAt}) =>
      SeedImportRow(
        name: name ?? this.name,
        version: version ?? this.version,
        importedAt: importedAt ?? this.importedAt,
      );
  SeedImportRow copyWithCompanion(SeedImportsCompanion data) {
    return SeedImportRow(
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeedImportRow(')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, version, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeedImportRow &&
          other.name == this.name &&
          other.version == this.version &&
          other.importedAt == this.importedAt);
}

class SeedImportsCompanion extends UpdateCompanion<SeedImportRow> {
  final Value<String> name;
  final Value<int> version;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const SeedImportsCompanion({
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeedImportsCompanion.insert({
    required String name,
    required int version,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       version = Value(version),
       importedAt = Value(importedAt);
  static Insertable<SeedImportRow> custom({
    Expression<String>? name,
    Expression<int>? version,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeedImportsCompanion copyWith({
    Value<String>? name,
    Value<int>? version,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return SeedImportsCompanion(
      name: name ?? this.name,
      version: version ?? this.version,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeedImportsCompanion(')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectorProfilesTable extends CollectorProfiles
    with TableInfo<$CollectorProfilesTable, CollectorProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectorProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileVersionMeta = const VerificationMeta(
    'profileVersion',
  );
  @override
  late final GeneratedColumn<int> profileVersion = GeneratedColumn<int>(
    'profile_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectorTypeMeta = const VerificationMeta(
    'collectorType',
  );
  @override
  late final GeneratedColumn<String> collectorType = GeneratedColumn<String>(
    'collector_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parishMeta = const VerificationMeta('parish');
  @override
  late final GeneratedColumn<String> parish = GeneratedColumn<String>(
    'parish',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcountyMeta = const VerificationMeta(
    'subcounty',
  );
  @override
  late final GeneratedColumn<String> subcounty = GeneratedColumn<String>(
    'subcounty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organisationMeta = const VerificationMeta(
    'organisation',
  );
  @override
  late final GeneratedColumn<String> organisation = GeneratedColumn<String>(
    'organisation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectorKey,
    profileVersion,
    fullName,
    phone,
    collectorType,
    village,
    parish,
    subcounty,
    district,
    organisation,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collector_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectorProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorKeyMeta);
    }
    if (data.containsKey('profile_version')) {
      context.handle(
        _profileVersionMeta,
        profileVersion.isAcceptableOrUnknown(
          data['profile_version']!,
          _profileVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_profileVersionMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('collector_type')) {
      context.handle(
        _collectorTypeMeta,
        collectorType.isAcceptableOrUnknown(
          data['collector_type']!,
          _collectorTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorTypeMeta);
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    } else if (isInserting) {
      context.missing(_villageMeta);
    }
    if (data.containsKey('parish')) {
      context.handle(
        _parishMeta,
        parish.isAcceptableOrUnknown(data['parish']!, _parishMeta),
      );
    } else if (isInserting) {
      context.missing(_parishMeta);
    }
    if (data.containsKey('subcounty')) {
      context.handle(
        _subcountyMeta,
        subcounty.isAcceptableOrUnknown(data['subcounty']!, _subcountyMeta),
      );
    } else if (isInserting) {
      context.missing(_subcountyMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('organisation')) {
      context.handle(
        _organisationMeta,
        organisation.isAcceptableOrUnknown(
          data['organisation']!,
          _organisationMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectorKey};
  @override
  CollectorProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectorProfileRow(
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      )!,
      profileVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_version'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      collectorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_type'],
      )!,
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      )!,
      parish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parish'],
      )!,
      subcounty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcounty'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
      organisation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organisation'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectorProfilesTable createAlias(String alias) {
    return $CollectorProfilesTable(attachedDatabase, alias);
  }
}

class CollectorProfileRow extends DataClass
    implements Insertable<CollectorProfileRow> {
  final String collectorKey;
  final int profileVersion;
  final String fullName;
  final String phone;
  final String collectorType;
  final String village;
  final String parish;
  final String subcounty;
  final String district;
  final String? organisation;
  final bool isActive;
  final DateTime updatedAt;
  const CollectorProfileRow({
    required this.collectorKey,
    required this.profileVersion,
    required this.fullName,
    required this.phone,
    required this.collectorType,
    required this.village,
    required this.parish,
    required this.subcounty,
    required this.district,
    this.organisation,
    required this.isActive,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collector_key'] = Variable<String>(collectorKey);
    map['profile_version'] = Variable<int>(profileVersion);
    map['full_name'] = Variable<String>(fullName);
    map['phone'] = Variable<String>(phone);
    map['collector_type'] = Variable<String>(collectorType);
    map['village'] = Variable<String>(village);
    map['parish'] = Variable<String>(parish);
    map['subcounty'] = Variable<String>(subcounty);
    map['district'] = Variable<String>(district);
    if (!nullToAbsent || organisation != null) {
      map['organisation'] = Variable<String>(organisation);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectorProfilesCompanion toCompanion(bool nullToAbsent) {
    return CollectorProfilesCompanion(
      collectorKey: Value(collectorKey),
      profileVersion: Value(profileVersion),
      fullName: Value(fullName),
      phone: Value(phone),
      collectorType: Value(collectorType),
      village: Value(village),
      parish: Value(parish),
      subcounty: Value(subcounty),
      district: Value(district),
      organisation: organisation == null && nullToAbsent
          ? const Value.absent()
          : Value(organisation),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectorProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectorProfileRow(
      collectorKey: serializer.fromJson<String>(json['collector_key']),
      profileVersion: serializer.fromJson<int>(json['profile_version']),
      fullName: serializer.fromJson<String>(json['full_name']),
      phone: serializer.fromJson<String>(json['phone']),
      collectorType: serializer.fromJson<String>(json['collector_type']),
      village: serializer.fromJson<String>(json['village']),
      parish: serializer.fromJson<String>(json['parish']),
      subcounty: serializer.fromJson<String>(json['subcounty']),
      district: serializer.fromJson<String>(json['district']),
      organisation: serializer.fromJson<String?>(json['organisation']),
      isActive: serializer.fromJson<bool>(json['is_active']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collector_key': serializer.toJson<String>(collectorKey),
      'profile_version': serializer.toJson<int>(profileVersion),
      'full_name': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String>(phone),
      'collector_type': serializer.toJson<String>(collectorType),
      'village': serializer.toJson<String>(village),
      'parish': serializer.toJson<String>(parish),
      'subcounty': serializer.toJson<String>(subcounty),
      'district': serializer.toJson<String>(district),
      'organisation': serializer.toJson<String?>(organisation),
      'is_active': serializer.toJson<bool>(isActive),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectorProfileRow copyWith({
    String? collectorKey,
    int? profileVersion,
    String? fullName,
    String? phone,
    String? collectorType,
    String? village,
    String? parish,
    String? subcounty,
    String? district,
    Value<String?> organisation = const Value.absent(),
    bool? isActive,
    DateTime? updatedAt,
  }) => CollectorProfileRow(
    collectorKey: collectorKey ?? this.collectorKey,
    profileVersion: profileVersion ?? this.profileVersion,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    collectorType: collectorType ?? this.collectorType,
    village: village ?? this.village,
    parish: parish ?? this.parish,
    subcounty: subcounty ?? this.subcounty,
    district: district ?? this.district,
    organisation: organisation.present ? organisation.value : this.organisation,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectorProfileRow copyWithCompanion(CollectorProfilesCompanion data) {
    return CollectorProfileRow(
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      profileVersion: data.profileVersion.present
          ? data.profileVersion.value
          : this.profileVersion,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      collectorType: data.collectorType.present
          ? data.collectorType.value
          : this.collectorType,
      village: data.village.present ? data.village.value : this.village,
      parish: data.parish.present ? data.parish.value : this.parish,
      subcounty: data.subcounty.present ? data.subcounty.value : this.subcounty,
      district: data.district.present ? data.district.value : this.district,
      organisation: data.organisation.present
          ? data.organisation.value
          : this.organisation,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectorProfileRow(')
          ..write('collectorKey: $collectorKey, ')
          ..write('profileVersion: $profileVersion, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('collectorType: $collectorType, ')
          ..write('village: $village, ')
          ..write('parish: $parish, ')
          ..write('subcounty: $subcounty, ')
          ..write('district: $district, ')
          ..write('organisation: $organisation, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    collectorKey,
    profileVersion,
    fullName,
    phone,
    collectorType,
    village,
    parish,
    subcounty,
    district,
    organisation,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectorProfileRow &&
          other.collectorKey == this.collectorKey &&
          other.profileVersion == this.profileVersion &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.collectorType == this.collectorType &&
          other.village == this.village &&
          other.parish == this.parish &&
          other.subcounty == this.subcounty &&
          other.district == this.district &&
          other.organisation == this.organisation &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CollectorProfilesCompanion extends UpdateCompanion<CollectorProfileRow> {
  final Value<String> collectorKey;
  final Value<int> profileVersion;
  final Value<String> fullName;
  final Value<String> phone;
  final Value<String> collectorType;
  final Value<String> village;
  final Value<String> parish;
  final Value<String> subcounty;
  final Value<String> district;
  final Value<String?> organisation;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollectorProfilesCompanion({
    this.collectorKey = const Value.absent(),
    this.profileVersion = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.collectorType = const Value.absent(),
    this.village = const Value.absent(),
    this.parish = const Value.absent(),
    this.subcounty = const Value.absent(),
    this.district = const Value.absent(),
    this.organisation = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectorProfilesCompanion.insert({
    required String collectorKey,
    required int profileVersion,
    required String fullName,
    required String phone,
    required String collectorType,
    required String village,
    required String parish,
    required String subcounty,
    required String district,
    this.organisation = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : collectorKey = Value(collectorKey),
       profileVersion = Value(profileVersion),
       fullName = Value(fullName),
       phone = Value(phone),
       collectorType = Value(collectorType),
       village = Value(village),
       parish = Value(parish),
       subcounty = Value(subcounty),
       district = Value(district),
       updatedAt = Value(updatedAt);
  static Insertable<CollectorProfileRow> custom({
    Expression<String>? collectorKey,
    Expression<int>? profileVersion,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? collectorType,
    Expression<String>? village,
    Expression<String>? parish,
    Expression<String>? subcounty,
    Expression<String>? district,
    Expression<String>? organisation,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectorKey != null) 'collector_key': collectorKey,
      if (profileVersion != null) 'profile_version': profileVersion,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (collectorType != null) 'collector_type': collectorType,
      if (village != null) 'village': village,
      if (parish != null) 'parish': parish,
      if (subcounty != null) 'subcounty': subcounty,
      if (district != null) 'district': district,
      if (organisation != null) 'organisation': organisation,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectorProfilesCompanion copyWith({
    Value<String>? collectorKey,
    Value<int>? profileVersion,
    Value<String>? fullName,
    Value<String>? phone,
    Value<String>? collectorType,
    Value<String>? village,
    Value<String>? parish,
    Value<String>? subcounty,
    Value<String>? district,
    Value<String?>? organisation,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollectorProfilesCompanion(
      collectorKey: collectorKey ?? this.collectorKey,
      profileVersion: profileVersion ?? this.profileVersion,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      collectorType: collectorType ?? this.collectorType,
      village: village ?? this.village,
      parish: parish ?? this.parish,
      subcounty: subcounty ?? this.subcounty,
      district: district ?? this.district,
      organisation: organisation ?? this.organisation,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (profileVersion.present) {
      map['profile_version'] = Variable<int>(profileVersion.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (collectorType.present) {
      map['collector_type'] = Variable<String>(collectorType.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (parish.present) {
      map['parish'] = Variable<String>(parish.value);
    }
    if (subcounty.present) {
      map['subcounty'] = Variable<String>(subcounty.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (organisation.present) {
      map['organisation'] = Variable<String>(organisation.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectorProfilesCompanion(')
          ..write('collectorKey: $collectorKey, ')
          ..write('profileVersion: $profileVersion, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('collectorType: $collectorType, ')
          ..write('village: $village, ')
          ..write('parish: $parish, ')
          ..write('subcounty: $subcounty, ')
          ..write('district: $district, ')
          ..write('organisation: $organisation, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassificationsTable extends Classifications
    with TableInfo<$ClassificationsTable, ClassificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resultIdMeta = const VerificationMeta(
    'resultId',
  );
  @override
  late final GeneratedColumn<String> resultId = GeneratedColumn<String>(
    'result_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _standardIdMeta = const VerificationMeta(
    'standardId',
  );
  @override
  late final GeneratedColumn<String> standardId = GeneratedColumn<String>(
    'standard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedByMeta = const VerificationMeta(
    'computedBy',
  );
  @override
  late final GeneratedColumn<String> computedBy = GeneratedColumn<String>(
    'computed_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallMeta = const VerificationMeta(
    'overall',
  );
  @override
  late final GeneratedColumn<String> overall = GeneratedColumn<String>(
    'overall',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingResultsMeta = const VerificationMeta(
    'readingResults',
  );
  @override
  late final GeneratedColumn<String> readingResults = GeneratedColumn<String>(
    'reading_results',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<String> flags = GeneratedColumn<String>(
    'flags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resultId,
    standardId,
    computedBy,
    overall,
    readingResults,
    flags,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassificationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('result_id')) {
      context.handle(
        _resultIdMeta,
        resultId.isAcceptableOrUnknown(data['result_id']!, _resultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resultIdMeta);
    }
    if (data.containsKey('standard_id')) {
      context.handle(
        _standardIdMeta,
        standardId.isAcceptableOrUnknown(data['standard_id']!, _standardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_standardIdMeta);
    }
    if (data.containsKey('computed_by')) {
      context.handle(
        _computedByMeta,
        computedBy.isAcceptableOrUnknown(data['computed_by']!, _computedByMeta),
      );
    } else if (isInserting) {
      context.missing(_computedByMeta);
    }
    if (data.containsKey('overall')) {
      context.handle(
        _overallMeta,
        overall.isAcceptableOrUnknown(data['overall']!, _overallMeta),
      );
    } else if (isInserting) {
      context.missing(_overallMeta);
    }
    if (data.containsKey('reading_results')) {
      context.handle(
        _readingResultsMeta,
        readingResults.isAcceptableOrUnknown(
          data['reading_results']!,
          _readingResultsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingResultsMeta);
    }
    if (data.containsKey('flags')) {
      context.handle(
        _flagsMeta,
        flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta),
      );
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resultId, standardId, computedBy};
  @override
  ClassificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassificationRow(
      resultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_id'],
      )!,
      standardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}standard_id'],
      )!,
      computedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computed_by'],
      )!,
      overall: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall'],
      )!,
      readingResults: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_results'],
      )!,
      flags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flags'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
    );
  }

  @override
  $ClassificationsTable createAlias(String alias) {
    return $ClassificationsTable(attachedDatabase, alias);
  }
}

class ClassificationRow extends DataClass
    implements Insertable<ClassificationRow> {
  final String resultId;
  final String standardId;
  final String computedBy;
  final String overall;
  final String readingResults;
  final String flags;
  final DateTime computedAt;
  const ClassificationRow({
    required this.resultId,
    required this.standardId,
    required this.computedBy,
    required this.overall,
    required this.readingResults,
    required this.flags,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['result_id'] = Variable<String>(resultId);
    map['standard_id'] = Variable<String>(standardId);
    map['computed_by'] = Variable<String>(computedBy);
    map['overall'] = Variable<String>(overall);
    map['reading_results'] = Variable<String>(readingResults);
    map['flags'] = Variable<String>(flags);
    map['computed_at'] = Variable<DateTime>(computedAt);
    return map;
  }

  ClassificationsCompanion toCompanion(bool nullToAbsent) {
    return ClassificationsCompanion(
      resultId: Value(resultId),
      standardId: Value(standardId),
      computedBy: Value(computedBy),
      overall: Value(overall),
      readingResults: Value(readingResults),
      flags: Value(flags),
      computedAt: Value(computedAt),
    );
  }

  factory ClassificationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassificationRow(
      resultId: serializer.fromJson<String>(json['result_id']),
      standardId: serializer.fromJson<String>(json['standard_id']),
      computedBy: serializer.fromJson<String>(json['computed_by']),
      overall: serializer.fromJson<String>(json['overall']),
      readingResults: serializer.fromJson<String>(json['reading_results']),
      flags: serializer.fromJson<String>(json['flags']),
      computedAt: serializer.fromJson<DateTime>(json['computed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'result_id': serializer.toJson<String>(resultId),
      'standard_id': serializer.toJson<String>(standardId),
      'computed_by': serializer.toJson<String>(computedBy),
      'overall': serializer.toJson<String>(overall),
      'reading_results': serializer.toJson<String>(readingResults),
      'flags': serializer.toJson<String>(flags),
      'computed_at': serializer.toJson<DateTime>(computedAt),
    };
  }

  ClassificationRow copyWith({
    String? resultId,
    String? standardId,
    String? computedBy,
    String? overall,
    String? readingResults,
    String? flags,
    DateTime? computedAt,
  }) => ClassificationRow(
    resultId: resultId ?? this.resultId,
    standardId: standardId ?? this.standardId,
    computedBy: computedBy ?? this.computedBy,
    overall: overall ?? this.overall,
    readingResults: readingResults ?? this.readingResults,
    flags: flags ?? this.flags,
    computedAt: computedAt ?? this.computedAt,
  );
  ClassificationRow copyWithCompanion(ClassificationsCompanion data) {
    return ClassificationRow(
      resultId: data.resultId.present ? data.resultId.value : this.resultId,
      standardId: data.standardId.present
          ? data.standardId.value
          : this.standardId,
      computedBy: data.computedBy.present
          ? data.computedBy.value
          : this.computedBy,
      overall: data.overall.present ? data.overall.value : this.overall,
      readingResults: data.readingResults.present
          ? data.readingResults.value
          : this.readingResults,
      flags: data.flags.present ? data.flags.value : this.flags,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassificationRow(')
          ..write('resultId: $resultId, ')
          ..write('standardId: $standardId, ')
          ..write('computedBy: $computedBy, ')
          ..write('overall: $overall, ')
          ..write('readingResults: $readingResults, ')
          ..write('flags: $flags, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resultId,
    standardId,
    computedBy,
    overall,
    readingResults,
    flags,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassificationRow &&
          other.resultId == this.resultId &&
          other.standardId == this.standardId &&
          other.computedBy == this.computedBy &&
          other.overall == this.overall &&
          other.readingResults == this.readingResults &&
          other.flags == this.flags &&
          other.computedAt == this.computedAt);
}

class ClassificationsCompanion extends UpdateCompanion<ClassificationRow> {
  final Value<String> resultId;
  final Value<String> standardId;
  final Value<String> computedBy;
  final Value<String> overall;
  final Value<String> readingResults;
  final Value<String> flags;
  final Value<DateTime> computedAt;
  final Value<int> rowid;
  const ClassificationsCompanion({
    this.resultId = const Value.absent(),
    this.standardId = const Value.absent(),
    this.computedBy = const Value.absent(),
    this.overall = const Value.absent(),
    this.readingResults = const Value.absent(),
    this.flags = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassificationsCompanion.insert({
    required String resultId,
    required String standardId,
    required String computedBy,
    required String overall,
    required String readingResults,
    this.flags = const Value.absent(),
    required DateTime computedAt,
    this.rowid = const Value.absent(),
  }) : resultId = Value(resultId),
       standardId = Value(standardId),
       computedBy = Value(computedBy),
       overall = Value(overall),
       readingResults = Value(readingResults),
       computedAt = Value(computedAt);
  static Insertable<ClassificationRow> custom({
    Expression<String>? resultId,
    Expression<String>? standardId,
    Expression<String>? computedBy,
    Expression<String>? overall,
    Expression<String>? readingResults,
    Expression<String>? flags,
    Expression<DateTime>? computedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resultId != null) 'result_id': resultId,
      if (standardId != null) 'standard_id': standardId,
      if (computedBy != null) 'computed_by': computedBy,
      if (overall != null) 'overall': overall,
      if (readingResults != null) 'reading_results': readingResults,
      if (flags != null) 'flags': flags,
      if (computedAt != null) 'computed_at': computedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassificationsCompanion copyWith({
    Value<String>? resultId,
    Value<String>? standardId,
    Value<String>? computedBy,
    Value<String>? overall,
    Value<String>? readingResults,
    Value<String>? flags,
    Value<DateTime>? computedAt,
    Value<int>? rowid,
  }) {
    return ClassificationsCompanion(
      resultId: resultId ?? this.resultId,
      standardId: standardId ?? this.standardId,
      computedBy: computedBy ?? this.computedBy,
      overall: overall ?? this.overall,
      readingResults: readingResults ?? this.readingResults,
      flags: flags ?? this.flags,
      computedAt: computedAt ?? this.computedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resultId.present) {
      map['result_id'] = Variable<String>(resultId.value);
    }
    if (standardId.present) {
      map['standard_id'] = Variable<String>(standardId.value);
    }
    if (computedBy.present) {
      map['computed_by'] = Variable<String>(computedBy.value);
    }
    if (overall.present) {
      map['overall'] = Variable<String>(overall.value);
    }
    if (readingResults.present) {
      map['reading_results'] = Variable<String>(readingResults.value);
    }
    if (flags.present) {
      map['flags'] = Variable<String>(flags.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassificationsCompanion(')
          ..write('resultId: $resultId, ')
          ..write('standardId: $standardId, ')
          ..write('computedBy: $computedBy, ')
          ..write('overall: $overall, ')
          ..write('readingResults: $readingResults, ')
          ..write('flags: $flags, ')
          ..write('computedAt: $computedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectKeyMeta = const VerificationMeta(
    'objectKey',
  );
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadStatusMeta = const VerificationMeta(
    'uploadStatus',
  );
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    id,
    ownerType,
    ownerId,
    objectKey,
    sha256,
    bytes,
    mime,
    uploadStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('object_key')) {
      context.handle(
        _objectKeyMeta,
        objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('upload_status')) {
      context.handle(
        _uploadStatusMeta,
        uploadStatus.isAcceptableOrUnknown(
          data['upload_status']!,
          _uploadStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      objectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_key'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      uploadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_status'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final int? serverSeq;
  final String id;
  final String ownerType;
  final String ownerId;
  final String? objectKey;
  final String sha256;
  final int bytes;
  final String mime;
  final String uploadStatus;
  const AttachmentRow({
    this.serverSeq,
    required this.id,
    required this.ownerType,
    required this.ownerId,
    this.objectKey,
    required this.sha256,
    required this.bytes,
    required this.mime,
    required this.uploadStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || objectKey != null) {
      map['object_key'] = Variable<String>(objectKey);
    }
    map['sha256'] = Variable<String>(sha256);
    map['bytes'] = Variable<int>(bytes);
    map['mime'] = Variable<String>(mime);
    map['upload_status'] = Variable<String>(uploadStatus);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      objectKey: objectKey == null && nullToAbsent
          ? const Value.absent()
          : Value(objectKey),
      sha256: Value(sha256),
      bytes: Value(bytes),
      mime: Value(mime),
      uploadStatus: Value(uploadStatus),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      ownerType: serializer.fromJson<String>(json['owner_type']),
      ownerId: serializer.fromJson<String>(json['owner_id']),
      objectKey: serializer.fromJson<String?>(json['object_key']),
      sha256: serializer.fromJson<String>(json['sha256']),
      bytes: serializer.fromJson<int>(json['bytes']),
      mime: serializer.fromJson<String>(json['mime']),
      uploadStatus: serializer.fromJson<String>(json['upload_status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'owner_type': serializer.toJson<String>(ownerType),
      'owner_id': serializer.toJson<String>(ownerId),
      'object_key': serializer.toJson<String?>(objectKey),
      'sha256': serializer.toJson<String>(sha256),
      'bytes': serializer.toJson<int>(bytes),
      'mime': serializer.toJson<String>(mime),
      'upload_status': serializer.toJson<String>(uploadStatus),
    };
  }

  AttachmentRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? ownerType,
    String? ownerId,
    Value<String?> objectKey = const Value.absent(),
    String? sha256,
    int? bytes,
    String? mime,
    String? uploadStatus,
  }) => AttachmentRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    objectKey: objectKey.present ? objectKey.value : this.objectKey,
    sha256: sha256 ?? this.sha256,
    bytes: bytes ?? this.bytes,
    mime: mime ?? this.mime,
    uploadStatus: uploadStatus ?? this.uploadStatus,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      mime: data.mime.present ? data.mime.value : this.mime,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('objectKey: $objectKey, ')
          ..write('sha256: $sha256, ')
          ..write('bytes: $bytes, ')
          ..write('mime: $mime, ')
          ..write('uploadStatus: $uploadStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    id,
    ownerType,
    ownerId,
    objectKey,
    sha256,
    bytes,
    mime,
    uploadStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.objectKey == this.objectKey &&
          other.sha256 == this.sha256 &&
          other.bytes == this.bytes &&
          other.mime == this.mime &&
          other.uploadStatus == this.uploadStatus);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String?> objectKey;
  final Value<String> sha256;
  final Value<int> bytes;
  final Value<String> mime;
  final Value<String> uploadStatus;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.bytes = const Value.absent(),
    this.mime = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String id,
    required String ownerType,
    required String ownerId,
    this.objectKey = const Value.absent(),
    required String sha256,
    required int bytes,
    required String mime,
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       sha256 = Value(sha256),
       bytes = Value(bytes),
       mime = Value(mime);
  static Insertable<AttachmentRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? objectKey,
    Expression<String>? sha256,
    Expression<int>? bytes,
    Expression<String>? mime,
    Expression<String>? uploadStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (objectKey != null) 'object_key': objectKey,
      if (sha256 != null) 'sha256': sha256,
      if (bytes != null) 'bytes': bytes,
      if (mime != null) 'mime': mime,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<String?>? objectKey,
    Value<String>? sha256,
    Value<int>? bytes,
    Value<String>? mime,
    Value<String>? uploadStatus,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      objectKey: objectKey ?? this.objectKey,
      sha256: sha256 ?? this.sha256,
      bytes: bytes ?? this.bytes,
      mime: mime ?? this.mime,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('objectKey: $objectKey, ')
          ..write('sha256: $sha256, ')
          ..write('bytes: $bytes, ')
          ..write('mime: $mime, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectorMarksTable extends CollectorMarks
    with TableInfo<$CollectorMarksTable, CollectorMarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectorMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorKeyMeta = const VerificationMeta(
    'collectorKey',
  );
  @override
  late final GeneratedColumn<String> collectorKey = GeneratedColumn<String>(
    'collector_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedByMeta = const VerificationMeta(
    'markedBy',
  );
  @override
  late final GeneratedColumn<String> markedBy = GeneratedColumn<String>(
    'marked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedAtMeta = const VerificationMeta(
    'markedAt',
  );
  @override
  late final GeneratedColumn<DateTime> markedAt = GeneratedColumn<DateTime>(
    'marked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    collectorKey,
    status,
    note,
    markedBy,
    markedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collector_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectorMarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('collector_key')) {
      context.handle(
        _collectorKeyMeta,
        collectorKey.isAcceptableOrUnknown(
          data['collector_key']!,
          _collectorKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('marked_by')) {
      context.handle(
        _markedByMeta,
        markedBy.isAcceptableOrUnknown(data['marked_by']!, _markedByMeta),
      );
    }
    if (data.containsKey('marked_at')) {
      context.handle(
        _markedAtMeta,
        markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_markedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectorKey};
  @override
  CollectorMarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectorMarkRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      collectorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      markedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by'],
      ),
      markedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}marked_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $CollectorMarksTable createAlias(String alias) {
    return $CollectorMarksTable(attachedDatabase, alias);
  }
}

class CollectorMarkRow extends DataClass
    implements Insertable<CollectorMarkRow> {
  final int? serverSeq;
  final String collectorKey;
  final String status;
  final String? note;
  final String? markedBy;
  final DateTime markedAt;
  final int version;
  const CollectorMarkRow({
    this.serverSeq,
    required this.collectorKey,
    required this.status,
    this.note,
    this.markedBy,
    required this.markedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['collector_key'] = Variable<String>(collectorKey);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || markedBy != null) {
      map['marked_by'] = Variable<String>(markedBy);
    }
    map['marked_at'] = Variable<DateTime>(markedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  CollectorMarksCompanion toCompanion(bool nullToAbsent) {
    return CollectorMarksCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      collectorKey: Value(collectorKey),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      markedBy: markedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(markedBy),
      markedAt: Value(markedAt),
      version: Value(version),
    );
  }

  factory CollectorMarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectorMarkRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      collectorKey: serializer.fromJson<String>(json['collector_key']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      markedBy: serializer.fromJson<String?>(json['marked_by']),
      markedAt: serializer.fromJson<DateTime>(json['marked_at']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'collector_key': serializer.toJson<String>(collectorKey),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'marked_by': serializer.toJson<String?>(markedBy),
      'marked_at': serializer.toJson<DateTime>(markedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  CollectorMarkRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? collectorKey,
    String? status,
    Value<String?> note = const Value.absent(),
    Value<String?> markedBy = const Value.absent(),
    DateTime? markedAt,
    int? version,
  }) => CollectorMarkRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    collectorKey: collectorKey ?? this.collectorKey,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    markedBy: markedBy.present ? markedBy.value : this.markedBy,
    markedAt: markedAt ?? this.markedAt,
    version: version ?? this.version,
  );
  CollectorMarkRow copyWithCompanion(CollectorMarksCompanion data) {
    return CollectorMarkRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      collectorKey: data.collectorKey.present
          ? data.collectorKey.value
          : this.collectorKey,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      markedBy: data.markedBy.present ? data.markedBy.value : this.markedBy,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectorMarkRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedAt: $markedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    serverSeq,
    collectorKey,
    status,
    note,
    markedBy,
    markedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectorMarkRow &&
          other.serverSeq == this.serverSeq &&
          other.collectorKey == this.collectorKey &&
          other.status == this.status &&
          other.note == this.note &&
          other.markedBy == this.markedBy &&
          other.markedAt == this.markedAt &&
          other.version == this.version);
}

class CollectorMarksCompanion extends UpdateCompanion<CollectorMarkRow> {
  final Value<int?> serverSeq;
  final Value<String> collectorKey;
  final Value<String> status;
  final Value<String?> note;
  final Value<String?> markedBy;
  final Value<DateTime> markedAt;
  final Value<int> version;
  final Value<int> rowid;
  const CollectorMarksCompanion({
    this.serverSeq = const Value.absent(),
    this.collectorKey = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.markedBy = const Value.absent(),
    this.markedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectorMarksCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String collectorKey,
    required String status,
    this.note = const Value.absent(),
    this.markedBy = const Value.absent(),
    required DateTime markedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collectorKey = Value(collectorKey),
       status = Value(status),
       markedAt = Value(markedAt);
  static Insertable<CollectorMarkRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? collectorKey,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? markedBy,
    Expression<DateTime>? markedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (collectorKey != null) 'collector_key': collectorKey,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (markedBy != null) 'marked_by': markedBy,
      if (markedAt != null) 'marked_at': markedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectorMarksCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? collectorKey,
    Value<String>? status,
    Value<String?>? note,
    Value<String?>? markedBy,
    Value<DateTime>? markedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return CollectorMarksCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      collectorKey: collectorKey ?? this.collectorKey,
      status: status ?? this.status,
      note: note ?? this.note,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (collectorKey.present) {
      map['collector_key'] = Variable<String>(collectorKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (markedBy.present) {
      map['marked_by'] = Variable<String>(markedBy.value);
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<DateTime>(markedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectorMarksCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('collectorKey: $collectorKey, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedAt: $markedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubmissionFlagsTable extends SubmissionFlags
    with TableInfo<$SubmissionFlagsTable, SubmissionFlagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmissionFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultIdMeta = const VerificationMeta(
    'resultId',
  );
  @override
  late final GeneratedColumn<String> resultId = GeneratedColumn<String>(
    'result_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flaggedByMeta = const VerificationMeta(
    'flaggedBy',
  );
  @override
  late final GeneratedColumn<String> flaggedBy = GeneratedColumn<String>(
    'flagged_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    serverSeq,
    id,
    resultId,
    reason,
    flaggedBy,
    createdAtDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submission_flags';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubmissionFlagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('result_id')) {
      context.handle(
        _resultIdMeta,
        resultId.isAcceptableOrUnknown(data['result_id']!, _resultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resultIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('flagged_by')) {
      context.handle(
        _flaggedByMeta,
        flaggedBy.isAcceptableOrUnknown(data['flagged_by']!, _flaggedByMeta),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubmissionFlagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubmissionFlagRow(
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      resultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      flaggedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flagged_by'],
      ),
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
    );
  }

  @override
  $SubmissionFlagsTable createAlias(String alias) {
    return $SubmissionFlagsTable(attachedDatabase, alias);
  }
}

class SubmissionFlagRow extends DataClass
    implements Insertable<SubmissionFlagRow> {
  final int? serverSeq;
  final String id;
  final String resultId;
  final String reason;
  final String? flaggedBy;
  final DateTime createdAtDevice;
  const SubmissionFlagRow({
    this.serverSeq,
    required this.id,
    required this.resultId,
    required this.reason,
    this.flaggedBy,
    required this.createdAtDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['id'] = Variable<String>(id);
    map['result_id'] = Variable<String>(resultId);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || flaggedBy != null) {
      map['flagged_by'] = Variable<String>(flaggedBy);
    }
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    return map;
  }

  SubmissionFlagsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionFlagsCompanion(
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      id: Value(id),
      resultId: Value(resultId),
      reason: Value(reason),
      flaggedBy: flaggedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(flaggedBy),
      createdAtDevice: Value(createdAtDevice),
    );
  }

  factory SubmissionFlagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubmissionFlagRow(
      serverSeq: serializer.fromJson<int?>(json['server_seq']),
      id: serializer.fromJson<String>(json['id']),
      resultId: serializer.fromJson<String>(json['result_id']),
      reason: serializer.fromJson<String>(json['reason']),
      flaggedBy: serializer.fromJson<String?>(json['flagged_by']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'server_seq': serializer.toJson<int?>(serverSeq),
      'id': serializer.toJson<String>(id),
      'result_id': serializer.toJson<String>(resultId),
      'reason': serializer.toJson<String>(reason),
      'flagged_by': serializer.toJson<String?>(flaggedBy),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
    };
  }

  SubmissionFlagRow copyWith({
    Value<int?> serverSeq = const Value.absent(),
    String? id,
    String? resultId,
    String? reason,
    Value<String?> flaggedBy = const Value.absent(),
    DateTime? createdAtDevice,
  }) => SubmissionFlagRow(
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    id: id ?? this.id,
    resultId: resultId ?? this.resultId,
    reason: reason ?? this.reason,
    flaggedBy: flaggedBy.present ? flaggedBy.value : this.flaggedBy,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
  );
  SubmissionFlagRow copyWithCompanion(SubmissionFlagsCompanion data) {
    return SubmissionFlagRow(
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      id: data.id.present ? data.id.value : this.id,
      resultId: data.resultId.present ? data.resultId.value : this.resultId,
      reason: data.reason.present ? data.reason.value : this.reason,
      flaggedBy: data.flaggedBy.present ? data.flaggedBy.value : this.flaggedBy,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionFlagRow(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('resultId: $resultId, ')
          ..write('reason: $reason, ')
          ..write('flaggedBy: $flaggedBy, ')
          ..write('createdAtDevice: $createdAtDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(serverSeq, id, resultId, reason, flaggedBy, createdAtDevice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubmissionFlagRow &&
          other.serverSeq == this.serverSeq &&
          other.id == this.id &&
          other.resultId == this.resultId &&
          other.reason == this.reason &&
          other.flaggedBy == this.flaggedBy &&
          other.createdAtDevice == this.createdAtDevice);
}

class SubmissionFlagsCompanion extends UpdateCompanion<SubmissionFlagRow> {
  final Value<int?> serverSeq;
  final Value<String> id;
  final Value<String> resultId;
  final Value<String> reason;
  final Value<String?> flaggedBy;
  final Value<DateTime> createdAtDevice;
  final Value<int> rowid;
  const SubmissionFlagsCompanion({
    this.serverSeq = const Value.absent(),
    this.id = const Value.absent(),
    this.resultId = const Value.absent(),
    this.reason = const Value.absent(),
    this.flaggedBy = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubmissionFlagsCompanion.insert({
    this.serverSeq = const Value.absent(),
    required String id,
    required String resultId,
    required String reason,
    this.flaggedBy = const Value.absent(),
    required DateTime createdAtDevice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       resultId = Value(resultId),
       reason = Value(reason),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<SubmissionFlagRow> custom({
    Expression<int>? serverSeq,
    Expression<String>? id,
    Expression<String>? resultId,
    Expression<String>? reason,
    Expression<String>? flaggedBy,
    Expression<DateTime>? createdAtDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverSeq != null) 'server_seq': serverSeq,
      if (id != null) 'id': id,
      if (resultId != null) 'result_id': resultId,
      if (reason != null) 'reason': reason,
      if (flaggedBy != null) 'flagged_by': flaggedBy,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubmissionFlagsCompanion copyWith({
    Value<int?>? serverSeq,
    Value<String>? id,
    Value<String>? resultId,
    Value<String>? reason,
    Value<String?>? flaggedBy,
    Value<DateTime>? createdAtDevice,
    Value<int>? rowid,
  }) {
    return SubmissionFlagsCompanion(
      serverSeq: serverSeq ?? this.serverSeq,
      id: id ?? this.id,
      resultId: resultId ?? this.resultId,
      reason: reason ?? this.reason,
      flaggedBy: flaggedBy ?? this.flaggedBy,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (resultId.present) {
      map['result_id'] = Variable<String>(resultId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (flaggedBy.present) {
      map['flagged_by'] = Variable<String>(flaggedBy.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionFlagsCompanion(')
          ..write('serverSeq: $serverSeq, ')
          ..write('id: $id, ')
          ..write('resultId: $resultId, ')
          ..write('reason: $reason, ')
          ..write('flaggedBy: $flaggedBy, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityId,
    op,
    payload,
    baseVersion,
    createdAt,
    attempts,
    lastError,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int id;
  final String entity;
  final String entityId;

  /// `insert` or `update`.
  final String op;
  final String payload;
  final int? baseVersion;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  /// `pending`, `sent` or `rejected` (never deleted, SPEC §8.1).
  final String status;
  const OutboxRow({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payload,
    this.baseVersion,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      payload: Value(payload),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      baseVersion: serializer.fromJson<int?>(json['base_version']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['last_error']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'entity_id': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'base_version': serializer.toJson<int?>(baseVersion),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'last_error': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  OutboxRow copyWith({
    int? id,
    String? entity,
    String? entityId,
    String? op,
    String? payload,
    Value<int?> baseVersion = const Value.absent(),
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    String? status,
  }) => OutboxRow(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payload: payload ?? this.payload,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity,
    entityId,
    op,
    payload,
    baseVersion,
    createdAt,
    attempts,
    lastError,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.baseVersion == this.baseVersion &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> payload;
  final Value<int?> baseVersion;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<String> status;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String entityId,
    required String op,
    required String payload,
    this.baseVersion = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<int>? baseVersion,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (baseVersion != null) 'base_version': baseVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? payload,
    Value<int?>? baseVersion,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<String>? status,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      baseVersion: baseVersion ?? this.baseVersion,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _streamMeta = const VerificationMeta('stream');
  @override
  late final GeneratedColumn<String> stream = GeneratedColumn<String>(
    'stream',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cursorTokenMeta = const VerificationMeta(
    'cursorToken',
  );
  @override
  late final GeneratedColumn<String> cursorToken = GeneratedColumn<String>(
    'cursor_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failuresMeta = const VerificationMeta(
    'failures',
  );
  @override
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stream,
    cursor,
    lastSuccessAt,
    cursorToken,
    failures,
    nextAttemptAt,
    lastAttemptAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stream')) {
      context.handle(
        _streamMeta,
        stream.isAcceptableOrUnknown(data['stream']!, _streamMeta),
      );
    } else if (isInserting) {
      context.missing(_streamMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('cursor_token')) {
      context.handle(
        _cursorTokenMeta,
        cursorToken.isAcceptableOrUnknown(
          data['cursor_token']!,
          _cursorTokenMeta,
        ),
      );
    }
    if (data.containsKey('failures')) {
      context.handle(
        _failuresMeta,
        failures.isAcceptableOrUnknown(data['failures']!, _failuresMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stream};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      stream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      cursorToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor_token'],
      ),
      failures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failures'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String stream;

  /// Unused since v2: the server's cursor is opaque text ([cursorToken]).
  final int cursor;
  final DateTime? lastSuccessAt;

  /// The server's opaque pull cursor (ADR-011). Added in v2.
  final String? cursorToken;

  /// Consecutive failures, for exponential backoff (SPEC §8.1). Added in v2.
  final int failures;
  final DateTime? nextAttemptAt;
  final DateTime? lastAttemptAt;
  final String? lastError;
  const SyncStateRow({
    required this.stream,
    required this.cursor,
    this.lastSuccessAt,
    this.cursorToken,
    required this.failures,
    this.nextAttemptAt,
    this.lastAttemptAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stream'] = Variable<String>(stream);
    map['cursor'] = Variable<int>(cursor);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || cursorToken != null) {
      map['cursor_token'] = Variable<String>(cursorToken);
    }
    map['failures'] = Variable<int>(failures);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      stream: Value(stream),
      cursor: Value(cursor),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      cursorToken: cursorToken == null && nullToAbsent
          ? const Value.absent()
          : Value(cursorToken),
      failures: Value(failures),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      stream: serializer.fromJson<String>(json['stream']),
      cursor: serializer.fromJson<int>(json['cursor']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['last_success_at']),
      cursorToken: serializer.fromJson<String?>(json['cursor_token']),
      failures: serializer.fromJson<int>(json['failures']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['next_attempt_at']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['last_attempt_at']),
      lastError: serializer.fromJson<String?>(json['last_error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stream': serializer.toJson<String>(stream),
      'cursor': serializer.toJson<int>(cursor),
      'last_success_at': serializer.toJson<DateTime?>(lastSuccessAt),
      'cursor_token': serializer.toJson<String?>(cursorToken),
      'failures': serializer.toJson<int>(failures),
      'next_attempt_at': serializer.toJson<DateTime?>(nextAttemptAt),
      'last_attempt_at': serializer.toJson<DateTime?>(lastAttemptAt),
      'last_error': serializer.toJson<String?>(lastError),
    };
  }

  SyncStateRow copyWith({
    String? stream,
    int? cursor,
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> cursorToken = const Value.absent(),
    int? failures,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncStateRow(
    stream: stream ?? this.stream,
    cursor: cursor ?? this.cursor,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    cursorToken: cursorToken.present ? cursorToken.value : this.cursorToken,
    failures: failures ?? this.failures,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      stream: data.stream.present ? data.stream.value : this.stream,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      cursorToken: data.cursorToken.present
          ? data.cursorToken.value
          : this.cursorToken,
      failures: data.failures.present ? data.failures.value : this.failures,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('stream: $stream, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('cursorToken: $cursorToken, ')
          ..write('failures: $failures, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stream,
    cursor,
    lastSuccessAt,
    cursorToken,
    failures,
    nextAttemptAt,
    lastAttemptAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.stream == this.stream &&
          other.cursor == this.cursor &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.cursorToken == this.cursorToken &&
          other.failures == this.failures &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> stream;
  final Value<int> cursor;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> cursorToken;
  final Value<int> failures;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.stream = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.cursorToken = const Value.absent(),
    this.failures = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String stream,
    this.cursor = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.cursorToken = const Value.absent(),
    this.failures = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stream = Value(stream);
  static Insertable<SyncStateRow> custom({
    Expression<String>? stream,
    Expression<int>? cursor,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? cursorToken,
    Expression<int>? failures,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stream != null) 'stream': stream,
      if (cursor != null) 'cursor': cursor,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (cursorToken != null) 'cursor_token': cursorToken,
      if (failures != null) 'failures': failures,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? stream,
    Value<int>? cursor,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? cursorToken,
    Value<int>? failures,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      stream: stream ?? this.stream,
      cursor: cursor ?? this.cursor,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      cursorToken: cursorToken ?? this.cursorToken,
      failures: failures ?? this.failures,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stream.present) {
      map['stream'] = Variable<String>(stream.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (cursorToken.present) {
      map['cursor_token'] = Variable<String>(cursorToken.value);
    }
    if (failures.present) {
      map['failures'] = Variable<int>(failures.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('stream: $stream, ')
          ..write('cursor: $cursor, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('cursorToken: $cursorToken, ')
          ..write('failures: $failures, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLocksTable extends SyncLocks
    with TableInfo<$SyncLocksTable, SyncLockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, owner, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_locks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SyncLockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLockRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $SyncLocksTable createAlias(String alias) {
    return $SyncLocksTable(attachedDatabase, alias);
  }
}

class SyncLockRow extends DataClass implements Insertable<SyncLockRow> {
  final String name;
  final String owner;
  final DateTime expiresAt;
  const SyncLockRow({
    required this.name,
    required this.owner,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['owner'] = Variable<String>(owner);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  SyncLocksCompanion toCompanion(bool nullToAbsent) {
    return SyncLocksCompanion(
      name: Value(name),
      owner: Value(owner),
      expiresAt: Value(expiresAt),
    );
  }

  factory SyncLockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLockRow(
      name: serializer.fromJson<String>(json['name']),
      owner: serializer.fromJson<String>(json['owner']),
      expiresAt: serializer.fromJson<DateTime>(json['expires_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'owner': serializer.toJson<String>(owner),
      'expires_at': serializer.toJson<DateTime>(expiresAt),
    };
  }

  SyncLockRow copyWith({String? name, String? owner, DateTime? expiresAt}) =>
      SyncLockRow(
        name: name ?? this.name,
        owner: owner ?? this.owner,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  SyncLockRow copyWithCompanion(SyncLocksCompanion data) {
    return SyncLockRow(
      name: data.name.present ? data.name.value : this.name,
      owner: data.owner.present ? data.owner.value : this.owner,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLockRow(')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, owner, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLockRow &&
          other.name == this.name &&
          other.owner == this.owner &&
          other.expiresAt == this.expiresAt);
}

class SyncLocksCompanion extends UpdateCompanion<SyncLockRow> {
  final Value<String> name;
  final Value<String> owner;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const SyncLocksCompanion({
    this.name = const Value.absent(),
    this.owner = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncLocksCompanion.insert({
    required String name,
    required String owner,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       owner = Value(owner),
       expiresAt = Value(expiresAt);
  static Insertable<SyncLockRow> custom({
    Expression<String>? name,
    Expression<String>? owner,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (owner != null) 'owner': owner,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncLocksCompanion copyWith({
    Value<String>? name,
    Value<String>? owner,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return SyncLocksCompanion(
      name: name ?? this.name,
      owner: owner ?? this.owner,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLocksCompanion(')
          ..write('name: $name, ')
          ..write('owner: $owner, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentQueueTable extends AttachmentQueue
    with TableInfo<$AttachmentQueueTable, AttachmentQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesSentMeta = const VerificationMeta(
    'bytesSent',
  );
  @override
  late final GeneratedColumn<int> bytesSent = GeneratedColumn<int>(
    'bytes_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    attachmentId,
    localPath,
    bytesSent,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('bytes_sent')) {
      context.handle(
        _bytesSentMeta,
        bytesSent.isAcceptableOrUnknown(data['bytes_sent']!, _bytesSentMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attachmentId};
  @override
  AttachmentQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentQueueRow(
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      bytesSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_sent'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AttachmentQueueTable createAlias(String alias) {
    return $AttachmentQueueTable(attachedDatabase, alias);
  }
}

class AttachmentQueueRow extends DataClass
    implements Insertable<AttachmentQueueRow> {
  final String attachmentId;
  final String localPath;
  final int bytesSent;
  final String status;
  const AttachmentQueueRow({
    required this.attachmentId,
    required this.localPath,
    required this.bytesSent,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attachment_id'] = Variable<String>(attachmentId);
    map['local_path'] = Variable<String>(localPath);
    map['bytes_sent'] = Variable<int>(bytesSent);
    map['status'] = Variable<String>(status);
    return map;
  }

  AttachmentQueueCompanion toCompanion(bool nullToAbsent) {
    return AttachmentQueueCompanion(
      attachmentId: Value(attachmentId),
      localPath: Value(localPath),
      bytesSent: Value(bytesSent),
      status: Value(status),
    );
  }

  factory AttachmentQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentQueueRow(
      attachmentId: serializer.fromJson<String>(json['attachment_id']),
      localPath: serializer.fromJson<String>(json['local_path']),
      bytesSent: serializer.fromJson<int>(json['bytes_sent']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attachment_id': serializer.toJson<String>(attachmentId),
      'local_path': serializer.toJson<String>(localPath),
      'bytes_sent': serializer.toJson<int>(bytesSent),
      'status': serializer.toJson<String>(status),
    };
  }

  AttachmentQueueRow copyWith({
    String? attachmentId,
    String? localPath,
    int? bytesSent,
    String? status,
  }) => AttachmentQueueRow(
    attachmentId: attachmentId ?? this.attachmentId,
    localPath: localPath ?? this.localPath,
    bytesSent: bytesSent ?? this.bytesSent,
    status: status ?? this.status,
  );
  AttachmentQueueRow copyWithCompanion(AttachmentQueueCompanion data) {
    return AttachmentQueueRow(
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      bytesSent: data.bytesSent.present ? data.bytesSent.value : this.bytesSent,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentQueueRow(')
          ..write('attachmentId: $attachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('bytesSent: $bytesSent, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(attachmentId, localPath, bytesSent, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentQueueRow &&
          other.attachmentId == this.attachmentId &&
          other.localPath == this.localPath &&
          other.bytesSent == this.bytesSent &&
          other.status == this.status);
}

class AttachmentQueueCompanion extends UpdateCompanion<AttachmentQueueRow> {
  final Value<String> attachmentId;
  final Value<String> localPath;
  final Value<int> bytesSent;
  final Value<String> status;
  final Value<int> rowid;
  const AttachmentQueueCompanion({
    this.attachmentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.bytesSent = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentQueueCompanion.insert({
    required String attachmentId,
    required String localPath,
    this.bytesSent = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : attachmentId = Value(attachmentId),
       localPath = Value(localPath);
  static Insertable<AttachmentQueueRow> custom({
    Expression<String>? attachmentId,
    Expression<String>? localPath,
    Expression<int>? bytesSent,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (localPath != null) 'local_path': localPath,
      if (bytesSent != null) 'bytes_sent': bytesSent,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentQueueCompanion copyWith({
    Value<String>? attachmentId,
    Value<String>? localPath,
    Value<int>? bytesSent,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return AttachmentQueueCompanion(
      attachmentId: attachmentId ?? this.attachmentId,
      localPath: localPath ?? this.localPath,
      bytesSent: bytesSent ?? this.bytesSent,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (bytesSent.present) {
      map['bytes_sent'] = Variable<int>(bytesSent.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentQueueCompanion(')
          ..write('attachmentId: $attachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('bytesSent: $bytesSent, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WaterSourcesTable waterSources = $WaterSourcesTable(this);
  late final $TestSessionsTable testSessions = $TestSessionsTable(this);
  late final Trigger testSessionsNoDelete = Trigger(
    'CREATE TRIGGER test_sessions_no_delete BEFORE DELETE ON test_sessions BEGIN SELECT RAISE (ABORT, \'test_sessions are immutable\');END',
    'test_sessions_no_delete',
  );
  late final Trigger testSessionsNoUpdate = Trigger(
    'CREATE TRIGGER test_sessions_no_update BEFORE UPDATE OF id, source_id, calibration_id, tester_profile_id, reference_standard_id, calibrated, lat, lon, location_accuracy_m, distance_from_source_m, distance_override_reason, notes, tested_at_device, installation_id, collector_key, collector_snapshot ON test_sessions BEGIN SELECT RAISE (ABORT, \'test_sessions are immutable\');END',
    'test_sessions_no_update',
  );
  late final $TestResultsTable testResults = $TestResultsTable(this);
  late final Trigger testResultsNoDelete = Trigger(
    'CREATE TRIGGER test_results_no_delete BEFORE DELETE ON test_results BEGIN SELECT RAISE (ABORT, \'test_results are immutable\');END',
    'test_results_no_delete',
  );
  late final Trigger testResultsNoUpdate = Trigger(
    'CREATE TRIGGER test_results_no_update BEFORE UPDATE OF id, session_id, overall, standard_id, computed_by, retest_of, amendment_of, amendment_reason, flags, limitation_code, created_at_device ON test_results BEGIN SELECT RAISE (ABORT, \'test_results are immutable\');END',
    'test_results_no_update',
  );
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final Trigger readingsNoDelete = Trigger(
    'CREATE TRIGGER readings_no_delete BEFORE DELETE ON readings BEGIN SELECT RAISE (ABORT, \'readings are immutable\');END',
    'readings_no_delete',
  );
  late final Trigger readingsNoUpdate = Trigger(
    'CREATE TRIGGER readings_no_update BEFORE UPDATE OF id, session_id, result_id, parameter_code, value, detected, acceptable, value_text, unit, result, is_derived, source_device ON readings BEGIN SELECT RAISE (ABORT, \'readings are immutable\');END',
    'readings_no_update',
  );
  late final $CalibrationsTable calibrations = $CalibrationsTable(this);
  late final Trigger calibrationsNoDelete = Trigger(
    'CREATE TRIGGER calibrations_no_delete BEFORE DELETE ON calibrations BEGIN SELECT RAISE (ABORT, \'calibrations are immutable\');END',
    'calibrations_no_delete',
  );
  late final Trigger calibrationsNoUpdate = Trigger(
    'CREATE TRIGGER calibrations_no_update BEFORE UPDATE OF id, tester_serial, tester_profile_id, reference_standard_id, buffers, passed, performed_at_device, installation_id, collector_key, collector_snapshot ON calibrations BEGIN SELECT RAISE (ABORT, \'calibrations are immutable\');END',
    'calibrations_no_update',
  );
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $AlertEventsTable alertEvents = $AlertEventsTable(this);
  late final Trigger alertEventsNoDelete = Trigger(
    'CREATE TRIGGER alert_events_no_delete BEFORE DELETE ON alert_events BEGIN SELECT RAISE (ABORT, \'alert_events are immutable\');END',
    'alert_events_no_delete',
  );
  late final Trigger alertEventsNoUpdate = Trigger(
    'CREATE TRIGGER alert_events_no_update BEFORE UPDATE OF id, alert_id, actor_id, event_type, note, occurred_at_device, installation_id, collector_key, collector_snapshot ON alert_events BEGIN SELECT RAISE (ABORT, \'alert_events are immutable\');END',
    'alert_events_no_update',
  );
  late final $SanitaryInspectionsTable sanitaryInspections =
      $SanitaryInspectionsTable(this);
  late final Trigger sanitaryInspectionsNoDelete = Trigger(
    'CREATE TRIGGER sanitary_inspections_no_delete BEFORE DELETE ON sanitary_inspections BEGIN SELECT RAISE (ABORT, \'sanitary_inspections are immutable\');END',
    'sanitary_inspections_no_delete',
  );
  late final Trigger sanitaryInspectionsNoUpdate = Trigger(
    'CREATE TRIGGER sanitary_inspections_no_update BEFORE UPDATE OF id, source_id, answers, inspected_at_device, installation_id, collector_key, collector_snapshot ON sanitary_inspections BEGIN SELECT RAISE (ABORT, \'sanitary_inspections are immutable\');END',
    'sanitary_inspections_no_update',
  );
  late final Trigger waterSourcesNoDelete = Trigger(
    'CREATE TRIGGER water_sources_no_delete BEFORE DELETE ON water_sources BEGIN SELECT RAISE (ABORT, \'water_sources are deactivated, never deleted\');END',
    'water_sources_no_delete',
  );
  late final $AdminUnitsTable adminUnits = $AdminUnitsTable(this);
  late final $ParameterCategoriesTable parameterCategories =
      $ParameterCategoriesTable(this);
  late final $ParameterDefinitionsTable parameterDefinitions =
      $ParameterDefinitionsTable(this);
  late final $TesterProfilesTable testerProfiles = $TesterProfilesTable(this);
  late final $ReferenceProfilesTable referenceProfiles =
      $ReferenceProfilesTable(this);
  late final $ResponseCardsTable responseCards = $ResponseCardsTable(this);
  late final $ResponsibilitiesTable responsibilities = $ResponsibilitiesTable(
    this,
  );
  late final $ConfigDocumentsTable configDocuments = $ConfigDocumentsTable(
    this,
  );
  late final $SeedImportsTable seedImports = $SeedImportsTable(this);
  late final $CollectorProfilesTable collectorProfiles =
      $CollectorProfilesTable(this);
  late final $ClassificationsTable classifications = $ClassificationsTable(
    this,
  );
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $CollectorMarksTable collectorMarks = $CollectorMarksTable(this);
  late final $SubmissionFlagsTable submissionFlags = $SubmissionFlagsTable(
    this,
  );
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SyncLocksTable syncLocks = $SyncLocksTable(this);
  late final $AttachmentQueueTable attachmentQueue = $AttachmentQueueTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    waterSources,
    testSessions,
    testSessionsNoDelete,
    testSessionsNoUpdate,
    testResults,
    testResultsNoDelete,
    testResultsNoUpdate,
    readings,
    readingsNoDelete,
    readingsNoUpdate,
    calibrations,
    calibrationsNoDelete,
    calibrationsNoUpdate,
    alerts,
    alertEvents,
    alertEventsNoDelete,
    alertEventsNoUpdate,
    sanitaryInspections,
    sanitaryInspectionsNoDelete,
    sanitaryInspectionsNoUpdate,
    waterSourcesNoDelete,
    adminUnits,
    parameterCategories,
    parameterDefinitions,
    testerProfiles,
    referenceProfiles,
    responseCards,
    responsibilities,
    configDocuments,
    seedImports,
    collectorProfiles,
    classifications,
    attachments,
    collectorMarks,
    submissionFlags,
    outbox,
    syncState,
    syncLocks,
    attachmentQueue,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'test_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'test_sessions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'test_results',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'test_results',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'readings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'readings',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calibrations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'calibrations',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'alert_events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'alert_events',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sanitary_inspections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sanitary_inspections',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'water_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$WaterSourcesTableCreateCompanionBuilder =
    WaterSourcesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String villageId,
      required String code,
      Value<String?> name,
      required String sourceType,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> locationAccuracyM,
      Value<int?> householdsServed,
      Value<String> functionalStatus,
      Value<bool> isActive,
      Value<int> version,
      Value<String?> createdBy,
      required DateTime createdAtDevice,
      required DateTime updatedAtDevice,
      Value<int> rowid,
    });
typedef $$WaterSourcesTableUpdateCompanionBuilder =
    WaterSourcesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> villageId,
      Value<String> code,
      Value<String?> name,
      Value<String> sourceType,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> locationAccuracyM,
      Value<int?> householdsServed,
      Value<String> functionalStatus,
      Value<bool> isActive,
      Value<int> version,
      Value<String?> createdBy,
      Value<DateTime> createdAtDevice,
      Value<DateTime> updatedAtDevice,
      Value<int> rowid,
    });

final class $$WaterSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $WaterSourcesTable, WaterSourceRow> {
  $$WaterSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestSessionsTable, List<TestSessionRow>>
  _testSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.testSessions,
    aliasName: 'water_sources__id__test_sessions__source_id',
  );

  $$TestSessionsTableProcessedTableManager get testSessionsRefs {
    final manager = $$TestSessionsTableTableManager(
      $_db,
      $_db.testSessions,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_testSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlertsTable, List<AlertRow>> _alertsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.alerts,
    aliasName: 'water_sources__id__alerts__source_id',
  );

  $$AlertsTableProcessedTableManager get alertsRefs {
    final manager = $$AlertsTableTableManager(
      $_db,
      $_db.alerts,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alertsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SanitaryInspectionsTable,
    List<SanitaryInspectionRow>
  >
  _sanitaryInspectionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sanitaryInspections,
        aliasName: 'water_sources__id__sanitary_inspections__source_id',
      );

  $$SanitaryInspectionsTableProcessedTableManager get sanitaryInspectionsRefs {
    final manager = $$SanitaryInspectionsTableTableManager(
      $_db,
      $_db.sanitaryInspections,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sanitaryInspectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WaterSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $WaterSourcesTable> {
  $$WaterSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get householdsServed => $composableBuilder(
    column: $table.householdsServed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functionalStatus => $composableBuilder(
    column: $table.functionalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtDevice => $composableBuilder(
    column: $table.updatedAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> testSessionsRefs(
    Expression<bool> Function($$TestSessionsTableFilterComposer f) f,
  ) {
    final $$TestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> alertsRefs(
    Expression<bool> Function($$AlertsTableFilterComposer f) f,
  ) {
    final $$AlertsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alerts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertsTableFilterComposer(
            $db: $db,
            $table: $db.alerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sanitaryInspectionsRefs(
    Expression<bool> Function($$SanitaryInspectionsTableFilterComposer f) f,
  ) {
    final $$SanitaryInspectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sanitaryInspections,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SanitaryInspectionsTableFilterComposer(
            $db: $db,
            $table: $db.sanitaryInspections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WaterSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterSourcesTable> {
  $$WaterSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get householdsServed => $composableBuilder(
    column: $table.householdsServed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functionalStatus => $composableBuilder(
    column: $table.functionalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtDevice => $composableBuilder(
    column: $table.updatedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterSourcesTable> {
  $$WaterSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get householdsServed => $composableBuilder(
    column: $table.householdsServed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get functionalStatus => $composableBuilder(
    column: $table.functionalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtDevice => $composableBuilder(
    column: $table.updatedAtDevice,
    builder: (column) => column,
  );

  Expression<T> testSessionsRefs<T extends Object>(
    Expression<T> Function($$TestSessionsTableAnnotationComposer a) f,
  ) {
    final $$TestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> alertsRefs<T extends Object>(
    Expression<T> Function($$AlertsTableAnnotationComposer a) f,
  ) {
    final $$AlertsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alerts,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertsTableAnnotationComposer(
            $db: $db,
            $table: $db.alerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sanitaryInspectionsRefs<T extends Object>(
    Expression<T> Function($$SanitaryInspectionsTableAnnotationComposer a) f,
  ) {
    final $$SanitaryInspectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sanitaryInspections,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SanitaryInspectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.sanitaryInspections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WaterSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterSourcesTable,
          WaterSourceRow,
          $$WaterSourcesTableFilterComposer,
          $$WaterSourcesTableOrderingComposer,
          $$WaterSourcesTableAnnotationComposer,
          $$WaterSourcesTableCreateCompanionBuilder,
          $$WaterSourcesTableUpdateCompanionBuilder,
          (WaterSourceRow, $$WaterSourcesTableReferences),
          WaterSourceRow,
          PrefetchHooks Function({
            bool testSessionsRefs,
            bool alertsRefs,
            bool sanitaryInspectionsRefs,
          })
        > {
  $$WaterSourcesTableTableManager(_$AppDatabase db, $WaterSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> villageId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<int?> householdsServed = const Value.absent(),
                Value<String> functionalStatus = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<DateTime> updatedAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterSourcesCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                villageId: villageId,
                code: code,
                name: name,
                sourceType: sourceType,
                lat: lat,
                lon: lon,
                locationAccuracyM: locationAccuracyM,
                householdsServed: householdsServed,
                functionalStatus: functionalStatus,
                isActive: isActive,
                version: version,
                createdBy: createdBy,
                createdAtDevice: createdAtDevice,
                updatedAtDevice: updatedAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String villageId,
                required String code,
                Value<String?> name = const Value.absent(),
                required String sourceType,
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<int?> householdsServed = const Value.absent(),
                Value<String> functionalStatus = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required DateTime createdAtDevice,
                required DateTime updatedAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => WaterSourcesCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                villageId: villageId,
                code: code,
                name: name,
                sourceType: sourceType,
                lat: lat,
                lon: lon,
                locationAccuracyM: locationAccuracyM,
                householdsServed: householdsServed,
                functionalStatus: functionalStatus,
                isActive: isActive,
                version: version,
                createdBy: createdBy,
                createdAtDevice: createdAtDevice,
                updatedAtDevice: updatedAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterSourcesTable, WaterSourceRow>(table),
                  $$WaterSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                testSessionsRefs = false,
                alertsRefs = false,
                sanitaryInspectionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (testSessionsRefs) db.testSessions,
                    if (alertsRefs) db.alerts,
                    if (sanitaryInspectionsRefs) db.sanitaryInspections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (testSessionsRefs)
                        await $_getPrefetchedData<
                          WaterSourceRow,
                          $WaterSourcesTable,
                          TestSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$WaterSourcesTableReferences
                              ._testSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WaterSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).testSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (alertsRefs)
                        await $_getPrefetchedData<
                          WaterSourceRow,
                          $WaterSourcesTable,
                          AlertRow
                        >(
                          currentTable: table,
                          referencedTable: $$WaterSourcesTableReferences
                              ._alertsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WaterSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).alertsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sanitaryInspectionsRefs)
                        await $_getPrefetchedData<
                          WaterSourceRow,
                          $WaterSourcesTable,
                          SanitaryInspectionRow
                        >(
                          currentTable: table,
                          referencedTable: $$WaterSourcesTableReferences
                              ._sanitaryInspectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WaterSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).sanitaryInspectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WaterSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterSourcesTable,
      WaterSourceRow,
      $$WaterSourcesTableFilterComposer,
      $$WaterSourcesTableOrderingComposer,
      $$WaterSourcesTableAnnotationComposer,
      $$WaterSourcesTableCreateCompanionBuilder,
      $$WaterSourcesTableUpdateCompanionBuilder,
      (WaterSourceRow, $$WaterSourcesTableReferences),
      WaterSourceRow,
      PrefetchHooks Function({
        bool testSessionsRefs,
        bool alertsRefs,
        bool sanitaryInspectionsRefs,
      })
    >;
typedef $$TestSessionsTableCreateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String sourceId,
      Value<String?> calibrationId,
      Value<String?> testerProfileId,
      required String referenceStandardId,
      required bool calibrated,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> locationAccuracyM,
      Value<double?> distanceFromSourceM,
      Value<String?> distanceOverrideReason,
      Value<String?> notes,
      required DateTime testedAtDevice,
      Value<int> rowid,
    });
typedef $$TestSessionsTableUpdateCompanionBuilder =
    TestSessionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> sourceId,
      Value<String?> calibrationId,
      Value<String?> testerProfileId,
      Value<String> referenceStandardId,
      Value<bool> calibrated,
      Value<double?> lat,
      Value<double?> lon,
      Value<double?> locationAccuracyM,
      Value<double?> distanceFromSourceM,
      Value<String?> distanceOverrideReason,
      Value<String?> notes,
      Value<DateTime> testedAtDevice,
      Value<int> rowid,
    });

final class $$TestSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $TestSessionsTable, TestSessionRow> {
  $$TestSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WaterSourcesTable _sourceIdTable(_$AppDatabase db) => db.waterSources
      .createAlias('test_sessions__source_id__water_sources__id');

  $$WaterSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$WaterSourcesTableTableManager(
      $_db,
      $_db.waterSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TestResultsTable, List<TestResultRow>>
  _testResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.testResults,
    aliasName: 'test_sessions__id__test_results__session_id',
  );

  $$TestResultsTableProcessedTableManager get testResultsRefs {
    final manager = $$TestResultsTableTableManager(
      $_db,
      $_db.testResults,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_testResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingsTable, List<ReadingRow>>
  _readingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readings,
    aliasName: 'test_sessions__id__readings__session_id',
  );

  $$ReadingsTableProcessedTableManager get readingsRefs {
    final manager = $$ReadingsTableTableManager(
      $_db,
      $_db.readings,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibrationId => $composableBuilder(
    column: $table.calibrationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get calibrated => $composableBuilder(
    column: $table.calibrated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceFromSourceM => $composableBuilder(
    column: $table.distanceFromSourceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceOverrideReason => $composableBuilder(
    column: $table.distanceOverrideReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get testedAtDevice => $composableBuilder(
    column: $table.testedAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  $$WaterSourcesTableFilterComposer get sourceId {
    final $$WaterSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableFilterComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> testResultsRefs(
    Expression<bool> Function($$TestResultsTableFilterComposer f) f,
  ) {
    final $$TestResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableFilterComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingsRefs(
    Expression<bool> Function($$ReadingsTableFilterComposer f) f,
  ) {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableFilterComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibrationId => $composableBuilder(
    column: $table.calibrationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get calibrated => $composableBuilder(
    column: $table.calibrated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceFromSourceM => $composableBuilder(
    column: $table.distanceFromSourceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceOverrideReason => $composableBuilder(
    column: $table.distanceOverrideReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get testedAtDevice => $composableBuilder(
    column: $table.testedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  $$WaterSourcesTableOrderingComposer get sourceId {
    final $$WaterSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestSessionsTable> {
  $$TestSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get calibrationId => $composableBuilder(
    column: $table.calibrationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get calibrated => $composableBuilder(
    column: $table.calibrated,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceFromSourceM => $composableBuilder(
    column: $table.distanceFromSourceM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distanceOverrideReason => $composableBuilder(
    column: $table.distanceOverrideReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get testedAtDevice => $composableBuilder(
    column: $table.testedAtDevice,
    builder: (column) => column,
  );

  $$WaterSourcesTableAnnotationComposer get sourceId {
    final $$WaterSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> testResultsRefs<T extends Object>(
    Expression<T> Function($$TestResultsTableAnnotationComposer a) f,
  ) {
    final $$TestResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingsRefs<T extends Object>(
    Expression<T> Function($$ReadingsTableAnnotationComposer a) f,
  ) {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestSessionsTable,
          TestSessionRow,
          $$TestSessionsTableFilterComposer,
          $$TestSessionsTableOrderingComposer,
          $$TestSessionsTableAnnotationComposer,
          $$TestSessionsTableCreateCompanionBuilder,
          $$TestSessionsTableUpdateCompanionBuilder,
          (TestSessionRow, $$TestSessionsTableReferences),
          TestSessionRow,
          PrefetchHooks Function({
            bool sourceId,
            bool testResultsRefs,
            bool readingsRefs,
          })
        > {
  $$TestSessionsTableTableManager(_$AppDatabase db, $TestSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> calibrationId = const Value.absent(),
                Value<String?> testerProfileId = const Value.absent(),
                Value<String> referenceStandardId = const Value.absent(),
                Value<bool> calibrated = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<double?> distanceFromSourceM = const Value.absent(),
                Value<String?> distanceOverrideReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> testedAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestSessionsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                calibrationId: calibrationId,
                testerProfileId: testerProfileId,
                referenceStandardId: referenceStandardId,
                calibrated: calibrated,
                lat: lat,
                lon: lon,
                locationAccuracyM: locationAccuracyM,
                distanceFromSourceM: distanceFromSourceM,
                distanceOverrideReason: distanceOverrideReason,
                notes: notes,
                testedAtDevice: testedAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String sourceId,
                Value<String?> calibrationId = const Value.absent(),
                Value<String?> testerProfileId = const Value.absent(),
                required String referenceStandardId,
                required bool calibrated,
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<double?> distanceFromSourceM = const Value.absent(),
                Value<String?> distanceOverrideReason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime testedAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => TestSessionsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                calibrationId: calibrationId,
                testerProfileId: testerProfileId,
                referenceStandardId: referenceStandardId,
                calibrated: calibrated,
                lat: lat,
                lon: lon,
                locationAccuracyM: locationAccuracyM,
                distanceFromSourceM: distanceFromSourceM,
                distanceOverrideReason: distanceOverrideReason,
                notes: notes,
                testedAtDevice: testedAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TestSessionsTable, TestSessionRow>(table),
                  $$TestSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceId = false,
                testResultsRefs = false,
                readingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (testResultsRefs) db.testResults,
                    if (readingsRefs) db.readings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$TestSessionsTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$TestSessionsTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (testResultsRefs)
                        await $_getPrefetchedData<
                          TestSessionRow,
                          $TestSessionsTable,
                          TestResultRow
                        >(
                          currentTable: table,
                          referencedTable: $$TestSessionsTableReferences
                              ._testResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TestSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).testResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingsRefs)
                        await $_getPrefetchedData<
                          TestSessionRow,
                          $TestSessionsTable,
                          ReadingRow
                        >(
                          currentTable: table,
                          referencedTable: $$TestSessionsTableReferences
                              ._readingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TestSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).readingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TestSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestSessionsTable,
      TestSessionRow,
      $$TestSessionsTableFilterComposer,
      $$TestSessionsTableOrderingComposer,
      $$TestSessionsTableAnnotationComposer,
      $$TestSessionsTableCreateCompanionBuilder,
      $$TestSessionsTableUpdateCompanionBuilder,
      (TestSessionRow, $$TestSessionsTableReferences),
      TestSessionRow,
      PrefetchHooks Function({
        bool sourceId,
        bool testResultsRefs,
        bool readingsRefs,
      })
    >;
typedef $$TestResultsTableCreateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int?> serverSeq,
      required String id,
      required String sessionId,
      required String overall,
      required String standardId,
      Value<String> computedBy,
      Value<String?> retestOf,
      Value<String?> amendmentOf,
      Value<String?> amendmentReason,
      Value<String> flags,
      Value<String?> limitationCode,
      required DateTime createdAtDevice,
      Value<int> rowid,
    });
typedef $$TestResultsTableUpdateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> sessionId,
      Value<String> overall,
      Value<String> standardId,
      Value<String> computedBy,
      Value<String?> retestOf,
      Value<String?> amendmentOf,
      Value<String?> amendmentReason,
      Value<String> flags,
      Value<String?> limitationCode,
      Value<DateTime> createdAtDevice,
      Value<int> rowid,
    });

final class $$TestResultsTableReferences
    extends BaseReferences<_$AppDatabase, $TestResultsTable, TestResultRow> {
  $$TestResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TestSessionsTable _sessionIdTable(_$AppDatabase db) => db.testSessions
      .createAlias('test_results__session_id__test_sessions__id');

  $$TestSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$TestSessionsTableTableManager(
      $_db,
      $_db.testSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReadingsTable, List<ReadingRow>>
  _readingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readings,
    aliasName: 'test_results__id__readings__result_id',
  );

  $$ReadingsTableProcessedTableManager get readingsRefs {
    final manager = $$ReadingsTableTableManager(
      $_db,
      $_db.readings,
    ).filter((f) => f.resultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retestOf => $composableBuilder(
    column: $table.retestOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amendmentOf => $composableBuilder(
    column: $table.amendmentOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitationCode => $composableBuilder(
    column: $table.limitationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  $$TestSessionsTableFilterComposer get sessionId {
    final $$TestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> readingsRefs(
    Expression<bool> Function($$ReadingsTableFilterComposer f) f,
  ) {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.resultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableFilterComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retestOf => $composableBuilder(
    column: $table.retestOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amendmentOf => $composableBuilder(
    column: $table.amendmentOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitationCode => $composableBuilder(
    column: $table.limitationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  $$TestSessionsTableOrderingComposer get sessionId {
    final $$TestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get overall =>
      $composableBuilder(column: $table.overall, builder: (column) => column);

  GeneratedColumn<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retestOf =>
      $composableBuilder(column: $table.retestOf, builder: (column) => column);

  GeneratedColumn<String> get amendmentOf => $composableBuilder(
    column: $table.amendmentOf,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<String> get limitationCode => $composableBuilder(
    column: $table.limitationCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  $$TestSessionsTableAnnotationComposer get sessionId {
    final $$TestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> readingsRefs<T extends Object>(
    Expression<T> Function($$ReadingsTableAnnotationComposer a) f,
  ) {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readings,
      getReferencedColumn: (t) => t.resultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.readings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestResultsTable,
          TestResultRow,
          $$TestResultsTableFilterComposer,
          $$TestResultsTableOrderingComposer,
          $$TestResultsTableAnnotationComposer,
          $$TestResultsTableCreateCompanionBuilder,
          $$TestResultsTableUpdateCompanionBuilder,
          (TestResultRow, $$TestResultsTableReferences),
          TestResultRow,
          PrefetchHooks Function({bool sessionId, bool readingsRefs})
        > {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> overall = const Value.absent(),
                Value<String> standardId = const Value.absent(),
                Value<String> computedBy = const Value.absent(),
                Value<String?> retestOf = const Value.absent(),
                Value<String?> amendmentOf = const Value.absent(),
                Value<String?> amendmentReason = const Value.absent(),
                Value<String> flags = const Value.absent(),
                Value<String?> limitationCode = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestResultsCompanion(
                serverSeq: serverSeq,
                id: id,
                sessionId: sessionId,
                overall: overall,
                standardId: standardId,
                computedBy: computedBy,
                retestOf: retestOf,
                amendmentOf: amendmentOf,
                amendmentReason: amendmentReason,
                flags: flags,
                limitationCode: limitationCode,
                createdAtDevice: createdAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String sessionId,
                required String overall,
                required String standardId,
                Value<String> computedBy = const Value.absent(),
                Value<String?> retestOf = const Value.absent(),
                Value<String?> amendmentOf = const Value.absent(),
                Value<String?> amendmentReason = const Value.absent(),
                Value<String> flags = const Value.absent(),
                Value<String?> limitationCode = const Value.absent(),
                required DateTime createdAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => TestResultsCompanion.insert(
                serverSeq: serverSeq,
                id: id,
                sessionId: sessionId,
                overall: overall,
                standardId: standardId,
                computedBy: computedBy,
                retestOf: retestOf,
                amendmentOf: amendmentOf,
                amendmentReason: amendmentReason,
                flags: flags,
                limitationCode: limitationCode,
                createdAtDevice: createdAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TestResultsTable, TestResultRow>(table),
                  $$TestResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, readingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (readingsRefs) db.readings],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TestResultsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$TestResultsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingsRefs)
                    await $_getPrefetchedData<
                      TestResultRow,
                      $TestResultsTable,
                      ReadingRow
                    >(
                      currentTable: table,
                      referencedTable: $$TestResultsTableReferences
                          ._readingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TestResultsTableReferences(
                            db,
                            table,
                            p0,
                          ).readingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.resultId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestResultsTable,
      TestResultRow,
      $$TestResultsTableFilterComposer,
      $$TestResultsTableOrderingComposer,
      $$TestResultsTableAnnotationComposer,
      $$TestResultsTableCreateCompanionBuilder,
      $$TestResultsTableUpdateCompanionBuilder,
      (TestResultRow, $$TestResultsTableReferences),
      TestResultRow,
      PrefetchHooks Function({bool sessionId, bool readingsRefs})
    >;
typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  Value<int?> serverSeq,
  required String id,
  required String sessionId,
  required String resultId,
  required String parameterCode,
  Value<String?> value,
  Value<bool?> detected,
  Value<bool?> acceptable,
  Value<String?> valueText,
  Value<String?> unit,
  required String result,
  Value<bool> isDerived,
  Value<String?> sourceDevice,
  Value<int> rowid,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<int?> serverSeq,
  Value<String> id,
  Value<String> sessionId,
  Value<String> resultId,
  Value<String> parameterCode,
  Value<String?> value,
  Value<bool?> detected,
  Value<bool?> acceptable,
  Value<String?> valueText,
  Value<String?> unit,
  Value<String> result,
  Value<bool> isDerived,
  Value<String?> sourceDevice,
  Value<int> rowid,
});

final class $$ReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingsTable, ReadingRow> {
  $$ReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TestSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.testSessions.createAlias('readings__session_id__test_sessions__id');

  $$TestSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$TestSessionsTableTableManager(
      $_db,
      $_db.testSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TestResultsTable _resultIdTable(_$AppDatabase db) =>
      db.testResults.createAlias('readings__result_id__test_results__id');

  $$TestResultsTableProcessedTableManager get resultId {
    final $_column = $_itemColumn<String>('result_id')!;

    final manager = $$TestResultsTableTableManager(
      $_db,
      $_db.testResults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parameterCode => $composableBuilder(
    column: $table.parameterCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detected => $composableBuilder(
    column: $table.detected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acceptable => $composableBuilder(
    column: $table.acceptable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDerived => $composableBuilder(
    column: $table.isDerived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnFilters(column),
  );

  $$TestSessionsTableFilterComposer get sessionId {
    final $$TestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestResultsTableFilterComposer get resultId {
    final $$TestResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableFilterComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameterCode => $composableBuilder(
    column: $table.parameterCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detected => $composableBuilder(
    column: $table.detected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acceptable => $composableBuilder(
    column: $table.acceptable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDerived => $composableBuilder(
    column: $table.isDerived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => ColumnOrderings(column),
  );

  $$TestSessionsTableOrderingComposer get sessionId {
    final $$TestSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestResultsTableOrderingComposer get resultId {
    final $$TestResultsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableOrderingComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parameterCode => $composableBuilder(
    column: $table.parameterCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get detected =>
      $composableBuilder(column: $table.detected, builder: (column) => column);

  GeneratedColumn<bool> get acceptable => $composableBuilder(
    column: $table.acceptable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<bool> get isDerived =>
      $composableBuilder(column: $table.isDerived, builder: (column) => column);

  GeneratedColumn<String> get sourceDevice => $composableBuilder(
    column: $table.sourceDevice,
    builder: (column) => column,
  );

  $$TestSessionsTableAnnotationComposer get sessionId {
    final $$TestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.testSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestResultsTableAnnotationComposer get resultId {
    final $$TestResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingsTable,
          ReadingRow,
          $$ReadingsTableFilterComposer,
          $$ReadingsTableOrderingComposer,
          $$ReadingsTableAnnotationComposer,
          $$ReadingsTableCreateCompanionBuilder,
          $$ReadingsTableUpdateCompanionBuilder,
          (ReadingRow, $$ReadingsTableReferences),
          ReadingRow,
          PrefetchHooks Function({bool sessionId, bool resultId})
        > {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> resultId = const Value.absent(),
                Value<String> parameterCode = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<bool?> detected = const Value.absent(),
                Value<bool?> acceptable = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<bool> isDerived = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingsCompanion(
                serverSeq: serverSeq,
                id: id,
                sessionId: sessionId,
                resultId: resultId,
                parameterCode: parameterCode,
                value: value,
                detected: detected,
                acceptable: acceptable,
                valueText: valueText,
                unit: unit,
                result: result,
                isDerived: isDerived,
                sourceDevice: sourceDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String sessionId,
                required String resultId,
                required String parameterCode,
                Value<String?> value = const Value.absent(),
                Value<bool?> detected = const Value.absent(),
                Value<bool?> acceptable = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                required String result,
                Value<bool> isDerived = const Value.absent(),
                Value<String?> sourceDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingsCompanion.insert(
                serverSeq: serverSeq,
                id: id,
                sessionId: sessionId,
                resultId: resultId,
                parameterCode: parameterCode,
                value: value,
                detected: detected,
                acceptable: acceptable,
                valueText: valueText,
                unit: unit,
                result: result,
                isDerived: isDerived,
                sourceDevice: sourceDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingsTable, ReadingRow>(table),
                  $$ReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, resultId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ReadingsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ReadingsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (resultId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.resultId,
                        referencedTable: $$ReadingsTableReferences
                            ._resultIdTable(db),
                        referencedColumn: $$ReadingsTableReferences
                            ._resultIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingsTable,
      ReadingRow,
      $$ReadingsTableFilterComposer,
      $$ReadingsTableOrderingComposer,
      $$ReadingsTableAnnotationComposer,
      $$ReadingsTableCreateCompanionBuilder,
      $$ReadingsTableUpdateCompanionBuilder,
      (ReadingRow, $$ReadingsTableReferences),
      ReadingRow,
      PrefetchHooks Function({bool sessionId, bool resultId})
    >;
typedef $$CalibrationsTableCreateCompanionBuilder =
    CalibrationsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      Value<String?> testerSerial,
      Value<String?> testerProfileId,
      required String referenceStandardId,
      Value<String?> buffers,
      required bool passed,
      required DateTime performedAtDevice,
      Value<int> rowid,
    });
typedef $$CalibrationsTableUpdateCompanionBuilder =
    CalibrationsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String?> testerSerial,
      Value<String?> testerProfileId,
      Value<String> referenceStandardId,
      Value<String?> buffers,
      Value<bool> passed,
      Value<DateTime> performedAtDevice,
      Value<int> rowid,
    });

class $$CalibrationsTableFilterComposer
    extends Composer<_$AppDatabase, $CalibrationsTable> {
  $$CalibrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testerSerial => $composableBuilder(
    column: $table.testerSerial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buffers => $composableBuilder(
    column: $table.buffers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAtDevice => $composableBuilder(
    column: $table.performedAtDevice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalibrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalibrationsTable> {
  $$CalibrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testerSerial => $composableBuilder(
    column: $table.testerSerial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buffers => $composableBuilder(
    column: $table.buffers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAtDevice => $composableBuilder(
    column: $table.performedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalibrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalibrationsTable> {
  $$CalibrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get testerSerial => $composableBuilder(
    column: $table.testerSerial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testerProfileId => $composableBuilder(
    column: $table.testerProfileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceStandardId => $composableBuilder(
    column: $table.referenceStandardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buffers =>
      $composableBuilder(column: $table.buffers, builder: (column) => column);

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAtDevice => $composableBuilder(
    column: $table.performedAtDevice,
    builder: (column) => column,
  );
}

class $$CalibrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalibrationsTable,
          CalibrationRow,
          $$CalibrationsTableFilterComposer,
          $$CalibrationsTableOrderingComposer,
          $$CalibrationsTableAnnotationComposer,
          $$CalibrationsTableCreateCompanionBuilder,
          $$CalibrationsTableUpdateCompanionBuilder,
          (
            CalibrationRow,
            BaseReferences<_$AppDatabase, $CalibrationsTable, CalibrationRow>,
          ),
          CalibrationRow,
          PrefetchHooks Function()
        > {
  $$CalibrationsTableTableManager(_$AppDatabase db, $CalibrationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalibrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalibrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalibrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> testerSerial = const Value.absent(),
                Value<String?> testerProfileId = const Value.absent(),
                Value<String> referenceStandardId = const Value.absent(),
                Value<String?> buffers = const Value.absent(),
                Value<bool> passed = const Value.absent(),
                Value<DateTime> performedAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalibrationsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                testerSerial: testerSerial,
                testerProfileId: testerProfileId,
                referenceStandardId: referenceStandardId,
                buffers: buffers,
                passed: passed,
                performedAtDevice: performedAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                Value<String?> testerSerial = const Value.absent(),
                Value<String?> testerProfileId = const Value.absent(),
                required String referenceStandardId,
                Value<String?> buffers = const Value.absent(),
                required bool passed,
                required DateTime performedAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => CalibrationsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                testerSerial: testerSerial,
                testerProfileId: testerProfileId,
                referenceStandardId: referenceStandardId,
                buffers: buffers,
                passed: passed,
                performedAtDevice: performedAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalibrationsTable, CalibrationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CalibrationsTable,
                    CalibrationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalibrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalibrationsTable,
      CalibrationRow,
      $$CalibrationsTableFilterComposer,
      $$CalibrationsTableOrderingComposer,
      $$CalibrationsTableAnnotationComposer,
      $$CalibrationsTableCreateCompanionBuilder,
      $$CalibrationsTableUpdateCompanionBuilder,
      (
        CalibrationRow,
        BaseReferences<_$AppDatabase, $CalibrationsTable, CalibrationRow>,
      ),
      CalibrationRow,
      PrefetchHooks Function()
    >;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  Value<String?> installationId,
  Value<String?> collectorKey,
  Value<String?> collectorSnapshot,
  Value<int?> serverSeq,
  required String id,
  required String sourceId,
  Value<String?> triggerResultId,
  required String triggerRule,
  Value<String> status,
  Value<String> severity,
  required DateTime openedAt,
  Value<DateTime?> acknowledgedAt,
  Value<DateTime?> closedAt,
  Value<String?> linkedAlertId,
  Value<int> version,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String?> installationId,
  Value<String?> collectorKey,
  Value<String?> collectorSnapshot,
  Value<int?> serverSeq,
  Value<String> id,
  Value<String> sourceId,
  Value<String?> triggerResultId,
  Value<String> triggerRule,
  Value<String> status,
  Value<String> severity,
  Value<DateTime> openedAt,
  Value<DateTime?> acknowledgedAt,
  Value<DateTime?> closedAt,
  Value<String?> linkedAlertId,
  Value<int> version,
  Value<int> rowid,
});

final class $$AlertsTableReferences
    extends BaseReferences<_$AppDatabase, $AlertsTable, AlertRow> {
  $$AlertsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WaterSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.waterSources.createAlias('alerts__source_id__water_sources__id');

  $$WaterSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$WaterSourcesTableTableManager(
      $_db,
      $_db.waterSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AlertEventsTable, List<AlertEventRow>>
  _alertEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.alertEvents,
    aliasName: 'alerts__id__alert_events__alert_id',
  );

  $$AlertEventsTableProcessedTableManager get alertEventsRefs {
    final manager = $$AlertEventsTableTableManager(
      $_db,
      $_db.alertEvents,
    ).filter((f) => f.alertId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alertEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerResultId => $composableBuilder(
    column: $table.triggerResultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAlertId => $composableBuilder(
    column: $table.linkedAlertId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  $$WaterSourcesTableFilterComposer get sourceId {
    final $$WaterSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableFilterComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> alertEventsRefs(
    Expression<bool> Function($$AlertEventsTableFilterComposer f) f,
  ) {
    final $$AlertEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertEvents,
      getReferencedColumn: (t) => t.alertId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertEventsTableFilterComposer(
            $db: $db,
            $table: $db.alertEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerResultId => $composableBuilder(
    column: $table.triggerResultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAlertId => $composableBuilder(
    column: $table.linkedAlertId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  $$WaterSourcesTableOrderingComposer get sourceId {
    final $$WaterSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get triggerResultId => $composableBuilder(
    column: $table.triggerResultId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get linkedAlertId => $composableBuilder(
    column: $table.linkedAlertId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$WaterSourcesTableAnnotationComposer get sourceId {
    final $$WaterSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> alertEventsRefs<T extends Object>(
    Expression<T> Function($$AlertEventsTableAnnotationComposer a) f,
  ) {
    final $$AlertEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alertEvents,
      getReferencedColumn: (t) => t.alertId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.alertEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertsTable,
          AlertRow,
          $$AlertsTableFilterComposer,
          $$AlertsTableOrderingComposer,
          $$AlertsTableAnnotationComposer,
          $$AlertsTableCreateCompanionBuilder,
          $$AlertsTableUpdateCompanionBuilder,
          (AlertRow, $$AlertsTableReferences),
          AlertRow,
          PrefetchHooks Function({bool sourceId, bool alertEventsRefs})
        > {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> triggerResultId = const Value.absent(),
                Value<String> triggerRule = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> linkedAlertId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                triggerResultId: triggerResultId,
                triggerRule: triggerRule,
                status: status,
                severity: severity,
                openedAt: openedAt,
                acknowledgedAt: acknowledgedAt,
                closedAt: closedAt,
                linkedAlertId: linkedAlertId,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String sourceId,
                Value<String?> triggerResultId = const Value.absent(),
                required String triggerRule,
                Value<String> status = const Value.absent(),
                Value<String> severity = const Value.absent(),
                required DateTime openedAt,
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> linkedAlertId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                triggerResultId: triggerResultId,
                triggerRule: triggerRule,
                status: status,
                severity: severity,
                openedAt: openedAt,
                acknowledgedAt: acknowledgedAt,
                closedAt: closedAt,
                linkedAlertId: linkedAlertId,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertsTable, AlertRow>(table),
                  $$AlertsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false, alertEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (alertEventsRefs) db.alertEvents],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$AlertsTableReferences._sourceIdTable(
                          db,
                        ),
                        referencedColumn: $$AlertsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (alertEventsRefs)
                    await $_getPrefetchedData<
                      AlertRow,
                      $AlertsTable,
                      AlertEventRow
                    >(
                      currentTable: table,
                      referencedTable: $$AlertsTableReferences
                          ._alertEventsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AlertsTableReferences(
                        db,
                        table,
                        p0,
                      ).alertEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.alertId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertsTable,
      AlertRow,
      $$AlertsTableFilterComposer,
      $$AlertsTableOrderingComposer,
      $$AlertsTableAnnotationComposer,
      $$AlertsTableCreateCompanionBuilder,
      $$AlertsTableUpdateCompanionBuilder,
      (AlertRow, $$AlertsTableReferences),
      AlertRow,
      PrefetchHooks Function({bool sourceId, bool alertEventsRefs})
    >;
typedef $$AlertEventsTableCreateCompanionBuilder =
    AlertEventsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String alertId,
      Value<String?> actorId,
      required String eventType,
      Value<String?> note,
      required DateTime occurredAtDevice,
      Value<int> rowid,
    });
typedef $$AlertEventsTableUpdateCompanionBuilder =
    AlertEventsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> alertId,
      Value<String?> actorId,
      Value<String> eventType,
      Value<String?> note,
      Value<DateTime> occurredAtDevice,
      Value<int> rowid,
    });

final class $$AlertEventsTableReferences
    extends BaseReferences<_$AppDatabase, $AlertEventsTable, AlertEventRow> {
  $$AlertEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AlertsTable _alertIdTable(_$AppDatabase db) =>
      db.alerts.createAlias('alert_events__alert_id__alerts__id');

  $$AlertsTableProcessedTableManager get alertId {
    final $_column = $_itemColumn<String>('alert_id')!;

    final manager = $$AlertsTableTableManager(
      $_db,
      $_db.alerts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_alertIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlertEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtDevice => $composableBuilder(
    column: $table.occurredAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  $$AlertsTableFilterComposer get alertId {
    final $$AlertsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alertId,
      referencedTable: $db.alerts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertsTableFilterComposer(
            $db: $db,
            $table: $db.alerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtDevice => $composableBuilder(
    column: $table.occurredAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  $$AlertsTableOrderingComposer get alertId {
    final $$AlertsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alertId,
      referencedTable: $db.alerts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertsTableOrderingComposer(
            $db: $db,
            $table: $db.alerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtDevice => $composableBuilder(
    column: $table.occurredAtDevice,
    builder: (column) => column,
  );

  $$AlertsTableAnnotationComposer get alertId {
    final $$AlertsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.alertId,
      referencedTable: $db.alerts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertsTableAnnotationComposer(
            $db: $db,
            $table: $db.alerts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertEventsTable,
          AlertEventRow,
          $$AlertEventsTableFilterComposer,
          $$AlertEventsTableOrderingComposer,
          $$AlertEventsTableAnnotationComposer,
          $$AlertEventsTableCreateCompanionBuilder,
          $$AlertEventsTableUpdateCompanionBuilder,
          (AlertEventRow, $$AlertEventsTableReferences),
          AlertEventRow,
          PrefetchHooks Function({bool alertId})
        > {
  $$AlertEventsTableTableManager(_$AppDatabase db, $AlertEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> alertId = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> occurredAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertEventsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                alertId: alertId,
                actorId: actorId,
                eventType: eventType,
                note: note,
                occurredAtDevice: occurredAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String alertId,
                Value<String?> actorId = const Value.absent(),
                required String eventType,
                Value<String?> note = const Value.absent(),
                required DateTime occurredAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => AlertEventsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                alertId: alertId,
                actorId: actorId,
                eventType: eventType,
                note: note,
                occurredAtDevice: occurredAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertEventsTable, AlertEventRow>(table),
                  $$AlertEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({alertId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (alertId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.alertId,
                        referencedTable: $$AlertEventsTableReferences
                            ._alertIdTable(db),
                        referencedColumn: $$AlertEventsTableReferences
                            ._alertIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlertEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertEventsTable,
      AlertEventRow,
      $$AlertEventsTableFilterComposer,
      $$AlertEventsTableOrderingComposer,
      $$AlertEventsTableAnnotationComposer,
      $$AlertEventsTableCreateCompanionBuilder,
      $$AlertEventsTableUpdateCompanionBuilder,
      (AlertEventRow, $$AlertEventsTableReferences),
      AlertEventRow,
      PrefetchHooks Function({bool alertId})
    >;
typedef $$SanitaryInspectionsTableCreateCompanionBuilder =
    SanitaryInspectionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String sourceId,
      required String answers,
      required DateTime inspectedAtDevice,
      Value<int> rowid,
    });
typedef $$SanitaryInspectionsTableUpdateCompanionBuilder =
    SanitaryInspectionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> sourceId,
      Value<String> answers,
      Value<DateTime> inspectedAtDevice,
      Value<int> rowid,
    });

final class $$SanitaryInspectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SanitaryInspectionsTable,
          SanitaryInspectionRow
        > {
  $$SanitaryInspectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WaterSourcesTable _sourceIdTable(_$AppDatabase db) => db.waterSources
      .createAlias('sanitary_inspections__source_id__water_sources__id');

  $$WaterSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$WaterSourcesTableTableManager(
      $_db,
      $_db.waterSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SanitaryInspectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SanitaryInspectionsTable> {
  $$SanitaryInspectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inspectedAtDevice => $composableBuilder(
    column: $table.inspectedAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  $$WaterSourcesTableFilterComposer get sourceId {
    final $$WaterSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableFilterComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SanitaryInspectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SanitaryInspectionsTable> {
  $$SanitaryInspectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inspectedAtDevice => $composableBuilder(
    column: $table.inspectedAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  $$WaterSourcesTableOrderingComposer get sourceId {
    final $$WaterSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SanitaryInspectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SanitaryInspectionsTable> {
  $$SanitaryInspectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<DateTime> get inspectedAtDevice => $composableBuilder(
    column: $table.inspectedAtDevice,
    builder: (column) => column,
  );

  $$WaterSourcesTableAnnotationComposer get sourceId {
    final $$WaterSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.waterSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.waterSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SanitaryInspectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SanitaryInspectionsTable,
          SanitaryInspectionRow,
          $$SanitaryInspectionsTableFilterComposer,
          $$SanitaryInspectionsTableOrderingComposer,
          $$SanitaryInspectionsTableAnnotationComposer,
          $$SanitaryInspectionsTableCreateCompanionBuilder,
          $$SanitaryInspectionsTableUpdateCompanionBuilder,
          (SanitaryInspectionRow, $$SanitaryInspectionsTableReferences),
          SanitaryInspectionRow,
          PrefetchHooks Function({bool sourceId})
        > {
  $$SanitaryInspectionsTableTableManager(
    _$AppDatabase db,
    $SanitaryInspectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SanitaryInspectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SanitaryInspectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SanitaryInspectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<DateTime> inspectedAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SanitaryInspectionsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                answers: answers,
                inspectedAtDevice: inspectedAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String sourceId,
                required String answers,
                required DateTime inspectedAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => SanitaryInspectionsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                sourceId: sourceId,
                answers: answers,
                inspectedAtDevice: inspectedAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SanitaryInspectionsTable, SanitaryInspectionRow>(
                    table,
                  ),
                  $$SanitaryInspectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$SanitaryInspectionsTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$SanitaryInspectionsTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SanitaryInspectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SanitaryInspectionsTable,
      SanitaryInspectionRow,
      $$SanitaryInspectionsTableFilterComposer,
      $$SanitaryInspectionsTableOrderingComposer,
      $$SanitaryInspectionsTableAnnotationComposer,
      $$SanitaryInspectionsTableCreateCompanionBuilder,
      $$SanitaryInspectionsTableUpdateCompanionBuilder,
      (SanitaryInspectionRow, $$SanitaryInspectionsTableReferences),
      SanitaryInspectionRow,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$AdminUnitsTableCreateCompanionBuilder = AdminUnitsCompanion Function({
  required String id,
  required String level,
  required String name,
  required String code,
  Value<String?> parentId,
  Value<int> rowid,
});
typedef $$AdminUnitsTableUpdateCompanionBuilder = AdminUnitsCompanion Function({
  Value<String> id,
  Value<String> level,
  Value<String> name,
  Value<String> code,
  Value<String?> parentId,
  Value<int> rowid,
});

final class $$AdminUnitsTableReferences
    extends BaseReferences<_$AppDatabase, $AdminUnitsTable, AdminUnitRow> {
  $$AdminUnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AdminUnitsTable _parentIdTable(_$AppDatabase db) =>
      db.adminUnits.createAlias('admin_units__parent_id__admin_units__id');

  $$AdminUnitsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$AdminUnitsTableTableManager(
      $_db,
      $_db.adminUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdminUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $AdminUnitsTable> {
  $$AdminUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  $$AdminUnitsTableFilterComposer get parentId {
    final $$AdminUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.adminUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUnitsTableFilterComposer(
            $db: $db,
            $table: $db.adminUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminUnitsTable> {
  $$AdminUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  $$AdminUnitsTableOrderingComposer get parentId {
    final $$AdminUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.adminUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.adminUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminUnitsTable> {
  $$AdminUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  $$AdminUnitsTableAnnotationComposer get parentId {
    final $$AdminUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.adminUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdminUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.adminUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdminUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminUnitsTable,
          AdminUnitRow,
          $$AdminUnitsTableFilterComposer,
          $$AdminUnitsTableOrderingComposer,
          $$AdminUnitsTableAnnotationComposer,
          $$AdminUnitsTableCreateCompanionBuilder,
          $$AdminUnitsTableUpdateCompanionBuilder,
          (AdminUnitRow, $$AdminUnitsTableReferences),
          AdminUnitRow,
          PrefetchHooks Function({bool parentId})
        > {
  $$AdminUnitsTableTableManager(_$AppDatabase db, $AdminUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminUnitsCompanion(
                id: id,
                level: level,
                name: name,
                code: code,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String level,
                required String name,
                required String code,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminUnitsCompanion.insert(
                id: id,
                level: level,
                name: name,
                code: code,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdminUnitsTable, AdminUnitRow>(table),
                  $$AdminUnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.parentId,
                        referencedTable: $$AdminUnitsTableReferences
                            ._parentIdTable(db),
                        referencedColumn: $$AdminUnitsTableReferences
                            ._parentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AdminUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminUnitsTable,
      AdminUnitRow,
      $$AdminUnitsTableFilterComposer,
      $$AdminUnitsTableOrderingComposer,
      $$AdminUnitsTableAnnotationComposer,
      $$AdminUnitsTableCreateCompanionBuilder,
      $$AdminUnitsTableUpdateCompanionBuilder,
      (AdminUnitRow, $$AdminUnitsTableReferences),
      AdminUnitRow,
      PrefetchHooks Function({bool parentId})
    >;
typedef $$ParameterCategoriesTableCreateCompanionBuilder =
    ParameterCategoriesCompanion Function({
      required String code,
      required String name,
      required int displayOrder,
      Value<int> rowid,
    });
typedef $$ParameterCategoriesTableUpdateCompanionBuilder =
    ParameterCategoriesCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<int> displayOrder,
      Value<int> rowid,
    });

final class $$ParameterCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ParameterCategoriesTable,
          ParameterCategoryRow
        > {
  $$ParameterCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ParameterDefinitionsTable,
    List<ParameterDefinitionRow>
  >
  _parameterDefinitionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.parameterDefinitions,
        aliasName:
            'parameter_categories__code__parameter_definitions__category_code',
      );

  $$ParameterDefinitionsTableProcessedTableManager
  get parameterDefinitionsRefs {
    final manager =
        $$ParameterDefinitionsTableTableManager(
          $_db,
          $_db.parameterDefinitions,
        ).filter(
          (f) => f.categoryCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _parameterDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParameterCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ParameterCategoriesTable> {
  $$ParameterCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> parameterDefinitionsRefs(
    Expression<bool> Function($$ParameterDefinitionsTableFilterComposer f) f,
  ) {
    final $$ParameterDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.parameterDefinitions,
      getReferencedColumn: (t) => t.categoryCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParameterDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.parameterDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParameterCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ParameterCategoriesTable> {
  $$ParameterCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParameterCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParameterCategoriesTable> {
  $$ParameterCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  Expression<T> parameterDefinitionsRefs<T extends Object>(
    Expression<T> Function($$ParameterDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$ParameterDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.parameterDefinitions,
          getReferencedColumn: (t) => t.categoryCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParameterDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.parameterDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ParameterCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParameterCategoriesTable,
          ParameterCategoryRow,
          $$ParameterCategoriesTableFilterComposer,
          $$ParameterCategoriesTableOrderingComposer,
          $$ParameterCategoriesTableAnnotationComposer,
          $$ParameterCategoriesTableCreateCompanionBuilder,
          $$ParameterCategoriesTableUpdateCompanionBuilder,
          (ParameterCategoryRow, $$ParameterCategoriesTableReferences),
          ParameterCategoryRow,
          PrefetchHooks Function({bool parameterDefinitionsRefs})
        > {
  $$ParameterCategoriesTableTableManager(
    _$AppDatabase db,
    $ParameterCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParameterCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParameterCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParameterCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParameterCategoriesCompanion(
                code: code,
                name: name,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required int displayOrder,
                Value<int> rowid = const Value.absent(),
              }) => ParameterCategoriesCompanion.insert(
                code: code,
                name: name,
                displayOrder: displayOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ParameterCategoriesTable, ParameterCategoryRow>(
                    table,
                  ),
                  $$ParameterCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parameterDefinitionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (parameterDefinitionsRefs) db.parameterDefinitions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (parameterDefinitionsRefs)
                    await $_getPrefetchedData<
                      ParameterCategoryRow,
                      $ParameterCategoriesTable,
                      ParameterDefinitionRow
                    >(
                      currentTable: table,
                      referencedTable: $$ParameterCategoriesTableReferences
                          ._parameterDefinitionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ParameterCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).parameterDefinitionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categoryCode == item.code,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ParameterCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParameterCategoriesTable,
      ParameterCategoryRow,
      $$ParameterCategoriesTableFilterComposer,
      $$ParameterCategoriesTableOrderingComposer,
      $$ParameterCategoriesTableAnnotationComposer,
      $$ParameterCategoriesTableCreateCompanionBuilder,
      $$ParameterCategoriesTableUpdateCompanionBuilder,
      (ParameterCategoryRow, $$ParameterCategoriesTableReferences),
      ParameterCategoryRow,
      PrefetchHooks Function({bool parameterDefinitionsRefs})
    >;
typedef $$ParameterDefinitionsTableCreateCompanionBuilder =
    ParameterDefinitionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String code,
      required String name,
      required String categoryCode,
      required String defaultUnit,
      required String valueType,
      Value<bool> isCore,
      Value<int> displayOrder,
      Value<String?> plausibleMin,
      Value<String?> plausibleMax,
      Value<bool> isCustom,
      Value<String?> scopeAdminUnitId,
      Value<String> reviewStatus,
      Value<int> rowid,
    });
typedef $$ParameterDefinitionsTableUpdateCompanionBuilder =
    ParameterDefinitionsCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> code,
      Value<String> name,
      Value<String> categoryCode,
      Value<String> defaultUnit,
      Value<String> valueType,
      Value<bool> isCore,
      Value<int> displayOrder,
      Value<String?> plausibleMin,
      Value<String?> plausibleMax,
      Value<bool> isCustom,
      Value<String?> scopeAdminUnitId,
      Value<String> reviewStatus,
      Value<int> rowid,
    });

final class $$ParameterDefinitionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ParameterDefinitionsTable,
          ParameterDefinitionRow
        > {
  $$ParameterDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ParameterCategoriesTable _categoryCodeTable(_$AppDatabase db) =>
      db.parameterCategories.createAlias(
        'parameter_definitions__category_code__parameter_categories__code',
      );

  $$ParameterCategoriesTableProcessedTableManager get categoryCode {
    final $_column = $_itemColumn<String>('category_code')!;

    final manager = $$ParameterCategoriesTableTableManager(
      $_db,
      $_db.parameterCategories,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ParameterDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $ParameterDefinitionsTable> {
  $$ParameterDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCore => $composableBuilder(
    column: $table.isCore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plausibleMin => $composableBuilder(
    column: $table.plausibleMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plausibleMax => $composableBuilder(
    column: $table.plausibleMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeAdminUnitId => $composableBuilder(
    column: $table.scopeAdminUnitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$ParameterCategoriesTableFilterComposer get categoryCode {
    final $$ParameterCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryCode,
      referencedTable: $db.parameterCategories,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParameterCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.parameterCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParameterDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParameterDefinitionsTable> {
  $$ParameterDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCore => $composableBuilder(
    column: $table.isCore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plausibleMin => $composableBuilder(
    column: $table.plausibleMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plausibleMax => $composableBuilder(
    column: $table.plausibleMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeAdminUnitId => $composableBuilder(
    column: $table.scopeAdminUnitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ParameterCategoriesTableOrderingComposer get categoryCode {
    final $$ParameterCategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryCode,
          referencedTable: $db.parameterCategories,
          getReferencedColumn: (t) => t.code,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParameterCategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.parameterCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParameterDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParameterDefinitionsTable> {
  $$ParameterDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get defaultUnit => $composableBuilder(
    column: $table.defaultUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<bool> get isCore =>
      $composableBuilder(column: $table.isCore, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plausibleMin => $composableBuilder(
    column: $table.plausibleMin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plausibleMax => $composableBuilder(
    column: $table.plausibleMax,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get scopeAdminUnitId => $composableBuilder(
    column: $table.scopeAdminUnitId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  $$ParameterCategoriesTableAnnotationComposer get categoryCode {
    final $$ParameterCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryCode,
          referencedTable: $db.parameterCategories,
          getReferencedColumn: (t) => t.code,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParameterCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.parameterCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParameterDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParameterDefinitionsTable,
          ParameterDefinitionRow,
          $$ParameterDefinitionsTableFilterComposer,
          $$ParameterDefinitionsTableOrderingComposer,
          $$ParameterDefinitionsTableAnnotationComposer,
          $$ParameterDefinitionsTableCreateCompanionBuilder,
          $$ParameterDefinitionsTableUpdateCompanionBuilder,
          (ParameterDefinitionRow, $$ParameterDefinitionsTableReferences),
          ParameterDefinitionRow,
          PrefetchHooks Function({bool categoryCode})
        > {
  $$ParameterDefinitionsTableTableManager(
    _$AppDatabase db,
    $ParameterDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParameterDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParameterDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParameterDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> categoryCode = const Value.absent(),
                Value<String> defaultUnit = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<bool> isCore = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<String?> plausibleMin = const Value.absent(),
                Value<String?> plausibleMax = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> scopeAdminUnitId = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParameterDefinitionsCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                code: code,
                name: name,
                categoryCode: categoryCode,
                defaultUnit: defaultUnit,
                valueType: valueType,
                isCore: isCore,
                displayOrder: displayOrder,
                plausibleMin: plausibleMin,
                plausibleMax: plausibleMax,
                isCustom: isCustom,
                scopeAdminUnitId: scopeAdminUnitId,
                reviewStatus: reviewStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String code,
                required String name,
                required String categoryCode,
                required String defaultUnit,
                required String valueType,
                Value<bool> isCore = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<String?> plausibleMin = const Value.absent(),
                Value<String?> plausibleMax = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> scopeAdminUnitId = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParameterDefinitionsCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                code: code,
                name: name,
                categoryCode: categoryCode,
                defaultUnit: defaultUnit,
                valueType: valueType,
                isCore: isCore,
                displayOrder: displayOrder,
                plausibleMin: plausibleMin,
                plausibleMax: plausibleMax,
                isCustom: isCustom,
                scopeAdminUnitId: scopeAdminUnitId,
                reviewStatus: reviewStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ParameterDefinitionsTable,
                    ParameterDefinitionRow
                  >(table),
                  $$ParameterDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryCode,
                        referencedTable: $$ParameterDefinitionsTableReferences
                            ._categoryCodeTable(db),
                        referencedColumn: $$ParameterDefinitionsTableReferences
                            ._categoryCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ParameterDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParameterDefinitionsTable,
      ParameterDefinitionRow,
      $$ParameterDefinitionsTableFilterComposer,
      $$ParameterDefinitionsTableOrderingComposer,
      $$ParameterDefinitionsTableAnnotationComposer,
      $$ParameterDefinitionsTableCreateCompanionBuilder,
      $$ParameterDefinitionsTableUpdateCompanionBuilder,
      (ParameterDefinitionRow, $$ParameterDefinitionsTableReferences),
      ParameterDefinitionRow,
      PrefetchHooks Function({bool categoryCode})
    >;
typedef $$TesterProfilesTableCreateCompanionBuilder =
    TesterProfilesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String name,
      Value<String?> manufacturer,
      Value<String?> model,
      Value<String?> tdsFactor,
      required String parameters,
      Value<int> rowid,
    });
typedef $$TesterProfilesTableUpdateCompanionBuilder =
    TesterProfilesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> name,
      Value<String?> manufacturer,
      Value<String?> model,
      Value<String?> tdsFactor,
      Value<String> parameters,
      Value<int> rowid,
    });

class $$TesterProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $TesterProfilesTable> {
  $$TesterProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tdsFactor => $composableBuilder(
    column: $table.tdsFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TesterProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $TesterProfilesTable> {
  $$TesterProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tdsFactor => $composableBuilder(
    column: $table.tdsFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TesterProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TesterProfilesTable> {
  $$TesterProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get tdsFactor =>
      $composableBuilder(column: $table.tdsFactor, builder: (column) => column);

  GeneratedColumn<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => column,
  );
}

class $$TesterProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TesterProfilesTable,
          TesterProfileRow,
          $$TesterProfilesTableFilterComposer,
          $$TesterProfilesTableOrderingComposer,
          $$TesterProfilesTableAnnotationComposer,
          $$TesterProfilesTableCreateCompanionBuilder,
          $$TesterProfilesTableUpdateCompanionBuilder,
          (
            TesterProfileRow,
            BaseReferences<
              _$AppDatabase,
              $TesterProfilesTable,
              TesterProfileRow
            >,
          ),
          TesterProfileRow,
          PrefetchHooks Function()
        > {
  $$TesterProfilesTableTableManager(
    _$AppDatabase db,
    $TesterProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TesterProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TesterProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TesterProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> tdsFactor = const Value.absent(),
                Value<String> parameters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TesterProfilesCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                name: name,
                manufacturer: manufacturer,
                model: model,
                tdsFactor: tdsFactor,
                parameters: parameters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String name,
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> tdsFactor = const Value.absent(),
                required String parameters,
                Value<int> rowid = const Value.absent(),
              }) => TesterProfilesCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                name: name,
                manufacturer: manufacturer,
                model: model,
                tdsFactor: tdsFactor,
                parameters: parameters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TesterProfilesTable, TesterProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TesterProfilesTable,
                    TesterProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TesterProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TesterProfilesTable,
      TesterProfileRow,
      $$TesterProfilesTableFilterComposer,
      $$TesterProfilesTableOrderingComposer,
      $$TesterProfilesTableAnnotationComposer,
      $$TesterProfilesTableCreateCompanionBuilder,
      $$TesterProfilesTableUpdateCompanionBuilder,
      (
        TesterProfileRow,
        BaseReferences<_$AppDatabase, $TesterProfilesTable, TesterProfileRow>,
      ),
      TesterProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ReferenceProfilesTableCreateCompanionBuilder =
    ReferenceProfilesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      required String id,
      required String code,
      required String title,
      required int version,
      Value<String?> basedOnId,
      Value<bool> isCustom,
      Value<String?> customReason,
      Value<bool> isProvisional,
      Value<DateTime?> publishedAt,
      required String document,
      Value<int> rowid,
    });
typedef $$ReferenceProfilesTableUpdateCompanionBuilder =
    ReferenceProfilesCompanion Function({
      Value<String?> installationId,
      Value<String?> collectorKey,
      Value<String?> collectorSnapshot,
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> code,
      Value<String> title,
      Value<int> version,
      Value<String?> basedOnId,
      Value<bool> isCustom,
      Value<String?> customReason,
      Value<bool> isProvisional,
      Value<DateTime?> publishedAt,
      Value<String> document,
      Value<int> rowid,
    });

class $$ReferenceProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ReferenceProfilesTable> {
  $$ReferenceProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basedOnId => $composableBuilder(
    column: $table.basedOnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customReason => $composableBuilder(
    column: $table.customReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProvisional => $composableBuilder(
    column: $table.isProvisional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReferenceProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferenceProfilesTable> {
  $$ReferenceProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basedOnId => $composableBuilder(
    column: $table.basedOnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customReason => $composableBuilder(
    column: $table.customReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProvisional => $composableBuilder(
    column: $table.isProvisional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReferenceProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferenceProfilesTable> {
  $$ReferenceProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorSnapshot => $composableBuilder(
    column: $table.collectorSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get basedOnId =>
      $composableBuilder(column: $table.basedOnId, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get customReason => $composableBuilder(
    column: $table.customReason,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isProvisional => $composableBuilder(
    column: $table.isProvisional,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get document =>
      $composableBuilder(column: $table.document, builder: (column) => column);
}

class $$ReferenceProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReferenceProfilesTable,
          ReferenceProfileRow,
          $$ReferenceProfilesTableFilterComposer,
          $$ReferenceProfilesTableOrderingComposer,
          $$ReferenceProfilesTableAnnotationComposer,
          $$ReferenceProfilesTableCreateCompanionBuilder,
          $$ReferenceProfilesTableUpdateCompanionBuilder,
          (
            ReferenceProfileRow,
            BaseReferences<
              _$AppDatabase,
              $ReferenceProfilesTable,
              ReferenceProfileRow
            >,
          ),
          ReferenceProfileRow,
          PrefetchHooks Function()
        > {
  $$ReferenceProfilesTableTableManager(
    _$AppDatabase db,
    $ReferenceProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenceProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenceProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenceProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> basedOnId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> customReason = const Value.absent(),
                Value<bool> isProvisional = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> document = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenceProfilesCompanion(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                code: code,
                title: title,
                version: version,
                basedOnId: basedOnId,
                isCustom: isCustom,
                customReason: customReason,
                isProvisional: isProvisional,
                publishedAt: publishedAt,
                document: document,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> installationId = const Value.absent(),
                Value<String?> collectorKey = const Value.absent(),
                Value<String?> collectorSnapshot = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String code,
                required String title,
                required int version,
                Value<String?> basedOnId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> customReason = const Value.absent(),
                Value<bool> isProvisional = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                required String document,
                Value<int> rowid = const Value.absent(),
              }) => ReferenceProfilesCompanion.insert(
                installationId: installationId,
                collectorKey: collectorKey,
                collectorSnapshot: collectorSnapshot,
                serverSeq: serverSeq,
                id: id,
                code: code,
                title: title,
                version: version,
                basedOnId: basedOnId,
                isCustom: isCustom,
                customReason: customReason,
                isProvisional: isProvisional,
                publishedAt: publishedAt,
                document: document,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReferenceProfilesTable, ReferenceProfileRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ReferenceProfilesTable,
                    ReferenceProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReferenceProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReferenceProfilesTable,
      ReferenceProfileRow,
      $$ReferenceProfilesTableFilterComposer,
      $$ReferenceProfilesTableOrderingComposer,
      $$ReferenceProfilesTableAnnotationComposer,
      $$ReferenceProfilesTableCreateCompanionBuilder,
      $$ReferenceProfilesTableUpdateCompanionBuilder,
      (
        ReferenceProfileRow,
        BaseReferences<
          _$AppDatabase,
          $ReferenceProfilesTable,
          ReferenceProfileRow
        >,
      ),
      ReferenceProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ResponseCardsTableCreateCompanionBuilder =
    ResponseCardsCompanion Function({
      Value<int?> serverSeq,
      required String id,
      required String triggerRule,
      required String audience,
      required int version,
      required String content,
      Value<int> rowid,
    });
typedef $$ResponseCardsTableUpdateCompanionBuilder =
    ResponseCardsCompanion Function({
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> triggerRule,
      Value<String> audience,
      Value<int> version,
      Value<String> content,
      Value<int> rowid,
    });

class $$ResponseCardsTableFilterComposer
    extends Composer<_$AppDatabase, $ResponseCardsTable> {
  $$ResponseCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResponseCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponseCardsTable> {
  $$ResponseCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResponseCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponseCardsTable> {
  $$ResponseCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get triggerRule => $composableBuilder(
    column: $table.triggerRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audience =>
      $composableBuilder(column: $table.audience, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$ResponseCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResponseCardsTable,
          ResponseCardRow,
          $$ResponseCardsTableFilterComposer,
          $$ResponseCardsTableOrderingComposer,
          $$ResponseCardsTableAnnotationComposer,
          $$ResponseCardsTableCreateCompanionBuilder,
          $$ResponseCardsTableUpdateCompanionBuilder,
          (
            ResponseCardRow,
            BaseReferences<_$AppDatabase, $ResponseCardsTable, ResponseCardRow>,
          ),
          ResponseCardRow,
          PrefetchHooks Function()
        > {
  $$ResponseCardsTableTableManager(_$AppDatabase db, $ResponseCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResponseCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResponseCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResponseCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> triggerRule = const Value.absent(),
                Value<String> audience = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResponseCardsCompanion(
                serverSeq: serverSeq,
                id: id,
                triggerRule: triggerRule,
                audience: audience,
                version: version,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String triggerRule,
                required String audience,
                required int version,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => ResponseCardsCompanion.insert(
                serverSeq: serverSeq,
                id: id,
                triggerRule: triggerRule,
                audience: audience,
                version: version,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResponseCardsTable, ResponseCardRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ResponseCardsTable,
                    ResponseCardRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResponseCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResponseCardsTable,
      ResponseCardRow,
      $$ResponseCardsTableFilterComposer,
      $$ResponseCardsTableOrderingComposer,
      $$ResponseCardsTableAnnotationComposer,
      $$ResponseCardsTableCreateCompanionBuilder,
      $$ResponseCardsTableUpdateCompanionBuilder,
      (
        ResponseCardRow,
        BaseReferences<_$AppDatabase, $ResponseCardsTable, ResponseCardRow>,
      ),
      ResponseCardRow,
      PrefetchHooks Function()
    >;
typedef $$ResponsibilitiesTableCreateCompanionBuilder =
    ResponsibilitiesCompanion Function({
      required String code,
      required String name,
      Value<int> rowid,
    });
typedef $$ResponsibilitiesTableUpdateCompanionBuilder =
    ResponsibilitiesCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<int> rowid,
    });

class $$ResponsibilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ResponsibilitiesTable> {
  $$ResponsibilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResponsibilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponsibilitiesTable> {
  $$ResponsibilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResponsibilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponsibilitiesTable> {
  $$ResponsibilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ResponsibilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResponsibilitiesTable,
          ResponsibilityRow,
          $$ResponsibilitiesTableFilterComposer,
          $$ResponsibilitiesTableOrderingComposer,
          $$ResponsibilitiesTableAnnotationComposer,
          $$ResponsibilitiesTableCreateCompanionBuilder,
          $$ResponsibilitiesTableUpdateCompanionBuilder,
          (
            ResponsibilityRow,
            BaseReferences<
              _$AppDatabase,
              $ResponsibilitiesTable,
              ResponsibilityRow
            >,
          ),
          ResponsibilityRow,
          PrefetchHooks Function()
        > {
  $$ResponsibilitiesTableTableManager(
    _$AppDatabase db,
    $ResponsibilitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResponsibilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResponsibilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResponsibilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ResponsibilitiesCompanion(code: code, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ResponsibilitiesCompanion.insert(
                code: code,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResponsibilitiesTable, ResponsibilityRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ResponsibilitiesTable,
                    ResponsibilityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResponsibilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResponsibilitiesTable,
      ResponsibilityRow,
      $$ResponsibilitiesTableFilterComposer,
      $$ResponsibilitiesTableOrderingComposer,
      $$ResponsibilitiesTableAnnotationComposer,
      $$ResponsibilitiesTableCreateCompanionBuilder,
      $$ResponsibilitiesTableUpdateCompanionBuilder,
      (
        ResponsibilityRow,
        BaseReferences<
          _$AppDatabase,
          $ResponsibilitiesTable,
          ResponsibilityRow
        >,
      ),
      ResponsibilityRow,
      PrefetchHooks Function()
    >;
typedef $$ConfigDocumentsTableCreateCompanionBuilder =
    ConfigDocumentsCompanion Function({
      required String key,
      required String document,
      required int version,
      Value<int> rowid,
    });
typedef $$ConfigDocumentsTableUpdateCompanionBuilder =
    ConfigDocumentsCompanion Function({
      Value<String> key,
      Value<String> document,
      Value<int> version,
      Value<int> rowid,
    });

class $$ConfigDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigDocumentsTable> {
  $$ConfigDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigDocumentsTable> {
  $$ConfigDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigDocumentsTable> {
  $$ConfigDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get document =>
      $composableBuilder(column: $table.document, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$ConfigDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigDocumentsTable,
          ConfigDocumentRow,
          $$ConfigDocumentsTableFilterComposer,
          $$ConfigDocumentsTableOrderingComposer,
          $$ConfigDocumentsTableAnnotationComposer,
          $$ConfigDocumentsTableCreateCompanionBuilder,
          $$ConfigDocumentsTableUpdateCompanionBuilder,
          (
            ConfigDocumentRow,
            BaseReferences<
              _$AppDatabase,
              $ConfigDocumentsTable,
              ConfigDocumentRow
            >,
          ),
          ConfigDocumentRow,
          PrefetchHooks Function()
        > {
  $$ConfigDocumentsTableTableManager(
    _$AppDatabase db,
    $ConfigDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> document = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigDocumentsCompanion(
                key: key,
                document: document,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String document,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => ConfigDocumentsCompanion.insert(
                key: key,
                document: document,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigDocumentsTable, ConfigDocumentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfigDocumentsTable,
                    ConfigDocumentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigDocumentsTable,
      ConfigDocumentRow,
      $$ConfigDocumentsTableFilterComposer,
      $$ConfigDocumentsTableOrderingComposer,
      $$ConfigDocumentsTableAnnotationComposer,
      $$ConfigDocumentsTableCreateCompanionBuilder,
      $$ConfigDocumentsTableUpdateCompanionBuilder,
      (
        ConfigDocumentRow,
        BaseReferences<_$AppDatabase, $ConfigDocumentsTable, ConfigDocumentRow>,
      ),
      ConfigDocumentRow,
      PrefetchHooks Function()
    >;
typedef $$SeedImportsTableCreateCompanionBuilder =
    SeedImportsCompanion Function({
      required String name,
      required int version,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$SeedImportsTableUpdateCompanionBuilder =
    SeedImportsCompanion Function({
      Value<String> name,
      Value<int> version,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$SeedImportsTableFilterComposer
    extends Composer<_$AppDatabase, $SeedImportsTable> {
  $$SeedImportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeedImportsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeedImportsTable> {
  $$SeedImportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeedImportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeedImportsTable> {
  $$SeedImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$SeedImportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeedImportsTable,
          SeedImportRow,
          $$SeedImportsTableFilterComposer,
          $$SeedImportsTableOrderingComposer,
          $$SeedImportsTableAnnotationComposer,
          $$SeedImportsTableCreateCompanionBuilder,
          $$SeedImportsTableUpdateCompanionBuilder,
          (
            SeedImportRow,
            BaseReferences<_$AppDatabase, $SeedImportsTable, SeedImportRow>,
          ),
          SeedImportRow,
          PrefetchHooks Function()
        > {
  $$SeedImportsTableTableManager(_$AppDatabase db, $SeedImportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeedImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeedImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeedImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeedImportsCompanion(
                name: name,
                version: version,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required int version,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => SeedImportsCompanion.insert(
                name: name,
                version: version,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeedImportsTable, SeedImportRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SeedImportsTable,
                    SeedImportRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeedImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeedImportsTable,
      SeedImportRow,
      $$SeedImportsTableFilterComposer,
      $$SeedImportsTableOrderingComposer,
      $$SeedImportsTableAnnotationComposer,
      $$SeedImportsTableCreateCompanionBuilder,
      $$SeedImportsTableUpdateCompanionBuilder,
      (
        SeedImportRow,
        BaseReferences<_$AppDatabase, $SeedImportsTable, SeedImportRow>,
      ),
      SeedImportRow,
      PrefetchHooks Function()
    >;
typedef $$CollectorProfilesTableCreateCompanionBuilder =
    CollectorProfilesCompanion Function({
      required String collectorKey,
      required int profileVersion,
      required String fullName,
      required String phone,
      required String collectorType,
      required String village,
      required String parish,
      required String subcounty,
      required String district,
      Value<String?> organisation,
      Value<bool> isActive,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CollectorProfilesTableUpdateCompanionBuilder =
    CollectorProfilesCompanion Function({
      Value<String> collectorKey,
      Value<int> profileVersion,
      Value<String> fullName,
      Value<String> phone,
      Value<String> collectorType,
      Value<String> village,
      Value<String> parish,
      Value<String> subcounty,
      Value<String> district,
      Value<String?> organisation,
      Value<bool> isActive,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CollectorProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CollectorProfilesTable> {
  $$CollectorProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorType => $composableBuilder(
    column: $table.collectorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parish => $composableBuilder(
    column: $table.parish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcounty => $composableBuilder(
    column: $table.subcounty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organisation => $composableBuilder(
    column: $table.organisation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectorProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectorProfilesTable> {
  $$CollectorProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorType => $composableBuilder(
    column: $table.collectorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parish => $composableBuilder(
    column: $table.parish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcounty => $composableBuilder(
    column: $table.subcounty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organisation => $composableBuilder(
    column: $table.organisation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectorProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectorProfilesTable> {
  $$CollectorProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profileVersion => $composableBuilder(
    column: $table.profileVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get collectorType => $composableBuilder(
    column: $table.collectorType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get parish =>
      $composableBuilder(column: $table.parish, builder: (column) => column);

  GeneratedColumn<String> get subcounty =>
      $composableBuilder(column: $table.subcounty, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get organisation => $composableBuilder(
    column: $table.organisation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectorProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectorProfilesTable,
          CollectorProfileRow,
          $$CollectorProfilesTableFilterComposer,
          $$CollectorProfilesTableOrderingComposer,
          $$CollectorProfilesTableAnnotationComposer,
          $$CollectorProfilesTableCreateCompanionBuilder,
          $$CollectorProfilesTableUpdateCompanionBuilder,
          (
            CollectorProfileRow,
            BaseReferences<
              _$AppDatabase,
              $CollectorProfilesTable,
              CollectorProfileRow
            >,
          ),
          CollectorProfileRow,
          PrefetchHooks Function()
        > {
  $$CollectorProfilesTableTableManager(
    _$AppDatabase db,
    $CollectorProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectorProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectorProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectorProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> collectorKey = const Value.absent(),
                Value<int> profileVersion = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> collectorType = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String> parish = const Value.absent(),
                Value<String> subcounty = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String?> organisation = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectorProfilesCompanion(
                collectorKey: collectorKey,
                profileVersion: profileVersion,
                fullName: fullName,
                phone: phone,
                collectorType: collectorType,
                village: village,
                parish: parish,
                subcounty: subcounty,
                district: district,
                organisation: organisation,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectorKey,
                required int profileVersion,
                required String fullName,
                required String phone,
                required String collectorType,
                required String village,
                required String parish,
                required String subcounty,
                required String district,
                Value<String?> organisation = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectorProfilesCompanion.insert(
                collectorKey: collectorKey,
                profileVersion: profileVersion,
                fullName: fullName,
                phone: phone,
                collectorType: collectorType,
                village: village,
                parish: parish,
                subcounty: subcounty,
                district: district,
                organisation: organisation,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectorProfilesTable, CollectorProfileRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectorProfilesTable,
                    CollectorProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectorProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectorProfilesTable,
      CollectorProfileRow,
      $$CollectorProfilesTableFilterComposer,
      $$CollectorProfilesTableOrderingComposer,
      $$CollectorProfilesTableAnnotationComposer,
      $$CollectorProfilesTableCreateCompanionBuilder,
      $$CollectorProfilesTableUpdateCompanionBuilder,
      (
        CollectorProfileRow,
        BaseReferences<
          _$AppDatabase,
          $CollectorProfilesTable,
          CollectorProfileRow
        >,
      ),
      CollectorProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ClassificationsTableCreateCompanionBuilder =
    ClassificationsCompanion Function({
      required String resultId,
      required String standardId,
      required String computedBy,
      required String overall,
      required String readingResults,
      Value<String> flags,
      required DateTime computedAt,
      Value<int> rowid,
    });
typedef $$ClassificationsTableUpdateCompanionBuilder =
    ClassificationsCompanion Function({
      Value<String> resultId,
      Value<String> standardId,
      Value<String> computedBy,
      Value<String> overall,
      Value<String> readingResults,
      Value<String> flags,
      Value<DateTime> computedAt,
      Value<int> rowid,
    });

class $$ClassificationsTableFilterComposer
    extends Composer<_$AppDatabase, $ClassificationsTable> {
  $$ClassificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingResults => $composableBuilder(
    column: $table.readingResults,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassificationsTable> {
  $$ClassificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overall => $composableBuilder(
    column: $table.overall,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingResults => $composableBuilder(
    column: $table.readingResults,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flags => $composableBuilder(
    column: $table.flags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassificationsTable> {
  $$ClassificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resultId =>
      $composableBuilder(column: $table.resultId, builder: (column) => column);

  GeneratedColumn<String> get standardId => $composableBuilder(
    column: $table.standardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedBy => $composableBuilder(
    column: $table.computedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overall =>
      $composableBuilder(column: $table.overall, builder: (column) => column);

  GeneratedColumn<String> get readingResults => $composableBuilder(
    column: $table.readingResults,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );
}

class $$ClassificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassificationsTable,
          ClassificationRow,
          $$ClassificationsTableFilterComposer,
          $$ClassificationsTableOrderingComposer,
          $$ClassificationsTableAnnotationComposer,
          $$ClassificationsTableCreateCompanionBuilder,
          $$ClassificationsTableUpdateCompanionBuilder,
          (
            ClassificationRow,
            BaseReferences<
              _$AppDatabase,
              $ClassificationsTable,
              ClassificationRow
            >,
          ),
          ClassificationRow,
          PrefetchHooks Function()
        > {
  $$ClassificationsTableTableManager(
    _$AppDatabase db,
    $ClassificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> resultId = const Value.absent(),
                Value<String> standardId = const Value.absent(),
                Value<String> computedBy = const Value.absent(),
                Value<String> overall = const Value.absent(),
                Value<String> readingResults = const Value.absent(),
                Value<String> flags = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassificationsCompanion(
                resultId: resultId,
                standardId: standardId,
                computedBy: computedBy,
                overall: overall,
                readingResults: readingResults,
                flags: flags,
                computedAt: computedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String resultId,
                required String standardId,
                required String computedBy,
                required String overall,
                required String readingResults,
                Value<String> flags = const Value.absent(),
                required DateTime computedAt,
                Value<int> rowid = const Value.absent(),
              }) => ClassificationsCompanion.insert(
                resultId: resultId,
                standardId: standardId,
                computedBy: computedBy,
                overall: overall,
                readingResults: readingResults,
                flags: flags,
                computedAt: computedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClassificationsTable, ClassificationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ClassificationsTable,
                    ClassificationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassificationsTable,
      ClassificationRow,
      $$ClassificationsTableFilterComposer,
      $$ClassificationsTableOrderingComposer,
      $$ClassificationsTableAnnotationComposer,
      $$ClassificationsTableCreateCompanionBuilder,
      $$ClassificationsTableUpdateCompanionBuilder,
      (
        ClassificationRow,
        BaseReferences<_$AppDatabase, $ClassificationsTable, ClassificationRow>,
      ),
      ClassificationRow,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int?> serverSeq,
      required String id,
      required String ownerType,
      required String ownerId,
      Value<String?> objectKey,
      required String sha256,
      required int bytes,
      required String mime,
      Value<String> uploadStatus,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<String?> objectKey,
      Value<String> sha256,
      Value<int> bytes,
      Value<String> mime,
      Value<String> uploadStatus,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => column,
  );
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String?> objectKey = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                serverSeq: serverSeq,
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                objectKey: objectKey,
                sha256: sha256,
                bytes: bytes,
                mime: mime,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String ownerType,
                required String ownerId,
                Value<String?> objectKey = const Value.absent(),
                required String sha256,
                required int bytes,
                required String mime,
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                serverSeq: serverSeq,
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                objectKey: objectKey,
                sha256: sha256,
                bytes: bytes,
                mime: mime,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, AttachmentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttachmentsTable,
                    AttachmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$CollectorMarksTableCreateCompanionBuilder =
    CollectorMarksCompanion Function({
      Value<int?> serverSeq,
      required String collectorKey,
      required String status,
      Value<String?> note,
      Value<String?> markedBy,
      required DateTime markedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$CollectorMarksTableUpdateCompanionBuilder =
    CollectorMarksCompanion Function({
      Value<int?> serverSeq,
      Value<String> collectorKey,
      Value<String> status,
      Value<String?> note,
      Value<String?> markedBy,
      Value<DateTime> markedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$CollectorMarksTableFilterComposer
    extends Composer<_$AppDatabase, $CollectorMarksTable> {
  $$CollectorMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectorMarksTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectorMarksTable> {
  $$CollectorMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectorMarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectorMarksTable> {
  $$CollectorMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get collectorKey => $composableBuilder(
    column: $table.collectorKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get markedBy =>
      $composableBuilder(column: $table.markedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$CollectorMarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectorMarksTable,
          CollectorMarkRow,
          $$CollectorMarksTableFilterComposer,
          $$CollectorMarksTableOrderingComposer,
          $$CollectorMarksTableAnnotationComposer,
          $$CollectorMarksTableCreateCompanionBuilder,
          $$CollectorMarksTableUpdateCompanionBuilder,
          (
            CollectorMarkRow,
            BaseReferences<
              _$AppDatabase,
              $CollectorMarksTable,
              CollectorMarkRow
            >,
          ),
          CollectorMarkRow,
          PrefetchHooks Function()
        > {
  $$CollectorMarksTableTableManager(
    _$AppDatabase db,
    $CollectorMarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectorMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectorMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectorMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> collectorKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> markedBy = const Value.absent(),
                Value<DateTime> markedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectorMarksCompanion(
                serverSeq: serverSeq,
                collectorKey: collectorKey,
                status: status,
                note: note,
                markedBy: markedBy,
                markedAt: markedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String collectorKey,
                required String status,
                Value<String?> note = const Value.absent(),
                Value<String?> markedBy = const Value.absent(),
                required DateTime markedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectorMarksCompanion.insert(
                serverSeq: serverSeq,
                collectorKey: collectorKey,
                status: status,
                note: note,
                markedBy: markedBy,
                markedAt: markedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectorMarksTable, CollectorMarkRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectorMarksTable,
                    CollectorMarkRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectorMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectorMarksTable,
      CollectorMarkRow,
      $$CollectorMarksTableFilterComposer,
      $$CollectorMarksTableOrderingComposer,
      $$CollectorMarksTableAnnotationComposer,
      $$CollectorMarksTableCreateCompanionBuilder,
      $$CollectorMarksTableUpdateCompanionBuilder,
      (
        CollectorMarkRow,
        BaseReferences<_$AppDatabase, $CollectorMarksTable, CollectorMarkRow>,
      ),
      CollectorMarkRow,
      PrefetchHooks Function()
    >;
typedef $$SubmissionFlagsTableCreateCompanionBuilder =
    SubmissionFlagsCompanion Function({
      Value<int?> serverSeq,
      required String id,
      required String resultId,
      required String reason,
      Value<String?> flaggedBy,
      required DateTime createdAtDevice,
      Value<int> rowid,
    });
typedef $$SubmissionFlagsTableUpdateCompanionBuilder =
    SubmissionFlagsCompanion Function({
      Value<int?> serverSeq,
      Value<String> id,
      Value<String> resultId,
      Value<String> reason,
      Value<String?> flaggedBy,
      Value<DateTime> createdAtDevice,
      Value<int> rowid,
    });

class $$SubmissionFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $SubmissionFlagsTable> {
  $$SubmissionFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flaggedBy => $composableBuilder(
    column: $table.flaggedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubmissionFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmissionFlagsTable> {
  $$SubmissionFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flaggedBy => $composableBuilder(
    column: $table.flaggedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubmissionFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmissionFlagsTable> {
  $$SubmissionFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resultId =>
      $composableBuilder(column: $table.resultId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get flaggedBy =>
      $composableBuilder(column: $table.flaggedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );
}

class $$SubmissionFlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubmissionFlagsTable,
          SubmissionFlagRow,
          $$SubmissionFlagsTableFilterComposer,
          $$SubmissionFlagsTableOrderingComposer,
          $$SubmissionFlagsTableAnnotationComposer,
          $$SubmissionFlagsTableCreateCompanionBuilder,
          $$SubmissionFlagsTableUpdateCompanionBuilder,
          (
            SubmissionFlagRow,
            BaseReferences<
              _$AppDatabase,
              $SubmissionFlagsTable,
              SubmissionFlagRow
            >,
          ),
          SubmissionFlagRow,
          PrefetchHooks Function()
        > {
  $$SubmissionFlagsTableTableManager(
    _$AppDatabase db,
    $SubmissionFlagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmissionFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmissionFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmissionFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> resultId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> flaggedBy = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubmissionFlagsCompanion(
                serverSeq: serverSeq,
                id: id,
                resultId: resultId,
                reason: reason,
                flaggedBy: flaggedBy,
                createdAtDevice: createdAtDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int?> serverSeq = const Value.absent(),
                required String id,
                required String resultId,
                required String reason,
                Value<String?> flaggedBy = const Value.absent(),
                required DateTime createdAtDevice,
                Value<int> rowid = const Value.absent(),
              }) => SubmissionFlagsCompanion.insert(
                serverSeq: serverSeq,
                id: id,
                resultId: resultId,
                reason: reason,
                flaggedBy: flaggedBy,
                createdAtDevice: createdAtDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubmissionFlagsTable, SubmissionFlagRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SubmissionFlagsTable,
                    SubmissionFlagRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubmissionFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubmissionFlagsTable,
      SubmissionFlagRow,
      $$SubmissionFlagsTableFilterComposer,
      $$SubmissionFlagsTableOrderingComposer,
      $$SubmissionFlagsTableAnnotationComposer,
      $$SubmissionFlagsTableCreateCompanionBuilder,
      $$SubmissionFlagsTableUpdateCompanionBuilder,
      (
        SubmissionFlagRow,
        BaseReferences<_$AppDatabase, $SubmissionFlagsTable, SubmissionFlagRow>,
      ),
      SubmissionFlagRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String entity,
  required String entityId,
  required String op,
  required String payload,
  Value<int?> baseVersion,
  required DateTime createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String> status,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> entity,
  Value<String> entityId,
  Value<String> op,
  Value<String> payload,
  Value<int?> baseVersion,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String> status,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                baseVersion: baseVersion,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                required String entityId,
                required String op,
                required String payload,
                Value<int?> baseVersion = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                baseVersion: baseVersion,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String stream,
  Value<int> cursor,
  Value<DateTime?> lastSuccessAt,
  Value<String?> cursorToken,
  Value<int> failures,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> lastAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> stream,
  Value<int> cursor,
  Value<DateTime?> lastSuccessAt,
  Value<String?> cursorToken,
  Value<int> failures,
  Value<DateTime?> nextAttemptAt,
  Value<DateTime?> lastAttemptAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursorToken => $composableBuilder(
    column: $table.cursorToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursorToken => $composableBuilder(
    column: $table.cursorToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failures => $composableBuilder(
    column: $table.failures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stream =>
      $composableBuilder(column: $table.stream, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursorToken => $composableBuilder(
    column: $table.cursorToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stream = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> cursorToken = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                stream: stream,
                cursor: cursor,
                lastSuccessAt: lastSuccessAt,
                cursorToken: cursorToken,
                failures: failures,
                nextAttemptAt: nextAttemptAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stream,
                Value<int> cursor = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> cursorToken = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                stream: stream,
                cursor: cursor,
                lastSuccessAt: lastSuccessAt,
                cursorToken: cursorToken,
                failures: failures,
                nextAttemptAt: nextAttemptAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;
typedef $$SyncLocksTableCreateCompanionBuilder = SyncLocksCompanion Function({
  required String name,
  required String owner,
  required DateTime expiresAt,
  Value<int> rowid,
});
typedef $$SyncLocksTableUpdateCompanionBuilder = SyncLocksCompanion Function({
  Value<String> name,
  Value<String> owner,
  Value<DateTime> expiresAt,
  Value<int> rowid,
});

class $$SyncLocksTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLocksTable> {
  $$SyncLocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLocksTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLocksTable> {
  $$SyncLocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLocksTable> {
  $$SyncLocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$SyncLocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLocksTable,
          SyncLockRow,
          $$SyncLocksTableFilterComposer,
          $$SyncLocksTableOrderingComposer,
          $$SyncLocksTableAnnotationComposer,
          $$SyncLocksTableCreateCompanionBuilder,
          $$SyncLocksTableUpdateCompanionBuilder,
          (
            SyncLockRow,
            BaseReferences<_$AppDatabase, $SyncLocksTable, SyncLockRow>,
          ),
          SyncLockRow,
          PrefetchHooks Function()
        > {
  $$SyncLocksTableTableManager(_$AppDatabase db, $SyncLocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncLocksCompanion(
                name: name,
                owner: owner,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String owner,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncLocksCompanion.insert(
                name: name,
                owner: owner,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncLocksTable, SyncLockRow>(table),
                  BaseReferences<_$AppDatabase, $SyncLocksTable, SyncLockRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLocksTable,
      SyncLockRow,
      $$SyncLocksTableFilterComposer,
      $$SyncLocksTableOrderingComposer,
      $$SyncLocksTableAnnotationComposer,
      $$SyncLocksTableCreateCompanionBuilder,
      $$SyncLocksTableUpdateCompanionBuilder,
      (
        SyncLockRow,
        BaseReferences<_$AppDatabase, $SyncLocksTable, SyncLockRow>,
      ),
      SyncLockRow,
      PrefetchHooks Function()
    >;
typedef $$AttachmentQueueTableCreateCompanionBuilder =
    AttachmentQueueCompanion Function({
      required String attachmentId,
      required String localPath,
      Value<int> bytesSent,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$AttachmentQueueTableUpdateCompanionBuilder =
    AttachmentQueueCompanion Function({
      Value<String> attachmentId,
      Value<String> localPath,
      Value<int> bytesSent,
      Value<String> status,
      Value<int> rowid,
    });

class $$AttachmentQueueTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesSent => $composableBuilder(
    column: $table.bytesSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesSent => $composableBuilder(
    column: $table.bytesSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get bytesSent =>
      $composableBuilder(column: $table.bytesSent, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AttachmentQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentQueueTable,
          AttachmentQueueRow,
          $$AttachmentQueueTableFilterComposer,
          $$AttachmentQueueTableOrderingComposer,
          $$AttachmentQueueTableAnnotationComposer,
          $$AttachmentQueueTableCreateCompanionBuilder,
          $$AttachmentQueueTableUpdateCompanionBuilder,
          (
            AttachmentQueueRow,
            BaseReferences<
              _$AppDatabase,
              $AttachmentQueueTable,
              AttachmentQueueRow
            >,
          ),
          AttachmentQueueRow,
          PrefetchHooks Function()
        > {
  $$AttachmentQueueTableTableManager(
    _$AppDatabase db,
    $AttachmentQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attachmentId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> bytesSent = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentQueueCompanion(
                attachmentId: attachmentId,
                localPath: localPath,
                bytesSent: bytesSent,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attachmentId,
                required String localPath,
                Value<int> bytesSent = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentQueueCompanion.insert(
                attachmentId: attachmentId,
                localPath: localPath,
                bytesSent: bytesSent,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentQueueTable, AttachmentQueueRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AttachmentQueueTable,
                    AttachmentQueueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentQueueTable,
      AttachmentQueueRow,
      $$AttachmentQueueTableFilterComposer,
      $$AttachmentQueueTableOrderingComposer,
      $$AttachmentQueueTableAnnotationComposer,
      $$AttachmentQueueTableCreateCompanionBuilder,
      $$AttachmentQueueTableUpdateCompanionBuilder,
      (
        AttachmentQueueRow,
        BaseReferences<
          _$AppDatabase,
          $AttachmentQueueTable,
          AttachmentQueueRow
        >,
      ),
      AttachmentQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WaterSourcesTableTableManager get waterSources =>
      $$WaterSourcesTableTableManager(_db, _db.waterSources);
  $$TestSessionsTableTableManager get testSessions =>
      $$TestSessionsTableTableManager(_db, _db.testSessions);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$CalibrationsTableTableManager get calibrations =>
      $$CalibrationsTableTableManager(_db, _db.calibrations);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$AlertEventsTableTableManager get alertEvents =>
      $$AlertEventsTableTableManager(_db, _db.alertEvents);
  $$SanitaryInspectionsTableTableManager get sanitaryInspections =>
      $$SanitaryInspectionsTableTableManager(_db, _db.sanitaryInspections);
  $$AdminUnitsTableTableManager get adminUnits =>
      $$AdminUnitsTableTableManager(_db, _db.adminUnits);
  $$ParameterCategoriesTableTableManager get parameterCategories =>
      $$ParameterCategoriesTableTableManager(_db, _db.parameterCategories);
  $$ParameterDefinitionsTableTableManager get parameterDefinitions =>
      $$ParameterDefinitionsTableTableManager(_db, _db.parameterDefinitions);
  $$TesterProfilesTableTableManager get testerProfiles =>
      $$TesterProfilesTableTableManager(_db, _db.testerProfiles);
  $$ReferenceProfilesTableTableManager get referenceProfiles =>
      $$ReferenceProfilesTableTableManager(_db, _db.referenceProfiles);
  $$ResponseCardsTableTableManager get responseCards =>
      $$ResponseCardsTableTableManager(_db, _db.responseCards);
  $$ResponsibilitiesTableTableManager get responsibilities =>
      $$ResponsibilitiesTableTableManager(_db, _db.responsibilities);
  $$ConfigDocumentsTableTableManager get configDocuments =>
      $$ConfigDocumentsTableTableManager(_db, _db.configDocuments);
  $$SeedImportsTableTableManager get seedImports =>
      $$SeedImportsTableTableManager(_db, _db.seedImports);
  $$CollectorProfilesTableTableManager get collectorProfiles =>
      $$CollectorProfilesTableTableManager(_db, _db.collectorProfiles);
  $$ClassificationsTableTableManager get classifications =>
      $$ClassificationsTableTableManager(_db, _db.classifications);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$CollectorMarksTableTableManager get collectorMarks =>
      $$CollectorMarksTableTableManager(_db, _db.collectorMarks);
  $$SubmissionFlagsTableTableManager get submissionFlags =>
      $$SubmissionFlagsTableTableManager(_db, _db.submissionFlags);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$SyncLocksTableTableManager get syncLocks =>
      $$SyncLocksTableTableManager(_db, _db.syncLocks);
  $$AttachmentQueueTableTableManager get attachmentQueue =>
      $$AttachmentQueueTableTableManager(_db, _db.attachmentQueue);
}
