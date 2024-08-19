class BaseAPI{
  static String ip$port = "192.168.230.98:7062";
  static String base = "https://192.168.230.98:7062";
  static var api = base + "/itk";
  var authPath = base + "/login";
  var registerPath = base + "/register";

  Map<String,String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',};
}
