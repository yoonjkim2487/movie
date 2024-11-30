import 'package:flutter/material.dart';
import '../data/movie_data.dart';  // 영화 데이터를 가져오기 위해 추가
import '../data/review_data.dart';
import '../model/movie_model.dart';  // 영화 모델 클래스
import '../model/review_model.dart';
import '../uikit/widgets/top_bar.dart';
import '../constants/colors.dart';
import '../uikit/widgets/review_card.dart';

class ReviewListScreen extends StatefulWidget {
  @override
  _ReviewListScreenState createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final MovieReviewData _reviewData = MovieReviewData();  // 수정된 데이터 클래스
  List<MovieReview> _reviews = [];  // 수정된 모델
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    try {
      List<MovieReview> reviews = await _reviewData.fetchReviewsSortedUpvotes();
      print('Reviews fetched: ${reviews.length}'); // 리뷰 개수 출력
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리뷰를 불러오는 데 실패했습니다.')),
      );
    }
  }

  Future<MovieModel> fetchMovieById(int movieId) async {
    var data = MovieData();
    return await data.fetchMovieDetail(movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 배경 색상 설정
      appBar: TopBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? Center(child: Text('리뷰가 없습니다', style: TextStyle(color: AppColors.textWhite)))
          : ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return FutureBuilder<MovieModel>(
            future: fetchMovieById(review.tmdbId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading movie data'));
              }
              final movie = snapshot.data;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ReviewCard(
                  nickname: review.nickname,
                  rating: review.rating.toDouble(),  // 수정된 부분
                  reviewTitle: review.reviewTitle,
                  movieTitle: movie?.title ?? 'Unknown Title',  // 영화 타이틀 사용
                  moviePosterUrl: 'https://image.tmdb.org/t/p/w500/${movie?.posterPath}', // 영화 포스터 URL 사용
                  review: review.review,
                  likes: review.upvotes,
                  onTap: () {
                    // 리뷰 카드 클릭 시 이벤트 처리
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
