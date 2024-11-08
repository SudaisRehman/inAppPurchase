import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  String _productId = 'premium_upgrade'; // Replace with your product ID

  @override
  void initState() {
    super.initState();
    _initializePurchase();
    _loadProducts();
  }

  void _initializePurchase() {
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdates(purchaseDetailsList);
    });
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({_productId});
    if (response.notFoundIDs.isNotEmpty) {
      // Handle error if product ID not found
    }
    setState(() {
      _products = response.productDetails;
    });
  }

  void _buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handlePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase error: ${purchaseDetails.error?.message}')),
        );
      }
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _handlePurchase(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == _productId) {
      // Unlock premium features here
      print("Purchase successful! Unlock premium features.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In-App Purchase Demo'),
      ),
      body: Center(
        child: _products.isEmpty
            ? Text("No products available")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _products.map((product) {
                  return ElevatedButton(
                    onPressed: () => _buyProduct(product),
                    child: Text("Buy ${product.title} for ${product.price}"),
                  );
                }).toList(),
              ),
      ),
    );
  }
}