import 'package:flutter/material.dart';
import '../mahas/widget/mahas_alert.dart';
import '../utils/mahas_utils.dart';
import '../utils/type_utils.dart';

class AuthErrorHandler {
  /// Menangani error unauthorized dengan menampilkan dialog login
  static Future<bool> handleUnauthorized(
    BuildContext context, {
    String message = 'Login untuk melakukan aksi ini',
  }) async {
    // Menampilkan dialog login menggunakan MahasAlertDialog
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => MahasAlertDialog(
        alertType: AlertType.info,
        title: 'Login Diperlukan',
        content: Text(message),
        positiveButtonText: 'Login',
        negativeButtonText: 'Batal',
        onPositivePressed: () {
          // Navigasi ke halaman login
          Mahas.routeTo('/login');
          return true;
        },
        onNegativePressed: () {
          return false;
        },
      ),
    );
    
    return result ?? false;
  }
  
  /// Menangani error dari Dio dengan menampilkan dialog yang sesuai
  static Future<bool> handleError(
    BuildContext context,
    dynamic error, {
    String defaultMessage = 'Terjadi kesalahan, silakan coba lagi nanti',
  }) async {
    // Cek apakah error adalah unauthorized (401)
    if (error.toString().contains('401') || 
        error.toString().toLowerCase().contains('unauthorized')) {
      return await handleUnauthorized(context);
    }
    
    // Untuk error lainnya, tampilkan pesan error biasa
    await showDialog(
      context: context,
      builder: (context) => MahasAlertDialog(
        alertType: AlertType.error,
        title: 'Error',
        content: Text(error.toString().contains('Exception:') 
            ? error.toString().split('Exception:')[1].trim()
            : defaultMessage),
        showNegativeButton: false,
      ),
    );
    
    return false;
  }
}
