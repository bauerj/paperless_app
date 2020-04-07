import 'dart:async';
import 'dart:convert';
import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

@JsonSerializable()
class Correspondent {
  Correspondent();
  int id;
  String name;

  factory Correspondent.fromJson(Map<String, dynamic> json) => _$CorrespondentFromJson(json);
}

@JsonSerializable()
class Tag {
  Tag();
  int id;
  String name;
  int colour;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

}

@JsonSerializable(fieldRename: FieldRename.snake)
class Document {
  Document();
  int id;
  String correspondent;
  String title;
  String content;
  List<String> tags;
  String checksum;
  DateTime created;
  DateTime modified;
  String fileName;
  String thumbnailUrl;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}

@JsonSerializable()
class ResponseList<T> {
  ResponseList();
  int count;
  String next;
  @_Converter()
  List<T> results;

  factory ResponseList.fromJson(Map<String, dynamic> json) => _$ResponseListFromJson(json);

  bool hasMoreData() {
    return next != null;
  }

  Future<ResponseList<T>> getNext() async {
    var json = await API.instance.get(next, isFullUrl: true);
    return ResponseList<T>.fromJson(json);
  }

}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    if (json is Map<String, dynamic> &&
        json.containsKey('checksum')) {
      return Document.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> &&
        json.containsKey('colour')) {
      return Tag.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> &&
        json.containsKey('name')) {
      return Correspondent.fromJson(json) as T;
    }
    // This will only work if `json` is a native JSON type:
    //   num, String, bool, null, etc
    // *and* is assignable to `T`.
    return json as T;
  }

  @override
  Object toJson(T object) {
    // This will only work if `object` is a native JSON type:
    //   num, String, bool, null, etc
    // Or if it has a `toJson()` function`.
    return object;
  }
}

class AuthClient extends http.BaseClient{
  http.Client _httpClient = new http.Client();
  String _username;
  String _password;

  AuthClient(this._username, this._password);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll({"Authorization": getAuthString()});
    return _httpClient.send(request);
  }

  String getAuthString() {
    final token = base64.encode(latin1.encode('$_username:$_password'));
    final authstr = 'Basic ' + token.trim();
    return authstr;
  }
}


class API {
  static API instance;
  String baseURL;
  String username;
  String password;
  AuthClient client;

  API(String baseURL, {this.username="", this.password=""}) {
    client = AuthClient(username, password);

    if (!baseURL.startsWith("http://") && !baseURL.startsWith("https://"))
      baseURL = "https://" + baseURL;
    this.baseURL = baseURL;
    instance = this;
  }

  Future<bool> testConnection() async {
    var response = await http.get(baseURL + "/api/");
    return (response.statusCode == 200 && response.body.contains("{"));
  }

  Future<bool> checkCredentials() async {
    var response = await client.get(baseURL + "/api/documents/");
    return (response.statusCode == 200);
  }

  Future<Map<String, dynamic>> get(String context, {isFullUrl = false}) async {
    String url = isFullUrl ? context : baseURL + "/api/" + context + "/?format=json";
    if (!url.startsWith(baseURL)) {
      // Try to repair
      url = baseURL + "/api/" + url.split("/api/")[1];
    }
    var response = await client.get(url);
    return jsonDecode(response.body);
  }

  Future<ResponseList<Document>> getDocuments() async {
    var json = await get("documents");
    return ResponseList<Document>.fromJson(json);
  }

  Future<ResponseList<Correspondent>> getCorrespondents() async {
    var json = await get("correspondents");
    return ResponseList<Correspondent>.fromJson(json);
  }

  Future<ResponseList<Tag>> getTags() async {
    var json = await get("tags");
    return ResponseList<Tag>.fromJson(json);
  }

}