class FlavorSettings {
  final String apiUrl;
  final String chainId;

  FlavorSettings.devnet()
      : apiUrl = 'https://devnet-api.multiversx.com',
        chainId = 'D';
  FlavorSettings.testnet()
      : apiUrl = 'https://testnet-api.multiversx.com',
        chainId = 'T';
  FlavorSettings.mainnet()
      : apiUrl = 'https://api.multiversx.com',
        chainId = '1';
}
