class CounterItem {
  String name;
  int count;

  CounterItem({required this.name, this.count = 0});

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
      };

  static CounterItem fromJson(Map<String, dynamic> json) => CounterItem(
        name: json['name'],
        count: json['count'],
      );
}
