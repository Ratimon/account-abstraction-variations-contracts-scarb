#[starknet::contract]
mod AccountWithMulticall {
    use core::starknet::SyscallResultTrait;
    // use array::{ArrayTrait, ArraySerde, SpanTrait};
    // use array::ArrayTCloneImpl;
    
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;
    use option::OptionTrait;
    use starknet::account::Call;
    use starknet::{ContractAddress, call_contract_syscall};
    use zeroable::Zeroable;

    use account_abstraction_variations::accounts::interface::ISRC6;
    use account_abstraction_variations::accounts::interface::IAccountAddon;

    #[storage]
    struct Storage {
        public_key: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, public_key_: felt252) {
        self.public_key.write(public_key_);
    }

    #[generate_trait]
    impl ProtocolImpl of ProtocolTrait {
        fn validate_transaction(self: @ContractState) -> felt252 {
            let tx_info = starknet::get_tx_info().unbox();
             // Extract signature
            let signature = tx_info.signature;
            // Check signature length
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');
            // Verify ECDSA signature
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: self.public_key.read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED
        }

        fn is_valid_signature_bool(self: @ContractState, hash: felt252, signature: Array<felt252>) -> bool {
            let is_valid_length = signature.len() == 2_u32;

            if !is_valid_length {
                return false;
            }
            
            check_ecdsa_signature(
                hash, self.public_key.read(), *signature.at(0_u32), *signature.at(1_u32)
            )
        }
    }

    #[external(v0)]
    impl IAccountAddonImpl of IAccountAddon<ContractState> {

        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            self.validate_transaction()
        }

        fn __validate_deploy__(self: @ContractState, class_hash: felt252,contract_address_salt: felt252,public_key_: felt252) -> felt252 {
            self.validate_transaction()
        }

        fn public_key(self: @ContractState) -> felt252 {
            self.public_key.read()
        }
    }

    #[external(v0)]
    impl ISRC6Impl of ISRC6<ContractState> {

        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
            self.validate_transaction()
        }

        // execute a contract call
        fn __execute__(ref self: ContractState, mut calls: Array<Call>) -> Array<Span<felt252>> {
            // Validate caller
            assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

            let tx_info = starknet::get_tx_info().unbox();
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            let mut result : Array<Span<felt252>> = ArrayTrait::new();
            loop {
                match calls.pop_front() {
                    Option::Some(call) => {
                        let res = call_contract_syscall(
                            address: call.to,
                            entry_point_selector: call.selector,
                            calldata: call.calldata.span()
                        ).unwrap_syscall();

                        // ArrayTCloneImpl::clone(res)

                        result.append(res);
                    },
                    Option::None(()) => {
                        break; // Can't break result; because of 'variable was previously moved'
                    },
                };
            };
            result
        }

        fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
            let is_valid = self.is_valid_signature_bool(hash, signature);
            if is_valid { 'VALID' } else { 0 }
        }
        
    }

}