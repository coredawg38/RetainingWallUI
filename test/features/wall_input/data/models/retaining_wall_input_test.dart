/// Retaining Wall Input Model Tests
///
/// Unit tests for the RetainingWallInput, Address, and CustomerInfo models.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retaining_wall_builder/features/wall_input/data/models/retaining_wall_input.dart';
import 'package:retaining_wall_builder/core/constants/app_constants.dart';

void main() {
  group('Address', () {
    test('creates with default values', () {
      const address = Address();

      expect(address.street, isEmpty);
      expect(address.city, isEmpty);
      expect(address.state, isEmpty);
      expect(address.zipCode, equals(0));
    });

    test('creates with specified values', () {
      const address = Address(
        street: '123 Main St',
        city: 'Test City',
        state: 'UT',
        zipCode: 84101,
      );

      expect(address.street, equals('123 Main St'));
      expect(address.city, equals('Test City'));
      expect(address.state, equals('UT'));
      expect(address.zipCode, equals(84101));
    });

    test('serializes to JSON with correct keys', () {
      const address = Address(
        street: '123 Main St',
        city: 'Test City',
        state: 'UT',
        zipCode: 84101,
      );

      final json = address.toJson();

      expect(json['street'], equals('123 Main St'));
      expect(json['City'], equals('Test City'));
      expect(json['State'], equals('UT'));
      expect(json['Zip Code'], equals(84101));
    });

    test('deserializes from JSON', () {
      final json = {
        'street': '456 Oak Ave',
        'City': 'Another City',
        'State': 'CA',
        'Zip Code': 90210,
      };

      final address = Address.fromJson(json);

      expect(address.street, equals('456 Oak Ave'));
      expect(address.city, equals('Another City'));
      expect(address.state, equals('CA'));
      expect(address.zipCode, equals(90210));
    });

    test('copyWith creates new instance with updated values', () {
      const original = Address(
        street: '123 Main St',
        city: 'Test City',
        state: 'UT',
        zipCode: 84101,
      );

      final updated = original.copyWith(city: 'New City');

      expect(updated.street, equals('123 Main St'));
      expect(updated.city, equals('New City'));
      expect(updated.state, equals('UT'));
      expect(updated.zipCode, equals(84101));
      expect(original.city, equals('Test City')); // Original unchanged
    });
  });

  group('CustomerInfo', () {
    test('creates with default values', () {
      const info = CustomerInfo();

      expect(info.name, isEmpty);
      expect(info.email, isEmpty);
      expect(info.phone, isEmpty);
      expect(info.mailingAddress.street, isEmpty);
    });

    test('creates with specified values', () {
      const info = CustomerInfo(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-1234',
        mailingAddress: Address(
          street: '789 Pine Rd',
          city: 'Mail City',
          state: 'NY',
          zipCode: 10001,
        ),
      );

      expect(info.name, equals('John Doe'));
      expect(info.email, equals('john@example.com'));
      expect(info.phone, equals('555-1234'));
      expect(info.mailingAddress.city, equals('Mail City'));
    });

    test('serializes to JSON', () {
      const info = CustomerInfo(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555-5678',
      );

      final json = info.toJson();

      expect(json['name'], equals('Jane Doe'));
      expect(json['email'], equals('jane@example.com'));
      expect(json['phone'], equals('555-5678'));
      // The mailing_address is an Address object that can be converted to JSON
      expect(json['mailing_address'], isA<Address>());
    });
  });

  group('RetainingWallInput', () {
    test('creates with default values', () {
      const input = RetainingWallInput();

      expect(input.height, equals(WallConstraints.defaultHeight));
      expect(input.material, equals(WallMaterialType.cmu));
      expect(input.surcharge, equals(SurchargeType.flat));
      expect(input.optimizationParameter, equals(OptimizationType.excavation));
      expect(input.soilStiffness, equals(SoilStiffnessType.stiff));
      expect(input.topping, equals(WallConstraints.defaultTopping));
      expect(input.hasSlab, isFalse);
      expect(input.toe, equals(WallConstraints.defaultToe));
    });

    test('creates with specified values', () {
      const input = RetainingWallInput(
        height: 96,
        material: WallMaterialType.concrete,
        surcharge: SurchargeType.slope1to2,
        optimizationParameter: OptimizationType.footing,
        soilStiffness: SoilStiffnessType.soft,
        topping: 4,
        hasSlab: true,
        toe: 24,
      );

      expect(input.height, equals(96));
      expect(input.material, equals(WallMaterialType.concrete));
      expect(input.surcharge, equals(SurchargeType.slope1to2));
      expect(input.optimizationParameter, equals(OptimizationType.footing));
      expect(input.soilStiffness, equals(SoilStiffnessType.soft));
      expect(input.topping, equals(4));
      expect(input.hasSlab, isTrue);
      expect(input.toe, equals(24));
    });

    test('serializes to JSON with correct keys', () {
      const input = RetainingWallInput(
        height: 72,
        material: WallMaterialType.cmu,
        hasSlab: true,
      );

      final json = input.toJson();

      expect(json['height'], equals(72));
      expect(json['material'], equals(WallMaterialType.cmu));
      expect(json['has_slab'], isTrue);
      expect(json['optimization_parameter'], equals(OptimizationType.excavation));
      expect(json['soil_stiffness'], equals(SoilStiffnessType.stiff));
      // Nested objects are Address and CustomerInfo that can be serialized
      expect(json['site_address'], isA<Address>());
      expect(json['customer_info'], isA<CustomerInfo>());
    });

    test('deserializes from JSON', () {
      final json = {
        'height': 120.0,
        'material': 1,
        'surcharge': 2,
        'optimization_parameter': 1,
        'soil_stiffness': 0,
        'topping': 6,
        'has_slab': false,
        'toe': 30,
        'site_address': {
          'street': '123 Site St',
          'City': 'Site City',
          'State': 'TX',
          'Zip Code': 75001,
        },
        'customer_info': {
          'name': 'Test User',
          'email': 'test@test.com',
          'phone': '555-0000',
          'mailing_address': {
            'street': '456 Mail St',
            'City': 'Mail City',
            'State': 'FL',
            'Zip Code': 33101,
          },
        },
      };

      final input = RetainingWallInput.fromJson(json);

      expect(input.height, equals(120.0));
      expect(input.material, equals(1));
      expect(input.surcharge, equals(2));
      expect(input.siteAddress.city, equals('Site City'));
      expect(input.customerInfo.name, equals('Test User'));
    });
  });

  group('RetainingWallInput extensions', () {
    test('heightInFeet calculates correctly', () {
      const input = RetainingWallInput(height: 96);
      expect(input.heightInFeet, equals(8.0));

      const input2 = RetainingWallInput(height: 48);
      expect(input2.heightInFeet, equals(4.0));
    });

    test('price calculates based on height tiers', () {
      // Small wall (under 4 feet = 48 inches)
      const smallWall = RetainingWallInput(height: 36);
      expect(smallWall.price, equals(PricingTiers.smallWallPrice));

      // Medium wall (4-8 feet = 48-96 inches)
      const mediumWall = RetainingWallInput(height: 72);
      expect(mediumWall.price, equals(PricingTiers.mediumWallPrice));

      // Large wall (over 8 feet = over 96 inches)
      const largeWall = RetainingWallInput(height: 120);
      expect(largeWall.price, equals(PricingTiers.largeWallPrice));
    });

    test('hasValidWallParameters validates constraints', () {
      const valid = RetainingWallInput(
        height: 72,
        toe: 24,
        topping: 4,
      );
      expect(valid.hasValidWallParameters, isTrue);

      const invalidHeight = RetainingWallInput(height: 12);
      expect(invalidHeight.hasValidWallParameters, isFalse);

      const tooTall = RetainingWallInput(height: 200);
      expect(tooTall.hasValidWallParameters, isFalse);
    });

    test('hasValidSiteAddress checks all fields', () {
      const valid = RetainingWallInput(
        siteAddress: Address(
          street: '123 Main St',
          city: 'Test City',
          state: 'UT',
          zipCode: 84101,
        ),
      );
      expect(valid.hasValidSiteAddress, isTrue);

      const missingStreet = RetainingWallInput(
        siteAddress: Address(
          city: 'Test City',
          state: 'UT',
          zipCode: 84101,
        ),
      );
      expect(missingStreet.hasValidSiteAddress, isFalse);
    });

    test('hasValidCustomerInfo checks all fields', () {
      const valid = RetainingWallInput(
        customerInfo: CustomerInfo(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '555-1234',
          mailingAddress: Address(
            street: '123 Main St',
            city: 'Test City',
            state: 'UT',
            zipCode: 84101,
          ),
        ),
      );
      expect(valid.hasValidCustomerInfo, isTrue);

      const missingEmail = RetainingWallInput(
        customerInfo: CustomerInfo(
          name: 'John Doe',
          phone: '555-1234',
          mailingAddress: Address(
            street: '123 Main St',
            city: 'Test City',
            state: 'UT',
            zipCode: 84101,
          ),
        ),
      );
      expect(missingEmail.hasValidCustomerInfo, isFalse);
    });

    test('materialLabel returns correct string', () {
      const concrete = RetainingWallInput(material: WallMaterialType.concrete);
      expect(concrete.materialLabel, equals('Concrete'));

      const cmu = RetainingWallInput(material: WallMaterialType.cmu);
      expect(cmu.materialLabel, equals('CMU (Concrete Masonry Unit)'));
    });

    test('surchargeLabel returns correct string', () {
      const flat = RetainingWallInput(surcharge: SurchargeType.flat);
      expect(flat.surchargeLabel, equals('Flat (No Slope)'));

      const slope = RetainingWallInput(surcharge: SurchargeType.slope1to2);
      expect(slope.surchargeLabel, equals('1:2 Slope'));
    });
  });
}
