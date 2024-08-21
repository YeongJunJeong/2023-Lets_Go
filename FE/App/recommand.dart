class RecommandAPI {
  int? id;
  String? name;
  String? image;
  String? classification;
  bool? parking;
  String? info;
  String? call;
  List<String>? tag;
  String? time;

  RecommandAPI({
    this.id,
    this.name,
    this.image,
    this.classification,
    this.parking,
    this.info,
    this.call,
    this.tag,
    this.time,
  });

  factory RecommandAPI.fromJson(Map<String, dynamic> json) {
    return RecommandAPI(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      classification: json['classification'],
      parking: json['parking'],
      info: json['info'],
      call: json['call'],
      tag: List<String>.from(json['tag'].map((tag) => tag.toString())),
      time: json['time'],
    );
  }
  @override
  String toString() {
    return 'RecommandAPI(id: $id, name: $name, image: $image, classification: $classification, parking: $parking, info: $info, call: $call, tag: $tag, time: $time)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'classification': classification,
      'parking': parking,
      'info': info,
      'call': call,
      'tag': tag,
      'time': time,
    };
  }
}
