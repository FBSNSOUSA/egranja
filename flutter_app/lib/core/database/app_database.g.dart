// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LotesTable extends Lotes with TableInfo<$LotesTable, Lote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _galpaoIdMeta = const VerificationMeta(
    'galpaoId',
  );
  @override
  late final GeneratedColumn<String> galpaoId = GeneratedColumn<String>(
    'galpao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _galpaoNomeMeta = const VerificationMeta(
    'galpaoNome',
  );
  @override
  late final GeneratedColumn<String> galpaoNome = GeneratedColumn<String>(
    'galpao_nome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataAlojamentoMeta = const VerificationMeta(
    'dataAlojamento',
  );
  @override
  late final GeneratedColumn<DateTime> dataAlojamento =
      GeneratedColumn<DateTime>(
        'data_alojamento',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataPrevistaAbateMeta = const VerificationMeta(
    'dataPrevistaAbate',
  );
  @override
  late final GeneratedColumn<DateTime> dataPrevistaAbate =
      GeneratedColumn<DateTime>(
        'data_prevista_abate',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
    'quantidade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linhagemMeta = const VerificationMeta(
    'linhagem',
  );
  @override
  late final GeneratedColumn<String> linhagem = GeneratedColumn<String>(
    'linhagem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pesoInicialGMeta = const VerificationMeta(
    'pesoInicialG',
  );
  @override
  late final GeneratedColumn<double> pesoInicialG = GeneratedColumn<double>(
    'peso_inicial_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    defaultValue: const Constant('ativo'),
  );
  static const VerificationMeta _dataFinalizacaoMeta = const VerificationMeta(
    'dataFinalizacao',
  );
  @override
  late final GeneratedColumn<DateTime> dataFinalizacao =
      GeneratedColumn<DateTime>(
        'data_finalizacao',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
    id,
    serverId,
    usuarioId,
    galpaoId,
    galpaoNome,
    dataAlojamento,
    dataPrevistaAbate,
    quantidade,
    tipo,
    linhagem,
    pesoInicialG,
    status,
    dataFinalizacao,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('galpao_id')) {
      context.handle(
        _galpaoIdMeta,
        galpaoId.isAcceptableOrUnknown(data['galpao_id']!, _galpaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_galpaoIdMeta);
    }
    if (data.containsKey('galpao_nome')) {
      context.handle(
        _galpaoNomeMeta,
        galpaoNome.isAcceptableOrUnknown(data['galpao_nome']!, _galpaoNomeMeta),
      );
    }
    if (data.containsKey('data_alojamento')) {
      context.handle(
        _dataAlojamentoMeta,
        dataAlojamento.isAcceptableOrUnknown(
          data['data_alojamento']!,
          _dataAlojamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataAlojamentoMeta);
    }
    if (data.containsKey('data_prevista_abate')) {
      context.handle(
        _dataPrevistaAbateMeta,
        dataPrevistaAbate.isAcceptableOrUnknown(
          data['data_prevista_abate']!,
          _dataPrevistaAbateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataPrevistaAbateMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('linhagem')) {
      context.handle(
        _linhagemMeta,
        linhagem.isAcceptableOrUnknown(data['linhagem']!, _linhagemMeta),
      );
    }
    if (data.containsKey('peso_inicial_g')) {
      context.handle(
        _pesoInicialGMeta,
        pesoInicialG.isAcceptableOrUnknown(
          data['peso_inicial_g']!,
          _pesoInicialGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pesoInicialGMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('data_finalizacao')) {
      context.handle(
        _dataFinalizacaoMeta,
        dataFinalizacao.isAcceptableOrUnknown(
          data['data_finalizacao']!,
          _dataFinalizacaoMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      galpaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}galpao_id'],
      )!,
      galpaoNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}galpao_nome'],
      ),
      dataAlojamento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_alojamento'],
      )!,
      dataPrevistaAbate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_prevista_abate'],
      )!,
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      linhagem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linhagem'],
      ),
      pesoInicialG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_inicial_g'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dataFinalizacao: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_finalizacao'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LotesTable createAlias(String alias) {
    return $LotesTable(attachedDatabase, alias);
  }
}

class Lote extends DataClass implements Insertable<Lote> {
  final int id;
  final String? serverId;
  final String usuarioId;
  final String galpaoId;
  final String? galpaoNome;
  final DateTime dataAlojamento;
  final DateTime dataPrevistaAbate;
  final int quantidade;
  final String tipo;
  final String? linhagem;
  final double pesoInicialG;
  final String status;
  final DateTime? dataFinalizacao;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Lote({
    required this.id,
    this.serverId,
    required this.usuarioId,
    required this.galpaoId,
    this.galpaoNome,
    required this.dataAlojamento,
    required this.dataPrevistaAbate,
    required this.quantidade,
    required this.tipo,
    this.linhagem,
    required this.pesoInicialG,
    required this.status,
    this.dataFinalizacao,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['galpao_id'] = Variable<String>(galpaoId);
    if (!nullToAbsent || galpaoNome != null) {
      map['galpao_nome'] = Variable<String>(galpaoNome);
    }
    map['data_alojamento'] = Variable<DateTime>(dataAlojamento);
    map['data_prevista_abate'] = Variable<DateTime>(dataPrevistaAbate);
    map['quantidade'] = Variable<int>(quantidade);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || linhagem != null) {
      map['linhagem'] = Variable<String>(linhagem);
    }
    map['peso_inicial_g'] = Variable<double>(pesoInicialG);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dataFinalizacao != null) {
      map['data_finalizacao'] = Variable<DateTime>(dataFinalizacao);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LotesCompanion toCompanion(bool nullToAbsent) {
    return LotesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      usuarioId: Value(usuarioId),
      galpaoId: Value(galpaoId),
      galpaoNome: galpaoNome == null && nullToAbsent
          ? const Value.absent()
          : Value(galpaoNome),
      dataAlojamento: Value(dataAlojamento),
      dataPrevistaAbate: Value(dataPrevistaAbate),
      quantidade: Value(quantidade),
      tipo: Value(tipo),
      linhagem: linhagem == null && nullToAbsent
          ? const Value.absent()
          : Value(linhagem),
      pesoInicialG: Value(pesoInicialG),
      status: Value(status),
      dataFinalizacao: dataFinalizacao == null && nullToAbsent
          ? const Value.absent()
          : Value(dataFinalizacao),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Lote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lote(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      galpaoId: serializer.fromJson<String>(json['galpaoId']),
      galpaoNome: serializer.fromJson<String?>(json['galpaoNome']),
      dataAlojamento: serializer.fromJson<DateTime>(json['dataAlojamento']),
      dataPrevistaAbate: serializer.fromJson<DateTime>(
        json['dataPrevistaAbate'],
      ),
      quantidade: serializer.fromJson<int>(json['quantidade']),
      tipo: serializer.fromJson<String>(json['tipo']),
      linhagem: serializer.fromJson<String?>(json['linhagem']),
      pesoInicialG: serializer.fromJson<double>(json['pesoInicialG']),
      status: serializer.fromJson<String>(json['status']),
      dataFinalizacao: serializer.fromJson<DateTime?>(json['dataFinalizacao']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'galpaoId': serializer.toJson<String>(galpaoId),
      'galpaoNome': serializer.toJson<String?>(galpaoNome),
      'dataAlojamento': serializer.toJson<DateTime>(dataAlojamento),
      'dataPrevistaAbate': serializer.toJson<DateTime>(dataPrevistaAbate),
      'quantidade': serializer.toJson<int>(quantidade),
      'tipo': serializer.toJson<String>(tipo),
      'linhagem': serializer.toJson<String?>(linhagem),
      'pesoInicialG': serializer.toJson<double>(pesoInicialG),
      'status': serializer.toJson<String>(status),
      'dataFinalizacao': serializer.toJson<DateTime?>(dataFinalizacao),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Lote copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? usuarioId,
    String? galpaoId,
    Value<String?> galpaoNome = const Value.absent(),
    DateTime? dataAlojamento,
    DateTime? dataPrevistaAbate,
    int? quantidade,
    String? tipo,
    Value<String?> linhagem = const Value.absent(),
    double? pesoInicialG,
    String? status,
    Value<DateTime?> dataFinalizacao = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Lote(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    usuarioId: usuarioId ?? this.usuarioId,
    galpaoId: galpaoId ?? this.galpaoId,
    galpaoNome: galpaoNome.present ? galpaoNome.value : this.galpaoNome,
    dataAlojamento: dataAlojamento ?? this.dataAlojamento,
    dataPrevistaAbate: dataPrevistaAbate ?? this.dataPrevistaAbate,
    quantidade: quantidade ?? this.quantidade,
    tipo: tipo ?? this.tipo,
    linhagem: linhagem.present ? linhagem.value : this.linhagem,
    pesoInicialG: pesoInicialG ?? this.pesoInicialG,
    status: status ?? this.status,
    dataFinalizacao: dataFinalizacao.present
        ? dataFinalizacao.value
        : this.dataFinalizacao,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Lote copyWithCompanion(LotesCompanion data) {
    return Lote(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      galpaoId: data.galpaoId.present ? data.galpaoId.value : this.galpaoId,
      galpaoNome: data.galpaoNome.present
          ? data.galpaoNome.value
          : this.galpaoNome,
      dataAlojamento: data.dataAlojamento.present
          ? data.dataAlojamento.value
          : this.dataAlojamento,
      dataPrevistaAbate: data.dataPrevistaAbate.present
          ? data.dataPrevistaAbate.value
          : this.dataPrevistaAbate,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      linhagem: data.linhagem.present ? data.linhagem.value : this.linhagem,
      pesoInicialG: data.pesoInicialG.present
          ? data.pesoInicialG.value
          : this.pesoInicialG,
      status: data.status.present ? data.status.value : this.status,
      dataFinalizacao: data.dataFinalizacao.present
          ? data.dataFinalizacao.value
          : this.dataFinalizacao,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lote(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('galpaoId: $galpaoId, ')
          ..write('galpaoNome: $galpaoNome, ')
          ..write('dataAlojamento: $dataAlojamento, ')
          ..write('dataPrevistaAbate: $dataPrevistaAbate, ')
          ..write('quantidade: $quantidade, ')
          ..write('tipo: $tipo, ')
          ..write('linhagem: $linhagem, ')
          ..write('pesoInicialG: $pesoInicialG, ')
          ..write('status: $status, ')
          ..write('dataFinalizacao: $dataFinalizacao, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    usuarioId,
    galpaoId,
    galpaoNome,
    dataAlojamento,
    dataPrevistaAbate,
    quantidade,
    tipo,
    linhagem,
    pesoInicialG,
    status,
    dataFinalizacao,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lote &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.usuarioId == this.usuarioId &&
          other.galpaoId == this.galpaoId &&
          other.galpaoNome == this.galpaoNome &&
          other.dataAlojamento == this.dataAlojamento &&
          other.dataPrevistaAbate == this.dataPrevistaAbate &&
          other.quantidade == this.quantidade &&
          other.tipo == this.tipo &&
          other.linhagem == this.linhagem &&
          other.pesoInicialG == this.pesoInicialG &&
          other.status == this.status &&
          other.dataFinalizacao == this.dataFinalizacao &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LotesCompanion extends UpdateCompanion<Lote> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> usuarioId;
  final Value<String> galpaoId;
  final Value<String?> galpaoNome;
  final Value<DateTime> dataAlojamento;
  final Value<DateTime> dataPrevistaAbate;
  final Value<int> quantidade;
  final Value<String> tipo;
  final Value<String?> linhagem;
  final Value<double> pesoInicialG;
  final Value<String> status;
  final Value<DateTime?> dataFinalizacao;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LotesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.galpaoId = const Value.absent(),
    this.galpaoNome = const Value.absent(),
    this.dataAlojamento = const Value.absent(),
    this.dataPrevistaAbate = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.tipo = const Value.absent(),
    this.linhagem = const Value.absent(),
    this.pesoInicialG = const Value.absent(),
    this.status = const Value.absent(),
    this.dataFinalizacao = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LotesCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String usuarioId,
    required String galpaoId,
    this.galpaoNome = const Value.absent(),
    required DateTime dataAlojamento,
    required DateTime dataPrevistaAbate,
    required int quantidade,
    required String tipo,
    this.linhagem = const Value.absent(),
    required double pesoInicialG,
    this.status = const Value.absent(),
    this.dataFinalizacao = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : usuarioId = Value(usuarioId),
       galpaoId = Value(galpaoId),
       dataAlojamento = Value(dataAlojamento),
       dataPrevistaAbate = Value(dataPrevistaAbate),
       quantidade = Value(quantidade),
       tipo = Value(tipo),
       pesoInicialG = Value(pesoInicialG),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Lote> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? usuarioId,
    Expression<String>? galpaoId,
    Expression<String>? galpaoNome,
    Expression<DateTime>? dataAlojamento,
    Expression<DateTime>? dataPrevistaAbate,
    Expression<int>? quantidade,
    Expression<String>? tipo,
    Expression<String>? linhagem,
    Expression<double>? pesoInicialG,
    Expression<String>? status,
    Expression<DateTime>? dataFinalizacao,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (galpaoId != null) 'galpao_id': galpaoId,
      if (galpaoNome != null) 'galpao_nome': galpaoNome,
      if (dataAlojamento != null) 'data_alojamento': dataAlojamento,
      if (dataPrevistaAbate != null) 'data_prevista_abate': dataPrevistaAbate,
      if (quantidade != null) 'quantidade': quantidade,
      if (tipo != null) 'tipo': tipo,
      if (linhagem != null) 'linhagem': linhagem,
      if (pesoInicialG != null) 'peso_inicial_g': pesoInicialG,
      if (status != null) 'status': status,
      if (dataFinalizacao != null) 'data_finalizacao': dataFinalizacao,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LotesCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? usuarioId,
    Value<String>? galpaoId,
    Value<String?>? galpaoNome,
    Value<DateTime>? dataAlojamento,
    Value<DateTime>? dataPrevistaAbate,
    Value<int>? quantidade,
    Value<String>? tipo,
    Value<String?>? linhagem,
    Value<double>? pesoInicialG,
    Value<String>? status,
    Value<DateTime?>? dataFinalizacao,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LotesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      usuarioId: usuarioId ?? this.usuarioId,
      galpaoId: galpaoId ?? this.galpaoId,
      galpaoNome: galpaoNome ?? this.galpaoNome,
      dataAlojamento: dataAlojamento ?? this.dataAlojamento,
      dataPrevistaAbate: dataPrevistaAbate ?? this.dataPrevistaAbate,
      quantidade: quantidade ?? this.quantidade,
      tipo: tipo ?? this.tipo,
      linhagem: linhagem ?? this.linhagem,
      pesoInicialG: pesoInicialG ?? this.pesoInicialG,
      status: status ?? this.status,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (galpaoId.present) {
      map['galpao_id'] = Variable<String>(galpaoId.value);
    }
    if (galpaoNome.present) {
      map['galpao_nome'] = Variable<String>(galpaoNome.value);
    }
    if (dataAlojamento.present) {
      map['data_alojamento'] = Variable<DateTime>(dataAlojamento.value);
    }
    if (dataPrevistaAbate.present) {
      map['data_prevista_abate'] = Variable<DateTime>(dataPrevistaAbate.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (linhagem.present) {
      map['linhagem'] = Variable<String>(linhagem.value);
    }
    if (pesoInicialG.present) {
      map['peso_inicial_g'] = Variable<double>(pesoInicialG.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dataFinalizacao.present) {
      map['data_finalizacao'] = Variable<DateTime>(dataFinalizacao.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('galpaoId: $galpaoId, ')
          ..write('galpaoNome: $galpaoNome, ')
          ..write('dataAlojamento: $dataAlojamento, ')
          ..write('dataPrevistaAbate: $dataPrevistaAbate, ')
          ..write('quantidade: $quantidade, ')
          ..write('tipo: $tipo, ')
          ..write('linhagem: $linhagem, ')
          ..write('pesoInicialG: $pesoInicialG, ')
          ..write('status: $status, ')
          ..write('dataFinalizacao: $dataFinalizacao, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PesagensTable extends Pesagens with TableInfo<$PesagensTable, Pesagen> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesagensTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeTotalMeta = const VerificationMeta(
    'quantidadeTotal',
  );
  @override
  late final GeneratedColumn<int> quantidadeTotal = GeneratedColumn<int>(
    'quantidade_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoTotalMeta = const VerificationMeta(
    'pesoTotal',
  );
  @override
  late final GeneratedColumn<double> pesoTotal = GeneratedColumn<double>(
    'peso_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoMedioMeta = const VerificationMeta(
    'pesoMedio',
  );
  @override
  late final GeneratedColumn<double> pesoMedio = GeneratedColumn<double>(
    'peso_medio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    id,
    serverId,
    loteId,
    data,
    quantidadeTotal,
    pesoTotal,
    pesoMedio,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesagens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pesagen> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('quantidade_total')) {
      context.handle(
        _quantidadeTotalMeta,
        quantidadeTotal.isAcceptableOrUnknown(
          data['quantidade_total']!,
          _quantidadeTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeTotalMeta);
    }
    if (data.containsKey('peso_total')) {
      context.handle(
        _pesoTotalMeta,
        pesoTotal.isAcceptableOrUnknown(data['peso_total']!, _pesoTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoTotalMeta);
    }
    if (data.containsKey('peso_medio')) {
      context.handle(
        _pesoMedioMeta,
        pesoMedio.isAcceptableOrUnknown(data['peso_medio']!, _pesoMedioMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoMedioMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pesagen map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pesagen(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      quantidadeTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade_total'],
      )!,
      pesoTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_total'],
      )!,
      pesoMedio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_medio'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PesagensTable createAlias(String alias) {
    return $PesagensTable(attachedDatabase, alias);
  }
}

class Pesagen extends DataClass implements Insertable<Pesagen> {
  final int id;
  final String? serverId;
  final String loteId;
  final DateTime data;
  final int quantidadeTotal;
  final double pesoTotal;
  final double pesoMedio;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Pesagen({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.data,
    required this.quantidadeTotal,
    required this.pesoTotal,
    required this.pesoMedio,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['data'] = Variable<DateTime>(data);
    map['quantidade_total'] = Variable<int>(quantidadeTotal);
    map['peso_total'] = Variable<double>(pesoTotal);
    map['peso_medio'] = Variable<double>(pesoMedio);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PesagensCompanion toCompanion(bool nullToAbsent) {
    return PesagensCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      data: Value(data),
      quantidadeTotal: Value(quantidadeTotal),
      pesoTotal: Value(pesoTotal),
      pesoMedio: Value(pesoMedio),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Pesagen.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pesagen(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      data: serializer.fromJson<DateTime>(json['data']),
      quantidadeTotal: serializer.fromJson<int>(json['quantidadeTotal']),
      pesoTotal: serializer.fromJson<double>(json['pesoTotal']),
      pesoMedio: serializer.fromJson<double>(json['pesoMedio']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'data': serializer.toJson<DateTime>(data),
      'quantidadeTotal': serializer.toJson<int>(quantidadeTotal),
      'pesoTotal': serializer.toJson<double>(pesoTotal),
      'pesoMedio': serializer.toJson<double>(pesoMedio),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Pesagen copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    DateTime? data,
    int? quantidadeTotal,
    double? pesoTotal,
    double? pesoMedio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Pesagen(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    data: data ?? this.data,
    quantidadeTotal: quantidadeTotal ?? this.quantidadeTotal,
    pesoTotal: pesoTotal ?? this.pesoTotal,
    pesoMedio: pesoMedio ?? this.pesoMedio,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Pesagen copyWithCompanion(PesagensCompanion data) {
    return Pesagen(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      data: data.data.present ? data.data.value : this.data,
      quantidadeTotal: data.quantidadeTotal.present
          ? data.quantidadeTotal.value
          : this.quantidadeTotal,
      pesoTotal: data.pesoTotal.present ? data.pesoTotal.value : this.pesoTotal,
      pesoMedio: data.pesoMedio.present ? data.pesoMedio.value : this.pesoMedio,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pesagen(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeTotal: $quantidadeTotal, ')
          ..write('pesoTotal: $pesoTotal, ')
          ..write('pesoMedio: $pesoMedio, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    data,
    quantidadeTotal,
    pesoTotal,
    pesoMedio,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pesagen &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.data == this.data &&
          other.quantidadeTotal == this.quantidadeTotal &&
          other.pesoTotal == this.pesoTotal &&
          other.pesoMedio == this.pesoMedio &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PesagensCompanion extends UpdateCompanion<Pesagen> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<DateTime> data;
  final Value<int> quantidadeTotal;
  final Value<double> pesoTotal;
  final Value<double> pesoMedio;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PesagensCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.data = const Value.absent(),
    this.quantidadeTotal = const Value.absent(),
    this.pesoTotal = const Value.absent(),
    this.pesoMedio = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PesagensCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required DateTime data,
    required int quantidadeTotal,
    required double pesoTotal,
    required double pesoMedio,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       data = Value(data),
       quantidadeTotal = Value(quantidadeTotal),
       pesoTotal = Value(pesoTotal),
       pesoMedio = Value(pesoMedio),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Pesagen> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<DateTime>? data,
    Expression<int>? quantidadeTotal,
    Expression<double>? pesoTotal,
    Expression<double>? pesoMedio,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (data != null) 'data': data,
      if (quantidadeTotal != null) 'quantidade_total': quantidadeTotal,
      if (pesoTotal != null) 'peso_total': pesoTotal,
      if (pesoMedio != null) 'peso_medio': pesoMedio,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PesagensCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<DateTime>? data,
    Value<int>? quantidadeTotal,
    Value<double>? pesoTotal,
    Value<double>? pesoMedio,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PesagensCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      quantidadeTotal: quantidadeTotal ?? this.quantidadeTotal,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      pesoMedio: pesoMedio ?? this.pesoMedio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (quantidadeTotal.present) {
      map['quantidade_total'] = Variable<int>(quantidadeTotal.value);
    }
    if (pesoTotal.present) {
      map['peso_total'] = Variable<double>(pesoTotal.value);
    }
    if (pesoMedio.present) {
      map['peso_medio'] = Variable<double>(pesoMedio.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesagensCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeTotal: $quantidadeTotal, ')
          ..write('pesoTotal: $pesoTotal, ')
          ..write('pesoMedio: $pesoMedio, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PesagemItemsTable extends PesagemItems
    with TableInfo<$PesagemItemsTable, PesagemItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesagemItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pesagemIdMeta = const VerificationMeta(
    'pesagemId',
  );
  @override
  late final GeneratedColumn<String> pesagemId = GeneratedColumn<String>(
    'pesagem_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
    'quantidade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
    'peso',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoMedioMeta = const VerificationMeta(
    'pesoMedio',
  );
  @override
  late final GeneratedColumn<double> pesoMedio = GeneratedColumn<double>(
    'peso_medio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    pesagemId,
    quantidade,
    peso,
    pesoMedio,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesagem_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PesagemItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('pesagem_id')) {
      context.handle(
        _pesagemIdMeta,
        pesagemId.isAcceptableOrUnknown(data['pesagem_id']!, _pesagemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pesagemIdMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
        _pesoMeta,
        peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoMeta);
    }
    if (data.containsKey('peso_medio')) {
      context.handle(
        _pesoMedioMeta,
        pesoMedio.isAcceptableOrUnknown(data['peso_medio']!, _pesoMedioMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoMedioMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PesagemItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PesagemItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      pesagemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pesagem_id'],
      )!,
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade'],
      )!,
      peso: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso'],
      )!,
      pesoMedio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_medio'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PesagemItemsTable createAlias(String alias) {
    return $PesagemItemsTable(attachedDatabase, alias);
  }
}

class PesagemItem extends DataClass implements Insertable<PesagemItem> {
  final int id;
  final String? serverId;
  final String pesagemId;
  final int quantidade;
  final double peso;
  final double pesoMedio;
  final DateTime createdAt;
  const PesagemItem({
    required this.id,
    this.serverId,
    required this.pesagemId,
    required this.quantidade,
    required this.peso,
    required this.pesoMedio,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['pesagem_id'] = Variable<String>(pesagemId);
    map['quantidade'] = Variable<int>(quantidade);
    map['peso'] = Variable<double>(peso);
    map['peso_medio'] = Variable<double>(pesoMedio);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PesagemItemsCompanion toCompanion(bool nullToAbsent) {
    return PesagemItemsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      pesagemId: Value(pesagemId),
      quantidade: Value(quantidade),
      peso: Value(peso),
      pesoMedio: Value(pesoMedio),
      createdAt: Value(createdAt),
    );
  }

  factory PesagemItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PesagemItem(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      pesagemId: serializer.fromJson<String>(json['pesagemId']),
      quantidade: serializer.fromJson<int>(json['quantidade']),
      peso: serializer.fromJson<double>(json['peso']),
      pesoMedio: serializer.fromJson<double>(json['pesoMedio']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'pesagemId': serializer.toJson<String>(pesagemId),
      'quantidade': serializer.toJson<int>(quantidade),
      'peso': serializer.toJson<double>(peso),
      'pesoMedio': serializer.toJson<double>(pesoMedio),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PesagemItem copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? pesagemId,
    int? quantidade,
    double? peso,
    double? pesoMedio,
    DateTime? createdAt,
  }) => PesagemItem(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    pesagemId: pesagemId ?? this.pesagemId,
    quantidade: quantidade ?? this.quantidade,
    peso: peso ?? this.peso,
    pesoMedio: pesoMedio ?? this.pesoMedio,
    createdAt: createdAt ?? this.createdAt,
  );
  PesagemItem copyWithCompanion(PesagemItemsCompanion data) {
    return PesagemItem(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      pesagemId: data.pesagemId.present ? data.pesagemId.value : this.pesagemId,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      peso: data.peso.present ? data.peso.value : this.peso,
      pesoMedio: data.pesoMedio.present ? data.pesoMedio.value : this.pesoMedio,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PesagemItem(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('pesagemId: $pesagemId, ')
          ..write('quantidade: $quantidade, ')
          ..write('peso: $peso, ')
          ..write('pesoMedio: $pesoMedio, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    pesagemId,
    quantidade,
    peso,
    pesoMedio,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PesagemItem &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.pesagemId == this.pesagemId &&
          other.quantidade == this.quantidade &&
          other.peso == this.peso &&
          other.pesoMedio == this.pesoMedio &&
          other.createdAt == this.createdAt);
}

class PesagemItemsCompanion extends UpdateCompanion<PesagemItem> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> pesagemId;
  final Value<int> quantidade;
  final Value<double> peso;
  final Value<double> pesoMedio;
  final Value<DateTime> createdAt;
  const PesagemItemsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.pesagemId = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.peso = const Value.absent(),
    this.pesoMedio = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PesagemItemsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String pesagemId,
    required int quantidade,
    required double peso,
    required double pesoMedio,
    required DateTime createdAt,
  }) : pesagemId = Value(pesagemId),
       quantidade = Value(quantidade),
       peso = Value(peso),
       pesoMedio = Value(pesoMedio),
       createdAt = Value(createdAt);
  static Insertable<PesagemItem> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? pesagemId,
    Expression<int>? quantidade,
    Expression<double>? peso,
    Expression<double>? pesoMedio,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (pesagemId != null) 'pesagem_id': pesagemId,
      if (quantidade != null) 'quantidade': quantidade,
      if (peso != null) 'peso': peso,
      if (pesoMedio != null) 'peso_medio': pesoMedio,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PesagemItemsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? pesagemId,
    Value<int>? quantidade,
    Value<double>? peso,
    Value<double>? pesoMedio,
    Value<DateTime>? createdAt,
  }) {
    return PesagemItemsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      pesagemId: pesagemId ?? this.pesagemId,
      quantidade: quantidade ?? this.quantidade,
      peso: peso ?? this.peso,
      pesoMedio: pesoMedio ?? this.pesoMedio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (pesagemId.present) {
      map['pesagem_id'] = Variable<String>(pesagemId.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (pesoMedio.present) {
      map['peso_medio'] = Variable<double>(pesoMedio.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesagemItemsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('pesagemId: $pesagemId, ')
          ..write('quantidade: $quantidade, ')
          ..write('peso: $peso, ')
          ..write('pesoMedio: $pesoMedio, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MortalidadesTable extends Mortalidades
    with TableInfo<$MortalidadesTable, Mortalidade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MortalidadesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
    'quantidade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causaMeta = const VerificationMeta('causa');
  @override
  late final GeneratedColumn<String> causa = GeneratedColumn<String>(
    'causa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacaoMeta = const VerificationMeta(
    'observacao',
  );
  @override
  late final GeneratedColumn<String> observacao = GeneratedColumn<String>(
    'observacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoUrlMeta = const VerificationMeta(
    'fotoUrl',
  );
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
    'foto_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    id,
    serverId,
    loteId,
    data,
    quantidade,
    causa,
    observacao,
    fotoUrl,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mortalidades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mortalidade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('causa')) {
      context.handle(
        _causaMeta,
        causa.isAcceptableOrUnknown(data['causa']!, _causaMeta),
      );
    } else if (isInserting) {
      context.missing(_causaMeta);
    }
    if (data.containsKey('observacao')) {
      context.handle(
        _observacaoMeta,
        observacao.isAcceptableOrUnknown(data['observacao']!, _observacaoMeta),
      );
    }
    if (data.containsKey('foto_url')) {
      context.handle(
        _fotoUrlMeta,
        fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mortalidade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mortalidade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade'],
      )!,
      causa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}causa'],
      )!,
      observacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacao'],
      ),
      fotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MortalidadesTable createAlias(String alias) {
    return $MortalidadesTable(attachedDatabase, alias);
  }
}

class Mortalidade extends DataClass implements Insertable<Mortalidade> {
  final int id;
  final String? serverId;
  final String loteId;
  final DateTime data;
  final int quantidade;
  final String causa;
  final String? observacao;
  final String? fotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Mortalidade({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.data,
    required this.quantidade,
    required this.causa,
    this.observacao,
    this.fotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['data'] = Variable<DateTime>(data);
    map['quantidade'] = Variable<int>(quantidade);
    map['causa'] = Variable<String>(causa);
    if (!nullToAbsent || observacao != null) {
      map['observacao'] = Variable<String>(observacao);
    }
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MortalidadesCompanion toCompanion(bool nullToAbsent) {
    return MortalidadesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      data: Value(data),
      quantidade: Value(quantidade),
      causa: Value(causa),
      observacao: observacao == null && nullToAbsent
          ? const Value.absent()
          : Value(observacao),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Mortalidade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mortalidade(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      data: serializer.fromJson<DateTime>(json['data']),
      quantidade: serializer.fromJson<int>(json['quantidade']),
      causa: serializer.fromJson<String>(json['causa']),
      observacao: serializer.fromJson<String?>(json['observacao']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'data': serializer.toJson<DateTime>(data),
      'quantidade': serializer.toJson<int>(quantidade),
      'causa': serializer.toJson<String>(causa),
      'observacao': serializer.toJson<String?>(observacao),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Mortalidade copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    DateTime? data,
    int? quantidade,
    String? causa,
    Value<String?> observacao = const Value.absent(),
    Value<String?> fotoUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Mortalidade(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    data: data ?? this.data,
    quantidade: quantidade ?? this.quantidade,
    causa: causa ?? this.causa,
    observacao: observacao.present ? observacao.value : this.observacao,
    fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Mortalidade copyWithCompanion(MortalidadesCompanion data) {
    return Mortalidade(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      data: data.data.present ? data.data.value : this.data,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      causa: data.causa.present ? data.causa.value : this.causa,
      observacao: data.observacao.present
          ? data.observacao.value
          : this.observacao,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mortalidade(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidade: $quantidade, ')
          ..write('causa: $causa, ')
          ..write('observacao: $observacao, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    data,
    quantidade,
    causa,
    observacao,
    fotoUrl,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mortalidade &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.data == this.data &&
          other.quantidade == this.quantidade &&
          other.causa == this.causa &&
          other.observacao == this.observacao &&
          other.fotoUrl == this.fotoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MortalidadesCompanion extends UpdateCompanion<Mortalidade> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<DateTime> data;
  final Value<int> quantidade;
  final Value<String> causa;
  final Value<String?> observacao;
  final Value<String?> fotoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MortalidadesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.data = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.causa = const Value.absent(),
    this.observacao = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MortalidadesCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required DateTime data,
    required int quantidade,
    required String causa,
    this.observacao = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       data = Value(data),
       quantidade = Value(quantidade),
       causa = Value(causa),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Mortalidade> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<DateTime>? data,
    Expression<int>? quantidade,
    Expression<String>? causa,
    Expression<String>? observacao,
    Expression<String>? fotoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (data != null) 'data': data,
      if (quantidade != null) 'quantidade': quantidade,
      if (causa != null) 'causa': causa,
      if (observacao != null) 'observacao': observacao,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MortalidadesCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<DateTime>? data,
    Value<int>? quantidade,
    Value<String>? causa,
    Value<String?>? observacao,
    Value<String?>? fotoUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MortalidadesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      quantidade: quantidade ?? this.quantidade,
      causa: causa ?? this.causa,
      observacao: observacao ?? this.observacao,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (causa.present) {
      map['causa'] = Variable<String>(causa.value);
    }
    if (observacao.present) {
      map['observacao'] = Variable<String>(observacao.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MortalidadesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidade: $quantidade, ')
          ..write('causa: $causa, ')
          ..write('observacao: $observacao, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeedReceiptsTable extends FeedReceipts
    with TableInfo<$FeedReceiptsTable, FeedReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedReceiptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoRacaoIdMeta = const VerificationMeta(
    'tipoRacaoId',
  );
  @override
  late final GeneratedColumn<String> tipoRacaoId = GeneratedColumn<String>(
    'tipo_racao_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoRacaoNomeMeta = const VerificationMeta(
    'tipoRacaoNome',
  );
  @override
  late final GeneratedColumn<String> tipoRacaoNome = GeneratedColumn<String>(
    'tipo_racao_nome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantidadeKgMeta = const VerificationMeta(
    'quantidadeKg',
  );
  @override
  late final GeneratedColumn<double> quantidadeKg = GeneratedColumn<double>(
    'quantidade_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataRecebimentoMeta = const VerificationMeta(
    'dataRecebimento',
  );
  @override
  late final GeneratedColumn<DateTime> dataRecebimento =
      GeneratedColumn<DateTime>(
        'data_recebimento',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fornecedorMeta = const VerificationMeta(
    'fornecedor',
  );
  @override
  late final GeneratedColumn<String> fornecedor = GeneratedColumn<String>(
    'fornecedor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteRacaoMeta = const VerificationMeta(
    'loteRacao',
  );
  @override
  late final GeneratedColumn<String> loteRacao = GeneratedColumn<String>(
    'lote_racao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('compra'),
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
    id,
    serverId,
    loteId,
    tipoRacaoId,
    tipoRacaoNome,
    quantidadeKg,
    dataRecebimento,
    fornecedor,
    loteRacao,
    origem,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('tipo_racao_id')) {
      context.handle(
        _tipoRacaoIdMeta,
        tipoRacaoId.isAcceptableOrUnknown(
          data['tipo_racao_id']!,
          _tipoRacaoIdMeta,
        ),
      );
    }
    if (data.containsKey('tipo_racao_nome')) {
      context.handle(
        _tipoRacaoNomeMeta,
        tipoRacaoNome.isAcceptableOrUnknown(
          data['tipo_racao_nome']!,
          _tipoRacaoNomeMeta,
        ),
      );
    }
    if (data.containsKey('quantidade_kg')) {
      context.handle(
        _quantidadeKgMeta,
        quantidadeKg.isAcceptableOrUnknown(
          data['quantidade_kg']!,
          _quantidadeKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeKgMeta);
    }
    if (data.containsKey('data_recebimento')) {
      context.handle(
        _dataRecebimentoMeta,
        dataRecebimento.isAcceptableOrUnknown(
          data['data_recebimento']!,
          _dataRecebimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataRecebimentoMeta);
    }
    if (data.containsKey('fornecedor')) {
      context.handle(
        _fornecedorMeta,
        fornecedor.isAcceptableOrUnknown(data['fornecedor']!, _fornecedorMeta),
      );
    }
    if (data.containsKey('lote_racao')) {
      context.handle(
        _loteRacaoMeta,
        loteRacao.isAcceptableOrUnknown(data['lote_racao']!, _loteRacaoMeta),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      tipoRacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_racao_id'],
      ),
      tipoRacaoNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_racao_nome'],
      ),
      quantidadeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_kg'],
      )!,
      dataRecebimento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_recebimento'],
      )!,
      fornecedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fornecedor'],
      ),
      loteRacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_racao'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeedReceiptsTable createAlias(String alias) {
    return $FeedReceiptsTable(attachedDatabase, alias);
  }
}

class FeedReceipt extends DataClass implements Insertable<FeedReceipt> {
  final int id;
  final String? serverId;
  final String loteId;
  final String? tipoRacaoId;
  final String? tipoRacaoNome;
  final double quantidadeKg;
  final DateTime dataRecebimento;
  final String? fornecedor;
  final String? loteRacao;
  final String origem;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FeedReceipt({
    required this.id,
    this.serverId,
    required this.loteId,
    this.tipoRacaoId,
    this.tipoRacaoNome,
    required this.quantidadeKg,
    required this.dataRecebimento,
    this.fornecedor,
    this.loteRacao,
    required this.origem,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    if (!nullToAbsent || tipoRacaoId != null) {
      map['tipo_racao_id'] = Variable<String>(tipoRacaoId);
    }
    if (!nullToAbsent || tipoRacaoNome != null) {
      map['tipo_racao_nome'] = Variable<String>(tipoRacaoNome);
    }
    map['quantidade_kg'] = Variable<double>(quantidadeKg);
    map['data_recebimento'] = Variable<DateTime>(dataRecebimento);
    if (!nullToAbsent || fornecedor != null) {
      map['fornecedor'] = Variable<String>(fornecedor);
    }
    if (!nullToAbsent || loteRacao != null) {
      map['lote_racao'] = Variable<String>(loteRacao);
    }
    map['origem'] = Variable<String>(origem);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedReceiptsCompanion toCompanion(bool nullToAbsent) {
    return FeedReceiptsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      tipoRacaoId: tipoRacaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoRacaoId),
      tipoRacaoNome: tipoRacaoNome == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoRacaoNome),
      quantidadeKg: Value(quantidadeKg),
      dataRecebimento: Value(dataRecebimento),
      fornecedor: fornecedor == null && nullToAbsent
          ? const Value.absent()
          : Value(fornecedor),
      loteRacao: loteRacao == null && nullToAbsent
          ? const Value.absent()
          : Value(loteRacao),
      origem: Value(origem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeedReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedReceipt(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      tipoRacaoId: serializer.fromJson<String?>(json['tipoRacaoId']),
      tipoRacaoNome: serializer.fromJson<String?>(json['tipoRacaoNome']),
      quantidadeKg: serializer.fromJson<double>(json['quantidadeKg']),
      dataRecebimento: serializer.fromJson<DateTime>(json['dataRecebimento']),
      fornecedor: serializer.fromJson<String?>(json['fornecedor']),
      loteRacao: serializer.fromJson<String?>(json['loteRacao']),
      origem: serializer.fromJson<String>(json['origem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'tipoRacaoId': serializer.toJson<String?>(tipoRacaoId),
      'tipoRacaoNome': serializer.toJson<String?>(tipoRacaoNome),
      'quantidadeKg': serializer.toJson<double>(quantidadeKg),
      'dataRecebimento': serializer.toJson<DateTime>(dataRecebimento),
      'fornecedor': serializer.toJson<String?>(fornecedor),
      'loteRacao': serializer.toJson<String?>(loteRacao),
      'origem': serializer.toJson<String>(origem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeedReceipt copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    Value<String?> tipoRacaoId = const Value.absent(),
    Value<String?> tipoRacaoNome = const Value.absent(),
    double? quantidadeKg,
    DateTime? dataRecebimento,
    Value<String?> fornecedor = const Value.absent(),
    Value<String?> loteRacao = const Value.absent(),
    String? origem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FeedReceipt(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    tipoRacaoId: tipoRacaoId.present ? tipoRacaoId.value : this.tipoRacaoId,
    tipoRacaoNome: tipoRacaoNome.present
        ? tipoRacaoNome.value
        : this.tipoRacaoNome,
    quantidadeKg: quantidadeKg ?? this.quantidadeKg,
    dataRecebimento: dataRecebimento ?? this.dataRecebimento,
    fornecedor: fornecedor.present ? fornecedor.value : this.fornecedor,
    loteRacao: loteRacao.present ? loteRacao.value : this.loteRacao,
    origem: origem ?? this.origem,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeedReceipt copyWithCompanion(FeedReceiptsCompanion data) {
    return FeedReceipt(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      tipoRacaoId: data.tipoRacaoId.present
          ? data.tipoRacaoId.value
          : this.tipoRacaoId,
      tipoRacaoNome: data.tipoRacaoNome.present
          ? data.tipoRacaoNome.value
          : this.tipoRacaoNome,
      quantidadeKg: data.quantidadeKg.present
          ? data.quantidadeKg.value
          : this.quantidadeKg,
      dataRecebimento: data.dataRecebimento.present
          ? data.dataRecebimento.value
          : this.dataRecebimento,
      fornecedor: data.fornecedor.present
          ? data.fornecedor.value
          : this.fornecedor,
      loteRacao: data.loteRacao.present ? data.loteRacao.value : this.loteRacao,
      origem: data.origem.present ? data.origem.value : this.origem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedReceipt(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('tipoRacaoId: $tipoRacaoId, ')
          ..write('tipoRacaoNome: $tipoRacaoNome, ')
          ..write('quantidadeKg: $quantidadeKg, ')
          ..write('dataRecebimento: $dataRecebimento, ')
          ..write('fornecedor: $fornecedor, ')
          ..write('loteRacao: $loteRacao, ')
          ..write('origem: $origem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    tipoRacaoId,
    tipoRacaoNome,
    quantidadeKg,
    dataRecebimento,
    fornecedor,
    loteRacao,
    origem,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedReceipt &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.tipoRacaoId == this.tipoRacaoId &&
          other.tipoRacaoNome == this.tipoRacaoNome &&
          other.quantidadeKg == this.quantidadeKg &&
          other.dataRecebimento == this.dataRecebimento &&
          other.fornecedor == this.fornecedor &&
          other.loteRacao == this.loteRacao &&
          other.origem == this.origem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedReceiptsCompanion extends UpdateCompanion<FeedReceipt> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<String?> tipoRacaoId;
  final Value<String?> tipoRacaoNome;
  final Value<double> quantidadeKg;
  final Value<DateTime> dataRecebimento;
  final Value<String?> fornecedor;
  final Value<String?> loteRacao;
  final Value<String> origem;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FeedReceiptsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.tipoRacaoId = const Value.absent(),
    this.tipoRacaoNome = const Value.absent(),
    this.quantidadeKg = const Value.absent(),
    this.dataRecebimento = const Value.absent(),
    this.fornecedor = const Value.absent(),
    this.loteRacao = const Value.absent(),
    this.origem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeedReceiptsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    this.tipoRacaoId = const Value.absent(),
    this.tipoRacaoNome = const Value.absent(),
    required double quantidadeKg,
    required DateTime dataRecebimento,
    this.fornecedor = const Value.absent(),
    this.loteRacao = const Value.absent(),
    this.origem = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       quantidadeKg = Value(quantidadeKg),
       dataRecebimento = Value(dataRecebimento),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeedReceipt> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<String>? tipoRacaoId,
    Expression<String>? tipoRacaoNome,
    Expression<double>? quantidadeKg,
    Expression<DateTime>? dataRecebimento,
    Expression<String>? fornecedor,
    Expression<String>? loteRacao,
    Expression<String>? origem,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (tipoRacaoId != null) 'tipo_racao_id': tipoRacaoId,
      if (tipoRacaoNome != null) 'tipo_racao_nome': tipoRacaoNome,
      if (quantidadeKg != null) 'quantidade_kg': quantidadeKg,
      if (dataRecebimento != null) 'data_recebimento': dataRecebimento,
      if (fornecedor != null) 'fornecedor': fornecedor,
      if (loteRacao != null) 'lote_racao': loteRacao,
      if (origem != null) 'origem': origem,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeedReceiptsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<String?>? tipoRacaoId,
    Value<String?>? tipoRacaoNome,
    Value<double>? quantidadeKg,
    Value<DateTime>? dataRecebimento,
    Value<String?>? fornecedor,
    Value<String?>? loteRacao,
    Value<String>? origem,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FeedReceiptsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      tipoRacaoId: tipoRacaoId ?? this.tipoRacaoId,
      tipoRacaoNome: tipoRacaoNome ?? this.tipoRacaoNome,
      quantidadeKg: quantidadeKg ?? this.quantidadeKg,
      dataRecebimento: dataRecebimento ?? this.dataRecebimento,
      fornecedor: fornecedor ?? this.fornecedor,
      loteRacao: loteRacao ?? this.loteRacao,
      origem: origem ?? this.origem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (tipoRacaoId.present) {
      map['tipo_racao_id'] = Variable<String>(tipoRacaoId.value);
    }
    if (tipoRacaoNome.present) {
      map['tipo_racao_nome'] = Variable<String>(tipoRacaoNome.value);
    }
    if (quantidadeKg.present) {
      map['quantidade_kg'] = Variable<double>(quantidadeKg.value);
    }
    if (dataRecebimento.present) {
      map['data_recebimento'] = Variable<DateTime>(dataRecebimento.value);
    }
    if (fornecedor.present) {
      map['fornecedor'] = Variable<String>(fornecedor.value);
    }
    if (loteRacao.present) {
      map['lote_racao'] = Variable<String>(loteRacao.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('tipoRacaoId: $tipoRacaoId, ')
          ..write('tipoRacaoNome: $tipoRacaoNome, ')
          ..write('quantidadeKg: $quantidadeKg, ')
          ..write('dataRecebimento: $dataRecebimento, ')
          ..write('fornecedor: $fornecedor, ')
          ..write('loteRacao: $loteRacao, ')
          ..write('origem: $origem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeedConsumptionsTable extends FeedConsumptions
    with TableInfo<$FeedConsumptionsTable, FeedConsumption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedConsumptionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeKgMeta = const VerificationMeta(
    'quantidadeKg',
  );
  @override
  late final GeneratedColumn<double> quantidadeKg = GeneratedColumn<double>(
    'quantidade_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    id,
    serverId,
    loteId,
    data,
    quantidadeKg,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_consumptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedConsumption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('quantidade_kg')) {
      context.handle(
        _quantidadeKgMeta,
        quantidadeKg.isAcceptableOrUnknown(
          data['quantidade_kg']!,
          _quantidadeKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeKgMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedConsumption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedConsumption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      quantidadeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_kg'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeedConsumptionsTable createAlias(String alias) {
    return $FeedConsumptionsTable(attachedDatabase, alias);
  }
}

class FeedConsumption extends DataClass implements Insertable<FeedConsumption> {
  final int id;
  final String? serverId;
  final String loteId;
  final DateTime data;
  final double quantidadeKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FeedConsumption({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.data,
    required this.quantidadeKg,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['data'] = Variable<DateTime>(data);
    map['quantidade_kg'] = Variable<double>(quantidadeKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedConsumptionsCompanion toCompanion(bool nullToAbsent) {
    return FeedConsumptionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      data: Value(data),
      quantidadeKg: Value(quantidadeKg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeedConsumption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedConsumption(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      data: serializer.fromJson<DateTime>(json['data']),
      quantidadeKg: serializer.fromJson<double>(json['quantidadeKg']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'data': serializer.toJson<DateTime>(data),
      'quantidadeKg': serializer.toJson<double>(quantidadeKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeedConsumption copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    DateTime? data,
    double? quantidadeKg,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FeedConsumption(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    data: data ?? this.data,
    quantidadeKg: quantidadeKg ?? this.quantidadeKg,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeedConsumption copyWithCompanion(FeedConsumptionsCompanion data) {
    return FeedConsumption(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      data: data.data.present ? data.data.value : this.data,
      quantidadeKg: data.quantidadeKg.present
          ? data.quantidadeKg.value
          : this.quantidadeKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedConsumption(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeKg: $quantidadeKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    data,
    quantidadeKg,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedConsumption &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.data == this.data &&
          other.quantidadeKg == this.quantidadeKg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedConsumptionsCompanion extends UpdateCompanion<FeedConsumption> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<DateTime> data;
  final Value<double> quantidadeKg;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FeedConsumptionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.data = const Value.absent(),
    this.quantidadeKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeedConsumptionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required DateTime data,
    required double quantidadeKg,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       data = Value(data),
       quantidadeKg = Value(quantidadeKg),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FeedConsumption> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<DateTime>? data,
    Expression<double>? quantidadeKg,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (data != null) 'data': data,
      if (quantidadeKg != null) 'quantidade_kg': quantidadeKg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeedConsumptionsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<DateTime>? data,
    Value<double>? quantidadeKg,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FeedConsumptionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      quantidadeKg: quantidadeKg ?? this.quantidadeKg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (quantidadeKg.present) {
      map['quantidade_kg'] = Variable<double>(quantidadeKg.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedConsumptionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeKg: $quantidadeKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WaterConsumptionsTable extends WaterConsumptions
    with TableInfo<$WaterConsumptionsTable, WaterConsumption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterConsumptionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeLitrosMeta = const VerificationMeta(
    'quantidadeLitros',
  );
  @override
  late final GeneratedColumn<double> quantidadeLitros = GeneratedColumn<double>(
    'quantidade_litros',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    id,
    serverId,
    loteId,
    data,
    quantidadeLitros,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_consumptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterConsumption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('quantidade_litros')) {
      context.handle(
        _quantidadeLitrosMeta,
        quantidadeLitros.isAcceptableOrUnknown(
          data['quantidade_litros']!,
          _quantidadeLitrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeLitrosMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterConsumption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterConsumption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      quantidadeLitros: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_litros'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WaterConsumptionsTable createAlias(String alias) {
    return $WaterConsumptionsTable(attachedDatabase, alias);
  }
}

class WaterConsumption extends DataClass
    implements Insertable<WaterConsumption> {
  final int id;
  final String? serverId;
  final String loteId;
  final DateTime data;
  final double quantidadeLitros;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WaterConsumption({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.data,
    required this.quantidadeLitros,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['data'] = Variable<DateTime>(data);
    map['quantidade_litros'] = Variable<double>(quantidadeLitros);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WaterConsumptionsCompanion toCompanion(bool nullToAbsent) {
    return WaterConsumptionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      data: Value(data),
      quantidadeLitros: Value(quantidadeLitros),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WaterConsumption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterConsumption(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      data: serializer.fromJson<DateTime>(json['data']),
      quantidadeLitros: serializer.fromJson<double>(json['quantidadeLitros']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'data': serializer.toJson<DateTime>(data),
      'quantidadeLitros': serializer.toJson<double>(quantidadeLitros),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WaterConsumption copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    DateTime? data,
    double? quantidadeLitros,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WaterConsumption(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    data: data ?? this.data,
    quantidadeLitros: quantidadeLitros ?? this.quantidadeLitros,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WaterConsumption copyWithCompanion(WaterConsumptionsCompanion data) {
    return WaterConsumption(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      data: data.data.present ? data.data.value : this.data,
      quantidadeLitros: data.quantidadeLitros.present
          ? data.quantidadeLitros.value
          : this.quantidadeLitros,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterConsumption(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeLitros: $quantidadeLitros, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    data,
    quantidadeLitros,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterConsumption &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.data == this.data &&
          other.quantidadeLitros == this.quantidadeLitros &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WaterConsumptionsCompanion extends UpdateCompanion<WaterConsumption> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<DateTime> data;
  final Value<double> quantidadeLitros;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WaterConsumptionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.data = const Value.absent(),
    this.quantidadeLitros = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WaterConsumptionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required DateTime data,
    required double quantidadeLitros,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       data = Value(data),
       quantidadeLitros = Value(quantidadeLitros),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WaterConsumption> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<DateTime>? data,
    Expression<double>? quantidadeLitros,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (data != null) 'data': data,
      if (quantidadeLitros != null) 'quantidade_litros': quantidadeLitros,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WaterConsumptionsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<DateTime>? data,
    Value<double>? quantidadeLitros,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WaterConsumptionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      quantidadeLitros: quantidadeLitros ?? this.quantidadeLitros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (quantidadeLitros.present) {
      map['quantidade_litros'] = Variable<double>(quantidadeLitros.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterConsumptionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('quantidadeLitros: $quantidadeLitros, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ChecklistsTable extends Checklists
    with TableInfo<$ChecklistsTable, Checklist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itensJsonMeta = const VerificationMeta(
    'itensJson',
  );
  @override
  late final GeneratedColumn<String> itensJson = GeneratedColumn<String>(
    'itens_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completadoMeta = const VerificationMeta(
    'completado',
  );
  @override
  late final GeneratedColumn<bool> completado = GeneratedColumn<bool>(
    'completado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    id,
    serverId,
    loteId,
    data,
    itensJson,
    completado,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Checklist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('itens_json')) {
      context.handle(
        _itensJsonMeta,
        itensJson.isAcceptableOrUnknown(data['itens_json']!, _itensJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itensJsonMeta);
    }
    if (data.containsKey('completado')) {
      context.handle(
        _completadoMeta,
        completado.isAcceptableOrUnknown(data['completado']!, _completadoMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Checklist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Checklist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      itensJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}itens_json'],
      )!,
      completado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChecklistsTable createAlias(String alias) {
    return $ChecklistsTable(attachedDatabase, alias);
  }
}

class Checklist extends DataClass implements Insertable<Checklist> {
  final int id;
  final String? serverId;
  final String loteId;
  final DateTime data;
  final String itensJson;
  final bool completado;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Checklist({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.data,
    required this.itensJson,
    required this.completado,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['data'] = Variable<DateTime>(data);
    map['itens_json'] = Variable<String>(itensJson);
    map['completado'] = Variable<bool>(completado);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChecklistsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      data: Value(data),
      itensJson: Value(itensJson),
      completado: Value(completado),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Checklist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Checklist(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      data: serializer.fromJson<DateTime>(json['data']),
      itensJson: serializer.fromJson<String>(json['itensJson']),
      completado: serializer.fromJson<bool>(json['completado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'data': serializer.toJson<DateTime>(data),
      'itensJson': serializer.toJson<String>(itensJson),
      'completado': serializer.toJson<bool>(completado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Checklist copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    DateTime? data,
    String? itensJson,
    bool? completado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Checklist(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    data: data ?? this.data,
    itensJson: itensJson ?? this.itensJson,
    completado: completado ?? this.completado,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Checklist copyWithCompanion(ChecklistsCompanion data) {
    return Checklist(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      data: data.data.present ? data.data.value : this.data,
      itensJson: data.itensJson.present ? data.itensJson.value : this.itensJson,
      completado: data.completado.present
          ? data.completado.value
          : this.completado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Checklist(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('itensJson: $itensJson, ')
          ..write('completado: $completado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    data,
    itensJson,
    completado,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Checklist &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.data == this.data &&
          other.itensJson == this.itensJson &&
          other.completado == this.completado &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChecklistsCompanion extends UpdateCompanion<Checklist> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<DateTime> data;
  final Value<String> itensJson;
  final Value<bool> completado;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ChecklistsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.data = const Value.absent(),
    this.itensJson = const Value.absent(),
    this.completado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ChecklistsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required DateTime data,
    required String itensJson,
    this.completado = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : loteId = Value(loteId),
       data = Value(data),
       itensJson = Value(itensJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Checklist> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<DateTime>? data,
    Expression<String>? itensJson,
    Expression<bool>? completado,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (data != null) 'data': data,
      if (itensJson != null) 'itens_json': itensJson,
      if (completado != null) 'completado': completado,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ChecklistsCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<DateTime>? data,
    Value<String>? itensJson,
    Value<bool>? completado,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ChecklistsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      data: data ?? this.data,
      itensJson: itensJson ?? this.itensJson,
      completado: completado ?? this.completado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (itensJson.present) {
      map['itens_json'] = Variable<String>(itensJson.value);
    }
    if (completado.present) {
      map['completado'] = Variable<bool>(completado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('data: $data, ')
          ..write('itensJson: $itensJson, ')
          ..write('completado: $completado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MensagensTable extends Mensagens
    with TableInfo<$MensagensTable, Mensagen> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MensagensTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remetenteIdMeta = const VerificationMeta(
    'remetenteId',
  );
  @override
  late final GeneratedColumn<String> remetenteId = GeneratedColumn<String>(
    'remetente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remetenteNomeMeta = const VerificationMeta(
    'remetenteNome',
  );
  @override
  late final GeneratedColumn<String> remetenteNome = GeneratedColumn<String>(
    'remetente_nome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conteudoMeta = const VerificationMeta(
    'conteudo',
  );
  @override
  late final GeneratedColumn<String> conteudo = GeneratedColumn<String>(
    'conteudo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _midiaUrlMeta = const VerificationMeta(
    'midiaUrl',
  );
  @override
  late final GeneratedColumn<String> midiaUrl = GeneratedColumn<String>(
    'midia_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _midiaThumbnailUrlMeta = const VerificationMeta(
    'midiaThumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> midiaThumbnailUrl =
      GeneratedColumn<String>(
        'midia_thumbnail_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lidaMeta = const VerificationMeta('lida');
  @override
  late final GeneratedColumn<bool> lida = GeneratedColumn<bool>(
    'lida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    loteId,
    remetenteId,
    remetenteNome,
    tipo,
    conteudo,
    midiaUrl,
    midiaThumbnailUrl,
    lida,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mensagens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mensagen> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('remetente_id')) {
      context.handle(
        _remetenteIdMeta,
        remetenteId.isAcceptableOrUnknown(
          data['remetente_id']!,
          _remetenteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remetenteIdMeta);
    }
    if (data.containsKey('remetente_nome')) {
      context.handle(
        _remetenteNomeMeta,
        remetenteNome.isAcceptableOrUnknown(
          data['remetente_nome']!,
          _remetenteNomeMeta,
        ),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('conteudo')) {
      context.handle(
        _conteudoMeta,
        conteudo.isAcceptableOrUnknown(data['conteudo']!, _conteudoMeta),
      );
    }
    if (data.containsKey('midia_url')) {
      context.handle(
        _midiaUrlMeta,
        midiaUrl.isAcceptableOrUnknown(data['midia_url']!, _midiaUrlMeta),
      );
    }
    if (data.containsKey('midia_thumbnail_url')) {
      context.handle(
        _midiaThumbnailUrlMeta,
        midiaThumbnailUrl.isAcceptableOrUnknown(
          data['midia_thumbnail_url']!,
          _midiaThumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('lida')) {
      context.handle(
        _lidaMeta,
        lida.isAcceptableOrUnknown(data['lida']!, _lidaMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mensagen map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mensagen(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      remetenteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remetente_id'],
      )!,
      remetenteNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remetente_nome'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      conteudo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conteudo'],
      ),
      midiaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}midia_url'],
      ),
      midiaThumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}midia_thumbnail_url'],
      ),
      lida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lida'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MensagensTable createAlias(String alias) {
    return $MensagensTable(attachedDatabase, alias);
  }
}

class Mensagen extends DataClass implements Insertable<Mensagen> {
  final int id;
  final String? serverId;
  final String loteId;
  final String remetenteId;
  final String? remetenteNome;
  final String tipo;
  final String? conteudo;
  final String? midiaUrl;
  final String? midiaThumbnailUrl;
  final bool lida;
  final DateTime createdAt;
  const Mensagen({
    required this.id,
    this.serverId,
    required this.loteId,
    required this.remetenteId,
    this.remetenteNome,
    required this.tipo,
    this.conteudo,
    this.midiaUrl,
    this.midiaThumbnailUrl,
    required this.lida,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['remetente_id'] = Variable<String>(remetenteId);
    if (!nullToAbsent || remetenteNome != null) {
      map['remetente_nome'] = Variable<String>(remetenteNome);
    }
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || conteudo != null) {
      map['conteudo'] = Variable<String>(conteudo);
    }
    if (!nullToAbsent || midiaUrl != null) {
      map['midia_url'] = Variable<String>(midiaUrl);
    }
    if (!nullToAbsent || midiaThumbnailUrl != null) {
      map['midia_thumbnail_url'] = Variable<String>(midiaThumbnailUrl);
    }
    map['lida'] = Variable<bool>(lida);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MensagensCompanion toCompanion(bool nullToAbsent) {
    return MensagensCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      loteId: Value(loteId),
      remetenteId: Value(remetenteId),
      remetenteNome: remetenteNome == null && nullToAbsent
          ? const Value.absent()
          : Value(remetenteNome),
      tipo: Value(tipo),
      conteudo: conteudo == null && nullToAbsent
          ? const Value.absent()
          : Value(conteudo),
      midiaUrl: midiaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(midiaUrl),
      midiaThumbnailUrl: midiaThumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(midiaThumbnailUrl),
      lida: Value(lida),
      createdAt: Value(createdAt),
    );
  }

  factory Mensagen.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mensagen(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      loteId: serializer.fromJson<String>(json['loteId']),
      remetenteId: serializer.fromJson<String>(json['remetenteId']),
      remetenteNome: serializer.fromJson<String?>(json['remetenteNome']),
      tipo: serializer.fromJson<String>(json['tipo']),
      conteudo: serializer.fromJson<String?>(json['conteudo']),
      midiaUrl: serializer.fromJson<String?>(json['midiaUrl']),
      midiaThumbnailUrl: serializer.fromJson<String?>(
        json['midiaThumbnailUrl'],
      ),
      lida: serializer.fromJson<bool>(json['lida']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'loteId': serializer.toJson<String>(loteId),
      'remetenteId': serializer.toJson<String>(remetenteId),
      'remetenteNome': serializer.toJson<String?>(remetenteNome),
      'tipo': serializer.toJson<String>(tipo),
      'conteudo': serializer.toJson<String?>(conteudo),
      'midiaUrl': serializer.toJson<String?>(midiaUrl),
      'midiaThumbnailUrl': serializer.toJson<String?>(midiaThumbnailUrl),
      'lida': serializer.toJson<bool>(lida),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Mensagen copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? loteId,
    String? remetenteId,
    Value<String?> remetenteNome = const Value.absent(),
    String? tipo,
    Value<String?> conteudo = const Value.absent(),
    Value<String?> midiaUrl = const Value.absent(),
    Value<String?> midiaThumbnailUrl = const Value.absent(),
    bool? lida,
    DateTime? createdAt,
  }) => Mensagen(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    loteId: loteId ?? this.loteId,
    remetenteId: remetenteId ?? this.remetenteId,
    remetenteNome: remetenteNome.present
        ? remetenteNome.value
        : this.remetenteNome,
    tipo: tipo ?? this.tipo,
    conteudo: conteudo.present ? conteudo.value : this.conteudo,
    midiaUrl: midiaUrl.present ? midiaUrl.value : this.midiaUrl,
    midiaThumbnailUrl: midiaThumbnailUrl.present
        ? midiaThumbnailUrl.value
        : this.midiaThumbnailUrl,
    lida: lida ?? this.lida,
    createdAt: createdAt ?? this.createdAt,
  );
  Mensagen copyWithCompanion(MensagensCompanion data) {
    return Mensagen(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      remetenteId: data.remetenteId.present
          ? data.remetenteId.value
          : this.remetenteId,
      remetenteNome: data.remetenteNome.present
          ? data.remetenteNome.value
          : this.remetenteNome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      conteudo: data.conteudo.present ? data.conteudo.value : this.conteudo,
      midiaUrl: data.midiaUrl.present ? data.midiaUrl.value : this.midiaUrl,
      midiaThumbnailUrl: data.midiaThumbnailUrl.present
          ? data.midiaThumbnailUrl.value
          : this.midiaThumbnailUrl,
      lida: data.lida.present ? data.lida.value : this.lida,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mensagen(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('remetenteId: $remetenteId, ')
          ..write('remetenteNome: $remetenteNome, ')
          ..write('tipo: $tipo, ')
          ..write('conteudo: $conteudo, ')
          ..write('midiaUrl: $midiaUrl, ')
          ..write('midiaThumbnailUrl: $midiaThumbnailUrl, ')
          ..write('lida: $lida, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    loteId,
    remetenteId,
    remetenteNome,
    tipo,
    conteudo,
    midiaUrl,
    midiaThumbnailUrl,
    lida,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mensagen &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.loteId == this.loteId &&
          other.remetenteId == this.remetenteId &&
          other.remetenteNome == this.remetenteNome &&
          other.tipo == this.tipo &&
          other.conteudo == this.conteudo &&
          other.midiaUrl == this.midiaUrl &&
          other.midiaThumbnailUrl == this.midiaThumbnailUrl &&
          other.lida == this.lida &&
          other.createdAt == this.createdAt);
}

class MensagensCompanion extends UpdateCompanion<Mensagen> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> loteId;
  final Value<String> remetenteId;
  final Value<String?> remetenteNome;
  final Value<String> tipo;
  final Value<String?> conteudo;
  final Value<String?> midiaUrl;
  final Value<String?> midiaThumbnailUrl;
  final Value<bool> lida;
  final Value<DateTime> createdAt;
  const MensagensCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.remetenteId = const Value.absent(),
    this.remetenteNome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.conteudo = const Value.absent(),
    this.midiaUrl = const Value.absent(),
    this.midiaThumbnailUrl = const Value.absent(),
    this.lida = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MensagensCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String loteId,
    required String remetenteId,
    this.remetenteNome = const Value.absent(),
    required String tipo,
    this.conteudo = const Value.absent(),
    this.midiaUrl = const Value.absent(),
    this.midiaThumbnailUrl = const Value.absent(),
    this.lida = const Value.absent(),
    required DateTime createdAt,
  }) : loteId = Value(loteId),
       remetenteId = Value(remetenteId),
       tipo = Value(tipo),
       createdAt = Value(createdAt);
  static Insertable<Mensagen> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? loteId,
    Expression<String>? remetenteId,
    Expression<String>? remetenteNome,
    Expression<String>? tipo,
    Expression<String>? conteudo,
    Expression<String>? midiaUrl,
    Expression<String>? midiaThumbnailUrl,
    Expression<bool>? lida,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (loteId != null) 'lote_id': loteId,
      if (remetenteId != null) 'remetente_id': remetenteId,
      if (remetenteNome != null) 'remetente_nome': remetenteNome,
      if (tipo != null) 'tipo': tipo,
      if (conteudo != null) 'conteudo': conteudo,
      if (midiaUrl != null) 'midia_url': midiaUrl,
      if (midiaThumbnailUrl != null) 'midia_thumbnail_url': midiaThumbnailUrl,
      if (lida != null) 'lida': lida,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MensagensCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? loteId,
    Value<String>? remetenteId,
    Value<String?>? remetenteNome,
    Value<String>? tipo,
    Value<String?>? conteudo,
    Value<String?>? midiaUrl,
    Value<String?>? midiaThumbnailUrl,
    Value<bool>? lida,
    Value<DateTime>? createdAt,
  }) {
    return MensagensCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      loteId: loteId ?? this.loteId,
      remetenteId: remetenteId ?? this.remetenteId,
      remetenteNome: remetenteNome ?? this.remetenteNome,
      tipo: tipo ?? this.tipo,
      conteudo: conteudo ?? this.conteudo,
      midiaUrl: midiaUrl ?? this.midiaUrl,
      midiaThumbnailUrl: midiaThumbnailUrl ?? this.midiaThumbnailUrl,
      lida: lida ?? this.lida,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (remetenteId.present) {
      map['remetente_id'] = Variable<String>(remetenteId.value);
    }
    if (remetenteNome.present) {
      map['remetente_nome'] = Variable<String>(remetenteNome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (conteudo.present) {
      map['conteudo'] = Variable<String>(conteudo.value);
    }
    if (midiaUrl.present) {
      map['midia_url'] = Variable<String>(midiaUrl.value);
    }
    if (midiaThumbnailUrl.present) {
      map['midia_thumbnail_url'] = Variable<String>(midiaThumbnailUrl.value);
    }
    if (lida.present) {
      map['lida'] = Variable<bool>(lida.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MensagensCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('loteId: $loteId, ')
          ..write('remetenteId: $remetenteId, ')
          ..write('remetenteNome: $remetenteNome, ')
          ..write('tipo: $tipo, ')
          ..write('conteudo: $conteudo, ')
          ..write('midiaUrl: $midiaUrl, ')
          ..write('midiaThumbnailUrl: $midiaThumbnailUrl, ')
          ..write('lida: $lida, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GalpaosTable extends Galpaos with TableInfo<$GalpaosTable, Galpao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GalpaosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacidadeMeta = const VerificationMeta(
    'capacidade',
  );
  @override
  late final GeneratedColumn<int> capacidade = GeneratedColumn<int>(
    'capacidade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orientacaoGrausMeta = const VerificationMeta(
    'orientacaoGraus',
  );
  @override
  late final GeneratedColumn<double> orientacaoGraus = GeneratedColumn<double>(
    'orientacao_graus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _comprimentoMMeta = const VerificationMeta(
    'comprimentoM',
  );
  @override
  late final GeneratedColumn<double> comprimentoM = GeneratedColumn<double>(
    'comprimento_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _larguraMMeta = const VerificationMeta(
    'larguraM',
  );
  @override
  late final GeneratedColumn<double> larguraM = GeneratedColumn<double>(
    'largura_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoVentilacaoMeta = const VerificationMeta(
    'tipoVentilacao',
  );
  @override
  late final GeneratedColumn<String> tipoVentilacao = GeneratedColumn<String>(
    'tipo_ventilacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ladoCortinasMeta = const VerificationMeta(
    'ladoCortinas',
  );
  @override
  late final GeneratedColumn<String> ladoCortinas = GeneratedColumn<String>(
    'lado_cortinas',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    id,
    serverId,
    usuarioId,
    nome,
    capacidade,
    latitude,
    longitude,
    orientacaoGraus,
    comprimentoM,
    larguraM,
    tipoVentilacao,
    ladoCortinas,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'galpaos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Galpao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('capacidade')) {
      context.handle(
        _capacidadeMeta,
        capacidade.isAcceptableOrUnknown(data['capacidade']!, _capacidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_capacidadeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('orientacao_graus')) {
      context.handle(
        _orientacaoGrausMeta,
        orientacaoGraus.isAcceptableOrUnknown(
          data['orientacao_graus']!,
          _orientacaoGrausMeta,
        ),
      );
    }
    if (data.containsKey('comprimento_m')) {
      context.handle(
        _comprimentoMMeta,
        comprimentoM.isAcceptableOrUnknown(
          data['comprimento_m']!,
          _comprimentoMMeta,
        ),
      );
    }
    if (data.containsKey('largura_m')) {
      context.handle(
        _larguraMMeta,
        larguraM.isAcceptableOrUnknown(data['largura_m']!, _larguraMMeta),
      );
    }
    if (data.containsKey('tipo_ventilacao')) {
      context.handle(
        _tipoVentilacaoMeta,
        tipoVentilacao.isAcceptableOrUnknown(
          data['tipo_ventilacao']!,
          _tipoVentilacaoMeta,
        ),
      );
    }
    if (data.containsKey('lado_cortinas')) {
      context.handle(
        _ladoCortinasMeta,
        ladoCortinas.isAcceptableOrUnknown(
          data['lado_cortinas']!,
          _ladoCortinasMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Galpao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Galpao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      capacidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacidade'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      orientacaoGraus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}orientacao_graus'],
      ),
      comprimentoM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}comprimento_m'],
      ),
      larguraM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}largura_m'],
      ),
      tipoVentilacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_ventilacao'],
      ),
      ladoCortinas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lado_cortinas'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GalpaosTable createAlias(String alias) {
    return $GalpaosTable(attachedDatabase, alias);
  }
}

class Galpao extends DataClass implements Insertable<Galpao> {
  final int id;
  final String? serverId;
  final String usuarioId;
  final String nome;
  final int capacidade;
  final double? latitude;
  final double? longitude;
  final double? orientacaoGraus;
  final double? comprimentoM;
  final double? larguraM;
  final String? tipoVentilacao;
  final String? ladoCortinas;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Galpao({
    required this.id,
    this.serverId,
    required this.usuarioId,
    required this.nome,
    required this.capacidade,
    this.latitude,
    this.longitude,
    this.orientacaoGraus,
    this.comprimentoM,
    this.larguraM,
    this.tipoVentilacao,
    this.ladoCortinas,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['nome'] = Variable<String>(nome);
    map['capacidade'] = Variable<int>(capacidade);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || orientacaoGraus != null) {
      map['orientacao_graus'] = Variable<double>(orientacaoGraus);
    }
    if (!nullToAbsent || comprimentoM != null) {
      map['comprimento_m'] = Variable<double>(comprimentoM);
    }
    if (!nullToAbsent || larguraM != null) {
      map['largura_m'] = Variable<double>(larguraM);
    }
    if (!nullToAbsent || tipoVentilacao != null) {
      map['tipo_ventilacao'] = Variable<String>(tipoVentilacao);
    }
    if (!nullToAbsent || ladoCortinas != null) {
      map['lado_cortinas'] = Variable<String>(ladoCortinas);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GalpaosCompanion toCompanion(bool nullToAbsent) {
    return GalpaosCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      usuarioId: Value(usuarioId),
      nome: Value(nome),
      capacidade: Value(capacidade),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      orientacaoGraus: orientacaoGraus == null && nullToAbsent
          ? const Value.absent()
          : Value(orientacaoGraus),
      comprimentoM: comprimentoM == null && nullToAbsent
          ? const Value.absent()
          : Value(comprimentoM),
      larguraM: larguraM == null && nullToAbsent
          ? const Value.absent()
          : Value(larguraM),
      tipoVentilacao: tipoVentilacao == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoVentilacao),
      ladoCortinas: ladoCortinas == null && nullToAbsent
          ? const Value.absent()
          : Value(ladoCortinas),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Galpao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Galpao(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      nome: serializer.fromJson<String>(json['nome']),
      capacidade: serializer.fromJson<int>(json['capacidade']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      orientacaoGraus: serializer.fromJson<double?>(json['orientacaoGraus']),
      comprimentoM: serializer.fromJson<double?>(json['comprimentoM']),
      larguraM: serializer.fromJson<double?>(json['larguraM']),
      tipoVentilacao: serializer.fromJson<String?>(json['tipoVentilacao']),
      ladoCortinas: serializer.fromJson<String?>(json['ladoCortinas']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'nome': serializer.toJson<String>(nome),
      'capacidade': serializer.toJson<int>(capacidade),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'orientacaoGraus': serializer.toJson<double?>(orientacaoGraus),
      'comprimentoM': serializer.toJson<double?>(comprimentoM),
      'larguraM': serializer.toJson<double?>(larguraM),
      'tipoVentilacao': serializer.toJson<String?>(tipoVentilacao),
      'ladoCortinas': serializer.toJson<String?>(ladoCortinas),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Galpao copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? usuarioId,
    String? nome,
    int? capacidade,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> orientacaoGraus = const Value.absent(),
    Value<double?> comprimentoM = const Value.absent(),
    Value<double?> larguraM = const Value.absent(),
    Value<String?> tipoVentilacao = const Value.absent(),
    Value<String?> ladoCortinas = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Galpao(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    usuarioId: usuarioId ?? this.usuarioId,
    nome: nome ?? this.nome,
    capacidade: capacidade ?? this.capacidade,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    orientacaoGraus: orientacaoGraus.present
        ? orientacaoGraus.value
        : this.orientacaoGraus,
    comprimentoM: comprimentoM.present ? comprimentoM.value : this.comprimentoM,
    larguraM: larguraM.present ? larguraM.value : this.larguraM,
    tipoVentilacao: tipoVentilacao.present
        ? tipoVentilacao.value
        : this.tipoVentilacao,
    ladoCortinas: ladoCortinas.present ? ladoCortinas.value : this.ladoCortinas,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Galpao copyWithCompanion(GalpaosCompanion data) {
    return Galpao(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      nome: data.nome.present ? data.nome.value : this.nome,
      capacidade: data.capacidade.present
          ? data.capacidade.value
          : this.capacidade,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      orientacaoGraus: data.orientacaoGraus.present
          ? data.orientacaoGraus.value
          : this.orientacaoGraus,
      comprimentoM: data.comprimentoM.present
          ? data.comprimentoM.value
          : this.comprimentoM,
      larguraM: data.larguraM.present ? data.larguraM.value : this.larguraM,
      tipoVentilacao: data.tipoVentilacao.present
          ? data.tipoVentilacao.value
          : this.tipoVentilacao,
      ladoCortinas: data.ladoCortinas.present
          ? data.ladoCortinas.value
          : this.ladoCortinas,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Galpao(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nome: $nome, ')
          ..write('capacidade: $capacidade, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('orientacaoGraus: $orientacaoGraus, ')
          ..write('comprimentoM: $comprimentoM, ')
          ..write('larguraM: $larguraM, ')
          ..write('tipoVentilacao: $tipoVentilacao, ')
          ..write('ladoCortinas: $ladoCortinas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    usuarioId,
    nome,
    capacidade,
    latitude,
    longitude,
    orientacaoGraus,
    comprimentoM,
    larguraM,
    tipoVentilacao,
    ladoCortinas,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Galpao &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.usuarioId == this.usuarioId &&
          other.nome == this.nome &&
          other.capacidade == this.capacidade &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.orientacaoGraus == this.orientacaoGraus &&
          other.comprimentoM == this.comprimentoM &&
          other.larguraM == this.larguraM &&
          other.tipoVentilacao == this.tipoVentilacao &&
          other.ladoCortinas == this.ladoCortinas &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GalpaosCompanion extends UpdateCompanion<Galpao> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> usuarioId;
  final Value<String> nome;
  final Value<int> capacidade;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> orientacaoGraus;
  final Value<double?> comprimentoM;
  final Value<double?> larguraM;
  final Value<String?> tipoVentilacao;
  final Value<String?> ladoCortinas;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GalpaosCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.nome = const Value.absent(),
    this.capacidade = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.orientacaoGraus = const Value.absent(),
    this.comprimentoM = const Value.absent(),
    this.larguraM = const Value.absent(),
    this.tipoVentilacao = const Value.absent(),
    this.ladoCortinas = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GalpaosCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String usuarioId,
    required String nome,
    required int capacidade,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.orientacaoGraus = const Value.absent(),
    this.comprimentoM = const Value.absent(),
    this.larguraM = const Value.absent(),
    this.tipoVentilacao = const Value.absent(),
    this.ladoCortinas = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : usuarioId = Value(usuarioId),
       nome = Value(nome),
       capacidade = Value(capacidade),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Galpao> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? usuarioId,
    Expression<String>? nome,
    Expression<int>? capacidade,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? orientacaoGraus,
    Expression<double>? comprimentoM,
    Expression<double>? larguraM,
    Expression<String>? tipoVentilacao,
    Expression<String>? ladoCortinas,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (nome != null) 'nome': nome,
      if (capacidade != null) 'capacidade': capacidade,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (orientacaoGraus != null) 'orientacao_graus': orientacaoGraus,
      if (comprimentoM != null) 'comprimento_m': comprimentoM,
      if (larguraM != null) 'largura_m': larguraM,
      if (tipoVentilacao != null) 'tipo_ventilacao': tipoVentilacao,
      if (ladoCortinas != null) 'lado_cortinas': ladoCortinas,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GalpaosCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? usuarioId,
    Value<String>? nome,
    Value<int>? capacidade,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? orientacaoGraus,
    Value<double?>? comprimentoM,
    Value<double?>? larguraM,
    Value<String?>? tipoVentilacao,
    Value<String?>? ladoCortinas,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return GalpaosCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      capacidade: capacidade ?? this.capacidade,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      orientacaoGraus: orientacaoGraus ?? this.orientacaoGraus,
      comprimentoM: comprimentoM ?? this.comprimentoM,
      larguraM: larguraM ?? this.larguraM,
      tipoVentilacao: tipoVentilacao ?? this.tipoVentilacao,
      ladoCortinas: ladoCortinas ?? this.ladoCortinas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (capacidade.present) {
      map['capacidade'] = Variable<int>(capacidade.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (orientacaoGraus.present) {
      map['orientacao_graus'] = Variable<double>(orientacaoGraus.value);
    }
    if (comprimentoM.present) {
      map['comprimento_m'] = Variable<double>(comprimentoM.value);
    }
    if (larguraM.present) {
      map['largura_m'] = Variable<double>(larguraM.value);
    }
    if (tipoVentilacao.present) {
      map['tipo_ventilacao'] = Variable<String>(tipoVentilacao.value);
    }
    if (ladoCortinas.present) {
      map['lado_cortinas'] = Variable<String>(ladoCortinas.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GalpaosCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nome: $nome, ')
          ..write('capacidade: $capacidade, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('orientacaoGraus: $orientacaoGraus, ')
          ..write('comprimentoM: $comprimentoM, ')
          ..write('larguraM: $larguraM, ')
          ..write('tipoVentilacao: $tipoVentilacao, ')
          ..write('ladoCortinas: $ladoCortinas, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BenchmarksLinhagemTable extends BenchmarksLinhagem
    with TableInfo<$BenchmarksLinhagemTable, BenchmarksLinhagemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BenchmarksLinhagemTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linhagemMeta = const VerificationMeta(
    'linhagem',
  );
  @override
  late final GeneratedColumn<String> linhagem = GeneratedColumn<String>(
    'linhagem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<int> dia = GeneratedColumn<int>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pesoGMeta = const VerificationMeta('pesoG');
  @override
  late final GeneratedColumn<double> pesoG = GeneratedColumn<double>(
    'peso_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumoAcumGMeta = const VerificationMeta(
    'consumoAcumG',
  );
  @override
  late final GeneratedColumn<double> consumoAcumG = GeneratedColumn<double>(
    'consumo_acum_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caMeta = const VerificationMeta('ca');
  @override
  late final GeneratedColumn<double> ca = GeneratedColumn<double>(
    'ca',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpdGMeta = const VerificationMeta('gpdG');
  @override
  late final GeneratedColumn<double> gpdG = GeneratedColumn<double>(
    'gpd_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    linhagem,
    dia,
    pesoG,
    consumoAcumG,
    ca,
    gpdG,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'benchmarks_linhagem';
  @override
  VerificationContext validateIntegrity(
    Insertable<BenchmarksLinhagemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('linhagem')) {
      context.handle(
        _linhagemMeta,
        linhagem.isAcceptableOrUnknown(data['linhagem']!, _linhagemMeta),
      );
    } else if (isInserting) {
      context.missing(_linhagemMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('peso_g')) {
      context.handle(
        _pesoGMeta,
        pesoG.isAcceptableOrUnknown(data['peso_g']!, _pesoGMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoGMeta);
    }
    if (data.containsKey('consumo_acum_g')) {
      context.handle(
        _consumoAcumGMeta,
        consumoAcumG.isAcceptableOrUnknown(
          data['consumo_acum_g']!,
          _consumoAcumGMeta,
        ),
      );
    }
    if (data.containsKey('ca')) {
      context.handle(_caMeta, ca.isAcceptableOrUnknown(data['ca']!, _caMeta));
    }
    if (data.containsKey('gpd_g')) {
      context.handle(
        _gpdGMeta,
        gpdG.isAcceptableOrUnknown(data['gpd_g']!, _gpdGMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BenchmarksLinhagemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BenchmarksLinhagemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      linhagem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linhagem'],
      )!,
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia'],
      )!,
      pesoG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_g'],
      )!,
      consumoAcumG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumo_acum_g'],
      ),
      ca: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ca'],
      ),
      gpdG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gpd_g'],
      ),
    );
  }

  @override
  $BenchmarksLinhagemTable createAlias(String alias) {
    return $BenchmarksLinhagemTable(attachedDatabase, alias);
  }
}

class BenchmarksLinhagemData extends DataClass
    implements Insertable<BenchmarksLinhagemData> {
  final int id;
  final String? serverId;
  final String linhagem;
  final int dia;
  final double pesoG;
  final double? consumoAcumG;
  final double? ca;
  final double? gpdG;
  const BenchmarksLinhagemData({
    required this.id,
    this.serverId,
    required this.linhagem,
    required this.dia,
    required this.pesoG,
    this.consumoAcumG,
    this.ca,
    this.gpdG,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['linhagem'] = Variable<String>(linhagem);
    map['dia'] = Variable<int>(dia);
    map['peso_g'] = Variable<double>(pesoG);
    if (!nullToAbsent || consumoAcumG != null) {
      map['consumo_acum_g'] = Variable<double>(consumoAcumG);
    }
    if (!nullToAbsent || ca != null) {
      map['ca'] = Variable<double>(ca);
    }
    if (!nullToAbsent || gpdG != null) {
      map['gpd_g'] = Variable<double>(gpdG);
    }
    return map;
  }

  BenchmarksLinhagemCompanion toCompanion(bool nullToAbsent) {
    return BenchmarksLinhagemCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      linhagem: Value(linhagem),
      dia: Value(dia),
      pesoG: Value(pesoG),
      consumoAcumG: consumoAcumG == null && nullToAbsent
          ? const Value.absent()
          : Value(consumoAcumG),
      ca: ca == null && nullToAbsent ? const Value.absent() : Value(ca),
      gpdG: gpdG == null && nullToAbsent ? const Value.absent() : Value(gpdG),
    );
  }

  factory BenchmarksLinhagemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BenchmarksLinhagemData(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      linhagem: serializer.fromJson<String>(json['linhagem']),
      dia: serializer.fromJson<int>(json['dia']),
      pesoG: serializer.fromJson<double>(json['pesoG']),
      consumoAcumG: serializer.fromJson<double?>(json['consumoAcumG']),
      ca: serializer.fromJson<double?>(json['ca']),
      gpdG: serializer.fromJson<double?>(json['gpdG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'linhagem': serializer.toJson<String>(linhagem),
      'dia': serializer.toJson<int>(dia),
      'pesoG': serializer.toJson<double>(pesoG),
      'consumoAcumG': serializer.toJson<double?>(consumoAcumG),
      'ca': serializer.toJson<double?>(ca),
      'gpdG': serializer.toJson<double?>(gpdG),
    };
  }

  BenchmarksLinhagemData copyWith({
    int? id,
    Value<String?> serverId = const Value.absent(),
    String? linhagem,
    int? dia,
    double? pesoG,
    Value<double?> consumoAcumG = const Value.absent(),
    Value<double?> ca = const Value.absent(),
    Value<double?> gpdG = const Value.absent(),
  }) => BenchmarksLinhagemData(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    linhagem: linhagem ?? this.linhagem,
    dia: dia ?? this.dia,
    pesoG: pesoG ?? this.pesoG,
    consumoAcumG: consumoAcumG.present ? consumoAcumG.value : this.consumoAcumG,
    ca: ca.present ? ca.value : this.ca,
    gpdG: gpdG.present ? gpdG.value : this.gpdG,
  );
  BenchmarksLinhagemData copyWithCompanion(BenchmarksLinhagemCompanion data) {
    return BenchmarksLinhagemData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      linhagem: data.linhagem.present ? data.linhagem.value : this.linhagem,
      dia: data.dia.present ? data.dia.value : this.dia,
      pesoG: data.pesoG.present ? data.pesoG.value : this.pesoG,
      consumoAcumG: data.consumoAcumG.present
          ? data.consumoAcumG.value
          : this.consumoAcumG,
      ca: data.ca.present ? data.ca.value : this.ca,
      gpdG: data.gpdG.present ? data.gpdG.value : this.gpdG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarksLinhagemData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('linhagem: $linhagem, ')
          ..write('dia: $dia, ')
          ..write('pesoG: $pesoG, ')
          ..write('consumoAcumG: $consumoAcumG, ')
          ..write('ca: $ca, ')
          ..write('gpdG: $gpdG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serverId, linhagem, dia, pesoG, consumoAcumG, ca, gpdG);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BenchmarksLinhagemData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.linhagem == this.linhagem &&
          other.dia == this.dia &&
          other.pesoG == this.pesoG &&
          other.consumoAcumG == this.consumoAcumG &&
          other.ca == this.ca &&
          other.gpdG == this.gpdG);
}

class BenchmarksLinhagemCompanion
    extends UpdateCompanion<BenchmarksLinhagemData> {
  final Value<int> id;
  final Value<String?> serverId;
  final Value<String> linhagem;
  final Value<int> dia;
  final Value<double> pesoG;
  final Value<double?> consumoAcumG;
  final Value<double?> ca;
  final Value<double?> gpdG;
  const BenchmarksLinhagemCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.linhagem = const Value.absent(),
    this.dia = const Value.absent(),
    this.pesoG = const Value.absent(),
    this.consumoAcumG = const Value.absent(),
    this.ca = const Value.absent(),
    this.gpdG = const Value.absent(),
  });
  BenchmarksLinhagemCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String linhagem,
    required int dia,
    required double pesoG,
    this.consumoAcumG = const Value.absent(),
    this.ca = const Value.absent(),
    this.gpdG = const Value.absent(),
  }) : linhagem = Value(linhagem),
       dia = Value(dia),
       pesoG = Value(pesoG);
  static Insertable<BenchmarksLinhagemData> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? linhagem,
    Expression<int>? dia,
    Expression<double>? pesoG,
    Expression<double>? consumoAcumG,
    Expression<double>? ca,
    Expression<double>? gpdG,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (linhagem != null) 'linhagem': linhagem,
      if (dia != null) 'dia': dia,
      if (pesoG != null) 'peso_g': pesoG,
      if (consumoAcumG != null) 'consumo_acum_g': consumoAcumG,
      if (ca != null) 'ca': ca,
      if (gpdG != null) 'gpd_g': gpdG,
    });
  }

  BenchmarksLinhagemCompanion copyWith({
    Value<int>? id,
    Value<String?>? serverId,
    Value<String>? linhagem,
    Value<int>? dia,
    Value<double>? pesoG,
    Value<double?>? consumoAcumG,
    Value<double?>? ca,
    Value<double?>? gpdG,
  }) {
    return BenchmarksLinhagemCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      linhagem: linhagem ?? this.linhagem,
      dia: dia ?? this.dia,
      pesoG: pesoG ?? this.pesoG,
      consumoAcumG: consumoAcumG ?? this.consumoAcumG,
      ca: ca ?? this.ca,
      gpdG: gpdG ?? this.gpdG,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (linhagem.present) {
      map['linhagem'] = Variable<String>(linhagem.value);
    }
    if (dia.present) {
      map['dia'] = Variable<int>(dia.value);
    }
    if (pesoG.present) {
      map['peso_g'] = Variable<double>(pesoG.value);
    }
    if (consumoAcumG.present) {
      map['consumo_acum_g'] = Variable<double>(consumoAcumG.value);
    }
    if (ca.present) {
      map['ca'] = Variable<double>(ca.value);
    }
    if (gpdG.present) {
      map['gpd_g'] = Variable<double>(gpdG.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarksLinhagemCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('linhagem: $linhagem, ')
          ..write('dia: $dia, ')
          ..write('pesoG: $pesoG, ')
          ..write('consumoAcumG: $consumoAcumG, ')
          ..write('ca: $ca, ')
          ..write('gpdG: $gpdG')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    method,
    url,
    dataJson,
    createdAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
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
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String method;
  final String url;
  final String? dataJson;
  final DateTime createdAt;
  final String status;
  const SyncQueueEntry({
    required this.id,
    required this.method,
    required this.url,
    this.dataJson,
    required this.createdAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      method: Value(method),
      url: Value(url),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'dataJson': serializer.toJson<String?>(dataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    String? method,
    String? url,
    Value<String?> dataJson = const Value.absent(),
    DateTime? createdAt,
    String? status,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    method: method ?? this.method,
    url: url ?? this.url,
    dataJson: dataJson.present ? dataJson.value : this.dataJson,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('dataJson: $dataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, method, url, dataJson, createdAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.method == this.method &&
          other.url == this.url &&
          other.dataJson == this.dataJson &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> method;
  final Value<String> url;
  final Value<String?> dataJson;
  final Value<DateTime> createdAt;
  final Value<String> status;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String method,
    required String url,
    this.dataJson = const Value.absent(),
    required DateTime createdAt,
    this.status = const Value.absent(),
  }) : method = Value(method),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? method,
    Expression<String>? url,
    Expression<String>? dataJson,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (dataJson != null) 'data_json': dataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? method,
    Value<String>? url,
    Value<String?>? dataJson,
    Value<DateTime>? createdAt,
    Value<String>? status,
  }) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      dataJson: dataJson ?? this.dataJson,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('dataJson: $dataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LotesTable lotes = $LotesTable(this);
  late final $PesagensTable pesagens = $PesagensTable(this);
  late final $PesagemItemsTable pesagemItems = $PesagemItemsTable(this);
  late final $MortalidadesTable mortalidades = $MortalidadesTable(this);
  late final $FeedReceiptsTable feedReceipts = $FeedReceiptsTable(this);
  late final $FeedConsumptionsTable feedConsumptions = $FeedConsumptionsTable(
    this,
  );
  late final $WaterConsumptionsTable waterConsumptions =
      $WaterConsumptionsTable(this);
  late final $ChecklistsTable checklists = $ChecklistsTable(this);
  late final $MensagensTable mensagens = $MensagensTable(this);
  late final $GalpaosTable galpaos = $GalpaosTable(this);
  late final $BenchmarksLinhagemTable benchmarksLinhagem =
      $BenchmarksLinhagemTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  late final LotesDao lotesDao = LotesDao(this as AppDatabase);
  late final PesagensDao pesagensDao = PesagensDao(this as AppDatabase);
  late final MortalidadesDao mortalidadesDao = MortalidadesDao(
    this as AppDatabase,
  );
  late final FeedReceiptsDao feedReceiptsDao = FeedReceiptsDao(
    this as AppDatabase,
  );
  late final FeedConsumptionsDao feedConsumptionsDao = FeedConsumptionsDao(
    this as AppDatabase,
  );
  late final WaterConsumptionsDao waterConsumptionsDao = WaterConsumptionsDao(
    this as AppDatabase,
  );
  late final ChecklistsDao checklistsDao = ChecklistsDao(this as AppDatabase);
  late final MensagensDao mensagensDao = MensagensDao(this as AppDatabase);
  late final GalpaosDao galpaosDao = GalpaosDao(this as AppDatabase);
  late final BenchmarksDao benchmarksDao = BenchmarksDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lotes,
    pesagens,
    pesagemItems,
    mortalidades,
    feedReceipts,
    feedConsumptions,
    waterConsumptions,
    checklists,
    mensagens,
    galpaos,
    benchmarksLinhagem,
    syncQueueEntries,
  ];
}

typedef $$LotesTableCreateCompanionBuilder =
    LotesCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String usuarioId,
      required String galpaoId,
      Value<String?> galpaoNome,
      required DateTime dataAlojamento,
      required DateTime dataPrevistaAbate,
      required int quantidade,
      required String tipo,
      Value<String?> linhagem,
      required double pesoInicialG,
      Value<String> status,
      Value<DateTime?> dataFinalizacao,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$LotesTableUpdateCompanionBuilder =
    LotesCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> usuarioId,
      Value<String> galpaoId,
      Value<String?> galpaoNome,
      Value<DateTime> dataAlojamento,
      Value<DateTime> dataPrevistaAbate,
      Value<int> quantidade,
      Value<String> tipo,
      Value<String?> linhagem,
      Value<double> pesoInicialG,
      Value<String> status,
      Value<DateTime?> dataFinalizacao,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LotesTableFilterComposer extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get galpaoId => $composableBuilder(
    column: $table.galpaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get galpaoNome => $composableBuilder(
    column: $table.galpaoNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataAlojamento => $composableBuilder(
    column: $table.dataAlojamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPrevistaAbate => $composableBuilder(
    column: $table.dataPrevistaAbate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linhagem => $composableBuilder(
    column: $table.linhagem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoInicialG => $composableBuilder(
    column: $table.pesoInicialG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataFinalizacao => $composableBuilder(
    column: $table.dataFinalizacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get galpaoId => $composableBuilder(
    column: $table.galpaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get galpaoNome => $composableBuilder(
    column: $table.galpaoNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataAlojamento => $composableBuilder(
    column: $table.dataAlojamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPrevistaAbate => $composableBuilder(
    column: $table.dataPrevistaAbate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linhagem => $composableBuilder(
    column: $table.linhagem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoInicialG => $composableBuilder(
    column: $table.pesoInicialG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataFinalizacao => $composableBuilder(
    column: $table.dataFinalizacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get galpaoId =>
      $composableBuilder(column: $table.galpaoId, builder: (column) => column);

  GeneratedColumn<String> get galpaoNome => $composableBuilder(
    column: $table.galpaoNome,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataAlojamento => $composableBuilder(
    column: $table.dataAlojamento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataPrevistaAbate => $composableBuilder(
    column: $table.dataPrevistaAbate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get linhagem =>
      $composableBuilder(column: $table.linhagem, builder: (column) => column);

  GeneratedColumn<double> get pesoInicialG => $composableBuilder(
    column: $table.pesoInicialG,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dataFinalizacao => $composableBuilder(
    column: $table.dataFinalizacao,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesTable,
          Lote,
          $$LotesTableFilterComposer,
          $$LotesTableOrderingComposer,
          $$LotesTableAnnotationComposer,
          $$LotesTableCreateCompanionBuilder,
          $$LotesTableUpdateCompanionBuilder,
          (Lote, BaseReferences<_$AppDatabase, $LotesTable, Lote>),
          Lote,
          PrefetchHooks Function()
        > {
  $$LotesTableTableManager(_$AppDatabase db, $LotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> galpaoId = const Value.absent(),
                Value<String?> galpaoNome = const Value.absent(),
                Value<DateTime> dataAlojamento = const Value.absent(),
                Value<DateTime> dataPrevistaAbate = const Value.absent(),
                Value<int> quantidade = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> linhagem = const Value.absent(),
                Value<double> pesoInicialG = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dataFinalizacao = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LotesCompanion(
                id: id,
                serverId: serverId,
                usuarioId: usuarioId,
                galpaoId: galpaoId,
                galpaoNome: galpaoNome,
                dataAlojamento: dataAlojamento,
                dataPrevistaAbate: dataPrevistaAbate,
                quantidade: quantidade,
                tipo: tipo,
                linhagem: linhagem,
                pesoInicialG: pesoInicialG,
                status: status,
                dataFinalizacao: dataFinalizacao,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String usuarioId,
                required String galpaoId,
                Value<String?> galpaoNome = const Value.absent(),
                required DateTime dataAlojamento,
                required DateTime dataPrevistaAbate,
                required int quantidade,
                required String tipo,
                Value<String?> linhagem = const Value.absent(),
                required double pesoInicialG,
                Value<String> status = const Value.absent(),
                Value<DateTime?> dataFinalizacao = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => LotesCompanion.insert(
                id: id,
                serverId: serverId,
                usuarioId: usuarioId,
                galpaoId: galpaoId,
                galpaoNome: galpaoNome,
                dataAlojamento: dataAlojamento,
                dataPrevistaAbate: dataPrevistaAbate,
                quantidade: quantidade,
                tipo: tipo,
                linhagem: linhagem,
                pesoInicialG: pesoInicialG,
                status: status,
                dataFinalizacao: dataFinalizacao,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesTable,
      Lote,
      $$LotesTableFilterComposer,
      $$LotesTableOrderingComposer,
      $$LotesTableAnnotationComposer,
      $$LotesTableCreateCompanionBuilder,
      $$LotesTableUpdateCompanionBuilder,
      (Lote, BaseReferences<_$AppDatabase, $LotesTable, Lote>),
      Lote,
      PrefetchHooks Function()
    >;
typedef $$PesagensTableCreateCompanionBuilder =
    PesagensCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required DateTime data,
      required int quantidadeTotal,
      required double pesoTotal,
      required double pesoMedio,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PesagensTableUpdateCompanionBuilder =
    PesagensCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<DateTime> data,
      Value<int> quantidadeTotal,
      Value<double> pesoTotal,
      Value<double> pesoMedio,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$PesagensTableFilterComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidadeTotal => $composableBuilder(
    column: $table.quantidadeTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoTotal => $composableBuilder(
    column: $table.pesoTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoMedio => $composableBuilder(
    column: $table.pesoMedio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PesagensTableOrderingComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidadeTotal => $composableBuilder(
    column: $table.quantidadeTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoTotal => $composableBuilder(
    column: $table.pesoTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoMedio => $composableBuilder(
    column: $table.pesoMedio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PesagensTableAnnotationComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get quantidadeTotal => $composableBuilder(
    column: $table.quantidadeTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoTotal =>
      $composableBuilder(column: $table.pesoTotal, builder: (column) => column);

  GeneratedColumn<double> get pesoMedio =>
      $composableBuilder(column: $table.pesoMedio, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PesagensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PesagensTable,
          Pesagen,
          $$PesagensTableFilterComposer,
          $$PesagensTableOrderingComposer,
          $$PesagensTableAnnotationComposer,
          $$PesagensTableCreateCompanionBuilder,
          $$PesagensTableUpdateCompanionBuilder,
          (Pesagen, BaseReferences<_$AppDatabase, $PesagensTable, Pesagen>),
          Pesagen,
          PrefetchHooks Function()
        > {
  $$PesagensTableTableManager(_$AppDatabase db, $PesagensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesagensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesagensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesagensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> quantidadeTotal = const Value.absent(),
                Value<double> pesoTotal = const Value.absent(),
                Value<double> pesoMedio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PesagensCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeTotal: quantidadeTotal,
                pesoTotal: pesoTotal,
                pesoMedio: pesoMedio,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required DateTime data,
                required int quantidadeTotal,
                required double pesoTotal,
                required double pesoMedio,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PesagensCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeTotal: quantidadeTotal,
                pesoTotal: pesoTotal,
                pesoMedio: pesoMedio,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PesagensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PesagensTable,
      Pesagen,
      $$PesagensTableFilterComposer,
      $$PesagensTableOrderingComposer,
      $$PesagensTableAnnotationComposer,
      $$PesagensTableCreateCompanionBuilder,
      $$PesagensTableUpdateCompanionBuilder,
      (Pesagen, BaseReferences<_$AppDatabase, $PesagensTable, Pesagen>),
      Pesagen,
      PrefetchHooks Function()
    >;
typedef $$PesagemItemsTableCreateCompanionBuilder =
    PesagemItemsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String pesagemId,
      required int quantidade,
      required double peso,
      required double pesoMedio,
      required DateTime createdAt,
    });
typedef $$PesagemItemsTableUpdateCompanionBuilder =
    PesagemItemsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> pesagemId,
      Value<int> quantidade,
      Value<double> peso,
      Value<double> pesoMedio,
      Value<DateTime> createdAt,
    });

class $$PesagemItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PesagemItemsTable> {
  $$PesagemItemsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pesagemId => $composableBuilder(
    column: $table.pesagemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoMedio => $composableBuilder(
    column: $table.pesoMedio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PesagemItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PesagemItemsTable> {
  $$PesagemItemsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pesagemId => $composableBuilder(
    column: $table.pesagemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peso => $composableBuilder(
    column: $table.peso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoMedio => $composableBuilder(
    column: $table.pesoMedio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PesagemItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PesagemItemsTable> {
  $$PesagemItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get pesagemId =>
      $composableBuilder(column: $table.pesagemId, builder: (column) => column);

  GeneratedColumn<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<double> get pesoMedio =>
      $composableBuilder(column: $table.pesoMedio, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PesagemItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PesagemItemsTable,
          PesagemItem,
          $$PesagemItemsTableFilterComposer,
          $$PesagemItemsTableOrderingComposer,
          $$PesagemItemsTableAnnotationComposer,
          $$PesagemItemsTableCreateCompanionBuilder,
          $$PesagemItemsTableUpdateCompanionBuilder,
          (
            PesagemItem,
            BaseReferences<_$AppDatabase, $PesagemItemsTable, PesagemItem>,
          ),
          PesagemItem,
          PrefetchHooks Function()
        > {
  $$PesagemItemsTableTableManager(_$AppDatabase db, $PesagemItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesagemItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesagemItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesagemItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> pesagemId = const Value.absent(),
                Value<int> quantidade = const Value.absent(),
                Value<double> peso = const Value.absent(),
                Value<double> pesoMedio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PesagemItemsCompanion(
                id: id,
                serverId: serverId,
                pesagemId: pesagemId,
                quantidade: quantidade,
                peso: peso,
                pesoMedio: pesoMedio,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String pesagemId,
                required int quantidade,
                required double peso,
                required double pesoMedio,
                required DateTime createdAt,
              }) => PesagemItemsCompanion.insert(
                id: id,
                serverId: serverId,
                pesagemId: pesagemId,
                quantidade: quantidade,
                peso: peso,
                pesoMedio: pesoMedio,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PesagemItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PesagemItemsTable,
      PesagemItem,
      $$PesagemItemsTableFilterComposer,
      $$PesagemItemsTableOrderingComposer,
      $$PesagemItemsTableAnnotationComposer,
      $$PesagemItemsTableCreateCompanionBuilder,
      $$PesagemItemsTableUpdateCompanionBuilder,
      (
        PesagemItem,
        BaseReferences<_$AppDatabase, $PesagemItemsTable, PesagemItem>,
      ),
      PesagemItem,
      PrefetchHooks Function()
    >;
typedef $$MortalidadesTableCreateCompanionBuilder =
    MortalidadesCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required DateTime data,
      required int quantidade,
      required String causa,
      Value<String?> observacao,
      Value<String?> fotoUrl,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$MortalidadesTableUpdateCompanionBuilder =
    MortalidadesCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<DateTime> data,
      Value<int> quantidade,
      Value<String> causa,
      Value<String?> observacao,
      Value<String?> fotoUrl,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$MortalidadesTableFilterComposer
    extends Composer<_$AppDatabase, $MortalidadesTable> {
  $$MortalidadesTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get causa => $composableBuilder(
    column: $table.causa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MortalidadesTableOrderingComposer
    extends Composer<_$AppDatabase, $MortalidadesTable> {
  $$MortalidadesTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get causa => $composableBuilder(
    column: $table.causa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MortalidadesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MortalidadesTable> {
  $$MortalidadesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get causa =>
      $composableBuilder(column: $table.causa, builder: (column) => column);

  GeneratedColumn<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MortalidadesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MortalidadesTable,
          Mortalidade,
          $$MortalidadesTableFilterComposer,
          $$MortalidadesTableOrderingComposer,
          $$MortalidadesTableAnnotationComposer,
          $$MortalidadesTableCreateCompanionBuilder,
          $$MortalidadesTableUpdateCompanionBuilder,
          (
            Mortalidade,
            BaseReferences<_$AppDatabase, $MortalidadesTable, Mortalidade>,
          ),
          Mortalidade,
          PrefetchHooks Function()
        > {
  $$MortalidadesTableTableManager(_$AppDatabase db, $MortalidadesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MortalidadesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MortalidadesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MortalidadesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> quantidade = const Value.absent(),
                Value<String> causa = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MortalidadesCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidade: quantidade,
                causa: causa,
                observacao: observacao,
                fotoUrl: fotoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required DateTime data,
                required int quantidade,
                required String causa,
                Value<String?> observacao = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MortalidadesCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidade: quantidade,
                causa: causa,
                observacao: observacao,
                fotoUrl: fotoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MortalidadesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MortalidadesTable,
      Mortalidade,
      $$MortalidadesTableFilterComposer,
      $$MortalidadesTableOrderingComposer,
      $$MortalidadesTableAnnotationComposer,
      $$MortalidadesTableCreateCompanionBuilder,
      $$MortalidadesTableUpdateCompanionBuilder,
      (
        Mortalidade,
        BaseReferences<_$AppDatabase, $MortalidadesTable, Mortalidade>,
      ),
      Mortalidade,
      PrefetchHooks Function()
    >;
typedef $$FeedReceiptsTableCreateCompanionBuilder =
    FeedReceiptsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      Value<String?> tipoRacaoId,
      Value<String?> tipoRacaoNome,
      required double quantidadeKg,
      required DateTime dataRecebimento,
      Value<String?> fornecedor,
      Value<String?> loteRacao,
      Value<String> origem,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FeedReceiptsTableUpdateCompanionBuilder =
    FeedReceiptsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<String?> tipoRacaoId,
      Value<String?> tipoRacaoNome,
      Value<double> quantidadeKg,
      Value<DateTime> dataRecebimento,
      Value<String?> fornecedor,
      Value<String?> loteRacao,
      Value<String> origem,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FeedReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedReceiptsTable> {
  $$FeedReceiptsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoRacaoId => $composableBuilder(
    column: $table.tipoRacaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoRacaoNome => $composableBuilder(
    column: $table.tipoRacaoNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fornecedor => $composableBuilder(
    column: $table.fornecedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteRacao => $composableBuilder(
    column: $table.loteRacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedReceiptsTable> {
  $$FeedReceiptsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoRacaoId => $composableBuilder(
    column: $table.tipoRacaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoRacaoNome => $composableBuilder(
    column: $table.tipoRacaoNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fornecedor => $composableBuilder(
    column: $table.fornecedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteRacao => $composableBuilder(
    column: $table.loteRacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedReceiptsTable> {
  $$FeedReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get tipoRacaoId => $composableBuilder(
    column: $table.tipoRacaoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoRacaoNome => $composableBuilder(
    column: $table.tipoRacaoNome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataRecebimento => $composableBuilder(
    column: $table.dataRecebimento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fornecedor => $composableBuilder(
    column: $table.fornecedor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loteRacao =>
      $composableBuilder(column: $table.loteRacao, builder: (column) => column);

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeedReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedReceiptsTable,
          FeedReceipt,
          $$FeedReceiptsTableFilterComposer,
          $$FeedReceiptsTableOrderingComposer,
          $$FeedReceiptsTableAnnotationComposer,
          $$FeedReceiptsTableCreateCompanionBuilder,
          $$FeedReceiptsTableUpdateCompanionBuilder,
          (
            FeedReceipt,
            BaseReferences<_$AppDatabase, $FeedReceiptsTable, FeedReceipt>,
          ),
          FeedReceipt,
          PrefetchHooks Function()
        > {
  $$FeedReceiptsTableTableManager(_$AppDatabase db, $FeedReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<String?> tipoRacaoId = const Value.absent(),
                Value<String?> tipoRacaoNome = const Value.absent(),
                Value<double> quantidadeKg = const Value.absent(),
                Value<DateTime> dataRecebimento = const Value.absent(),
                Value<String?> fornecedor = const Value.absent(),
                Value<String?> loteRacao = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FeedReceiptsCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                tipoRacaoId: tipoRacaoId,
                tipoRacaoNome: tipoRacaoNome,
                quantidadeKg: quantidadeKg,
                dataRecebimento: dataRecebimento,
                fornecedor: fornecedor,
                loteRacao: loteRacao,
                origem: origem,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                Value<String?> tipoRacaoId = const Value.absent(),
                Value<String?> tipoRacaoNome = const Value.absent(),
                required double quantidadeKg,
                required DateTime dataRecebimento,
                Value<String?> fornecedor = const Value.absent(),
                Value<String?> loteRacao = const Value.absent(),
                Value<String> origem = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FeedReceiptsCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                tipoRacaoId: tipoRacaoId,
                tipoRacaoNome: tipoRacaoNome,
                quantidadeKg: quantidadeKg,
                dataRecebimento: dataRecebimento,
                fornecedor: fornecedor,
                loteRacao: loteRacao,
                origem: origem,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedReceiptsTable,
      FeedReceipt,
      $$FeedReceiptsTableFilterComposer,
      $$FeedReceiptsTableOrderingComposer,
      $$FeedReceiptsTableAnnotationComposer,
      $$FeedReceiptsTableCreateCompanionBuilder,
      $$FeedReceiptsTableUpdateCompanionBuilder,
      (
        FeedReceipt,
        BaseReferences<_$AppDatabase, $FeedReceiptsTable, FeedReceipt>,
      ),
      FeedReceipt,
      PrefetchHooks Function()
    >;
typedef $$FeedConsumptionsTableCreateCompanionBuilder =
    FeedConsumptionsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required DateTime data,
      required double quantidadeKg,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FeedConsumptionsTableUpdateCompanionBuilder =
    FeedConsumptionsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<DateTime> data,
      Value<double> quantidadeKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FeedConsumptionsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedConsumptionsTable> {
  $$FeedConsumptionsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedConsumptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedConsumptionsTable> {
  $$FeedConsumptionsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedConsumptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedConsumptionsTable> {
  $$FeedConsumptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<double> get quantidadeKg => $composableBuilder(
    column: $table.quantidadeKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeedConsumptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedConsumptionsTable,
          FeedConsumption,
          $$FeedConsumptionsTableFilterComposer,
          $$FeedConsumptionsTableOrderingComposer,
          $$FeedConsumptionsTableAnnotationComposer,
          $$FeedConsumptionsTableCreateCompanionBuilder,
          $$FeedConsumptionsTableUpdateCompanionBuilder,
          (
            FeedConsumption,
            BaseReferences<
              _$AppDatabase,
              $FeedConsumptionsTable,
              FeedConsumption
            >,
          ),
          FeedConsumption,
          PrefetchHooks Function()
        > {
  $$FeedConsumptionsTableTableManager(
    _$AppDatabase db,
    $FeedConsumptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedConsumptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedConsumptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedConsumptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<double> quantidadeKg = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FeedConsumptionsCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeKg: quantidadeKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required DateTime data,
                required double quantidadeKg,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FeedConsumptionsCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeKg: quantidadeKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedConsumptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedConsumptionsTable,
      FeedConsumption,
      $$FeedConsumptionsTableFilterComposer,
      $$FeedConsumptionsTableOrderingComposer,
      $$FeedConsumptionsTableAnnotationComposer,
      $$FeedConsumptionsTableCreateCompanionBuilder,
      $$FeedConsumptionsTableUpdateCompanionBuilder,
      (
        FeedConsumption,
        BaseReferences<_$AppDatabase, $FeedConsumptionsTable, FeedConsumption>,
      ),
      FeedConsumption,
      PrefetchHooks Function()
    >;
typedef $$WaterConsumptionsTableCreateCompanionBuilder =
    WaterConsumptionsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required DateTime data,
      required double quantidadeLitros,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WaterConsumptionsTableUpdateCompanionBuilder =
    WaterConsumptionsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<DateTime> data,
      Value<double> quantidadeLitros,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WaterConsumptionsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterConsumptionsTable> {
  $$WaterConsumptionsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeLitros => $composableBuilder(
    column: $table.quantidadeLitros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterConsumptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterConsumptionsTable> {
  $$WaterConsumptionsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeLitros => $composableBuilder(
    column: $table.quantidadeLitros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterConsumptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterConsumptionsTable> {
  $$WaterConsumptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<double> get quantidadeLitros => $composableBuilder(
    column: $table.quantidadeLitros,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WaterConsumptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterConsumptionsTable,
          WaterConsumption,
          $$WaterConsumptionsTableFilterComposer,
          $$WaterConsumptionsTableOrderingComposer,
          $$WaterConsumptionsTableAnnotationComposer,
          $$WaterConsumptionsTableCreateCompanionBuilder,
          $$WaterConsumptionsTableUpdateCompanionBuilder,
          (
            WaterConsumption,
            BaseReferences<
              _$AppDatabase,
              $WaterConsumptionsTable,
              WaterConsumption
            >,
          ),
          WaterConsumption,
          PrefetchHooks Function()
        > {
  $$WaterConsumptionsTableTableManager(
    _$AppDatabase db,
    $WaterConsumptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterConsumptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterConsumptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterConsumptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<double> quantidadeLitros = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WaterConsumptionsCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeLitros: quantidadeLitros,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required DateTime data,
                required double quantidadeLitros,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WaterConsumptionsCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                quantidadeLitros: quantidadeLitros,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterConsumptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterConsumptionsTable,
      WaterConsumption,
      $$WaterConsumptionsTableFilterComposer,
      $$WaterConsumptionsTableOrderingComposer,
      $$WaterConsumptionsTableAnnotationComposer,
      $$WaterConsumptionsTableCreateCompanionBuilder,
      $$WaterConsumptionsTableUpdateCompanionBuilder,
      (
        WaterConsumption,
        BaseReferences<
          _$AppDatabase,
          $WaterConsumptionsTable,
          WaterConsumption
        >,
      ),
      WaterConsumption,
      PrefetchHooks Function()
    >;
typedef $$ChecklistsTableCreateCompanionBuilder =
    ChecklistsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required DateTime data,
      required String itensJson,
      Value<bool> completado,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ChecklistsTableUpdateCompanionBuilder =
    ChecklistsCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<DateTime> data,
      Value<String> itensJson,
      Value<bool> completado,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ChecklistsTableFilterComposer
    extends Composer<_$AppDatabase, $ChecklistsTable> {
  $$ChecklistsTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itensJson => $composableBuilder(
    column: $table.itensJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChecklistsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChecklistsTable> {
  $$ChecklistsTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itensJson => $composableBuilder(
    column: $table.itensJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChecklistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChecklistsTable> {
  $$ChecklistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get itensJson =>
      $composableBuilder(column: $table.itensJson, builder: (column) => column);

  GeneratedColumn<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChecklistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChecklistsTable,
          Checklist,
          $$ChecklistsTableFilterComposer,
          $$ChecklistsTableOrderingComposer,
          $$ChecklistsTableAnnotationComposer,
          $$ChecklistsTableCreateCompanionBuilder,
          $$ChecklistsTableUpdateCompanionBuilder,
          (
            Checklist,
            BaseReferences<_$AppDatabase, $ChecklistsTable, Checklist>,
          ),
          Checklist,
          PrefetchHooks Function()
        > {
  $$ChecklistsTableTableManager(_$AppDatabase db, $ChecklistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String> itensJson = const Value.absent(),
                Value<bool> completado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ChecklistsCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                itensJson: itensJson,
                completado: completado,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required DateTime data,
                required String itensJson,
                Value<bool> completado = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ChecklistsCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                data: data,
                itensJson: itensJson,
                completado: completado,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChecklistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChecklistsTable,
      Checklist,
      $$ChecklistsTableFilterComposer,
      $$ChecklistsTableOrderingComposer,
      $$ChecklistsTableAnnotationComposer,
      $$ChecklistsTableCreateCompanionBuilder,
      $$ChecklistsTableUpdateCompanionBuilder,
      (Checklist, BaseReferences<_$AppDatabase, $ChecklistsTable, Checklist>),
      Checklist,
      PrefetchHooks Function()
    >;
typedef $$MensagensTableCreateCompanionBuilder =
    MensagensCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String loteId,
      required String remetenteId,
      Value<String?> remetenteNome,
      required String tipo,
      Value<String?> conteudo,
      Value<String?> midiaUrl,
      Value<String?> midiaThumbnailUrl,
      Value<bool> lida,
      required DateTime createdAt,
    });
typedef $$MensagensTableUpdateCompanionBuilder =
    MensagensCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> loteId,
      Value<String> remetenteId,
      Value<String?> remetenteNome,
      Value<String> tipo,
      Value<String?> conteudo,
      Value<String?> midiaUrl,
      Value<String?> midiaThumbnailUrl,
      Value<bool> lida,
      Value<DateTime> createdAt,
    });

class $$MensagensTableFilterComposer
    extends Composer<_$AppDatabase, $MensagensTable> {
  $$MensagensTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remetenteId => $composableBuilder(
    column: $table.remetenteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remetenteNome => $composableBuilder(
    column: $table.remetenteNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conteudo => $composableBuilder(
    column: $table.conteudo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get midiaUrl => $composableBuilder(
    column: $table.midiaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get midiaThumbnailUrl => $composableBuilder(
    column: $table.midiaThumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lida => $composableBuilder(
    column: $table.lida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MensagensTableOrderingComposer
    extends Composer<_$AppDatabase, $MensagensTable> {
  $$MensagensTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remetenteId => $composableBuilder(
    column: $table.remetenteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remetenteNome => $composableBuilder(
    column: $table.remetenteNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conteudo => $composableBuilder(
    column: $table.conteudo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get midiaUrl => $composableBuilder(
    column: $table.midiaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get midiaThumbnailUrl => $composableBuilder(
    column: $table.midiaThumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lida => $composableBuilder(
    column: $table.lida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MensagensTableAnnotationComposer
    extends Composer<_$AppDatabase, $MensagensTable> {
  $$MensagensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get remetenteId => $composableBuilder(
    column: $table.remetenteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remetenteNome => $composableBuilder(
    column: $table.remetenteNome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get conteudo =>
      $composableBuilder(column: $table.conteudo, builder: (column) => column);

  GeneratedColumn<String> get midiaUrl =>
      $composableBuilder(column: $table.midiaUrl, builder: (column) => column);

  GeneratedColumn<String> get midiaThumbnailUrl => $composableBuilder(
    column: $table.midiaThumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lida =>
      $composableBuilder(column: $table.lida, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MensagensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MensagensTable,
          Mensagen,
          $$MensagensTableFilterComposer,
          $$MensagensTableOrderingComposer,
          $$MensagensTableAnnotationComposer,
          $$MensagensTableCreateCompanionBuilder,
          $$MensagensTableUpdateCompanionBuilder,
          (Mensagen, BaseReferences<_$AppDatabase, $MensagensTable, Mensagen>),
          Mensagen,
          PrefetchHooks Function()
        > {
  $$MensagensTableTableManager(_$AppDatabase db, $MensagensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MensagensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MensagensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MensagensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<String> remetenteId = const Value.absent(),
                Value<String?> remetenteNome = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> conteudo = const Value.absent(),
                Value<String?> midiaUrl = const Value.absent(),
                Value<String?> midiaThumbnailUrl = const Value.absent(),
                Value<bool> lida = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MensagensCompanion(
                id: id,
                serverId: serverId,
                loteId: loteId,
                remetenteId: remetenteId,
                remetenteNome: remetenteNome,
                tipo: tipo,
                conteudo: conteudo,
                midiaUrl: midiaUrl,
                midiaThumbnailUrl: midiaThumbnailUrl,
                lida: lida,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String loteId,
                required String remetenteId,
                Value<String?> remetenteNome = const Value.absent(),
                required String tipo,
                Value<String?> conteudo = const Value.absent(),
                Value<String?> midiaUrl = const Value.absent(),
                Value<String?> midiaThumbnailUrl = const Value.absent(),
                Value<bool> lida = const Value.absent(),
                required DateTime createdAt,
              }) => MensagensCompanion.insert(
                id: id,
                serverId: serverId,
                loteId: loteId,
                remetenteId: remetenteId,
                remetenteNome: remetenteNome,
                tipo: tipo,
                conteudo: conteudo,
                midiaUrl: midiaUrl,
                midiaThumbnailUrl: midiaThumbnailUrl,
                lida: lida,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MensagensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MensagensTable,
      Mensagen,
      $$MensagensTableFilterComposer,
      $$MensagensTableOrderingComposer,
      $$MensagensTableAnnotationComposer,
      $$MensagensTableCreateCompanionBuilder,
      $$MensagensTableUpdateCompanionBuilder,
      (Mensagen, BaseReferences<_$AppDatabase, $MensagensTable, Mensagen>),
      Mensagen,
      PrefetchHooks Function()
    >;
typedef $$GalpaosTableCreateCompanionBuilder =
    GalpaosCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String usuarioId,
      required String nome,
      required int capacidade,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> orientacaoGraus,
      Value<double?> comprimentoM,
      Value<double?> larguraM,
      Value<String?> tipoVentilacao,
      Value<String?> ladoCortinas,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$GalpaosTableUpdateCompanionBuilder =
    GalpaosCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> usuarioId,
      Value<String> nome,
      Value<int> capacidade,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> orientacaoGraus,
      Value<double?> comprimentoM,
      Value<double?> larguraM,
      Value<String?> tipoVentilacao,
      Value<String?> ladoCortinas,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$GalpaosTableFilterComposer
    extends Composer<_$AppDatabase, $GalpaosTable> {
  $$GalpaosTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacidade => $composableBuilder(
    column: $table.capacidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get orientacaoGraus => $composableBuilder(
    column: $table.orientacaoGraus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get comprimentoM => $composableBuilder(
    column: $table.comprimentoM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get larguraM => $composableBuilder(
    column: $table.larguraM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoVentilacao => $composableBuilder(
    column: $table.tipoVentilacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ladoCortinas => $composableBuilder(
    column: $table.ladoCortinas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GalpaosTableOrderingComposer
    extends Composer<_$AppDatabase, $GalpaosTable> {
  $$GalpaosTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacidade => $composableBuilder(
    column: $table.capacidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get orientacaoGraus => $composableBuilder(
    column: $table.orientacaoGraus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get comprimentoM => $composableBuilder(
    column: $table.comprimentoM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get larguraM => $composableBuilder(
    column: $table.larguraM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoVentilacao => $composableBuilder(
    column: $table.tipoVentilacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ladoCortinas => $composableBuilder(
    column: $table.ladoCortinas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GalpaosTableAnnotationComposer
    extends Composer<_$AppDatabase, $GalpaosTable> {
  $$GalpaosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get capacidade => $composableBuilder(
    column: $table.capacidade,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get orientacaoGraus => $composableBuilder(
    column: $table.orientacaoGraus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get comprimentoM => $composableBuilder(
    column: $table.comprimentoM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get larguraM =>
      $composableBuilder(column: $table.larguraM, builder: (column) => column);

  GeneratedColumn<String> get tipoVentilacao => $composableBuilder(
    column: $table.tipoVentilacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ladoCortinas => $composableBuilder(
    column: $table.ladoCortinas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GalpaosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GalpaosTable,
          Galpao,
          $$GalpaosTableFilterComposer,
          $$GalpaosTableOrderingComposer,
          $$GalpaosTableAnnotationComposer,
          $$GalpaosTableCreateCompanionBuilder,
          $$GalpaosTableUpdateCompanionBuilder,
          (Galpao, BaseReferences<_$AppDatabase, $GalpaosTable, Galpao>),
          Galpao,
          PrefetchHooks Function()
        > {
  $$GalpaosTableTableManager(_$AppDatabase db, $GalpaosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GalpaosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GalpaosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GalpaosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> capacidade = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> orientacaoGraus = const Value.absent(),
                Value<double?> comprimentoM = const Value.absent(),
                Value<double?> larguraM = const Value.absent(),
                Value<String?> tipoVentilacao = const Value.absent(),
                Value<String?> ladoCortinas = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => GalpaosCompanion(
                id: id,
                serverId: serverId,
                usuarioId: usuarioId,
                nome: nome,
                capacidade: capacidade,
                latitude: latitude,
                longitude: longitude,
                orientacaoGraus: orientacaoGraus,
                comprimentoM: comprimentoM,
                larguraM: larguraM,
                tipoVentilacao: tipoVentilacao,
                ladoCortinas: ladoCortinas,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String usuarioId,
                required String nome,
                required int capacidade,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> orientacaoGraus = const Value.absent(),
                Value<double?> comprimentoM = const Value.absent(),
                Value<double?> larguraM = const Value.absent(),
                Value<String?> tipoVentilacao = const Value.absent(),
                Value<String?> ladoCortinas = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => GalpaosCompanion.insert(
                id: id,
                serverId: serverId,
                usuarioId: usuarioId,
                nome: nome,
                capacidade: capacidade,
                latitude: latitude,
                longitude: longitude,
                orientacaoGraus: orientacaoGraus,
                comprimentoM: comprimentoM,
                larguraM: larguraM,
                tipoVentilacao: tipoVentilacao,
                ladoCortinas: ladoCortinas,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GalpaosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GalpaosTable,
      Galpao,
      $$GalpaosTableFilterComposer,
      $$GalpaosTableOrderingComposer,
      $$GalpaosTableAnnotationComposer,
      $$GalpaosTableCreateCompanionBuilder,
      $$GalpaosTableUpdateCompanionBuilder,
      (Galpao, BaseReferences<_$AppDatabase, $GalpaosTable, Galpao>),
      Galpao,
      PrefetchHooks Function()
    >;
typedef $$BenchmarksLinhagemTableCreateCompanionBuilder =
    BenchmarksLinhagemCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      required String linhagem,
      required int dia,
      required double pesoG,
      Value<double?> consumoAcumG,
      Value<double?> ca,
      Value<double?> gpdG,
    });
typedef $$BenchmarksLinhagemTableUpdateCompanionBuilder =
    BenchmarksLinhagemCompanion Function({
      Value<int> id,
      Value<String?> serverId,
      Value<String> linhagem,
      Value<int> dia,
      Value<double> pesoG,
      Value<double?> consumoAcumG,
      Value<double?> ca,
      Value<double?> gpdG,
    });

class $$BenchmarksLinhagemTableFilterComposer
    extends Composer<_$AppDatabase, $BenchmarksLinhagemTable> {
  $$BenchmarksLinhagemTableFilterComposer({
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

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linhagem => $composableBuilder(
    column: $table.linhagem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoG => $composableBuilder(
    column: $table.pesoG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumoAcumG => $composableBuilder(
    column: $table.consumoAcumG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ca => $composableBuilder(
    column: $table.ca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpdG => $composableBuilder(
    column: $table.gpdG,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BenchmarksLinhagemTableOrderingComposer
    extends Composer<_$AppDatabase, $BenchmarksLinhagemTable> {
  $$BenchmarksLinhagemTableOrderingComposer({
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

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linhagem => $composableBuilder(
    column: $table.linhagem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoG => $composableBuilder(
    column: $table.pesoG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumoAcumG => $composableBuilder(
    column: $table.consumoAcumG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ca => $composableBuilder(
    column: $table.ca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpdG => $composableBuilder(
    column: $table.gpdG,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BenchmarksLinhagemTableAnnotationComposer
    extends Composer<_$AppDatabase, $BenchmarksLinhagemTable> {
  $$BenchmarksLinhagemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get linhagem =>
      $composableBuilder(column: $table.linhagem, builder: (column) => column);

  GeneratedColumn<int> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<double> get pesoG =>
      $composableBuilder(column: $table.pesoG, builder: (column) => column);

  GeneratedColumn<double> get consumoAcumG => $composableBuilder(
    column: $table.consumoAcumG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ca =>
      $composableBuilder(column: $table.ca, builder: (column) => column);

  GeneratedColumn<double> get gpdG =>
      $composableBuilder(column: $table.gpdG, builder: (column) => column);
}

class $$BenchmarksLinhagemTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BenchmarksLinhagemTable,
          BenchmarksLinhagemData,
          $$BenchmarksLinhagemTableFilterComposer,
          $$BenchmarksLinhagemTableOrderingComposer,
          $$BenchmarksLinhagemTableAnnotationComposer,
          $$BenchmarksLinhagemTableCreateCompanionBuilder,
          $$BenchmarksLinhagemTableUpdateCompanionBuilder,
          (
            BenchmarksLinhagemData,
            BaseReferences<
              _$AppDatabase,
              $BenchmarksLinhagemTable,
              BenchmarksLinhagemData
            >,
          ),
          BenchmarksLinhagemData,
          PrefetchHooks Function()
        > {
  $$BenchmarksLinhagemTableTableManager(
    _$AppDatabase db,
    $BenchmarksLinhagemTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BenchmarksLinhagemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BenchmarksLinhagemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BenchmarksLinhagemTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> linhagem = const Value.absent(),
                Value<int> dia = const Value.absent(),
                Value<double> pesoG = const Value.absent(),
                Value<double?> consumoAcumG = const Value.absent(),
                Value<double?> ca = const Value.absent(),
                Value<double?> gpdG = const Value.absent(),
              }) => BenchmarksLinhagemCompanion(
                id: id,
                serverId: serverId,
                linhagem: linhagem,
                dia: dia,
                pesoG: pesoG,
                consumoAcumG: consumoAcumG,
                ca: ca,
                gpdG: gpdG,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required String linhagem,
                required int dia,
                required double pesoG,
                Value<double?> consumoAcumG = const Value.absent(),
                Value<double?> ca = const Value.absent(),
                Value<double?> gpdG = const Value.absent(),
              }) => BenchmarksLinhagemCompanion.insert(
                id: id,
                serverId: serverId,
                linhagem: linhagem,
                dia: dia,
                pesoG: pesoG,
                consumoAcumG: consumoAcumG,
                ca: ca,
                gpdG: gpdG,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BenchmarksLinhagemTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BenchmarksLinhagemTable,
      BenchmarksLinhagemData,
      $$BenchmarksLinhagemTableFilterComposer,
      $$BenchmarksLinhagemTableOrderingComposer,
      $$BenchmarksLinhagemTableAnnotationComposer,
      $$BenchmarksLinhagemTableCreateCompanionBuilder,
      $$BenchmarksLinhagemTableUpdateCompanionBuilder,
      (
        BenchmarksLinhagemData,
        BaseReferences<
          _$AppDatabase,
          $BenchmarksLinhagemTable,
          BenchmarksLinhagemData
        >,
      ),
      BenchmarksLinhagemData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      required String method,
      required String url,
      Value<String?> dataJson,
      required DateTime createdAt,
      Value<String> status,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      Value<String> method,
      Value<String> url,
      Value<String?> dataJson,
      Value<DateTime> createdAt,
      Value<String> status,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
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

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueEntry,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueEntriesTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> dataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                id: id,
                method: method,
                url: url,
                dataJson: dataJson,
                createdAt: createdAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String method,
                required String url,
                Value<String?> dataJson = const Value.absent(),
                required DateTime createdAt,
                Value<String> status = const Value.absent(),
              }) => SyncQueueEntriesCompanion.insert(
                id: id,
                method: method,
                url: url,
                dataJson: dataJson,
                createdAt: createdAt,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueEntry,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db, _db.lotes);
  $$PesagensTableTableManager get pesagens =>
      $$PesagensTableTableManager(_db, _db.pesagens);
  $$PesagemItemsTableTableManager get pesagemItems =>
      $$PesagemItemsTableTableManager(_db, _db.pesagemItems);
  $$MortalidadesTableTableManager get mortalidades =>
      $$MortalidadesTableTableManager(_db, _db.mortalidades);
  $$FeedReceiptsTableTableManager get feedReceipts =>
      $$FeedReceiptsTableTableManager(_db, _db.feedReceipts);
  $$FeedConsumptionsTableTableManager get feedConsumptions =>
      $$FeedConsumptionsTableTableManager(_db, _db.feedConsumptions);
  $$WaterConsumptionsTableTableManager get waterConsumptions =>
      $$WaterConsumptionsTableTableManager(_db, _db.waterConsumptions);
  $$ChecklistsTableTableManager get checklists =>
      $$ChecklistsTableTableManager(_db, _db.checklists);
  $$MensagensTableTableManager get mensagens =>
      $$MensagensTableTableManager(_db, _db.mensagens);
  $$GalpaosTableTableManager get galpaos =>
      $$GalpaosTableTableManager(_db, _db.galpaos);
  $$BenchmarksLinhagemTableTableManager get benchmarksLinhagem =>
      $$BenchmarksLinhagemTableTableManager(_db, _db.benchmarksLinhagem);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
}
