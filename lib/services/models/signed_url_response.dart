class SignedUrlResponse {
  final String url;
  final String key;

  SignedUrlResponse({
    required this.url,
    required this.key,
  });

  factory SignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return SignedUrlResponse(
      url: json['url'] as String,
      key: json['key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'key': key,
    };
  }
}
