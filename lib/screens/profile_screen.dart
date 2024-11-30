import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled1/SessionManager.dart';
import 'package:untitled1/screens/review_list_screen.dart';
import 'package:untitled1/screens/settings_screen.dart';
import 'package:untitled1/screens/user_review_screen.dart';
import 'package:untitled1/screens/watch_movie_screen.dart';
import '../SharedPreference.dart';
import '../constants/colors.dart';
import '../uikit/widgets/top_bar.dart';
import '../SessionManager.dart';
import 'favorite_movie_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  late bool _isLoggedIn; // 초기 상태는 null

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final userId = SharePrefManager.pref.getString(SharedPrefConst.USER_ID);

    if (userId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://3.37.239.121:8080/api/users/$userId'),
        );

        if (response.statusCode == 200) {
          setState(() {
            userProfile = json.decode(response.body); // 사용자 정보 저장
          });
        } else {
          print("프로필 조회 실패: ${response.body}");
        }
      } catch (e) {
        print("오류: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProfile != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://via.placeholder.com/80'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile!['nickName'] ?? '닉네임 없음',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      Text(
                        userProfile!['email'] ?? '이메일 없음',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.favorite, color: AppColors.textWhite),
                    title: Text('관심목록', style: TextStyle(color: AppColors.textWhite)),
                    onTap: () {
                      final userId = userProfile!['id']; // 프로필에서 사용자 ID 가져오기
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoriteMoviesScreen(userId: userId)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.history, color: AppColors.textWhite),
                    title: Text('시청기록', style: TextStyle(color: AppColors.textWhite)),
                    onTap: () {
                      final userId = userProfile!['id']; // 프로필에서 사용자 ID 가져오기
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WatchedMoviesScreen(userId: userId)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.rate_review, color: AppColors.textWhite),
                    title: Text('리뷰 관리', style: TextStyle(color: AppColors.textWhite)),
                    onTap: () {
                      final nickname = userProfile!['nickName']; // 닉네임 가져오기
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserReviewScreen(nickname: nickname)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: AppColors.textWhite),
                    title: Text('설정', style: TextStyle(color: AppColors.textWhite)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
