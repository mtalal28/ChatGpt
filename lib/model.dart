class Model{
  final String id;
  final String created;
  final String root;

  Model(
  {
    required this.id,
    required this.created,
    required this.root,
  }
      );

  factory Model.fromJson(Map<String, dynamic> json )=> Model(
    id: json["id"],
    root: json["root"],
    created: json["created"].toString(),  );

  static List<Model> modelFromSnapshot(List modelSnapshot)
  {
    return modelSnapshot.map((data)=> Model.fromJson(data)).toList();

  }

}