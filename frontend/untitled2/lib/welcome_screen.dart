import 'package:flutter/material.dart';
import 'package:untitled2/upload_screen.dart';
import 'package:untitled2/view_docs.dart';
import 'package:untitled2/config.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatelessWidget {

  Future<void> _checkHealth(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(Config.healthEndpoint));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend is healthy!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend health check failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking backend health: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkRender(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(Config.checkRenderEndpoint));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend is running on Render!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend Render check failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking Render status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 48.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title Section
                    Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Colors.indigo,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Form Automation Suite',
                      style: TextStyle(
                        fontSize: isWideScreen ? 36 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Choose your automation approach',
                      style: TextStyle(
                        fontSize: isWideScreen ? 20 : 16,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                    SizedBox(height: 48),

                    // Options Grid
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 800 : 600,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: isWideScreen ? 2 : 1,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: isWideScreen ? 1.5 : 1.2,
                        children: [
                          // AI/ML Option
                          _buildOptionCard(
                            context,
                            'AI/ML Based Automation',
                            'Leverage machine learning for intelligent form processing and data extraction',
                            Icons.psychology,
                            Colors.purple,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UploadScreen(),
                                ),
                              );
                            },
                          ),

                          // LLM Option
                          _buildOptionCard(
                            context,
                            'LLM Based Automation',
                            'Utilize large language models for advanced form understanding and processing',
                            Icons.auto_fix_high,
                            Colors.teal,
                            () {
                              _showComingSoonDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    SizedBox(height: 48),
                    Text(
                      'Powered by Advanced AI Technologies',
                      style: TextStyle(
                        color: Colors.indigo.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.teal),
            SizedBox(width: 10),
            Text('Coming Soon!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The LLM-based automation feature is currently under development.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Stay tuned for updates!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 