import 'dart:convert';
import 'package:untitled1/model/movie_model.dart';
import 'package:untitled1/model/cast_model.dart';
import 'package:http/http.dart' as http;

class MovieData {
  final String baseUrl ='https://api.themoviedb.org/3/movie';
  final String bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxYjEzNDM0ZTM3YzU5YjI5MmU1NjJhYzNiMWNmZjBhOSIsIm5iZiI6MTcyODAzNDM1Ny40MzgzMTksInN1YiI6IjY2ZmZiNDE4OTI1ZmRmOTI1YjdjYzAxYiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.12nn2eF2HxuoM3Ter1FSBXO87HDMCvOIupgxHmw4Nt4';
  final int defaultPageCount = 10;

  Future<MovieModel> fetchMovieById(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$movieId?language=ko-KR'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return MovieModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie');
    }
  }

  Future<List<MovieModel>> fetchMovies(String endpoint, {int? pageCount}) async {
    int pages = pageCount ?? defaultPageCount; // 페이지 수가 null인 경우 기본 값을 사용
    List<MovieModel> allMovies = [];
    for (int i = 1; i <= pages; i++) {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint?language=ko-KR&region=KR&&page=$i'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        allMovies.addAll(((jsonDecode(response.body)['results']) as List)
            .map((e) => MovieModel.fromJson(e))
            .toList());
      } else {
        throw Exception("Failed to load movie data");
      }
    }
    return allMovies;
  }

  Future<List<MovieModel>> fetchNowPlayingMovies({int? pageCount}) async {
    return fetchMovies('now_playing', pageCount: pageCount);
  }

  Future<List<MovieModel>> fetchTopRatedMovies({int? pageCount}) async {
    return fetchMovies('top_rated', pageCount: pageCount);
  }

  Future<List<MovieModel>> fetchPopularMovies({int? pageCount}) async {
    return fetchMovies('popular', pageCount: pageCount);
  }

  Future<MovieModel> fetchMovieDetail(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$movieId?language=ko-KR'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      MovieModel model = MovieModel.fromJson(jsonDecode(response.body));
      return MovieModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load movie detail");
    }
  }
  Future<List<MovieModel>> fetchSimilarMovies(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$movieId/similar?language=en-US&page=1'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ((jsonDecode(response.body)['results']) as List)
          .map((e) => MovieModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load similar movies");
    }
  }
  Future<List<CastModel>> fetchCastDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$movieId/credits?language=ko-KR'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List castList = jsonDecode(response.body)['cast']; // 출연진 데이터 추출
      return castList.map((cast) => CastModel.fromJson(cast)).toList(); // CastModel 리스트 반환
    } else {
      throw Exception("Failed to load cast details");
    }
  }
}
