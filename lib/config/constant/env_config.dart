import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(
  path: '.env',
  obfuscate: true,
)
abstract class EnvConfig {
  @EnviedField(
    varName: 'GOOGLE_MAPS_API_KEY',
    obfuscate: true,
  )
  static final String googleMapsApiKey = _EnvConfig.googleMapsApiKey;
}
