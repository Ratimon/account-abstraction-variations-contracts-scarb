use array::{ArrayTrait, ArraySerde, SpanTrait};
use starknet::account::Call;
use starknet::{ContractAddress, call_contract_syscall};


#[starnet::interface]
trait ISRC6<T> {
  fn __execute__(ref self: T, calls: Array<Call>) -> Array<Span<felt252>>;
  fn __validate__(self: @T, calls: Array<Call>) -> felt252;
  fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}


/// @title IAccount Additional account contract interface
trait IAccountAddon<T> {
    /// @notice Assert whether a declare transaction is valid to be executed
    /// @param class_hash The class hash of the smart contract to be declared
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_declare__(self: @T, class_hash: felt252) -> felt252;

    /// @notice Assert whether counterfactual deployment is valid to be executed
    /// @param class_hash The class hash of the account contract to be deployed
    /// @param salt Account address randomizer
    /// @param public_key The public key of the account signer
    /// @return The string 'VALID' represented as felt when is valid
    fn __validate_deploy__(self: @T, class_hash: felt252, contract_address_salt: felt252,public_key_: felt252) -> felt252;

    /// @notice Exposes the signer's public key
    /// @return The public key
    fn public_key(self: @T) -> felt252;
}