import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:honestore/models/tag.dart';
import 'package:http/http.dart' as http;
import 'package:honestore/secrets.env.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import '../screens/listingPage.dart';

typedef Tag Handler({String id, String name, String description});

class Backend {

  static const String host = 'api.8base.com';
  static const String base = '/cknp3jj7b00la0cmo5a66dnyw/';

  Uri _buildUri(Map<String, dynamic> params) => Uri.https(
      host,
      base,
      params
  );

  Future<http.Response> get(params) async => await http.get(
    _buildUri(params),
    headers: {
      'Authorization': 'Bearer ' + eightBaseKey
    }
  );

  Future<http.Response> post(body) async => await http.post(
      _buildUri({}),
      headers: {
        'Content-Type': 'application/json'
      },
      body: body
  );

  String getItems(dynamic items) {
    if (items is Map) return [for (var k in items.keys) k + ' {' + getItems(items[k]) + '}'].join(" ");
    if (items is List) return items.map((e) => getItems(e)).join(" ");
    if (items is String) return items;
    throw Exception('Unkown type for getItems ${items.runtimeType})');
  }

  Future<List> getListData(String entity, List items, [String variablesSignature = '', String filters = '', Map variables = const {}]) async {
    final response = await post(jsonEncode({
      "query": getItems({
        "query$variablesSignature": { "${entity}List$filters": { "items": items } }
      }),
      "variables": variables
    }));
    if (response.statusCode != 200) throw Exception(response.body);
    final Map body = jsonDecode(utf8.decode(response.bodyBytes));
    final Map data = body['data'];
    if (data == null) throw Exception(body['errors'][0]['message']);
    List entitiesData = data[entity+'List']['items'];
    return entitiesData;
  }

  Future<List<Category>> getCategories() async {
    var categoriesData = await getListData("categories", ["id", "name", { "picture": "downloadUrl" }]);
    return [for (var item in categoriesData) Category(item['id'], item['name'], NetworkImage(item['picture']['downloadUrl']))];
  }

  Future<List<Tag>> getTags() async {
    var tagsData = await getListData("tags", ["id", "name", "description"]);
    return [for (var item in tagsData) Tag(id: item['id'], name: item['name'], description: item['description'])];
  }

  Future<List<Product>> getProducts(ListingFilters filters, LocationData location) async {
    print('Getting products...');
    final String tagsFilter = filters.tags.map<String>((tag) => '''
    {
      tags: {
        some: {
          id: {
            equals: \"${tag.id}\"
          }
        }
      }
    }
    ''').toList().join(',');
    final String idsFilter = filters.productsIDs==null? '' : '''
    ,{
      id: {
        in: ${jsonEncode(filters.productsIDs)}
      }
    }
    ''';
    final String variableSignature = "(\$search: String, \$category: ID)";
    final String filterStr = '''
    (filter: {
            AND: [
              {
                _fullText: \$search
              },
              {
                categories: {
                  some: {
                    id: {
                      contains: \$category
                    }
                  }
                }
              }$idsFilter, $tagsFilter
            ]
          }, extraFields: {
            shop: {
              location: {
                as: "distance"
                fn: {
                  distance: {
                    from: { type: Point, coordinates: [${location.latitude},${location.longitude}] }
                    unit: meters
                  }
                }
              }
            }
          }, sort: {
            shop: {
              _extraField: {
                alias: "distance",
                direction: ASC
              }
            }
          })
    ''';
    var productsData = await getListData("products", [
      "id",
      "name",
      "description",
      {"pictures": {
        "items": "downloadUrl"
      }},
      "price",
      {"tags": {
        "items": [
          "id",
          "name",
          "description"
        ]
      }},
      {"shop": [
        {
          "location": "coordinates"
        },
        {"address": ["street1", "street2", "zip", "city"]
        },
        {
          "vendor": "name"
        },
        {"phone": ["code", "number"]},
        {"whatsapp": ["code", "number"]},
        "email"
      ]
      }], variableSignature, filterStr, {
      "search": filters.search,
      "category": filters.category != null ? filters.category.id : ''
    });
    return [for (var p in productsData) Product(
        id: p['id'],
        name: p['name'],
        description: p['description'],
        //categories: [1,2],
        images: p['pictures']['items'].map<NetworkImage>((picData){return NetworkImage(picData['downloadUrl']);}).toList(),
        price: Decimal.parse(p['price'].toString()),
        vendor: Vendor(
          name: p['shop']['vendor']['name'],
          location: LatLng(p['shop']['location']['coordinates'][0],p['shop']['location']['coordinates'][1]),
          address: '${p['shop']['address']['street1']} ${p['shop']['address']['street2']??''}, ${p['shop']['address']['zip']} ${p['shop']['address']['city']}',
          phone: '+'+p['shop']['phone']['code']+' '+p['shop']['phone']['number'],
          whatsapp: '+'+p['shop']['whatsapp']['code']+' '+p['shop']['whatsapp']['number'],
          email: p['shop']['email']
        ),
        tags: p['tags']['items'].map<Tag>((tag){return Tag(id: tag['id'], name: tag['name'], description: tag['description']);}).toList(),
        rating: 4,
        location: LatLng(p['shop']['location']['coordinates'][0],p['shop']['location']['coordinates'][1]),
        targetLocation: location
    )];

  }

}