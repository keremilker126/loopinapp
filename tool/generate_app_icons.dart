import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  final baseSize = 1024;
  final purple = Color(94, 92, 230);
  final accent = Color(255, 255, 255);

  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  final iosSizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  final iosAppIconDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  if (!iosAppIconDir.existsSync()) {
    iosAppIconDir.createSync(recursive: true);
  }

  // Generate web icons
  final webIconDir = Directory('web/icons');
  if (!webIconDir.existsSync()) {
    webIconDir.createSync(recursive: true);
  }

  final webSizes = {
    'Icon-192.png': 192,
    'Icon-512.png': 512,
    'Icon-maskable-192.png': 192,
    'Icon-maskable-512.png': 512,
  };

  for (final entry in webSizes.entries) {
    File('${webIconDir.path}/${entry.key}').writeAsBytesSync(
      generateIcon(entry.value, purple, accent),
    );
  }

  for (final entry in androidSizes.entries) {
    final path = Directory('android/app/src/main/res/${entry.key}');
    if (!path.existsSync()) path.createSync(recursive: true);
    File('${path.path}/ic_launcher.png').writeAsBytesSync(
      generateIcon(entry.value, purple, accent),
    );
  }

  for (final entry in iosSizes.entries) {
    File('${iosAppIconDir.path}/${entry.key}').writeAsBytesSync(
      generateIcon(entry.value, purple, accent),
    );
  }

  print('App icons generated successfully.');
}

Uint8List generateIcon(int size, Color background, Color foreground) {
  final pixels = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final offset = (y * size + x) * 4;
      pixels[offset] = background.r;
      pixels[offset + 1] = background.g;
      pixels[offset + 2] = background.b;
      pixels[offset + 3] = 255;
    }
  }

  final cx = size / 2;
  final cy = size / 2;
  final r = size * 0.36;
  final ringThickness = size * 0.08;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x + 0.5 - cx;
      final dy = y + 0.5 - cy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist >= r - ringThickness && dist <= r) {
        final offset = (y * size + x) * 4;
        pixels[offset] = foreground.r;
        pixels[offset + 1] = foreground.g;
        pixels[offset + 2] = foreground.b;
        pixels[offset + 3] = 220;
      }
    }
  }

  final tri = [
    Point(size * 0.42, size * 0.32),
    Point(size * 0.42, size * 0.68),
    Point(size * 0.72, size * 0.5),
  ];
  fillTriangle(pixels, size, tri, foreground);

  return writePng(size, size, pixels);
}

void fillTriangle(Uint8List pixels, int size, List<Point<double>> tri, Color color) {
  final minX = tri.map((p) => p.x).reduce(min).floor().clamp(0, size - 1);
  final maxX = tri.map((p) => p.x).reduce(max).ceil().clamp(0, size - 1);
  final minY = tri.map((p) => p.y).reduce(min).floor().clamp(0, size - 1);
  final maxY = tri.map((p) => p.y).reduce(max).ceil().clamp(0, size - 1);

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      if (pointInTriangle(Point(x + 0.5, y + 0.5), tri[0], tri[1], tri[2])) {
        final offset = (y * size + x) * 4;
        pixels[offset] = color.r;
        pixels[offset + 1] = color.g;
        pixels[offset + 2] = color.b;
        pixels[offset + 3] = 255;
      }
    }
  }
}

bool pointInTriangle(Point<double> p, Point<double> a, Point<double> b, Point<double> c) {
  final d1 = sign(p, a, b);
  final d2 = sign(p, b, c);
  final d3 = sign(p, c, a);

  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
  return !(hasNeg && hasPos);
}

double sign(Point<double> p1, Point<double> p2, Point<double> p3) {
  return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

Uint8List writePng(int width, int height, Uint8List pixels) {
  final png = BytesBuilder();
  png.add(_pngSignature);
  png.add(_createChunk('IHDR', _ihdrPayload(width, height)));
  png.add(_createChunk('IDAT', _idatPayload(width, height, pixels)));
  png.add(_createChunk('IEND', Uint8List(0)));
  return png.toBytes();
}

Uint8List _ihdrPayload(int width, int height) {
  final buffer = ByteData(13);
  buffer.setUint32(0, width);
  buffer.setUint32(4, height);
  buffer.setUint8(8, 8);
  buffer.setUint8(9, 6);
  buffer.setUint8(10, 0);
  buffer.setUint8(11, 0);
  buffer.setUint8(12, 0);
  return buffer.buffer.asUint8List();
}

Uint8List _idatPayload(int width, int height, Uint8List pixels) {
  final scanlines = BytesBuilder();
  for (var y = 0; y < height; y++) {
    scanlines.addByte(0);
    final rowStart = y * width * 4;
    scanlines.add(pixels.sublist(rowStart, rowStart + width * 4));
  }
  return Uint8List.fromList(zlib.encode(scanlines.toBytes()));
}

const _pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];

Uint8List _createChunk(String type, Uint8List data) {
  final bytes = BytesBuilder();
  final typeBytes = utf8.encode(type);
  final length = data.length;
  final buffer = ByteData(4);
  buffer.setUint32(0, length);
  bytes.add(buffer.buffer.asUint8List());
  bytes.add(typeBytes);
  bytes.add(data);
  bytes.add(_crc32Bytes(typeBytes + data));
  return bytes.toBytes();
}

Uint8List _crc32Bytes(List<int> data) {
  final crc = _crc32(Uint8List.fromList(data));
  final buffer = ByteData(4);
  buffer.setUint32(0, crc);
  return buffer.buffer.asUint8List();
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (var byte in data) {
    crc = _crcTable[(crc ^ byte) & 0xFF] ^ ((crc >> 8) & 0xFFFFFF);
  }
  return crc ^ 0xFFFFFFFF;
}

const _crcTable = <int>[
  0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
  0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
  0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
  0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
  0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
  0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
  0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
  0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
  0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
  0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
  0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
  0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
  0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
  0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
  0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
  0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
  0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
  0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
  0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
  0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
  0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
  0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
  0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
  0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
  0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
  0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
  0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
  0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
  0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
  0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
  0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
  0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8C, 0x5BDEAE1D,
  0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
  0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
  0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
  0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
  0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
  0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
  0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
  0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
  0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
  0x54DE5729, 0x23D967BF, 0xB3667A2B, 0xC4614AB7, 0x5D681B02, 0x2A6F2B94,
  0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D,
];

class Color {
  final int r;
  final int g;
  final int b;
  final int a;
  const Color(this.r, this.g, this.b, [this.a = 255]);
}
