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

    #[external(v0)]
    impl ISRC6Impl of ISRC6<ContractState> {

        
    }

}