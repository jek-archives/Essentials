import 'package:flutter/material.dart';

class SizeGuideTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Size')),
          DataColumn(label: Text('Bust')),
          DataColumn(label: Text('Waist')),
          DataColumn(label: Text('Hips')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('XS\n0')),
            DataCell(Text('32')),
            DataCell(Text('24–25')),
            DataCell(Text('34–35')),
          ]),
          DataRow(cells: [
            DataCell(Text('S\n2–4')),
            DataCell(Text('34')),
            DataCell(Text('26–27')),
            DataCell(Text('36–39')),
          ]),
          DataRow(cells: [
            DataCell(Text('M\n6–8')),
            DataCell(Text('36')),
            DataCell(Text('28–29')),
            DataCell(Text('38–39')),
          ]),
          DataRow(cells: [
            DataCell(Text('L\n10–12')),
            DataCell(Text('38–40')),
            DataCell(Text('31–33')),
            DataCell(Text('41–43')),
          ]),
          DataRow(cells: [
            DataCell(Text('XL\n14')),
            DataCell(Text('42')),
            DataCell(Text('34')),
            DataCell(Text('44')),
          ]),
        ],
      ),
    );
  }
}