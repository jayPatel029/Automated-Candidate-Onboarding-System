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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchAllData();
  }

  Future<List<User>> fetchAllData() async {
    final url = Uri.parse('http://127.0.0.1:5000/fetch_all_data');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> usersList = data['data'];
        final users = usersList.map((json) => User.fromJson(json)).toList();

        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });

        return users;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Document Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isWideScreen ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _usersFuture = fetchAllData();
              });
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isWideScreen ? 32.0 : 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade50,
              Colors.blue.shade50,
              Colors.lightBlue.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search and Stats Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by Name or Email',
                        prefixIcon: Icon(Icons.search, color: Colors.indigo),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.indigo),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterUsers('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      onChanged: _filterUsers,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Documents: ${_allUsers.length}',
                          style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Showing: ${_filteredUsers.length}',
                          style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Documents Grid
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading Documents...',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _usersFuture = fetchAllData();
                              });
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: Colors.indigo.shade300,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No documents found',
                            style: TextStyle(
                              color: Colors.indigo.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final users = _filteredUsers;
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.indigo.shade300,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No matching documents found',
                            style: TextStyle(
                              color: Colors.indigo.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideScreen ? 3 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isWideScreen ? 1.2 : 1.5,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () => _showUserDetails(context, user),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.indigo.shade50,
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.indigo.shade100,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          user.name ?? 'N/A',
                                          style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoRow(Icons.phone, user.mobile ?? 'N/A'),
                                  _buildInfoRow(Icons.email, user.emailId ?? 'N/A'),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showImages(context, user.images!),
                                      icon: Icon(Icons.image, size: 18),
                                      label: Text('View Images'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.indigo.shade600),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.indigo.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildDetailSection(
                      'Personal Information',
                      [
                        _buildDetailItem('Name', user.name),
                        _buildDetailItem('Mobile', user.mobile),
                        _buildDetailItem('Email', user.emailId),
                        _buildDetailItem('Gender', user.gender),
                        _buildDetailItem('Age', user.age?.toString()),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildAddressSection('Permanent Address', user.permanentAddress),
                    SizedBox(height: 24),
                    _buildAddressSection('Current Address', user.currentAddress),
                    if (user.educationalQualifications != null &&
                        user.educationalQualifications!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildDetailSection(
                        'Educational Qualifications',
                        user.educationalQualifications!.map((e) =>
                            _buildDetailItem(
                              'Qualification',
                              '${e.nameOfSchoolUniversity ?? "N/A"} - ${e.qualification ?? "N/A"}'
                            )
                        ).toList(),
                      ),
                    ],
                    if (user.trainingDetails != null &&
                        user.trainingDetails!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildDetailSection(
                        'Training Details',
                        user.trainingDetails!.map((e) =>
                            _buildDetailItem(
                              'Training',
                              '${e.program ?? "N/A"} - ${e.duration ?? "N/A"}'
                            )
                        ).toList(),
                      ),
                    ],
                    if (user.technicalCertifications != null &&
                        user.technicalCertifications!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildDetailSection(
                        'Technical Certifications',
                        user.technicalCertifications!.map((e) =>
                            _buildDetailItem(
                              'Certification',
                              '${e.certification ?? "N/A"} - ${e.duration ?? "N/A"}'
                            )
                        ).toList(),
                      ),
                    ],
                    if (user.familyDetails != null &&
                        user.familyDetails!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildDetailSection(
                        'Family Details',
                        user.familyDetails!.map((e) =>
                            _buildDetailItem(
                              e.relation ?? 'Relation',
                              '${e.occupation ?? "N/A"}, ${e.residentLocation ?? "N/A"}'
                            )
                        ).toList(),
                      ),
                    ],
                    if (user.references != null && user.references!.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildDetailSection(
                        'References',
                        user.references!.map((e) =>
                            _buildDetailItem(
                              e.name ?? 'Reference',
                              e.designation ?? 'N/A'
                            )
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(String title, Address? address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address?.streetAddress ?? 'Street: N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  address?.city ?? 'City: N/A',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '${address?.state ?? "State: N/A"}, ${address?.country ?? "Country: N/A"}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Zip Code: ${address?.zipCode ?? "N/A"}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImages(BuildContext context, List<ImageModel>? images) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Uploaded Images",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: images != null && images.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final image = images[index];
                            final decodedImage = base64Decode(image.content!);
                            return GestureDetector(
                              onTap: () => _showFullImage(context, decodedImage),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.indigo.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.memory(
                                    decodedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Colors.indigo.shade300,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No images available",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
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
                      borderRadius: BorderRadius.circular(16.0),
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
