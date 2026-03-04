import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fashion_product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<FashionProduct>> fetchFashionProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('fashion')
          .get()
          .timeout(const Duration(seconds: 12));

      return querySnapshot.docs
          .map((doc) => FashionProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw Exception(
          'Mất kết nối mạng. Vui lòng kiểm tra Internet rồi bấm Thử lại.',
        );
      }

      throw Exception('Không thể tải dữ liệu từ Firebase (${e.code}).');
    } on TimeoutException {
      throw Exception('Kết nối quá chậm hoặc bị gián đoạn. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.');
    }
  }
}
