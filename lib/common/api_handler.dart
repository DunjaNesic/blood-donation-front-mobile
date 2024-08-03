class BaseAPI{
  static String base = "https://10.87.0.161:7062";
  static var api = base + "/itk";
  var nekiPath = api + "/nesto";
  var authPath = base + "/login";
  //treba posle da dodam ostale rute

  Map<String,String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',};
}
