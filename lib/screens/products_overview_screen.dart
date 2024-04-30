import 'package:flutter/material.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/provider/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import '../widgets/product_grid.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';

enum FilterOption {
  OnlyFavorites,
  ShowAll,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isinit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Future.delayed(Duration.zero).then((value) =>
    //     Provider.of<Products>(context).fetchAndSetProducts()
    // ); this will work but huhh.......
    super.initState();
  }

  @override
  void didChangeDependencies() async{
    if (_isinit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              if (selectedValue == FilterOption.OnlyFavorites) {
                products.showOnlyFavorites();
              } else {
                products.showAll();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.OnlyFavorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.ShowAll,
              )
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cart, ch) => myBadge(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart),
              ),
              value: cart.itemCount.toString(),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Loading Products...")
                ],
              ),
            )
          : ProductGrid(),
    );
  }
}
