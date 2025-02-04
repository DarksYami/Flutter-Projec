class Gift {
  final String? id;
  final String name;
  final String image;
  final double price;
  final String category;
  final int? quantity;

  Gift({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.quantity,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'], 
      name: json['name'], // Ensure this is a String
      image: json['image'], // Ensure this is a String
      price: double.parse(json['price'].toString()), // Ensure this is a double
      category: json['category'], // Ensure this is a String
      quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : null, // Ensure this is an int or null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
      'category': category
    };
  }
}