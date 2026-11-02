import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_success_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/navigation/presentation/main_shell_screen.dart';
import '../../features/orders/presentation/order_details_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/product_details/presentation/product_details_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/about_screen.dart';
import '../../features/profile/presentation/help_support_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/saved_addresses_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash Route
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Stateful Nested Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 2: Categories
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              name: RouteNames.categories,
              builder: (context, state) => const CategoriesScreen(),
            ),
          ],
        ),

        // Tab 3: Products
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              name: RouteNames.products,
              builder: (context, state) => const ProductsScreen(),
            ),
          ],
        ),

        // Tab 4: Wishlist
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              name: RouteNames.wishlist,
              builder: (context, state) => const WishlistScreen(),
            ),
          ],
        ),

        // Tab 5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Product Details Screen (Dynamic with ID!)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/product/:id',
      name: RouteNames.productDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '5171';
        return ProductDetailsScreen(productId: id);
      },
    ),

    // Search Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/search',
      name: RouteNames.search,
      builder: (context, state) => const SearchScreen(),
    ),

    // Cart Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cart',
      name: RouteNames.cart,
      builder: (context, state) => const CartScreen(),
    ),

    // Checkout Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/checkout',
      name: RouteNames.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),

    // Order Success Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/order-success/:orderId',
      name: RouteNames.orderSuccess,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderSuccessScreen(orderId: orderId);
      },
    ),

    // Orders Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/orders',
      name: RouteNames.orders,
      builder: (context, state) => const OrdersScreen(),
    ),

    // Order Details Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/order/:id',
      name: RouteNames.orderDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),

    // Saved Addresses Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/saved-addresses',
      name: RouteNames.savedAddresses,
      builder: (context, state) => const SavedAddressesScreen(),
    ),

    // About Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      name: RouteNames.about,
      builder: (context, state) => const AboutScreen(),
    ),

    // Help & Support Screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/help-support',
      name: RouteNames.helpSupport,
      builder: (context, state) => const HelpSupportScreen(),
    ),
  ],
);

