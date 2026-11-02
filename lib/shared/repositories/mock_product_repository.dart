import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/asset_constants.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'product_repository.dart';

class MockProductRepository implements ProductRepository {
  // Categories matching the website screenshots
  static final List<CategoryModel> _categories = [
    const CategoryModel(
      id: 'cat-sensors',
      name: 'Sensors',
      icon: Icons.sensors_rounded,
      productCount: 142,
      bgColor: AppColors.catSensorsBg,
      iconColor: AppColors.catSensorsIcon,
    ),
    const CategoryModel(
      id: 'cat-dev-boards',
      name: 'Dev Boards',
      icon: Icons.developer_board_rounded,
      productCount: 88,
      bgColor: AppColors.catDevBoardsBg,
      iconColor: AppColors.catDevBoardsIcon,
    ),
    const CategoryModel(
      id: 'cat-arduino',
      name: 'Arduino',
      icon: Icons.memory_rounded,
      productCount: 64,
      bgColor: AppColors.catArduinoBg,
      iconColor: AppColors.catArduinoIcon,
    ),
    const CategoryModel(
      id: 'cat-displays',
      name: 'Displays',
      icon: Icons.tv_rounded,
      productCount: 53,
      bgColor: AppColors.catDisplaysBg,
      iconColor: AppColors.catDisplaysIcon,
    ),
    const CategoryModel(
      id: 'cat-modules',
      name: 'Modules',
      icon: Icons.view_in_ar_rounded,
      productCount: 196,
      bgColor: AppColors.catModulesBg,
      iconColor: AppColors.catModulesIcon,
    ),
    const CategoryModel(
      id: 'cat-ics',
      name: 'ICs & Chips',
      icon: Icons.hardware_rounded,
      productCount: 312,
      bgColor: AppColors.catICsBg,
      iconColor: AppColors.catICsIcon,
    ),
    const CategoryModel(
      id: 'cat-power',
      name: 'Power Supplies',
      icon: Icons.bolt_rounded,
      productCount: 75,
      bgColor: AppColors.catPowerBg,
      iconColor: AppColors.catPowerIcon,
    ),
    const CategoryModel(
      id: 'cat-cables',
      name: 'Cables & Wires',
      icon: Icons.cable_rounded,
      productCount: 118,
      bgColor: AppColors.catCablesBg,
      iconColor: AppColors.catCablesIcon,
    ),
    const CategoryModel(
      id: 'cat-connectors',
      name: 'Connectors',
      icon: Icons.power_rounded,
      productCount: 94,
      bgColor: AppColors.catConnectorsBg,
      iconColor: AppColors.catConnectorsIcon,
    ),
    const CategoryModel(
      id: 'cat-accessories',
      name: 'Accessories',
      icon: Icons.business_center_rounded,
      productCount: 165,
      bgColor: AppColors.catAccessoriesBg,
      iconColor: AppColors.catAccessoriesIcon,
    ),
  ];

  // Banners matching the website home screenshot
  static final List<BannerModel> _banners = [
    const BannerModel(
      id: 'b-1',
      title: 'Hot Deals on Electronics',
      subtitle: 'Limited-time prices on popular components & dev boards',
      badgeText: '🔥 HOT DEALS',
      productId: '5171',
      imageUrl: AssetConstants.productMicrocontroller,
      actionLabel: 'View Deals',
      promoTag: 'SPECIAL OFFER',
      productPrice: 1750,
      productMrp: 2431,
      discountPercentage: 28,
      productTitle: 'DWIN Wifi Module and Cloud Platform',
    ),
    const BannerModel(
      id: 'b-2',
      title: 'Precision Microcontrollers',
      subtitle: 'Original ESP32, Arduino & Raspberry Pi hardware in stock',
      badgeText: '⚡ NEW ARRIVALS',
      productId: '5173',
      imageUrl: AssetConstants.productCpu,
      actionLabel: 'Shop Hardware',
      promoTag: 'GENUINE CHIPS',
      productPrice: 580,
      productMrp: 850,
      discountPercentage: 32,
      productTitle: 'ESP32 Dual-Core WiFi + Bluetooth Board',
    ),
    const BannerModel(
      id: 'b-3',
      title: 'High-Performance Audio & IoT',
      subtitle: 'Fine FM Players, DSP audio decoders and amplifier kits',
      badgeText: '⭐ TOP RATED',
      productId: '5172',
      imageUrl: AssetConstants.productTvRemote,
      actionLabel: 'Explore Audio',
      promoTag: 'BEST SELLER',
      productPrice: 850,
      productMrp: 1164,
      discountPercentage: 27,
      productTitle: 'Fine Fm Player Quantity Performance',
    ),
  ];

