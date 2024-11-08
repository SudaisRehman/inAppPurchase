// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:inapppurchase/purchaseScreen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'In-App Purchase Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: PurchaseScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freemium App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
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
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Purchase successful!")),
      );
      // Here you would typically update your app state to unlock premium features
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Freemium App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Freemium App!'),
            SizedBox(height: 20),
            if (_products.isNotEmpty)
              ElevatedButton(
                onPressed: () => _buyProduct(_products[0]),
                child: Text('Upgrade to Premium for ${_products[0].price}'),
              ),
            if (_products.isEmpty)
              CircularProgressIndicator(), // Show a loading indicator
          ],
        ),
      ),
    );
  }
}
