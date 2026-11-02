import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/asset_constants.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

const List<AddressModel> mockAddresses = [
  AddressModel(
    id: 'addr-1',
    name: 'Senthil Kumar',
    phone: '+91 98765 43210',
    streetAddress: 'Plot No. 42, 2nd Cross, Electronics City Phase 1',
    locality: 'Near Tech Park Gate 3',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560100',
    isDefault: true,
    type: 'Home',
  ),
  AddressModel(
    id: 'addr-2',
    name: 'Senthil Kumar (Office)',
    phone: '+91 98765 43210',
    streetAddress: 'Circuit Point Labs, 3rd Floor, Innovation Tower',
    locality: 'Whitefield Main Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560066',
    isDefault: false,
    type: 'Work',
  ),
];

const _initialUser = UserModel(
  id: 'usr-001',
  name: 'Senthil Kumar',
  email: 'senthil.circuit@example.com',
  phone: '+91 98765 43210',
  avatarUrl: AssetConstants.logo,
  addresses: mockAddresses,
);

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(_initialUser);

  void setDefaultAddress(String addressId) {
    final updated = state.addresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
    state = state.copyWith(addresses: updated);
  }

  void addAddress(AddressModel address) {
    state = state.copyWith(addresses: [...state.addresses, address]);
  }

  void removeAddress(String addressId) {
    state = state.copyWith(
      addresses: state.addresses.where((a) => a.id != addressId).toList(),
    );
  }

  AddressModel get defaultAddress =>
      state.addresses.firstWhere((a) => a.isDefault, orElse: () => state.addresses.first);
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

final selectedAddressProvider = StateProvider<AddressModel>((ref) {
  return ref.watch(userProvider.notifier).defaultAddress;
});
