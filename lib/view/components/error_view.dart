import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorView extends StatefulWidget {
  final String shortErrorMessage;
  final String detailedErrorMessage;
  final Widget pageToRefresh;

  const ErrorView({
    super.key,
    required this.shortErrorMessage,
    this.detailedErrorMessage = '',
    required this.pageToRefresh,
  });

  @override
  ErrorViewState createState() => ErrorViewState();
}

class ErrorViewState extends State<ErrorView> {
  bool _isDetailedMessageVisible = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.detailedErrorMessage));

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

  Future<void> _launchGitHubRepo() async {
    final Uri url = Uri.parse(
        'https://github.com/404NotFoundIndonesia/kamus-banjar-mobile-app/issues');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(
          msg: "Tidak dapat membuka $url",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
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
          color: const Color.fromARGB(255, 224, 235, 245),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.blue,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.shortErrorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isDetailedMessageVisible) ...[
                  Text(
                    widget.detailedErrorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    label: const Text(
                      'Salin ke Clipboard',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  children: [
                    TextButton.icon(
                      onPressed: _toggleDetailedMessage,
                      icon: Icon(
                        _isDetailedMessageVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue,
                      ),
                      label: Text(
                        _isDetailedMessageVisible
                            ? 'Sembunyikan Detail'
                            : 'Tampilkan Detail',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _launchGitHubRepo,
                      icon: const Icon(Icons.link, color: Colors.blue),
                      label: const Text(
                        'Laporkan ke Github',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => widget.pageToRefresh),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      label: const Text(
                        'Muat Ulang',
                        style: TextStyle(color: Colors.blue),
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
