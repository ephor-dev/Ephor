import 'package:excel/excel.dart';

class ExcelGenerator {
  static List<int>? generateExcelBytes(List<Map<String, dynamic>> jsonData) {
    if (jsonData.isEmpty) return null;

    var excel = Excel.createExcel();

    String sheetName = 'Sheet1';
    Sheet sheet = excel[sheetName];

    List<String> headers = jsonData.first.keys.toList();
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (var row in jsonData) {
      List<CellValue> rowData = headers.map((key) {
        final value = row[key];
        
        if (value == null) return TextCellValue("");
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        return TextCellValue(value.toString());
      }).toList();
      
      sheet.appendRow(rowData);
    }

    return excel.save();
  }
}