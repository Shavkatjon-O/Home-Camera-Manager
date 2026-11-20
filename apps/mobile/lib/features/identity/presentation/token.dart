/// Returns the token inside [input], which may be a pasted link or the token itself.
String extractToken(String input) {
  final text = input.trim();
  final uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
    final query = uri.queryParameters['token'];
    if (query != null && query.isNotEmpty) return query;
    return uri.pathSegments.last;
  }
  return text;
}
