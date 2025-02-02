import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorView extends StatefulWidget {
  final String shortErrorMessage;
  final String detailedErrorMessage;

  const ErrorView({
    super.key,
    required this.shortErrorMessage,
    this.detailedErrorMessage = '',
  });

  @override
  ErrorViewState createState() => ErrorViewState();
}

class ErrorViewState extends State<ErrorView> {
  bool _isDetailedMessageVisible = false;

  // Function to copy the error message to the clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.detailedErrorMessage));

    // Show the toast message after copying the content
    Fluttertoast.showToast(
      msg: "Pesan kesalahan telah disalin ke clipboard!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color.fromARGB(255, 72, 93, 112),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _toggleDetailedMessage() {
    setState(() {
      _isDetailedMessageVisible = !_isDetailedMessageVisible;
    });
  }

  // Function to launch URL in the default browser
  Future<void> _launchGitHubRepo() async {
    final Uri url = Uri.parse(
        'https://github.com/404NotFoundIndonesia/kamus-banjar-mobile-app/issues');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url,
            mode:
                LaunchMode.externalApplication); // Open in the default browser
      } else {
        Fluttertoast.showToast(
          msg: "Tidak dapat membuka $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 235, 235),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.shortErrorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isDetailedMessageVisible) ...[
                  Text(
                    widget.detailedErrorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, color: Colors.red),
                    label: const Text(
                      'Salin ke Clipboard',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _toggleDetailedMessage,
                      icon: Icon(
                        _isDetailedMessageVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.red,
                      ),
                      label: Text(
                        _isDetailedMessageVisible
                            ? 'Sembunyikan Detail'
                            : 'Tampilkan Detail',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _launchGitHubRepo,
                      icon: const Icon(Icons.link, color: Colors.red),
                      label: const Text(
                        'Laporkan ke Github',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
