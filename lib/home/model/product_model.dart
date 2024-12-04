
class ProductModel {
  String? barCode;
  double? salesRate;
  String? attribute1Code;
  String? attribute;

  ProductModel(
      {this.barCode, this.salesRate, this.attribute1Code, this.attribute});

  ProductModel.fromJson(Map<String, dynamic> json) {
    barCode = json['BarCode'];
    salesRate = json['SalesRate'];
    attribute1Code = json['Attribute1Code'];
    attribute = json['Attribute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['BarCode'] = barCode;
    data['SalesRate'] = salesRate;
    data['Attribute1Code'] = attribute1Code;
    data['Attribute'] = attribute;
    return data;
  }
}
