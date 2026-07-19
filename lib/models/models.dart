class AppUser {
  const AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.role});
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: (map['phone'] as String?) ?? '',
        role: map['role'] as String,
      );
}

class Pet {
  const Pet(
      {this.id,
      required this.ownerId,
      required this.name,
      required this.species,
      required this.breed,
      required this.gender,
      required this.age,
      required this.weight,
      this.photo = ''});
  final int? id;
  final int ownerId;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final int age;
  final double weight;
  final String photo;

  Map<String, Object?> toMap() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'species': species,
        'breed': breed,
        'gender': gender,
        'age': age,
        'weight': weight,
        'photo': photo
      };
  factory Pet.fromMap(Map<String, Object?> map) => Pet(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      name: map['name'] as String,
      species: map['species'] as String,
      breed: (map['breed'] as String?) ?? '',
      gender: (map['gender'] as String?) ?? '',
      age: (map['age'] as int?) ?? 0,
      weight: ((map['weight'] as num?) ?? 0).toDouble(),
      photo: (map['photo'] as String?) ?? '');
}

class Doctor {
  const Doctor(
      {required this.id,
      required this.userId,
      required this.name,
      required this.email,
      required this.specialist,
      required this.license,
      required this.rating,
      required this.experience,
      required this.bio});
  final int id;
  final int userId;
  final String name;
  final String email;
  final String specialist;
  final String license;
  final double rating;
  final int experience;
  final String bio;

  factory Doctor.fromMap(Map<String, Object?> map) => Doctor(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      specialist: map['specialist'] as String,
      license: map['license'] as String,
      rating: ((map['rating'] as num?) ?? 0).toDouble(),
      experience: (map['experience'] as int?) ?? 0,
      bio: (map['bio'] as String?) ?? '');
}
