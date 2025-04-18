import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/view_docs.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  Uint8List? uploadedFileBytes;
  String? uploadedFileName;
  bool _isUploading = false;
  bool _isSuccess = false;
  bool _isError = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      uploadedFileBytes = null;
      uploadedFileName = null;
      _isUploading = false;
      _isSuccess = false;
      _isError = false;
      _errorMessage = null;
    });
  }

  void _showSuccessAnimation() {
    setState(() {
      _isSuccess = true;
      _isError = false;
    });
    _animationController.forward();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
        _animationController.reset();
      }
    });
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
      _isSuccess = false;
    });
  }

  void _pickFile() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'application/pdf,image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        final file = files[0];

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            uploadedFileBytes = reader.result as Uint8List;
            uploadedFileName = file.name;
            _isError = false;
            _errorMessage = null;
          });
        });
      }
    });
  }

  Future<void> _uploadFile() async {
    if (uploadedFileBytes != null && uploadedFileName != null) {
      setState(() => _isUploading = true);
      try {
        final uri = Uri.parse('http://127.0.0.1:5000/process');
        final request = http.MultipartRequest('POST', uri);

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            uploadedFileBytes!,
            filename: uploadedFileName!,
          ),
        );

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseData);

          _showSuccessAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload successful: ${jsonResponse["message"]}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          _showError('Upload failed: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${response.statusCode}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        _showError('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      _showError('Please select a file first!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a file first!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI/ML Document Processing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isWideScreen ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetState,
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
              Colors.purple.shade50,
              Colors.deepPurple.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 800 : 600,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.05),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWideScreen ? 32.0 : 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.psychology,
                            color: Colors.purple,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Upload Your Document',
                            style: TextStyle(
                              fontSize: isWideScreen ? 28 : 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple.shade800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Let our AI process your documents',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Success Animation
                      if (_isSuccess)
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Upload Successful!',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Error Message
                      if (_isError)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage ?? 'An error occurred',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isError = false;
                                    _errorMessage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                      // File Preview Section
                      if (uploadedFileName != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.file_present, color: Colors.purple, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      uploadedFileName!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${(uploadedFileBytes!.length / 1024).toStringAsFixed(2)} KB',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: _resetState,
                              ),
                            ],
                          ),
                        ),

                      // Upload Area
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isError ? Colors.red.shade200 : Colors.purple.shade200,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _isError ? Colors.red.shade50 : Colors.white,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _isError ? Icons.error_outline : Icons.cloud_upload,
                              size: 48,
                              color: _isError ? Colors.red : Colors.purple,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _isError ? 'Please try again' : 'Drag and drop your file here or',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isError ? Colors.red.shade800 : Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickFile,
                              icon: Icon(Icons.file_upload),
                              label: Text('Browse Files'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isError ? Colors.red : Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isUploading)
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            ElevatedButton.icon(
                              onPressed: uploadedFileBytes != null ? _uploadFile : null,
                              icon: Icon(Icons.cloud_upload),
                              label: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewAllDataPage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.library_books),
                              label: Text('View Documents'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
