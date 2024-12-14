import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/user_model.dart';

class ViewAllDataPage extends StatefulWidget {
  @override
  _ViewAllDataPageState createState() => _ViewAllDataPageState();
}

class _ViewAllDataPageState extends State<ViewAllDataPage> {
  late Future<List<User>> _usersFuture;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchAllData();
  }

  Future<List<User>> fetchAllData() async {
    final url = Uri.parse('http://127.0.0.1:5000/fetch_all_data');
    try {
      final response = await http.get(url);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        // Decode the JSON response body into a Map
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Access the "data" key to get the list of users
        final List<dynamic> usersList = data['data'];

        final users = usersList.map((json) => User.fromJson(json)).toList();

        setState(() {
          _allUsers = users;
          _filteredUsers = users;
        });

        return users;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }


  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nameLower = user.name?.toLowerCase();
        final emailLower = user.emailId?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return nameLower!.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('View All Data'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Name or Email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  _filterUsers(value);
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data found'));
                    }
                    final users = _filteredUsers;
                    if (users.isEmpty) {
                      return Center(child: Text('No matching users found'));
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return GestureDetector(
                          onTap: () => _showUserDetails(context, user),
                          child: Card(
                            elevation: 5,
                            shadowColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${user.name}',
                                      style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[800])),
                                  SizedBox(height: 8),
                                  Text('Mobile: ${user.mobile ?? "N/A"}',
                                      style: GoogleFonts.lato(fontSize: 14)),
                                  Text('Email: ${user.emailId ?? "N/A"}',
                                      style: GoogleFonts.lato(fontSize: 14)),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _showImages(context, user.images!),
                                      child: Text('View Uploaded Images'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text('Name: ${user.name}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text('Mobile: ${user.mobile ?? "N/A"}',
                    style: TextStyle(fontSize: 16)),
                Text('Email: ${user.emailId ?? "N/A"}',
                    style: TextStyle(fontSize: 16)),
                Text('Gender: ${user.gender ?? "N/A"}',
                    style: TextStyle(fontSize: 16)),
                Text('Age: ${user.age ?? "N/A"}',
                    style: TextStyle(fontSize: 16)),
                Divider(height: 32),
                _buildAddressDetails(
                    'Permanent Address', user.permanentAddress),
                _buildAddressDetails('Current Address', user.currentAddress),
                if (user.educationalQualifications != null &&
                    user.educationalQualifications!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Educational Qualifications:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...user.educationalQualifications!
                      .map((e) => Text(
                          '${e.nameOfSchoolUniversity ?? "N/A"} - ${e.qualification ?? "N/A"}',
                          style: TextStyle(fontSize: 16)))
                      .toList(),
                ],
                if (user.trainingDetails != null &&
                    user.trainingDetails!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Training Details:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...user.trainingDetails!
                      .map((e) => Text(
                          '${e.program ?? "N/A"} - ${e.duration ?? "N/A"}',
                          style: TextStyle(fontSize: 16)))
                      .toList(),
                ],
                if (user.technicalCertifications != null &&
                    user.technicalCertifications!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Technical Certifications:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...user.technicalCertifications!
                      .map((e) => Text(
                          '${e.certification ?? "N/A"} - ${e.duration ?? "N/A"}',
                          style: TextStyle(fontSize: 16)))
                      .toList(),
                ],
                if (user.familyDetails != null &&
                    user.familyDetails!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Family Details:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...user.familyDetails!
                      .map((e) => Text(
                          '${e.relation ?? "N/A"} - ${e.occupation ?? "N/A"}, ${e.residentLocation ?? "N/A"} ',
                          style: TextStyle(fontSize: 16)))
                      .toList(),
                ],
                if (user.references != null && user.references!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('References:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ...user.references!
                      .map((e) => Text(
                          '${e.name ?? "N/A"} - ${e.designation ?? "N/A"}',
                          style: TextStyle(fontSize: 16)))
                      .toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressDetails(String title, Address? address) {
    return ExpansionTile(
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        ListTile(
          title: Text(address?.streetAddress ?? "Street: N/A",
              style: TextStyle(fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address?.city ?? "City: N/A",
                  style: TextStyle(fontSize: 16)),
              Text(
                '${address?.state ?? "State: N/A"}, ${address?.country ?? "Country: N/A"}',
                style: TextStyle(fontSize: 16),
              ),
              Text('Zip Code: ${address?.zipCode ?? "N/A"}',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _showImages(BuildContext context, List<ImageModel>? images) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.6,
            child: images != null && images.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Uploaded Images",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final image = images[index];
                            final decodedImage = base64Decode(image.content!);
                            return GestureDetector(
                              onTap: () =>
                                  _showFullImage(context, decodedImage),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Image.memory(
                                    decodedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      "No images available",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
