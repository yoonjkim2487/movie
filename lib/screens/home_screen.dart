import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../data/movie_data.dart';
import '../data/review_data.dart';
import '../model/movie_model.dart';
import '../model/review_model.dart';
import '../uikit/widgets/more_button.dart';
import '../uikit/widgets/movie_card.dart';
import '../uikit/widgets/recommendation_card.dart';
import '../uikit/widgets/review_card.dart';
import '../uikit/widgets/sub_title.dart';
import '../uikit/widgets/top_bar.dart';
import 'movie_detail_screen.dart';
import 'movie_list_screen.dart';
import 'review_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MovieModel> _NowPlayingMovies = [];
  List<MovieReview> _reviewData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getMovieData();
    fetchLatestReviews(); // 최신 리뷰 데이터 가져오기
  }

  Future<void> getMovieData() async {
    try {
      var data = MovieData();
      List<MovieModel> movies = await data.fetchNowPlayingMovies();
      movies.sort((a, b) =>
          DateTime.parse(b.releaseDate).compareTo(DateTime.parse(a.releaseDate)));
      setState(() {
        _NowPlayingMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching movies: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchLatestReviews() async {
    try {
      var reviewData = MovieReviewData();
      _reviewData = await reviewData.fetchReviewsSortedUpvotes(); // 좋아요 수 내림차순으로 정렬된 리뷰 가져오기
      print("Reviews fetched: ${_reviewData.length}"); // 리뷰 개수 로그 추가
    } catch (e) {
      print("Error fetching reviews: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<MovieModel> fetchMovieById(int movieId) async {
    var data = MovieData();
    return await data.fetchMovieDetail(movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubTitle(title: '최신 인기 콘텐츠'),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _NowPlayingMovies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MovieCard(
                        title: _NowPlayingMovies[index].title,
                        image: Image.network(
                          'https://image.tmdb.org/t/p/w500/${_NowPlayingMovies[index].posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        ),
                        releaseInfo:
                        '${_NowPlayingMovies[index].releaseDate} · ${_NowPlayingMovies[index].originalLanguage}',
                        movieId: _NowPlayingMovies[index].id,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MovieDetailScreen(
                                  movieId: _NowPlayingMovies[index].id,
                                )),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubTitle(title: '최신 한줄평'),
                  MoreButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReviewListScreen()),
                    );
                  }),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: FutureBuilder(
                  future: Future.wait(
                    _reviewData.take(3).map((review) async { // 여기서 3개의 리뷰만 가져오도록 수정
                      MovieModel movie = await fetchMovieById(review.tmdbId);
                      print("Fetched movie for review ID ${review.id}: ${movie.title}"); // 로그 추가
                      return {
                        'review': review,
                        'movie': movie,
                      };
                    }).toList(),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("Error in FutureBuilder: ${snapshot.error}"); // 로그 추가
                      return Center(child: Text('Error loading reviews'));
                    }
                    if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      print("No data or empty list"); // 로그 추가
                      return Center(child: Text('No reviews found'));
                    }
                    List<Map<String, dynamic>> reviewMovieData = snapshot.data!;
                    return ListView.builder(
                      itemCount: reviewMovieData.length, // 여기도 3개의 리뷰만 표시하도록 수정
                      itemBuilder: (context, index) {
                        final review = reviewMovieData[index]['review'] as MovieReview;
                        final movie = reviewMovieData[index]['movie'] as MovieModel;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ReviewCard(
                            nickname: review.nickname,
                            rating: review.rating.toDouble(),
                            review: review.review,
                            reviewTitle: review.reviewTitle,
                            movieTitle: movie.title,
                            moviePosterUrl: 'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                            likes: review.upvotes,
                            onTap: () {
                              // 리뷰 카드 클릭 시 이벤트 처리 (예: 상세화면으로 이동)
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16), // 한줄평 섹션과 추천 섹션 간의 간격 추가
              SubTitle(title: '당신을 위한 추천'),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: RecommendationCard(
                        imageUrl: 'https://via.placeholder.com/216x122',
                        impressiveQuote: '인상적인 대사',
                        briefContent: '이 영화는 정말 대단합니다!',
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16), // 추천 섹션과 버튼 간의 간격 추가
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MovieListScreen()),
                    );
                  },
                  child: Text(
                    '더 많은 작품 보러가기',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
