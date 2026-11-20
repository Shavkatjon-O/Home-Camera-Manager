// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisations_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _OrganisationsClient extends OrganisationsClient {
  _OrganisationsClient._(
    this._dio,
    Dio _transport, {
    this.baseUrl,
    this.errorLogger,
  }) : super._(_transport);

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<OrganisationList> listOrganisations({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<OrganisationList>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/organisations',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late OrganisationList _value;
    try {
      _value = OrganisationList.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<OrganisationRead> createOrganisation({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required OrganisationCreate body,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Accept': 'application/json',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<OrganisationRead>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
          )
          .compose(
            _dio.options,
            '/api/v1/organisations',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late OrganisationRead _value;
    try {
      _value = OrganisationRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FacesConsent> getFacesConsent({
    Map<String, Object?> extra = const {},
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FacesConsent>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/organisations/faces-consent',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late FacesConsent _value;
    try {
      _value = FacesConsent.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<OrganisationRead> getOrganisation({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String organisation,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<OrganisationRead>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/organisations/${organisation}',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late OrganisationRead _value;
    try {
      _value = OrganisationRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> deleteOrganisation({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String organisation,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/organisations/${organisation}',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<OrganisationRead> updateOrganisation({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String organisation,
    required OrganisationUpdate body,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Accept': 'application/json',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<OrganisationRead>(
      Options(
            method: 'PATCH',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
          )
          .compose(
            _dio.options,
            '/api/v1/organisations/${organisation}',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late OrganisationRead _value;
    try {
      _value = OrganisationRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<OrganisationRead> transferOwnership({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"APIKeyCookie": []},
        {"HTTPBearer": []},
      ],
      "openapi.securitySchemes": {
        "APIKeyCookie": {
          "type": "apiKey",
          "name": "sss_session",
          "in": "cookie",
        },
        "HTTPBearer": {"type": "http", "scheme": "bearer"},
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String organisation,
    required OwnershipTransfer body,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Accept': 'application/json',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<OrganisationRead>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
          )
          .compose(
            _dio.options,
            '/api/v1/organisations/${organisation}/transfer',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late OrganisationRead _value;
    try {
      _value = OrganisationRead.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
