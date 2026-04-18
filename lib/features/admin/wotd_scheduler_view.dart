import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kamus_banjar_mobile_app/core/repositories/admin_repository.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:kamus_banjar_mobile_app/shared/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class WotdSchedulerView extends StatefulWidget {
  const WotdSchedulerView({super.key});

  @override
  State<WotdSchedulerView> createState() => _WotdSchedulerViewState();
}

class _WotdSchedulerViewState extends State<WotdSchedulerView> {
  final _formKey = GlobalKey<FormState>();
  final _wordCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = context.read<AdminRepository>();
    setState(() => _isSubmitting = true);

    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      await repo.setWordOfTheDay(_wordCtrl.text.trim(), dateStr);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Kata hari ini berhasil dijadwalkan!',
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        _wordCtrl.clear();
        setState(() {
          _selectedDate = DateTime.now().add(const Duration(days: 1));
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClipped = MediaQuery.of(context).viewPadding.top == 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateLabel =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Scaffold(
      appBar: CustomAppBar(title: 'Atur Kata Hari Ini', isClipped: isClipped),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 18, 41, 58)
                        : const Color.fromARGB(255, 219, 239, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _wordCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kata *',
                          hintText: 'Masukkan kata Banjar',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined,
                            color: Colors.blue),
                        label: Text(
                          'Tanggal: $dateLabel',
                          style: const TextStyle(color: Colors.blue),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Jadwalkan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
