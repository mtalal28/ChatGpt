import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:signin_signup/chat_model.dart';
import 'package:signin_signup/constants/api_consts.dart';
import 'package:signin_signup/model.dart';

class Api {
  static Future<List<Model>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return Model.modelFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message using ChatGPT API
  static Future<List<ChatModel>> sendMessageGPT(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
              (index) => ChatModel(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message fct
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "prompt": message,
            "max_tokens": 300,
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
              (index) => ChatModel(
            msg: jsonResponse["choices"][index]["text"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}

//
//   //send massage
//   static Future<List<ChatModel>> sendMessage(
//       {required String message, required String modelId}) async {
//     try {
//       var response = await http.post(Uri.parse("$BASE_URL/completions"),
//           headers: {
//             'Authorization': 'Bearer $API_KEY',
//             "Content-Type": 'application/json'
//           },
//           body: jsonEncode({
//             "model": modelId,
//             "messages": message,
//             "max_token": 100,
//
//           }));
//
//       if (response.statusCode == 200) {
//         Map jsonResponse = jsonDecode(response.body);
//         if (jsonResponse['error'] != null) {
//           print("jsonResponse['error']['message']: ${jsonResponse['error']['message']}");
//           throw HttpException(jsonResponse['error']['message']);
//         }
//          List<ChatModel> chatList=[];
//
//         // Extract the generated text from the response
//         if (jsonResponse["choices"].length > 0) {
//           // String generatedText = jsonResponse["choices"][0]["text];
//           // print("Generated Text: $generatedText");
//           // You can use the generatedText as needed in your application
//         chatList = List.generate(jsonResponse["choices"].length ,
//               (index) => ChatModel(
//                 msg: jsonResponse["choices"][index]["text"],
//                 chatIndex: 1,
//               ),
//         );
//
//         }
//
//       // } else {
//       //   print("Response Body: ${response.body}");
//       //   throw HttpException('Failed to make the API request. Status code: ${response.statusCode}');
//       // }
//         return  chatList;
//     } catch (error) {
//       print("error: $error");
//       rethrow;
//     }
//   }
// }


// List temp = [];
// for (var value in jsonResponse["data"]) {
// temp.add(value);
// log("temp: ${value["id"]}");
// }
//
// return Model.modelFromSnapshot(temp);
// } else {
// throw HttpException('Failed to load models. Status code: ${response.statusCode}');
// }

