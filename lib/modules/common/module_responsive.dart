import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared responsive spacing for screens under [lib/modules].
abstract final class ModuleResponsive {
  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h);

  static EdgeInsets get screenPaddingWide =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h);
}
