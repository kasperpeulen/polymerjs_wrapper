library jsutils;

import 'dart:js';
import 'dart:convert';
import 'package:polymerjs/polymer.dart';


final JsObject _jsJSON = context['JSON'];
final JsObject _Object = context['Object'];

/**
 * Convert a Dart object to a suitable parameter to a JavaScript method.
 */
dynamic jsify(Object dartObject, [Function typeConstructor]) {
  if (dartObject == null) {
    return null;
  } else if (dartObject is JsObject) {
    return dartObject;
  } else if (dartObject is List) {
    return new JsArray.from(dartObject.map((item) => jsify(item, typeConstructor)));
  } else if (dartObject is Map<String, dynamic>) {
    JsObject jsObject = new JsObject(context["Object"]);
    dartObject.forEach((key, value) {
      jsObject[key] = jsify(value, typeConstructor);
    });
    return jsObject;
  } else if (dartObject is Type) {
    return dartType2Js[dartObject];
  } else if (dartObject is Function) {
    return new JsFunction.withThis((HtmlElement element,
                                    [arg0, arg1, arg2, arg3, arg4, arg5, arg6]) {
      if (typeConstructor == null) {
        typeConstructor = (element) => new PolymerElement.from(element);
      }
      var polymerElement = typeConstructor(element);
      List args = [polymerElement, arg0, arg1, arg2, arg3, arg4, arg5, arg6];
      args.removeWhere((e) => e == null);
      Function.apply(dartObject, args);
    });
  }
  return dartObject;
}


Map<Type, JsFunction> dartType2Js = {
  int : context['Number'],
  double : context['Number'],
  num : context['Number'],
  bool : context["Boolean"],
  String : context["String"],
  List : context["Array"],
  DateTime : context["DateTime"],
  Map : context["Object"],
  JsObject : context["Object"],
  Function : context["JsFunction"]
};

/**
 * Convert a JavaScript result object to an equivalent Dart map.
 */
Map mapify(JsObject obj) {
  if (obj == null) return null;
  return JSON.decode(_jsJSON.callMethod('stringify', [obj]));
}

JsObject jsType(Type type) {
  switch ('$type') {
    case 'int':
    case 'double':
    case 'num':
      return context['Number'];
    case 'bool':
      return context['Boolean'];
    case 'List':
      return context['Array'];
    case 'DateTime':
      return context['DateTime'];
    case 'String':
      return context['String'];
    case 'Map':
    case 'JsObject':
    default:
      return context['Object'];
  }
}

HtmlElement jsElementToDartElement(jsHTMLElement) {
  context['hack_to_convert_jsobject_to_html_element'] = jsHTMLElement;
  Element element = context['hack_to_convert_jsobject_to_html_element'];
  context.deleteProperty('hack_to_convert_jsobject_to_html_element');
  return element;
}
