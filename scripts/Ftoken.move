module 0xCAFEE::Mpepe {

  use std::signer;
  use std::string::String;
  use aptos_framework::coin;
  use aptos_framework::account;

  const SEED: vector<u8> = b"MEME-Coin";
  const COIN_DECIMALS: u8 = 8;

  const E_USER_NOT_OWNER: u64 = 101;

  struct MPEPE {}

  struct AdminCap has key {}

  struct State has key {
    signer_cap: account::SignerCapability,
    aptos_coin_mint_cap: coin::MintCapability<MPEPE>,
    aptos_coin_burn_cap: coin::BurnCapability<MPEPE>
  }

  fun init_module(admin: &signer) {

    let (resource_account_signer, signer_cap) = account::create_resource_account(admin, SEED);

    let (burn_cap, freeze_cap, mint_cap) = coin::initialize<MPEPE>(
      admin, 
      utf8(b"Mpepe Token"),
      utf8(b"MPPT"),
      COIN_DECIMALS,
      true
    );
    coin::destroy_freeze_cap(freeze_cap);

    move_to<State>(
      &resource_account_signer,
      State {
        signer_cap: signer_cap,
        aptos_coin_mint_cap: mint_cap,
        aptos_coin_burn_cap: burn_cap
      }
    );

    coin::register<MPEPE>(&resource_account_signer);
  }

  public entry fun mint(
    admin: &signer,
    amount: u64, 
    recipient: address
  ) acquires State {
    assert_user_is_module_owner(admin);
    let state = borrow_global_mut<State>(get_resource_address());
    let minted_coin = coin::mint(amount, &state.aptos_coin_mint_cap);
    coin::deposit(recipient, minted_coin);
  }

  public entry fun register(recipient: &signer) {
    coin::register<MPEPE>(recipient);
  }

  public entry fun burn(
    owner: &signer,
    amount: u64
  ) acquires State {
    let state = borrow_global_mut<State>(get_resource_address());
    let coin_to_burn = coin::withdraw(owner, amount);
    coin::burn(coin_to_burn, &state.aptos_coin_burn_cap);
  }

  public entry fun transfer_coin(owner: &signer, account: address, amount: u64) {
    assert_user_is_module_owner(owner);
    coin::transfer<MPEPE>(owner, account, amount);
  }

  #[view]
  public fun is_register_account(_address: address): bool {
    let registered: bool = coin::is_account_registered<MPEPE>(_address);
    registered
  }

  inline fun get_resource_address(): address {
    account::create_resource_address(&@0xCAFEE, SEED)
  }

  inline fun assert_user_is_module_owner(user: &signer) {
    assert!(signer::address_of(user) == @0xCAFEE, E_USER_NOT_OWNER);
  }

  #[test_only]
  use std::debug::print;
  use std::string::utf8;

  #[test(admin=@0xCAFEE)]
  public entry fun test_function(admin: &signer) acquires State {
    init_module(admin);
    register(admin);
    let _address = @0x1122;
    let addr = signer::address_of(admin);

    mint(admin, 10000, addr);
    print(&utf8(b"minted Successfully"));
  }
}
