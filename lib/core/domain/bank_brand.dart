/// Resolve Vietnamese bank brand codes for logos (VietQR CDN).
abstract final class BankBrand {
  /// Public logo URL for a VietQR bank code, e.g. `VCB` → CDN PNG.
  static String logoUrl(String code) =>
      "https://api.vietqr.io/img/${code.toUpperCase()}.png";

  /// Match free-text bank name to a VietQR code, or null if unknown.
  static String? codeForName(String raw) {
    final key = _normalize(raw);
    if (key.isEmpty) return null;
    if (_aliases.containsKey(key)) return _aliases[key];

    String? bestCode;
    var bestLen = 0;
    for (final entry in _aliases.entries) {
      if (entry.key.length <= bestLen) continue;
      if (key.contains(entry.key) || entry.key.contains(key)) {
        bestLen = entry.key.length;
        bestCode = entry.value;
      }
    }
    return bestCode;
  }

  static String? logoUrlForName(String raw) {
    final code = codeForName(raw);
    return code == null ? null : logoUrl(code);
  }

  static String _normalize(String raw) {
    var s = raw.trim().toLowerCase();
    const pairs = <List<String>>[
      ["àáạảãâầấậẩẫăằắặẳẵ", "a"],
      ["èéẹẻẽêềếệểễ", "e"],
      ["ìíịỉĩ", "i"],
      ["òóọỏõôồốộổỗơờớợởỡ", "o"],
      ["ùúụủũưừứựửữ", "u"],
      ["ỳýỵỷỹ", "y"],
      ["đ", "d"],
    ];
    for (final p in pairs) {
      for (final ch in p[0].split("")) {
        s = s.replaceAll(ch, p[1]);
      }
    }
    return s.replaceAll(RegExp(r"[^a-z0-9]+"), "");
  }

  /// Longer / more specific aliases first via contains checks.
  static const _aliases = <String, String>{
    "vietcombank": "VCB",
    "ngoaithuong": "VCB",
    "vcb": "VCB",
    "techcombank": "TCB",
    "techcom": "TCB",
    "tcb": "TCB",
    "mbbank": "MB",
    "military": "MB",
    "mb": "MB",
    "acb": "ACB",
    "achau": "ACB",
    "vpbank": "VPB",
    "vpb": "VPB",
    "thinhvuong": "VPB",
    "bidv": "BIDV",
    "dautuvaphattien": "BIDV",
    "vietinbank": "ICB",
    "vietin": "ICB",
    "congthuong": "ICB",
    "ctg": "ICB",
    "icb": "ICB",
    "tpbank": "TPB",
    "tienphong": "TPB",
    "tpb": "TPB",
    "sacombank": "STB",
    "saigonthuongtin": "STB",
    "stb": "STB",
    "agribank": "VBA",
    "nongnghiep": "VBA",
    "vba": "VBA",
    "hdbank": "HDB",
    "hdb": "HDB",
    "msb": "MSB",
    "hanghai": "MSB",
    "ocb": "OCB",
    "phuongdong": "OCB",
    "vib": "VIB",
    "quocte": "VIB",
    "seabank": "SEAB",
    "dongnamai": "SEAB",
    "lpbank": "LPB",
    "lienviet": "LPB",
    "lpb": "LPB",
    "shb": "SHB",
    "saigonhaiphong": "SHB",
    "eximbank": "EIB",
    "exim": "EIB",
    "eib": "EIB",
    "abbank": "ABB",
    "anbinh": "ABB",
    "abb": "ABB",
    "namabank": "NAB",
    "namai": "NAB",
    "nab": "NAB",
    "pvcombank": "PVC",
    "pvc": "PVC",
    "baovietbank": "BVB",
    "bvb": "BVB",
    "kienlong": "KLB",
    "klb": "KLB",
    "vietabank": "VAB",
    "vab": "VAB",
    "pgbank": "PGB",
    "pgb": "PGB",
    "ncb": "NCB",
    "quocdan": "NCB",
    "scb": "SCB",
    "saigon": "SCB",
    "shinhan": "SHBVN",
    "woori": "WVN",
    "cimb": "CIMB",
    "hsbc": "HSBC",
    "standardchartered": "SCVN",
    "publicbank": "PBVN",
  };

  /// Popular banks for picker UI (display name + VietQR code).
  static const popular = <({String name, String code})>[
    (name: "Vietcombank", code: "VCB"),
    (name: "Techcombank", code: "TCB"),
    (name: "MB Bank", code: "MB"),
    (name: "BIDV", code: "BIDV"),
    (name: "VietinBank", code: "ICB"),
    (name: "ACB", code: "ACB"),
    (name: "VPBank", code: "VPB"),
    (name: "TPBank", code: "TPB"),
    (name: "Sacombank", code: "STB"),
    (name: "Agribank", code: "VBA"),
    (name: "HDBank", code: "HDB"),
    (name: "MSB", code: "MSB"),
    (name: "OCB", code: "OCB"),
    (name: "VIB", code: "VIB"),
    (name: "SHB", code: "SHB"),
    (name: "SeABank", code: "SEAB"),
  ];
}
