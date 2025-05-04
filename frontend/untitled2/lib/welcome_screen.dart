import 'package:flutter/material.dart';
import 'package:untitled2/upload_screen.dart';
import 'package:untitled2/view_docs.dart';
import 'package:untitled2/config.dart';
import 'package:untitled2/llm_upload_screen.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isCheckingHealth = false;
  bool _isApiHealthy = false;
  String? _healthMessage;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _healthMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(Config.healthEndpoint));
      if (response.statusCode == 200) {
        setState(() {
          _isApiHealthy = true;
          _healthMessage = 'API is healthy and running';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend is healthy!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isApiHealthy = false;
          _healthMessage = 'API health check failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend health check failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isApiHealthy = false;
        _healthMessage = 'Error checking API health: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking backend health: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingHealth = false;
      });
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
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => LLMUploadScreen(),
                              //   ),
                              // );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Footer with API Status
                    SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by Advanced AI Technologies',
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isApiHealthy
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isCheckingHealth)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.indigo),
                                  ),
                                )
                              else
                                Icon(
                                  _isApiHealthy
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  color:
                                      _isApiHealthy ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              SizedBox(width: 6),
                              Text(
                                _isCheckingHealth
                                    ? 'Checking...'
                                    : _isApiHealthy
                                        ? 'API Online'
                                        : 'API Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isApiHealthy
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: Colors.indigo.shade600,
                                ),
                                onPressed:
                                    _isCheckingHealth ? null : _checkHealth,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
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
