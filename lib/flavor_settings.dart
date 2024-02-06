class FlavorSettings {
  final String apiUrl;
  final String chainId;

  FlavorSettings.dev()
      : apiUrl = 'https://devnet-api.multiversx.com',
        chainId = 'D';
  FlavorSettings.qa()
      : apiUrl = 'https://testnet-api.multiversx.com',
        chainId = 'T';
  FlavorSettings.prod()
      : apiUrl = 'https://api.multiversx.com',
        chainId = '1';
}