  // Over 30 realistic electronics products with detailed specs, features, and realistic prices matching screenshots
  static final List<ProductModel> _products = [
    // 1 - From screenshot 1 & 2
    const ProductModel(
      id: '5171',
      name: 'DWIN Wifi Module and Cloud Platform',
      brand: 'IMPORTED',
      model: 'DWIN-WIFI-V4A',
      categoryId: 'cat-modules',
      categoryName: 'Modules',
      subCategory: 'Wireless & IoT Modules',
      description:
          'High performance DWIN WiFi module with integrated cloud platform firmware. Built for industrial IoT telemetrics, smart telemetry display boards, and remote cloud communication protocols. Features onboard antenna, UART communication, and ultra low power consumption modes.',
      price: 1750,
      mrp: 2431,
      discountPercentage: 28,
      rating: 4.7,
      reviewCount: 92,
      stock: 45,
      viewsCount: 340,
      soldCount: 88,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productIcTimer,
        AssetConstants.productDiode,
      ],
      specifications: {
        'Operating Voltage': '3.3V - 5.0V DC',
        'Protocol': '802.11 b/g/n (2.4GHz)',
        'Interface': 'UART Serial TTL',
        'Baud Rate': '115200 bps default',
        'Antenna': 'Onboard Ceramic Antenna',
        'Flash Memory': '4MB SPI Flash',
        'Operating Temp': '-40°C to +85°C',
        'Security': 'WPA/WPA2 PSK',
      },
      features: [
        'Cloud platform ready with out-of-the-box telemetry',
        'Supports standard AT command set',
        'Compact form factor for easy PCB soldering',
        'Hardware watchdog timer for rock-solid stability',
        'Deep sleep power consumption under 20uA',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      isRecommended: true,
      tags: ['wifi', 'iot', 'dwin', 'cloud', 'wireless', 'telemetry'],
    ),

    // 2 - From screenshot 2 & 3
    const ProductModel(
      id: '5172',
      name: 'Fine Fm Player Quantity Performance',
      brand: 'FINE',
      model: 'FN-FM-007MP3',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'woofers & speakers',
      description:
          'Digital USB & FM System with TF Card, AUX In, Bluetooth 5.0 Audio Decoder, and wireless IR remote control. Ideal for custom speaker builds, car audio retrofits, bench audio setups, and electronic sound projects.',
      price: 850,
      mrp: 1164,
      discountPercentage: 27,
      rating: 4.5,
      reviewCount: 48,
      stock: 120,
      viewsCount: 512,
      soldCount: 28,
      images: [
        AssetConstants.productTvRemote,
        AssetConstants.productCapacitor,
        AssetConstants.productResistor,
      ],
      specifications: {
        'Power Input': '12V DC (9V - 14V)',
        'Audio Output': 'Stereo Line Out (RCA/3.5mm)',
        'Connectivity': 'Bluetooth 5.0, USB, FM, TF Card, AUX',
        'Remote Control': 'IR Remote included',
        'FM Frequency': '87.5 MHz - 108.0 MHz',
        'Display': 'Red LED Digital Display',
        'Dimensions': '108mm x 25mm x 38mm',
      },
      features: [
        'Includes dedicated IR remote controller',
        'Supports lossless MP3 / WMA / WAV playback',
        'High sensitivity digital FM tuner',
        'Pre-amplified audio output with zero noise floor',
        '100% authentic component multi-point bench tested',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['fine', 'audio', 'fm player', 'bluetooth', 'speakers'],
    ),

    // 3 - From screenshot 2 (Network switch 400W)
    const ProductModel(
      id: '5173',
      name: '8ge+2ge+2sfp(400 Watt)',
      brand: 'IMPORTED',
      model: 'POE-8G2G2S-400W',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Network Switch',
      description:
          'Industrial Gigabit PoE+ Switch featuring 8 Gigabit Ethernet PoE ports with up to 400W total budget, 2 Gigabit Uplink ports, and 2 SFP fiber optical slots. Engineered for CCTV surveillance networks, enterprise Wi-Fi APs, and heavy IoT telemetry.',
      price: 31719,
      mrp: 41736,
      discountPercentage: 24,
      rating: 4.8,
      reviewCount: 64,
      stock: 18,
      viewsCount: 290,
      soldCount: 35,
      images: [
        AssetConstants.productGpu,
        AssetConstants.productSsd,
        AssetConstants.productCpu,
      ],
      specifications: {
        'PoE Power Budget': '400 Watt Total',
        'Port Configuration': '8 x 10/100/1000M PoE + 2 Uplink + 2 SFP',
        'Standard': 'IEEE 802.3af/at Compliant',
        'Switching Capacity': '24 Gbps wire speed',
        'Enclosure': 'Heavy-duty Metal Chassis, Rackmountable',
        'Surge Protection': '6kV Lightning Protection per port',
      },
      features: [
        'High power 400W budget for PTZ IP cameras',
        'Dual Gigabit SFP fiber slots for long-haul transmission',
        'VLAN isolation switch for CCTV broadcast storm prevention',
        'Internal industrial grade MeanWell power supply',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['network', 'switch', 'poe', 'gigabit', 'sfp', 'cctv'],
    ),

    // 4 - From screenshot 2 (Network switch 16fe 150W)
    const ProductModel(
      id: '5174',
      name: '16fe+2ge+1sfp(150 Watt)',
      brand: 'IMPORTED',
      model: 'POE-16F2G1S-150W',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Network Switch',
      description:
          'Robust 16 Fast Ethernet PoE+ Ports switch with 2 Gigabit RJ45 Uplink Ports and 1 Gigabit SFP Slot. Features an integrated 150W intelligent power supply designed for office networks and multi-camera security systems.',
      price: 28765,
      mrp: 36411,
      discountPercentage: 21,
      rating: 4.8,
      reviewCount: 42,
      stock: 25,
      viewsCount: 188,
      soldCount: 22,
      images: [
        AssetConstants.productSsd,
        AssetConstants.productGpu,
      ],
      specifications: {
        'PoE Power Budget': '150 Watt',
        'Ports': '16 x 10/100M PoE + 2 Gigabit Uplink + 1 SFP',
        'Standard': 'IEEE 802.3af/at',
        'Transmission Distance': 'Up to 250m in Extend Mode',
        'Cooling': 'Smart silent cooling fan',
      },
      features: [
        'Extend mode supports CCTV cable runs up to 250 meters',
        'QoS priority optimization for video streams',
        'Auto MDI/MDIX on all RJ45 ports',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: false,
      tags: ['network', 'switch', 'poe', '16port', 'cctv'],
    ),

    // 5 - From screenshot 2 (Network switch 8ge 1fiber 150W)
    const ProductModel(
      id: '5175',
      name: '8ge+2ge+1fiber(150 Watt)',
      brand: 'IMPORTED',
      model: 'POE-8G2G1F-150W',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Network Switch',
      description:
          'Smart PoE switch with 8 Gigabit PoE RJ45 ports, 2 Gigabit RJ45 Uplink ports, and 1 dedicated optical fiber uplink. Delivers 150W total PoE capacity for demanding enterprise edge deployments.',
      price: 21019,
      mrp: 25633,
      discountPercentage: 18,
      rating: 4.8,
      reviewCount: 39,
      stock: 14,
      viewsCount: 165,
      soldCount: 19,
      images: [
        AssetConstants.productCpu,
        AssetConstants.productGpu,
      ],
      specifications: {
        'Power Budget': '150 Watt',
        'Ports': '8 x 1Gbps PoE + 2 x 1Gbps Uplink + 1 SC Fiber',
        'Bandwidth': '20 Gbps',
        'Operating Temp': '0°C to 50°C',
      },
      features: [
        'Built-in SC optical fiber transceiver interface',
        'One-key CCTV mode with port isolation',
        'Energy efficient ethernet (IEEE 802.3az)',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: false,
      tags: ['switch', 'fiber', 'poe', 'gigabit'],
    ),

    // 6 - From screenshot 2 (Network switch 8ge 2sfp 150W)
    const ProductModel(
      id: '5176',
      name: '8ge+2ge+2sfp(150 Watt)',
      brand: 'IMPORTED',
      model: 'POE-8G2G2S-150W',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Network Switch',
      description:
          'Compact 8-Port Gigabit PoE Managed/Unmanaged Switch with 2 Gigabit Uplink ports and dual SFP fiber slots. Provides reliable 150W PoE power distribution with port priority assignment.',
      price: 14750,
      mrp: 17353,
      discountPercentage: 15,
      rating: 4.8,
      reviewCount: 51,
      stock: 30,
      viewsCount: 220,
      soldCount: 40,
      images: [
        AssetConstants.productGpu,
        AssetConstants.productCpu,
      ],
      specifications: {
        'PoE Power Budget': '150 Watt',
        'Ports': '8 Gigabit PoE + 2 Gigabit RJ45 + 2 SFP',
        'Standard': 'IEEE 802.3af/at',
        'Mounting': 'Desktop / Wall-mount ears included',
      },
      features: [
        'Dual SFP cage for optical fiber link redundancy',
        'Plug and play, no complicated configuration needed',
        'Sturdy all-metal industrial casing',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['switch', 'poe', 'gigabit', 'sfp'],
    ),

    // 7 - ESP32
    const ProductModel(
      id: '5177',
      name: 'ESP32 NodeMCU Development Board WiFi + BLE',
      brand: 'ESPRESSIF',
      model: 'ESP32-WROOM-32D',
      categoryId: 'cat-dev-boards',
      categoryName: 'Dev Boards',
      subCategory: 'Microcontrollers',
      description:
          'Genuine ESP-WROOM-32 30-pin development board featuring dual Tensilica LX6 cores clocked at 240MHz, integrated 2.4GHz Wi-Fi, Bluetooth v4.2 BR/EDR and BLE. Features CP2102 USB-to-UART bridge and micro-USB port.',
      price: 440,
      mrp: 650,
      discountPercentage: 32,
      rating: 4.9,
      reviewCount: 310,
      stock: 250,
      viewsCount: 1420,
      soldCount: 680,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productCpu,
      ],
      specifications: {
        'CPU': 'Dual-Core Xtensa LX6 @ 240MHz',
        'SRAM': '520 KB',
        'Flash': '4 MB SPI Flash',
        'Wireless': 'Wi-Fi 802.11 b/g/n + BLE 4.2',
        'GPIO Pins': '30 Pins (ADC, DAC, PWM, I2C, SPI, UART)',
        'USB Interface': 'CP2102 Micro-USB',
      },
      features: [
        'Dual core processing with FreeRTOS multitasking support',
        'Rich peripheral set including touch sensors and Hall sensor',
        'Full Arduino IDE, ESP-IDF and MicroPython compatibility',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      isRecommended: true,
      tags: ['esp32', 'wifi', 'bluetooth', 'iot', 'espressif', 'arduino'],
    ),

    // 8 - Arduino Uno R3
    const ProductModel(
      id: '5178',
      name: 'Arduino Uno R3 ATmega328P with USB Cable',
      brand: 'ARDUINO',
      model: 'A000066-R3',
      categoryId: 'cat-arduino',
      categoryName: 'Arduino',
      subCategory: 'Development Boards',
      description:
          'The classic Arduino Uno R3 microcontroller board based on the ATmega328P chip. Includes ATmega16U2 programmed as a USB-to-serial converter, 14 digital input/output pins, 6 analog inputs, a 16 MHz quartz crystal, and USB cable.',
      price: 650,
      mrp: 990,
      discountPercentage: 34,
      rating: 4.9,
      reviewCount: 420,
      stock: 180,
      viewsCount: 1800,
      soldCount: 950,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Microcontroller': 'ATmega328P DIP-28',
        'Operating Voltage': '5V DC',
        'Input Voltage (limits)': '6 - 20V DC',
        'Digital I/O Pins': '14 (6 provide PWM output)',
        'Analog Input Pins': '6',
        'Flash Memory': '32 KB (0.5 KB used by bootloader)',
        'Clock Speed': '16 MHz',
      },
      features: [
        'Socketed DIP microcontroller for easy replacement',
        'Pre-programmed Optiboot bootloader',
        'Standard Arduino 1.0 pinout with SDA/SCL and IOREF pins',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      isRecommended: true,
      tags: ['arduino', 'uno', 'atmega328p', 'maker', 'robotics'],
    ),

    // 9 - DHT11
    const ProductModel(
      id: '5179',
      name: 'DHT11 Digital Temperature & Humidity Sensor Module',
      brand: 'CIRCUIT POINT',
      model: 'CP-DHT11-MOD',
      categoryId: 'cat-sensors',
      categoryName: 'Sensors',
      subCategory: 'Environmental Sensors',
      description:
          'Pre-mounted 3-pin breakout module featuring calibrated digital signal output with pull-up resistor and filter capacitor. Directly connects to 3.3V or 5V microcontrollers for ambient temperature and relative humidity measurement.',
      price: 110,
      mrp: 180,
      discountPercentage: 38,
      rating: 4.4,
      reviewCount: 180,
      stock: 350,
      viewsCount: 890,
      soldCount: 410,
      images: [
        AssetConstants.productDiode,
        AssetConstants.productResistor,
      ],
      specifications: {
        'Operating Voltage': '3.3V to 5.5V DC',
        'Humidity Range': '20% to 90% RH (±5% accuracy)',
        'Temperature Range': '0°C to 50°C (±2°C accuracy)',
        'Sampling Rate': '1 Hz (1 reading per second)',
        'Output': 'Single-bus digital signal',
      },
      features: [
        'Pre-soldered on PCB with power indicator LED',
        'Single wire digital transmission up to 20 meters',
        'Low power consumption, 2.5mA max current',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['sensor', 'temperature', 'humidity', 'dht11', 'weather'],
    ),

    // 10 - HC-SR04
    const ProductModel(
      id: '5180',
      name: 'HC-SR04 Ultrasonic Distance Sensor Module',
      brand: 'CIRCUIT POINT',
      model: 'CP-HCSR04-5V',
      categoryId: 'cat-sensors',
      categoryName: 'Sensors',
      subCategory: 'Distance & Proximity',
      description:
          'Popular non-contact sonar sensor providing 2cm to 400cm measurement range with 3mm precision. Uses transmitter and receiver transducers operating at 40 kHz. Ideal for obstacle avoidance in robotics and liquid level sensing.',
      price: 135,
      mrp: 220,
      discountPercentage: 38,
      rating: 4.7,
      reviewCount: 260,
      stock: 220,
      viewsCount: 940,
      soldCount: 540,
      images: [
        AssetConstants.productTransistor,
        AssetConstants.productDiode,
      ],
      specifications: {
        'Power Supply': '5V DC',
        'Quiescent Current': '< 2mA',
        'Working Current': '15mA',
        'Measuring Angle': '15 degrees',
        'Range': '2cm - 400cm (0.8 in - 157 in)',
        'Resolution': '0.3 cm',
      },
      features: [
        'Standard 4-pin header (VCC, Trig, Echo, GND)',
        'Fast response time under 10us trigger pulse',
        'Accurate sonar detection unaffected by ambient light or color',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['sensor', 'ultrasonic', 'distance', 'sonar', 'robotics'],
    ),

    // 11 - 0.96 OLED
    const ProductModel(
      id: '5181',
      name: '0.96 inch I2C OLED Display 128x64 Blue',
      brand: 'CIRCUIT POINT',
      model: 'CP-OLED-096B',
      categoryId: 'cat-displays',
      categoryName: 'Displays',
      subCategory: 'OLED Displays',
      description:
          'Crisp high-contrast self-illuminating graphical display module driven by SSD1306 IC. Requires only two I2C communication wires (SDA and SCL). Operates seamlessly on both 3.3V and 5V power rails.',
      price: 260,
      mrp: 399,
      discountPercentage: 35,
      rating: 4.8,
      reviewCount: 195,
      stock: 140,
      viewsCount: 760,
      soldCount: 320,
      images: [
        AssetConstants.productIcTimer,
        AssetConstants.productMicrocontroller,
      ],
      specifications: {
        'Resolution': '128 x 64 pixels',
        'Driver IC': 'SSD1306',
        'Interface': 'I2C (Address 0x3C / 0x3D)',
        'Operating Voltage': '3.3V - 5.0V DC',
        'Viewing Angle': '> 160 degrees',
        'Power Consumption': '0.04W full screen on',
      },
      features: [
        'No backlight required - each pixel self emits light',
        'Wide viewing angles and high contrast ratio',
        'Supported by Adafruit_SSD1306 and U8g2 libraries',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['oled', 'display', 'i2c', 'screen', 'ssd1306'],
    ),

    // 12 - 16x2 LCD with I2C
    const ProductModel(
      id: '5182',
      name: '16x2 Character LCD Module with I2C Serial Backpack',
      brand: 'CIRCUIT POINT',
      model: 'CP-LCD1602-I2C',
      categoryId: 'cat-displays',
      categoryName: 'Displays',
      subCategory: 'Character LCDs',
      description:
          'Yellow-green backlight 1602 LCD display pre-soldered with PCF8574 I2C adapter. Reduces pin consumption from 16 pins down to just 2 I2C pins. Features an onboard contrast trim potentiometer and backlight jumper.',
      price: 240,
      mrp: 380,
      discountPercentage: 36,
      rating: 4.6,
      reviewCount: 145,
      stock: 95,
      viewsCount: 520,
      soldCount: 210,
      images: [
        AssetConstants.productIcTimer,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Characters': '16 characters x 2 lines',
        'Backlight': 'Yellow-Green with blue text',
        'I2C Adapter IC': 'PCF8574T (Address 0x27 or 0x3F)',
        'Supply Voltage': '5V DC',
        'Dimensions': '80mm x 36mm x 18mm',
      },
      features: [
        'Pre-soldered backpack eliminates spaghetti wiring',
        'Built-in contrast adjustment potentiometer',
        'Hardware jumper to toggle backlight on/off',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['lcd', '1602', 'i2c', 'display', 'screen'],
    ),

    // 13 - 4 Channel Relay Module
    const ProductModel(
      id: '5183',
      name: '4-Channel 5V Relay Module with Optocoupler Isolation',
      brand: 'CIRCUIT POINT',
      model: 'CP-RELAY-4CH',
      categoryId: 'cat-modules',
      categoryName: 'Modules',
      subCategory: 'Power & Relays',
      description:
          'Optically isolated 4-channel relay breakout module with status indicator LEDs for each channel. Capable of switching up to 250V AC at 10A or 30V DC at 10A. Active low trigger compatible with 3.3V and 5V logic.',
      price: 210,
      mrp: 320,
      discountPercentage: 34,
      rating: 4.7,
      reviewCount: 160,
      stock: 110,
      viewsCount: 680,
      soldCount: 290,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productTransistor,
      ],
      specifications: {
        'Channels': '4 Individual SPDT Relays',
        'Coil Voltage': '5V DC',
        'Max AC Load': '250V AC @ 10A',
        'Max DC Load': '30V DC @ 10A',
        'Trigger Signal': 'Active LOW (0V trigger)',
        'Isolation': 'EL817 Optocouplers on all channels',
      },
      features: [
        'Galvanic optocoupler isolation protects MCU from high-voltage spikes',
        'Screw terminals for solid wire clamping',
        'Independent status LEDs for active channel verification',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['relay', 'ac switch', 'automation', 'module', 'optocoupler'],
    ),

    // 14 - Raspberry Pi 4 Model B
    const ProductModel(
      id: '5184',
      name: 'Raspberry Pi 4 Model B - 4GB RAM Original UK',
      brand: 'RASPBERRY PI',
      model: 'RPI4-MOD-B-4GB',
      categoryId: 'cat-dev-boards',
      categoryName: 'Dev Boards',
      subCategory: 'Single Board Computers',
      description:
          'Complete desktop-grade single board computer powered by Broadcom BCM2711 quad-core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5GHz. Supports dual 4K micro-HDMI displays, true gigabit ethernet, USB 3.0, and dual-band Wi-Fi.',
      price: 5499,
      mrp: 6999,
      discountPercentage: 21,
      rating: 5.0,
      reviewCount: 380,
      stock: 22,
      viewsCount: 2450,
      soldCount: 175,
      images: [
        AssetConstants.productCpu,
        AssetConstants.productRam,
        AssetConstants.productMicrocontroller,
      ],
      specifications: {
        'Processor': 'Broadcom BCM2711 Quad-Core @ 1.5GHz',
        'Memory': '4GB LPDDR4-3200 SDRAM',
        'Connectivity': 'Gigabit Ethernet, 2.4/5.0GHz 802.11ac Wi-Fi, BLE 5.0',
        'Display Out': '2 x Micro-HDMI ports up to 4Kp60',
        'USB': '2 x USB 3.0, 2 x USB 2.0',
        'Power Input': '5V 3A via USB Type-C',
      },
      features: [
        'True gigabit ethernet throughput without USB bottleneck',
        'Dual monitor 4K 60fps video output support',
        'Standard 40-pin GPIO header compatible with all hats',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      isRecommended: true,
      tags: ['raspberry pi', 'rpi4', 'sbc', 'linux', 'arm', 'mini pc'],
    ),

    // 15 - LM2596 DC-DC Step Down
    const ProductModel(
      id: '5185',
      name: 'LM2596 DC-DC Step Down Buck Converter 3A',
      brand: 'CIRCUIT POINT',
      model: 'CP-LM2596-BUCK',
      categoryId: 'cat-power',
      categoryName: 'Power Supplies',
      subCategory: 'Voltage Regulators',
      description:
          'High efficiency switching power supply module capable of stepping down input voltage between 4.5V to 40V to regulated 1.25V to 35V output with up to 3A load current. Features multi-turn precision cermet trimmer.',
      price: 85,
      mrp: 140,
      discountPercentage: 39,
      rating: 4.6,
      reviewCount: 220,
      stock: 400,
      viewsCount: 1100,
      soldCount: 780,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productIcTimer,
      ],
      specifications: {
        'Input Voltage': '4.5V - 40V DC',
        'Output Voltage': '1.25V - 35V DC Adjustable',
        'Output Current': '2A continuous (3A max with heatsink)',
        'Efficiency': 'Up to 92%',
        'Switching Frequency': '150 kHz',
      },
      features: [
        'Multi-turn potentiometer for precision voltage tuning',
        'Thermal shutdown and current limit protection',
        'Low ripple and high conversion efficiency',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['power', 'buck', 'step down', 'lm2596', 'converter', 'regulator'],
    ),

    // 16 - NodeMCU ESP8266 V3
    const ProductModel(
      id: '5186',
      name: 'NodeMCU ESP8266 V3 Lolin CH340 Wireless Board',
      brand: 'LUA',
      model: 'NODEMCU-V3-CH340',
      categoryId: 'cat-dev-boards',
      categoryName: 'Dev Boards',
      subCategory: 'Microcontrollers',
      description:
          'Open-source IoT development platform based on ESP8266 ESP-12E Wi-Fi SoC with CH340G USB controller. Breadboard friendly with integrated 3.3V LDO regulator, flash reset buttons, and PCB antenna.',
      price: 280,
      mrp: 420,
      discountPercentage: 33,
      rating: 4.8,
      reviewCount: 275,
      stock: 190,
      viewsCount: 1320,
      soldCount: 520,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productTransistor,
      ],
      specifications: {
        'Chipset': 'ESP8266EX (ESP-12E Module)',
        'Clock Speed': '80MHz (overclockable to 160MHz)',
        'Flash Memory': '4 MB',
        'Wi-Fi': '802.11 b/g/n with integrated TCP/IP stack',
        'Interface': 'CH340 Micro-USB',
      },
      features: [
        'Integrated Wi-Fi antenna with strong signal reception',
        'Supports Lua scripts, Arduino C++, and MicroPython',
        'Built-in user LED and bootloader flash switch',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['nodemcu', 'esp8266', 'wifi', 'iot', 'ch340'],
    ),

    // 17 - SG90 Servo
    const ProductModel(
      id: '5187',
      name: 'TowerPro SG90 9g Micro Servo Motor with Horns',
      brand: 'TOWERPRO',
      model: 'SG90-9G',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Actuators & Motors',
      description:
          'Lightweight 9-gram high-output micro servo motor suitable for RC airplanes, robot arms, robotic grippers, and pan-tilt camera mounts. Comes complete with 3 servo arms and mounting screws.',
      price: 130,
      mrp: 200,
      discountPercentage: 35,
      rating: 4.5,
      reviewCount: 310,
      stock: 280,
      viewsCount: 890,
      soldCount: 620,
      images: [
        AssetConstants.productTransistor,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Weight': '9 grams',
        'Operating Speed': '0.12 sec / 60 degrees @ 4.8V',
        'Stall Torque': '1.8 kg-cm @ 4.8V',
        'Operating Voltage': '4.8V - 6.0V DC',
        'Rotation Angle': '180 degrees',
        'Gear Type': 'POM High-durability nylon gears',
      },
      features: [
        'Standard 3-pin JR connector compatible with all MCU boards',
        'Low inertia motor with quick response positioning',
        'Packaged with 3 multi-style horn attachments and screws',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['servo', 'motor', 'sg90', 'robotics', 'pwm'],
    ),

    // 18 - RC522 RFID
    const ProductModel(
      id: '5188',
      name: 'RC522 RFID Reader / Writer Module 13.56MHz Kit',
      brand: 'CIRCUIT POINT',
      model: 'CP-RC522-SPI',
      categoryId: 'cat-sensors',
      categoryName: 'Sensors',
      subCategory: 'ID & Security',
      description:
          'Complete 13.56 MHz contactless reader kit based on Philips MFRC522 chip. Comes bundled with an S50 RFID white keycard and blue key fob keychain. Supports SPI communication up to 10 Mbit/s.',
      price: 185,
      mrp: 299,
      discountPercentage: 38,
      rating: 4.7,
      reviewCount: 165,
      stock: 130,
      viewsCount: 670,
      soldCount: 340,
      images: [
        AssetConstants.productIcTimer,
        AssetConstants.productMicrocontroller,
      ],
      specifications: {
        'Operating Frequency': '13.56 MHz',
        'Operating Current': '13 - 26mA @ 3.3V',
        'Card Reading Distance': 'Up to 50mm',
        'Communication Interface': 'SPI (8-pin header)',
        'Supported Cards': 'Mifare1 S50, S70, UltraLight, Pro, Desfire',
      },
      features: [
        'Includes 1x RFID Card + 1x RFID Keyfob + Straight and 90° pin headers',
        'Hardware crypto unit for secure authentication',
        'Low-power sleep mode under 80uA',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: false,
      tags: ['rfid', 'rc522', 'nfc', 'security', 'reader', 'sensor'],
    ),

    // 19 - NE555 Timer IC Pack
    const ProductModel(
      id: '5189',
      name: 'NE555 Precision Timer IC DIP-8 (Pack of 10)',
      brand: 'TEXAS INSTRUMENTS',
      model: 'NE555P-DIP8-10PK',
      categoryId: 'cat-ics',
      categoryName: 'ICs & Chips',
      subCategory: 'Analog ICs',
      description:
          'Original TI NE555 precision monolithic timing circuit capable of producing accurate time delays or oscillations. Operating in both astable and monostable modes with timing ranging from microseconds to hours.',
      price: 95,
      mrp: 160,
      discountPercentage: 40,
      rating: 4.9,
      reviewCount: 185,
      stock: 450,
      viewsCount: 780,
      soldCount: 520,
      images: [
        AssetConstants.productIcTimer,
        AssetConstants.productDiode,
      ],
      specifications: {
        'Package': 'DIP-8 Through-hole',
        'Supply Voltage': '4.5V to 16V DC',
        'Max Sink/Source Current': '200 mA',
        'Timing Range': 'Microseconds to Hours',
        'Temperature Stability': '50 ppm/°C',
      },
      features: [
        '100% original Texas Instruments ICs',
        'Direct breadboard drop-in DIP footprint',
        'Drives TTL logic or power loads up to 200mA directly',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['ne555', 'timer', 'ic', 'chips', 'texas instruments', 'dip8'],
    ),

    // 20 - L298N Motor Driver
    const ProductModel(
      id: '5190',
      name: 'L298N Dual H-Bridge DC Stepper Motor Driver',
      brand: 'CIRCUIT POINT',
      model: 'CP-L298N-MOD',
      categoryId: 'cat-modules',
      categoryName: 'Modules',
      subCategory: 'Actuators & Motors',
      description:
          'Heavy duty dual H-bridge driver module using ST L298N chip with large aluminium heatsink and onboard 78M05 5V linear regulator. Drives two DC motors independently with direction and speed (PWM) control.',
      price: 190,
      mrp: 310,
      discountPercentage: 38,
      rating: 4.6,
      reviewCount: 210,
      stock: 160,
      viewsCount: 810,
      soldCount: 390,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productMicrocontroller,
      ],
      specifications: {
        'Driver Chip': 'ST L298N Dual Full-Bridge',
        'Motor Supply Voltage': '5V - 35V DC',
        'Peak Output Current': '2A per bridge (4A peak)',
        'Logic Voltage': '5V DC',
        'Max Power Dissipation': '20W with included heatsink',
      },
      features: [
        'Flywheel diodes on all outputs for back-EMF surge protection',
        'Heavy screw terminals for power and motor wire connections',
        'Onboard 5V regulator can power your Arduino microcontroller',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['motor driver', 'l298n', 'h-bridge', 'robotics', 'dc motor'],
    ),

    // 21 - Breadboard 830
    const ProductModel(
      id: '5191',
      name: 'MB-102 Solderless Breadboard 830 Points + Power Rails',
      brand: 'CIRCUIT POINT',
      model: 'CP-MB102-830',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Prototyping',
      description:
          'Full-size 830 tie-point solderless breadboard with colored coordinates and peelable double-sided foam adhesive tape backing. Compatible with standard 2.54mm pitch ICs, DIP components, and jumper wires.',
      price: 140,
      mrp: 220,
      discountPercentage: 36,
      rating: 4.7,
      reviewCount: 340,
      stock: 310,
      viewsCount: 1120,
      soldCount: 820,
      images: [
        AssetConstants.productResistor,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Tie Points': '830 (630 point terminal strip + 200 point power rails)',
        'Pitch': '2.54mm (0.1 inch standard)',
        'Material': 'ABS Plastic housing with nickel-plated phosphor bronze clips',
        'Adhesive Backing': 'Self-adhesive double-sided foam tape',
      },
      features: [
        'Interlocking tabs to connect multiple boards for complex circuits',
        'Clear colored coordinate letters and numbers for easy tracing',
        'Tight spring contacts prevent loose wire disconnects',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['breadboard', 'prototyping', 'mb102', 'diy', 'electronics'],
    ),

    // 22 - Jumper Wires 120pcs
    const ProductModel(
      id: '5192',
      name: 'Premium 120pcs Jumper Wire Ribbon Cable Kit',
      brand: 'CIRCUIT POINT',
      model: 'CP-JW-120PC',
      categoryId: 'cat-cables',
      categoryName: 'Cables & Wires',
      subCategory: 'Jumper Cables',
      description:
          'Set of 3 x 40-pin multicolour rainbow ribbon jumper wires (20cm length each): Male-to-Male (40pcs), Male-to-Female (40pcs), and Female-to-Female (40pcs). High-flex copper conductor with molded headers.',
      price: 180,
      mrp: 280,
      discountPercentage: 35,
      rating: 4.8,
      reviewCount: 290,
      stock: 450,
      viewsCount: 980,
      soldCount: 710,
      images: [
        AssetConstants.productDiode,
        AssetConstants.productResistor,
      ],
      specifications: {
        'Quantity': '120 pieces total (3 ribbons of 40)',
        'Combinations': 'M-M, M-F, F-F (40 of each)',
        'Length': '20 cm (7.87 inches)',
        'Header Pitch': '2.54mm Dupont standard',
        'Wire Gauge': '28 AWG multi-strand copper',
      },
      features: [
        'Cables can be easily separated into individual or multi-pin groupings',
        'Molded strain relief prevents pins from pulling out',
        '10 vibrant colors for quick polarity and bus identification',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['cables', 'jumper', 'dupont', 'wires', 'ribbon'],
    ),

    // 23 - USB to TTL CH340
    const ProductModel(
      id: '5193',
      name: 'CH340G USB to TTL Serial UART Converter Adapter',
      brand: 'CIRCUIT POINT',
      model: 'CP-CH340G-TTL',
      categoryId: 'cat-modules',
      categoryName: 'Modules',
      subCategory: 'Communication Modules',
      description:
          'Gold-plated USB-A to 5-pin TTL UART bridge module powered by WCH CH340G chipset. Provides 3.3V and 5V selectable logic levels via jumper cap, with TX and RX activity LEDs and polyfuse protection.',
      price: 120,
      mrp: 199,
      discountPercentage: 39,
      rating: 4.6,
      reviewCount: 130,
      stock: 210,
      viewsCount: 610,
      soldCount: 380,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productTransistor,
      ],
      specifications: {
        'Chipset': 'WCH CH340G',
        'USB Standard': 'USB 2.0 Full Speed',
        'Baud Rates': '50 bps to 2 Mbps',
        'Output Pins': '5V, 3.3V, TXD, RXD, GND',
        'OS Support': 'Windows 10/11, macOS, Linux, Android',
      },
      features: [
        'Hardware 500mA self-recovering polyfuse protects computer USB port',
        'Clear TX and RX data transmission indicator LEDs',
        'Selectable 3.3V or 5V power output via jumper switch',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: false,
      tags: ['usb to ttl', 'ch340', 'serial', 'uart', 'flasher'],
    ),

    // 24 - TP4056
    const ProductModel(
      id: '5194',
      name: 'TP4056 1A 18650 Lithium Battery Charger with Dual Protection',
      brand: 'CIRCUIT POINT',
      model: 'CP-TP4056-TYPEC',
      categoryId: 'cat-power',
      categoryName: 'Power Supplies',
      subCategory: 'Battery Management',
      description:
          'Modern Type-C USB single-cell 3.7V Lithium-Ion / 18650 charging breakout board with integrated DW01A protection IC and FS8205A dual MOSFET. Provides overcharge, over-discharge, and short-circuit protection.',
      price: 55,
      mrp: 90,
      discountPercentage: 38,
      rating: 4.8,
      reviewCount: 390,
      stock: 500,
      viewsCount: 1650,
      soldCount: 1200,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productLaptopBattery,
      ],
      specifications: {
        'Input Port': 'USB Type-C (4.5V - 5.5V)',
        'Charge Current': '1A (adjustable by changing Rprog resistor)',
        'Full Charge Cutoff': '4.2V ± 1%',
        'Battery Over-discharge Protection': '2.5V cutoff',
        'Overcurrent Protection': '3A max discharge',
      },
      features: [
        'Type-C USB input for modern phone cable compatibility',
        'Dual LED indicators: Red (Charging), Blue (Charged)',
        'Hardware battery protection circuit onboard',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      tags: ['tp4056', 'battery', 'charger', '18650', 'lithium', 'type-c'],
    ),

    // 25 - Potentiometers pack
    const ProductModel(
      id: '5195',
      name: '10K Ohm Linear Rotary Potentiometer with Knob (Pack of 5)',
      brand: 'CIRCUIT POINT',
      model: 'CP-POT-B10K-5PK',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Passive Components',
      description:
          'B10K 3-pin single linear rotary potentiometer with 15mm knurled shaft. Comes complete with 5 stylish colored aluminium alloy knob caps, mounting washers, and hex nuts.',
      price: 110,
      mrp: 175,
      discountPercentage: 37,
      rating: 4.5,
      reviewCount: 95,
      stock: 180,
      viewsCount: 420,
      soldCount: 190,
      images: [
        AssetConstants.productResistor,
        AssetConstants.productTransistor,
      ],
      specifications: {
        'Resistance': '10K Ohm Linear (B-Type)',
        'Tolerance': '± 20%',
        'Rotation Angle': '300 degrees',
        'Shaft Type': '6mm Knurled Shaft (15mm length)',
        'Rated Power': '0.125W',
      },
      features: [
        'Includes 5 knurled knobs, 5 nuts, and 5 washers',
        'Smooth rotation with consistent resistance linearity',
        'Standard 3-pin breadboard compatible pitch',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: false,
      tags: ['potentiometer', 'resistor', '10k', 'volume knob', 'analog'],
    ),

    // 26 - Buzzer pack
    const ProductModel(
      id: '5196',
      name: '5V Continuous Active Buzzer Module (Pack of 10)',
      brand: 'CIRCUIT POINT',
      model: 'CP-BUZZ-ACT5V-10',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Audio & Indicators',
      description:
          '12mm sealed electromagnetic active buzzers with internal oscillation circuit. Beeps loudly at 2300 Hz when connected to 5V DC without needing PWM audio generation.',
      price: 90,
      mrp: 150,
      discountPercentage: 40,
      rating: 4.6,
      reviewCount: 115,
      stock: 300,
      viewsCount: 510,
      soldCount: 260,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productDiode,
      ],
      specifications: {
        'Operating Voltage': '4.0V - 7.0V DC',
        'Rated Voltage': '5V DC',
        'Sound Output': '≥ 85 dB @ 10cm',
        'Oscillation Frequency': '2300 ± 300 Hz',
        'Current Consumption': '≤ 30 mA',
      },
      features: [
        'Active design has internal oscillator: simply apply 5V DC to beep',
        'High decibel 85dB alarm tone easily heard across a room',
        'Breadboard-friendly through-hole 7.6mm pin spacing',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: false,
      tags: ['buzzer', 'alarm', 'audio', 'beeper', '5v'],
    ),

    // 27 - Micro SD SPI
    const ProductModel(
      id: '5197',
      name: 'Micro SD Card Reader / Writer Module SPI Interface',
      brand: 'CIRCUIT POINT',
      model: 'CP-MSD-SPI-MOD',
      categoryId: 'cat-modules',
      categoryName: 'Modules',
      subCategory: 'Storage Modules',
      description:
          'MicroSD TF card adapter module with onboard 74LVC125 level converter chip and 3.3V AMS1117 regulator. Allows 5V microcontrollers like Arduino Uno to read and write high-capacity SDHC cards over SPI.',
      price: 135,
      mrp: 210,
      discountPercentage: 35,
      rating: 4.7,
      reviewCount: 88,
      stock: 150,
      viewsCount: 460,
      soldCount: 180,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productSsd,
      ],
      specifications: {
        'Card Type': 'Micro SD (TF) up to 32GB (FAT16 / FAT32)',
        'Power Supply': '4.5V - 5.5V DC',
        'Communication': 'SPI standard (CS, MOSI, MISO, SCK)',
        'Level Conversion': 'Onboard 74LVC125 logic level shifter',
      },
      features: [
        'Spring push-push TF card connector for easy card insertion',
        'Built-in level translator protects sensitive SD card circuits',
        'Directly supported by standard SD.h Arduino library',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: false,
      tags: ['microsd', 'sd card', 'storage', 'spi', 'datalogger'],
    ),

    // 28 - Power Supply Adapter 5V 2A
    const ProductModel(
      id: '5198',
      name: '5V 2A Regulated DC Power Supply Adapter (5.5x2.1mm)',
      brand: 'CIRCUIT POINT',
      model: 'CP-PSU-5V2A-EU',
      categoryId: 'cat-power',
      categoryName: 'Power Supplies',
      subCategory: 'Adapters & SMPS',
      description:
          'High stability wall plug AC-DC switched mode power supply delivering continuous 5V 2000mA. Equipped with a standard 5.5mm x 2.1mm center-positive barrel connector, ripple filter, and short-circuit protection.',
      price: 220,
      mrp: 350,
      discountPercentage: 37,
      rating: 4.8,
      reviewCount: 175,
      stock: 120,
      viewsCount: 590,
      soldCount: 310,
      images: [
        AssetConstants.productLaptopBattery,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Input Voltage': '100V - 240V AC 50/60Hz',
        'Output Voltage': '5V DC ± 2%',
        'Max Current': '2.0 Amperes (10W)',
        'DC Plug': '5.5mm x 2.1mm Center Positive',
        'Cable Length': '1.2 Meters',
      },
      features: [
        'IC chip controlled overload and overvoltage protection',
        'Low ripple and low standby power consumption (<0.1W)',
        'Ideal for Arduino, Raspberry Pi, LED strips, and routers',
      ],
      isFeatured: true,
      isHotDeal: false,
      isBestSeller: true,
      tags: ['power supply', 'adapter', '5v', 'smps', 'dc jack'],
    ),

    // 29 - Aluminium Heatsink Kit
    const ProductModel(
      id: '5199',
      name: 'Anodized Aluminium Heatsink Set with Thermal Tape (Pack of 3)',
      brand: 'CIRCUIT POINT',
      model: 'CP-HSINK-ALUM-3PK',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Cooling & Hardware',
      description:
          'Set of 3 precision-machined heatsinks (14x14mm, 9x9mm, 9x9mm) backed with high thermal conductivity 3M 8810 adhesive tape. Custom tailored for cooling SoC chips on Raspberry Pi, motor drivers, and FPGA boards.',
      price: 80,
      mrp: 130,
      discountPercentage: 38,
      rating: 4.7,
      reviewCount: 140,
      stock: 260,
      viewsCount: 470,
      soldCount: 320,
      images: [
        AssetConstants.productCpu,
        AssetConstants.productGpu,
      ],
      specifications: {
        'Material': 'High-purity extruded Aluminium',
        'Dimensions': '1x (14x14x6mm), 2x (9x9x5mm)',
        'Thermal Tape': 'Pre-applied 3M thermally conductive adhesive',
        'Thermal Resistance': '15°C/W',
      },
      features: [
        'Pre-applied genuine thermal tape - just peel and stick',
        'Reduces chip temperatures by up to 18°C under heavy loads',
        'Low profile fits under most electronic enclosures and shields',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: false,
      tags: ['heatsink', 'cooling', 'raspberry pi', 'thermal tape', 'hardware'],
    ),

    // 30 - Soldering Iron 60W
    const ProductModel(
      id: '5200',
      name: 'Adjustable Temperature 60W Soldering Iron with 5 Tips',
      brand: 'CIRCUIT POINT',
      model: 'CP-SOLD-60W-KIT',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Tools & Equipment',
      description:
          'Professional 60 Watt internal ceramic heating soldering iron with rotatable temperature dial (200°C to 450°C). Comes with 5 assorted 900M soldering tips, stainless steel iron stand, and heat-resistant silicone grip.',
      price: 499,
      mrp: 799,
      discountPercentage: 37,
      rating: 4.8,
      reviewCount: 280,
      stock: 85,
      viewsCount: 1250,
      soldCount: 410,
      images: [
        AssetConstants.productResistor,
        AssetConstants.productCapacitor,
      ],
      specifications: {
        'Power': '60 Watts',
        'Operating Voltage': '220V - 240V AC',
        'Temperature Range': '200°C - 450°C Adjustable',
        'Heating Element': 'Fast heating internal ceramic core',
        'Tip Model': '900M Series interchangeable tips',
      },
      features: [
        'Heats up to 300°C in less than 30 seconds',
        'Ergonomic anti-scald silicone insulated grip',
        'Includes 5 diverse tips: chisel, bevel, conical, fine point',
      ],
      isFeatured: true,
      isHotDeal: true,
      isBestSeller: true,
      isRecommended: true,
      tags: ['soldering iron', 'tools', 'diy', 'welding', 'equipment'],
    ),

    // 31 - Arduino Mega 2560 Pro
    const ProductModel(
      id: '5201',
      name: 'Arduino Mega 2560 Pro Embed ATmega2560-16AU',
      brand: 'ARDUINO',
      model: 'MEGA2560-PRO-CH340',
      categoryId: 'cat-arduino',
      categoryName: 'Arduino',
      subCategory: 'Development Boards',
      description:
          'Compact mini form-factor version of the Arduino Mega 2560 board. Retains all 54 digital I/O pins, 16 analog inputs, 4 hardware UART serial ports, and 256KB flash memory while fitting into a fraction of the standard board size.',
      price: 1150,
      mrp: 1650,
      discountPercentage: 30,
      rating: 4.8,
      reviewCount: 96,
      stock: 45,
      viewsCount: 620,
      soldCount: 110,
      images: [
        AssetConstants.productMicrocontroller,
        AssetConstants.productCpu,
      ],
      specifications: {
        'Microcontroller': 'ATmega2560 @ 16MHz',
        'Digital I/O': '54 pins (15 PWM capable)',
        'Analog Inputs': '16 pins',
        'Flash Memory': '256 KB (8 KB used by bootloader)',
        'SRAM': '8 KB',
        'EEPROM': '4 KB',
      },
      features: [
        'All the computing power of Arduino Mega in a compact breadboard footprint',
        '4 hardware UART ports for simultaneous GPS, Bluetooth, and cellular modules',
        'High quality immersion gold PCB finish',
      ],
      isFeatured: false,
      isHotDeal: false,
      isBestSeller: false,
      isRecommended: true,
      tags: ['arduino', 'mega2560', 'atmega2560', 'robotics', '3d printer'],
    ),

    // 32 - 100uF Electrolytic Capacitor Pack
    const ProductModel(
      id: '5202',
      name: '100uF 25V Low-ESR Radial Electrolytic Capacitors (Pack of 20)',
      brand: 'CIRCUIT POINT',
      model: 'CP-CAP-100U25V-20',
      categoryId: 'cat-accessories',
      categoryName: 'Accessories',
      subCategory: 'Passive Components',
      description:
          'High temperature 105°C low-impedance radial lead electrolytic capacitors. Ideal for power supply filtering, audio coupling, and voltage stabilization on microcontrollers.',
      price: 70,
      mrp: 120,
      discountPercentage: 41,
      rating: 4.7,
      reviewCount: 85,
      stock: 600,
      viewsCount: 380,
      soldCount: 420,
      images: [
        AssetConstants.productCapacitor,
        AssetConstants.productDiode,
      ],
      specifications: {
        'Capacitance': '100 uF',
        'Voltage Rating': '25V DC',
        'Temperature Rating': '-40°C to +105°C',
        'Tolerance': '± 20%',
        'Dimensions': '6.3mm diameter x 11mm height',
      },
      features: [
        'Pack of 20 brand-new industrial grade capacitors',
        'Long life 2000 hours @ 105°C rating',
        'Clear negative stripe indicator for correct polarity alignment',
      ],
      isFeatured: false,
      isHotDeal: true,
      isBestSeller: false,
      tags: ['capacitor', 'electrolytic', 'filter', 'passive', 'components'],
    ),
  ];

  @override
  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _products;
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _products.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<ProductModel>> getHotDeals() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _products.where((p) => p.isHotDeal).toList();
  }

  @override
  Future<List<ProductModel>> getBestSellers() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _products.where((p) => p.isBestSeller).toList();
  }

  @override
  Future<List<ProductModel>> getRecommendedProducts() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _products.where((p) => p.isRecommended).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _products;
    return _products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.model.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.subCategory.toLowerCase().contains(q) ||
          p.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _categories;
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _banners;
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(String productId, String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final sameCategory = _products
        .where((p) => p.id != productId && p.categoryId == categoryId)
        .toList();
    if (sameCategory.length >= 4) {
      return sameCategory.take(6).toList();
    }
    final others = _products.where((p) => p.id != productId && p.categoryId != categoryId);
    return [...sameCategory, ...others].take(6).toList();
  }
}

