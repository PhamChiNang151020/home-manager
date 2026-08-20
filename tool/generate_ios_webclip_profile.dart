// Regenerate web/to-am.mobileconfig after changing the app icon or URL.
//
// dart run tool/generate_ios_webclip_profile.dart

import "dart:convert";
import "dart:io";

void main() {
  const appUrl = "https://phamchinang151020.github.io/home-manager/";
  const iconPath = "web/icons/apple-touch-icon.png";
  const outputPath = "web/to-am.mobileconfig";
  const profileUuid = "A1B2C3D4-E5F6-4789-A012-3456789ABCDE";
  const webClipUuid = "B2C3D4E5-F6A7-4890-B123-456789ABCDEF";

  final iconBytes = File(iconPath).readAsBytesSync();
  final iconB64 = base64Encode(iconBytes);
  final xml = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>PayloadContent</key>
\t<array>
\t\t<dict>
\t\t\t<key>FullScreen</key>
\t\t\t<true/>
\t\t\t<key>Icon</key>
\t\t\t<data>
$iconB64
\t\t\t</data>
\t\t\t<key>IsRemovable</key>
\t\t\t<true/>
\t\t\t<key>Label</key>
\t\t\t<string>Tổ Ấm</string>
\t\t\t<key>PayloadDescription</key>
\t\t\t<string>Thêm icon Tổ Ấm ra Màn hình chính.</string>
\t\t\t<key>PayloadDisplayName</key>
\t\t\t<string>Web Clip — Tổ Ấm</string>
\t\t\t<key>PayloadIdentifier</key>
\t\t\t<string>com.phamchinang.home-manager.webclip</string>
\t\t\t<key>PayloadType</key>
\t\t\t<string>com.apple.webClip.managed</string>
\t\t\t<key>PayloadUUID</key>
\t\t\t<string>$webClipUuid</string>
\t\t\t<key>PayloadVersion</key>
\t\t\t<integer>1</integer>
\t\t\t<key>Precomposed</key>
\t\t\t<true/>
\t\t\t<key>URL</key>
\t\t\t<string>$appUrl</string>
\t\t</dict>
\t</array>
\t<key>PayloadDescription</key>
\t<string>Cài icon Tổ Ấm lên Màn hình chính iPhone hoặc iPad.</string>
\t<key>PayloadDisplayName</key>
\t<string>Cài Tổ Ấm lên iPhone</string>
\t<key>PayloadIdentifier</key>
\t<string>com.phamchinang.home-manager.profile</string>
\t<key>PayloadOrganization</key>
\t<string>PhamChiNang</string>
\t<key>PayloadRemovalDisallowed</key>
\t<false/>
\t<key>PayloadType</key>
\t<string>Configuration</string>
\t<key>PayloadUUID</key>
\t<string>$profileUuid</string>
\t<key>PayloadVersion</key>
\t<integer>1</integer>
</dict>
</plist>
""";

  File(outputPath).writeAsStringSync(xml);
  stdout.writeln("Wrote $outputPath (${File(outputPath).lengthSync()} bytes)");
}
