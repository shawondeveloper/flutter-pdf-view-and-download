import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewPage extends StatefulWidget {
  final String url;
  final String name;
  PdfViewPage({this.url, this.name});
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool loading = true;
  PDFDocument pdfDocumnet;

  loadPdf() async {
    pdfDocumnet = await PDFDocument.fromURL(widget.url);
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : PDFViewer(
            document: pdfDocumnet),
    );
  }
}
