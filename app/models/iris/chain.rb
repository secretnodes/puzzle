class Iris::Chain < ApplicationRecord
  include Chainlike

  SYNC_OFFSET = 1
  SUPPORTS_LEDGER = false

  PREFIXES = {
    account_address: 'iaa1',
    account_public_key: 'iap1',
    validator_consensus_address: 'ica1',
    validator_consensus_public_key: 'icp1',
    validator_operator_address: 'iva1',
    validator_operator_public_key: 'ivp1'
  }
  TESTNET_PREFIXES = {
    account_address: 'faa1',
    account_public_key: 'fap1',
    validator_consensus_address: 'fca1',
    validator_consensus_public_key: 'fcp1',
    validator_operator_address: 'fva1',
    validator_operator_public_key: 'fvp1'
  }

  DEFAULT_TOKEN_DISPLAY = 'IRIS'
  DEFAULT_TOKEN_REMOTE = 'iris-atto'
  DEFAULT_TOKEN_FACTOR = 18

  def network_name; 'IRIS'; end

  def prefixes
    testnet? ? TESTNET_PREFIXES : PREFIXES
  end
end
