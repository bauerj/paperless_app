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
  int correspondent;
  String title;
  String content;
  List<int> tags;
  String checksum;
  DateTime created;
  DateTime added;
  String fileName;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}

class API {
  http_auth.BasicAuthClient client;
  String baseURL;

  API(String baseURL, {username="", password=""}) {
    client = http_auth.BasicAuthClient(username, password);

    if (!baseURL.startsWith("http://") && !baseURL.startsWith("https://"))
      baseURL = "https://" + baseURL;
    this.baseURL = baseURL;
  }

  Future<bool> testConnection() async {
    var response = await http.get(baseURL + "/api/");
    return (response.statusCode == 200 && response.body.contains("{"));
  }

  Future<bool> checkCredentials() async {
    var response = await client.get(baseURL + "/api/documents/");
    return (response.statusCode == 200);
  }

}