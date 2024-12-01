import 'dart:convert';
import 'package:untitled1/data/req/REQ_L001.dart';
import 'package:http/http.dart' as http;

import '../uiState/profile/User.dart';

class UserData {
  // TODO 백엔드 서버  로그인 API domain으로 변경
  final String baseUrl ='http://3.37.239.121:8080/api/users';

  //TODO 로그인 메소드
  Future<User> login(REQ_L001 reqL001) async {
    final response = await http.post(
      // TODO 백엔드 서버  로그인 API path(uri)로 변경
      //url, domain, path(uri) 차이점
      //url은 uri를 포함하는 개념 http://..... 부터 전부다 지칭하는 표현
      //domain은 http://www.naver.com 처럼 앞부분
      //uri는 http://www.naver.com/maps 에서 뒤에붙는 /maps 부터를 지칭
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type' : 'application/json',
        'accept': 'application/json',
      },
      body: json.encode({
      'id' :reqL001.id,
      'pw': reqL001.pw,
    })
    );

    //성공응답
    if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return User(
    id: data['id'], // 사용자 ID
    nickname: data['nickName'], // 닉네임
    email: data['email'], // 이메일
    birthDate: data['birthDate'], // 생일
    gender: data['gender'], // 성별
    name: data['name'], // 이름
    phoneNumber: data['phoneNumber'], // 전화번호
    password: reqL001.pw, // 비밀번호
    );
    } else {
    throw Exception("로그인 실패: ${response.body}");
    }
  }

  Future<void> logout(String userId) async {
    final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
        'Content-Type': 'application/json',
        },
        body: json.encode({
        'userId': userId, // 사용자 ID를 전송
        }),
    );

  if (response.statusCode != 200) {
  throw Exception("로그아웃 실패: ${response.body}");
  }
}

  Future<void> deleteAccount(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception("계정 삭제 실패: ${response.body}");
    }
  }

}