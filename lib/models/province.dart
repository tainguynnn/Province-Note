
class Province {
  final int? id;
  final String?  provinceName;
  final String?  city;
  final String?  licensePlate;
  final String? createdAt;

  Province({this.id, this. provinceName, this. city,this.licensePlate, this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      ' provinceName': provinceName,
      ' city':  city,
      'licensePlate': licensePlate
    };
  }
}
