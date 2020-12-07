import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

@JsonSerializable()
class Correspondent {
  Correspondent();
  int id;
  String name;

  factory Correspondent.fromJson(Map<String, dynamic> json) =>
      _$CorrespondentFromJson(json);
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
  int correspondent;
  String title;
  String content;
  List<int> tags;
  String checksum;
  DateTime created;
  DateTime modified;
  String fileName;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  String getThumbnailUrl() {
    return "${API.instance.baseURL}/fetch/thumb/$id";
  }

  String getDownloadUrl() {
    return "${API.instance.baseURL}/fetch/doc/$id";
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OgDocument extends Document {
  OgDocument();

  static int _idFromUrl(String url) {
    return url == null ? null : _idsFromUrls([url])[0];
  }

  static List<int> _idsFromUrls(List<dynamic> urls) {
    List<int> ids = new List();
    for (String url in urls) {
      var parts = url.split("/");
      ids.add(int.parse(parts[parts.length - 2]));
    }
    return ids;
  }

  @JsonKey(fromJson: _idFromUrl)
  int correspondent;
  @JsonKey(fromJson: _idsFromUrls)
  List<int> tags;

  factory OgDocument.fromJson(Map<String, dynamic> json) =>
      _$OgDocumentFromJson(json);
}

@JsonSerializable()
class ResponseList<T> {
  ResponseList();
  int count;
  String next;
  @_Converter()
  List<T> results;

  factory ResponseList.fromJson(Map<String, dynamic> json) =>
      _$ResponseListFromJson(json);

  bool hasMoreData() {
    return next != null;
  }

  Future<ResponseList<T>> getNext() async {
    var json = await API.instance.get(next);
    return ResponseList<T>.fromJson(json);
  }
}

class _Converter<T> implements JsonConverter<T, Object> {
  const _Converter();

  @override
  T fromJson(Object json) {
    if (json is Map<String, dynamic> && json.containsKey('colour')) {
      return Tag.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> && json.containsKey('name')) {
      return Correspondent.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> &&
        json.containsKey('correspondent') &&
        !json.containsKey("thumbnail_url")) {
      return Document.fromJson(json) as T;
    }
    if (json is Map<String, dynamic> &&
        json.containsKey('correspondent')) {
      return OgDocument.fromJson(json) as T;
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

class API {
  static API instance;
  String baseURL;
  String username;
  String password;
  String authString;
  final Dio dio = new Dio();

  API(String baseURL, {this.username = "", this.password = ""}) {
    authString = getAuthString(username, password);
    dio.options.headers.addAll({"Authorization": authString});

    if (!baseURL.startsWith("http://") && !baseURL.startsWith("https://"))
      baseURL = "https://" + baseURL;
    this.baseURL = baseURL;
    instance = this;
  }

  String getAuthString(String username, String password) {
    final token = base64.encode(latin1.encode('$username:$password'));
    final authstr = 'Basic ' + token.trim();
    return authstr;
  }

  Future<bool> testConnection() async {
    var response = await new Dio().get(baseURL + "/api/");
    return (response.statusCode == 200);
  }

  Future<bool> checkCredentials() async {
    var response = await dio.get(baseURL + "/api/documents/");
    return (response.statusCode == 200);
  }

  String getFullURL(String url) {
    if (url.startsWith("/")) {
      return baseURL + url;
    }
    if (!url.startsWith(baseURL) && url.contains("/api/")) {
      // Try to repair
      return baseURL + "/api/" + url.split("/api/")[1];
    }
    return url;
  }

  Future<Map<String, dynamic>> getAPIResource(String resourceType,
      {String ordering, String search}) async {
    String url = "/api/" + resourceType + "/?format=json";
    print(url);
    if (ordering != null) {
      url += "&ordering=" + ordering;
    }
    if (search != null) {
      url += "&search=" + search;
    }
    return await get(url);
  }

  Future<Map<String, dynamic>> get(String url) async {
    url = getFullURL(url);
    var response = await dio.get(url);
    return response.data;
  }

  Future<ResponseList<Document>> getDocuments(
      {String ordering = "-created", String search}) async {
    var json =
        await getAPIResource("documents", ordering: ordering, search: search);
    return ResponseList<Document>.fromJson(json);
  }

  Future<ResponseList<Correspondent>> getCorrespondents() async {
    var json = await getAPIResource("correspondents");
    return ResponseList<Correspondent>.fromJson(json);
  }

  Future<ResponseList<Tag>> getTags() async {
    var json = await getAPIResource("tags");
    return ResponseList<Tag>.fromJson(json);
  }

  Future<void> downloadFile(String url, String savePath,
      {ProgressCallback onReceiveProgress}) async {
    url = getFullURL(url);
    await dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
  }

  Future<void> uploadFile(String path) async {
    FormData formData =
        new FormData.fromMap({"document": await MultipartFile.fromFile(path)});
    try {
      await dio.post(getFullURL("/push"), data: formData);
    } catch (e) {
      print(e.toString());
    }
  }
}
