class BaseAPI{
  static String ip$port = "10.87.0.161:7062";
  static String base = "https://10.87.0.161:7062";
  static var api = base + "/itk";
  var authPath = base + "/login";
  var registerPath = base + "/register";

  Map<String,String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',};
}
