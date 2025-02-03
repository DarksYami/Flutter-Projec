enum CartState { pending, completed }

class Cart {
  final int? id;
  final int userId;
  final int giftId;
  final int quantity;
  final CartState state;

  Cart({
    this.id,
    required this.userId,
    required this.giftId,
    required this.quantity,
    this.state = CartState.pending,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      giftId: json['gift_id'],
      quantity: json['quantity'],
      state: CartState.values.firstWhere(
        (e) => e.toString().split('.').last == json['state'],
        orElse: () => CartState.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gift_id': giftId,
      'quantity': quantity,
      'state': state.toString().split('.').last,
    };
  }
}