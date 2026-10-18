/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/request/chat_conversion_request_model.dart';
import 'package:user/app/core/models/request/load_more_chat_conversion_request_model.dart';
import 'package:user/app/core/models/request/send_chat_message_request_model.dart';
import 'package:user/app/core/models/request/support_chat_convertion_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class ChatRepository {
  final ApiRequestService _apiRequestService = ApiRequestService();
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> authRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<DioApiResponse> fetchChatMessages(ChatConversionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.fetchChatMessages, body: param);
  }

  Future<DioApiResponse> sendChatMessage(SendChatMessageRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.sendChatMessage, body: param);
  }

  Future<DioApiResponse> getChatList(String userId) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.chatList}$userId');
  }

  Future<DioApiResponse> getChatConversion(LoadMoreChatConversionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getChatConversion, body: param);
  }

  Future<DioApiResponse> fetchSupportChatMessages(SupportChatConvertionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.fetchSupportChatMessages, body: param);
  }

  Future<DioApiResponse> getSupportChatList(String userId) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.supportChatList}$userId');
  }

  Future<DioApiResponse> sendSupportChatMessage(SendChatMessageRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.sendSupportChatMessage, body: param);
  }

  Future<DioApiResponse> fetchSupportChips() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.supportChatChips);
  }

  /// Support image upload (evidence photos). Client compresses before send;
  /// server re-validates type + size and answers 400 otherwise.
  Future<DioApiResponse> uploadSupportImage(String uid, XFile file) async {
    return await _apiRequestService.uploadImageFile(ApiEndPoints.v1request.uploadImageFile, uid, file);
  }

  Future<DioApiResponse> getSupportChatConversion(LoadMoreChatConversionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getSupportChatConversion, body: param);
  }

  Future<String> firstName() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userFirstName) ?? '';
  }

  Future<String> lastName() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userLastName) ?? '';
  }

Future<String> userCover() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userCover) ?? '';
  }

  /// Access token for socket auth. The server's `io.use(jwtVerify)` rejects any
  /// socket that cannot present one, so a chat opened without this silently
  /// receives nothing.
  Future<String> authToken() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.authToken) ?? '';
  }

  // --- Bot-first -> human handover ------------------------------------------
  // Opens (or reuses) the room and returns the bot's first answer plus the
  // roomId the socket should join.
  Future<DioApiResponse> startSupportBot({required String user, required String type, required String typeId, String? locale}) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.supportBotStart, body: {'user': user, 'type': type, 'typeId': typeId, 'locale': ?locale});
  }

  Future<DioApiResponse> sendSupportBotMessage({required String roomId, required String message, String? locale}) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.supportBotMessage, body: {'roomId': roomId, 'message': message, 'locale': ?locale});
  }

  Future<DioApiResponse> supportQueueStatus(String roomId) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.supportQueueStatus}$roomId');
  }

  Future<DioApiResponse> requestSupportHandover({required String roomId, String? reason}) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.supportHandover}$roomId', body: {'reason': ?reason});
  }

  Future<DioApiResponse> submitSupportCsat({required String roomId, required int score, String? comment}) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.supportCsat}$roomId', body: {'score': score, 'comment': ?comment});
  }

  /// Reopens the customer's own resolved ticket within 48h. The server enforces
  /// ownership and the window; a refusal surfaces as an error response, not an
  /// exception, so callers handle it like any other send failure.
  Future<DioApiResponse> reopenSupportChat({required String roomId, required String userId}) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.supportReopen}$roomId', body: {'user': userId});
  }
}

