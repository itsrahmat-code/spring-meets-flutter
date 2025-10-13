import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../entity/product.dart'; // Make sure Product class is correctly capitalized
import '../service/product_service.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;
  final ProductService service = ProductService();

  @override
  void initState() {
    super.initState();
    futureProducts = service.fetchProducts();
  }

  void _refresh() {
    setState(() {
      futureProducts = service.fetchProducts();
    });
  }

  Future<void> _saveQrToDownloads(GlobalKey key) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Directory? downloadDir;

      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir != null && await downloadDir.exists()) {
        final file = File(
            '${downloadDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('QR Code saved to ${file.path}'),
        ));
      } else {
        throw Exception('Download directory not found');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save QR Code'),
      ));
    }
  }

  void _showQrDialog(Product product) {
    final GlobalKey qrKey = GlobalKey();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('QR Code for ${product.productName}'),
        content: RepaintBoundary(
          key: qrKey,
          child: QrImage(
            data: jsonEncode({
              "id": product.id,
              "name": product.productName,
              "price": product.price,
              "quantity": product.quantity
            }),
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveQrToDownloads(qrKey);
            },
            child: Text("Download QR"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.productName ?? ''),
                  subtitle: Text('Qty: ${p.quantity} | \$${p.price?.toStringAsFixed(2) ?? '0.00'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.qr_code),
                        onPressed: () {
                          _showQrDialog(p);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await service.deleteProduct(p.id!);
                          _refresh();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to update screen with this product
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Product Screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
