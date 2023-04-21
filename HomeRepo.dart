import 'package:rentors/model/home/Home.dart';
import 'package:rentors/model/home/HomeBean.dart';
import 'package:rentors/model/home/HomeModel.dart';
import 'package:rentors/model/home/Separator.dart';
import 'package:rentors/model/home/SingleCategory.dart';
import 'package:rentors/model/home/TwoCategory.dart';
import 'package:rentors/repo/FreshDio.dart' as dio;

Future<Home> getHomeData() async {
  var response = await dio.httpClient().get("home/index/%0A");
  var parsed = HomeModel.fromJson(response.data);
  var list = List<dynamic>();
  int size = parsed.data.category.length;
  var temp = parsed.data.category;
  int index = 0;
  do {
    if (index == 0) {
      list.add(SingleCategory(temp[index]));
      index++;
    } else {
      Category one = temp[index];

      Category two;
      index++;
      if (index < size) {
        two = temp[index];
        index++;
      }
      list.add(TwoCategoryCategory(one, two));
    }
  } while (index < size);
  return Home(parsed.data.homeSliderImage, list, parsed.data.featuredProducts,
      await parsedProduct(parsed.data.products), parsed.data.sliderImage);
}

Future<List<HomeBean>> parsedProduct(List<PurpleProduct> product) async {
  var response = List<HomeBean>();
  product.forEach((element) {
    response.add(Separator(element.category));
    element.subCategory.forEach((sub) {
      sub.subCategoryId = sub.products.first.subCategoryId;
    });
    response.addAll(element.subCategory);
  });
  return response;
}
