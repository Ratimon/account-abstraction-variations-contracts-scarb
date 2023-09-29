#[starknet::contract]
mod AccountWithMulticall {
    use array::{ArrayTrait, ArraySerde, SpanTrait};
    
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;
    use option::OptionTrait;
    use starknet::account::Call;
    use starknet::{ContractAddress, call_contract_syscall};
    use zeroable::Zeroable;

    use account_abstraction_variations::accounts::interface::ISRC6;

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
    }

    #[external(v0)]
    impl ISRC6Impl of ISRC6<ContractState> {

        
    }



}