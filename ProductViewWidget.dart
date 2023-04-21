import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:rentors/config/app_config.dart' as config;
import 'package:rentors/generated/l10n.dart';
import 'package:rentors/model/home/HomeModel.dart';
import 'package:rentors/util/Utils.dart';
import 'package:rentors/widget/FeatureWidget.dart';
import 'package:rentors/widget/LikeWidget.dart';
import 'package:rentors/widget/PlaceHolderWidget.dart';

class ProductViewWidget extends StatelessWidget {
  final FeaturedProductElement products;

  ProductViewWidget(this.products);

  void openDetails(
      BuildContext context, FeaturedProductElement products) async {
    var map = Map();
    map["id"] = products.id;
    map["name"] = products.details.productName;
    Navigator.of(context).pushNamed("/product_details", arguments: map);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
        onTap: () {
          openDetails(context, products);
        },
        child: SizedBox(
          width: config.App(context).appWidth(50),
          height: config.App(context).appHeight(30),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: [
                    Hero(
                      tag: products.id,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10)),
                          child: OptimizedCacheImage(
                              placeholder: (context, url) {
                                return PlaceHolderWidget();
                              },
                              fit: BoxFit.fill,
                              width: double.infinity,
                              height: config.App(context)
                                      .appHeight(Platform.isAndroid ? 34 : 35) *
                                  .6,
                              imageUrl: products.details.images)),
                    ),
                    FeatureWidget(
                      products.isFeatured,
                      radius: 10,
                    )
                  ]),
                  Container(
                    margin:
                        EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            width: config.App(context).appWidth(50),
                            child: Text(
                              products.details.productName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800),
                            )),
                        Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            child: FittedBox(
                              child: SizedBox(
                                width: config.App(context).appWidth(50),
                                child: Text(
                                  Utils.generateStringV2(
                                      products.details.fileds),
                                  maxLines: 1,
                                ),
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Row(children: <Widget>[
                            Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Text(
                                        S
                                            .of(context)
                                            .starting(products.details.price),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: config.Colors().color00A03E,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child:
                                      LikeWidget(products.id, products.isLike),
                                ))
                          ]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
