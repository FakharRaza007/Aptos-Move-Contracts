
// module farmer::Garry_store_ecommerece {
//     use std::signer::address_of;
//     use std::string::{Self, String, utf8};
//     use aptos_token::token;
//     use aptos_framework::account;
//     use aptos_framework::coin;
//     use std::simple_map::{SimpleMap,Self};
//     use std::bcs;
//     use aptos_framework::timestamp;
//     use aptos_framework::table::{Self, Table};
//     use aptos_framework::aptos_coin::AptosCoin;
//     use std::vector;
//     use aptos_framework::event;

//     const MARKETING_WALLET: address = @farmer;

//    const BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";


//     // Error codes
//     const EKEY_COUNT_NOT_MATCH_TYPE_COUNTER:u64 = 3;
//     const NOT_ADMIN: u64 = 1;
//     const EXCEED_MINT_COUNT: u64 = 2;
//     const VALUE_NOT_FOUND:u64 = 4;
//     const EKEY_NOT_FOUND:u64 = 5;
//     const E_NOT_OWNER:u64=6;
//     const E_ALREADY_CONFIRMED:u64 = 7 ;

//     // Define a struct to hold minting information
//     struct MintInfo has key {
//         pool_cap: account::SignerCapability,
//         cid: u64,
//         total_supply:u64
//     }

//    #[event]

//     struct NFTMinted has store, drop {
//         user: address,
//         token_Name: String,
//         collection_name: String,
//         token_Id: u64,
//     }


//     // EVENT: Fired when a new collection is created
//     #[event]
//     struct CollectionCreated has store, drop {
//         owner: address,
//         collection_name: String,
//         total_supply: u64,
//     }

//    // EVENT: Fired when an escrow sale is confirmed
//  #[event]
//     struct EscrowSaleConfirmed has store, drop {
//         buyer: address,
//         seller: address,
//         collection_name: String,
//         token_id: u64,
//         price: u64,
//     }

//     #[event]
//     struct FeeUpdated has store, drop {
//         admin: address,
//         new_fee: u64,
//     }


//     struct EscrowState has key,store {
     
//         confirmed: SimpleMap<u64,String>,
//         name_map: SimpleMap<u64,String>,

//     }

//     struct EscrowData has key ,  store, drop,copy {

//         user_address: address,
//         name_token: String,
//         name_collection: String,
//         price_per_token: u64,
//         collection_ids: u64,
//         token_id:u64,
//         confirmed:bool
//     }

// struct Metadata has key, store, drop, copy {

//     name: String,
//     collection_name: String,
//     total_supply: u64,
//     price_per_token: u64,
//     description: String,
//     base_url: String,
//     collection_url: String,
//     collection_owner: address,
//     next_token_id: u64 ,
//     // Add this field to track token IDs
// }

  

//    struct CollecList has key {
//     info: Table<u64, Metadata>,
//     escrow:Table<u64,vector<EscrowData>>,
//     prop_id: u64
// }

// struct CollectionFee has key, store {
//         fee_per_collection: u64,  // Fee amount in octas
//     }
   


// public entry  fun intialize_contract(admin:&signer,fee_per_collections:u64){


// assert!(address_of(admin) == MARKETING_WALLET, NOT_ADMIN);

// let seed_vec = bcs::to_bytes(&timestamp::now_seconds());
// let (pool_signer, pool_signer_cap) = account::create_resource_account(admin,seed_vec);

//     if (!token::has_token_store(address_of(&pool_signer))) {
//         token::initialize_token_store(&pool_signer);
//         token::opt_in_direct_transfer(&pool_signer, true);
//     };
// coin::register<AptosCoin>(&pool_signer);



// move_to(admin, CollectionFee { fee_per_collection: fee_per_collections });

//   move_to(admin, MintInfo {

//             pool_cap: pool_signer_cap,
//             cid: 0,
//             total_supply:0

//         });

//   let init_collection = CollecList{

//             info: table::new(),
//             escrow:table::new(),
//             prop_id: 0

//         };

//     move_to(admin,init_collection);
//     move_to(admin,EscrowState{confirmed:simple_map::create(),name_map:simple_map::create()});

// let meta_data = Metadata{
//     name:utf8(b""),
//     collection_name:utf8(b"") ,
//     total_supply: 0 ,
//     price_per_token :0,
//     description:utf8(b"")  ,
//     base_url:utf8(b"") ,
//     collection_url: utf8(b""),
//     collection_owner: @0x0,
//     next_token_id:0,
//     };

// move_to(admin,meta_data);

//     let escrow_data = EscrowData{

//         user_address: @0x0,
//         name_token:utf8(b"")  ,
//         name_collection: utf8(b"") ,
//         price_per_token: 0,
//         collection_ids: 0,
//         token_id:0,
//         confirmed:false ,
   
//     };


// move_to(admin,escrow_data);


// }

// public entry fun add_collection(
//     admin: &signer,
//     _name: String, 
//     _collection_name: String,
//     _total_supply: u64,
//     _price_per_token: u64,
//     _description: String,
//     _base_url: String,
//     _collection_url: String
// ) acquires CollecList, MintInfo,CollectionFee {

//     let data_instance = Metadata {
//         name: _name,
//         collection_name: _collection_name,
//         total_supply: _total_supply,
//         price_per_token: _price_per_token,
//         description: _description,
//         base_url: _base_url,
//         collection_url: _collection_url,
//         collection_owner: address_of(admin),
//         next_token_id: 1 , // Start token IDs from 1
        
//     };


// let owner_addr = address_of(admin);

//   if (!token::has_token_store(owner_addr)) {

//             token::initialize_token_store(admin);
//             token::opt_in_direct_transfer(admin, true);
//     };


//    let fee_struct = borrow_global<CollectionFee>(MARKETING_WALLET);

//         let fee_amount = fee_struct.fee_per_collection;
//         coin::transfer<AptosCoin>(admin, MARKETING_WALLET, fee_amount);


//     let collect_list = borrow_global_mut<CollecList>(MARKETING_WALLET);
//     let new_id = collect_list.prop_id + 1;

//     table::upsert(&mut collect_list.info, new_id, data_instance);
//     collect_list.prop_id = new_id;

// table::upsert(&mut collect_list.escrow, new_id,vector::empty<EscrowData>());
    


//     let mint_info = borrow_global_mut<MintInfo>(MARKETING_WALLET);
//     let prev_supply = mint_info.total_supply;
//     mint_info.total_supply = prev_supply + _total_supply;

//     let pool_signer = account::create_signer_with_capability(&mint_info.pool_cap);

//     token::create_collection(
//         &pool_signer,
//         _collection_name,
//         _description,
//         _collection_url,
//         _total_supply+1,
//         vector<bool>[true, true, true]
//     );

//     let token_name = utf8(b"Reserved_token");
    
//         let token_data_id = token::create_tokendata(
//             &pool_signer,
//             _collection_name,
//             token_name,
//            _description,
//             1,
//             _base_url,
//             MARKETING_WALLET,
//             0,
//             0,
//             token::create_token_mutability_config(&vector<bool>[false, false, false, false, false]),
//             vector<String>[utf8(BURNABLE_BY_OWNER)],
//             vector<vector<u8>>[bcs::to_bytes<bool>(&true)],
//             vector<String>[utf8(b"bool")]
//         );

//  token::mint_token_to(&pool_signer, address_of(&pool_signer), token_data_id, 1);

//       event::emit<CollectionCreated>(CollectionCreated {
//             owner: owner_addr,
//             collection_name: _collection_name,
//             total_supply: _total_supply
//         });
// }


//   public entry fun set_collection_fee(admin: &signer, new_fee: u64) acquires CollectionFee {
//         assert!(address_of(admin) == MARKETING_WALLET, 1);  // Ensure only marketing wallet can set fee
//         let fee_struct = borrow_global_mut<CollectionFee>(MARKETING_WALLET);
//         fee_struct.fee_per_collection = new_fee;
        
//         event::emit<FeeUpdated>(FeeUpdated {
//             admin: address_of(admin),
//             new_fee: new_fee
//         });
//     }



// public entry fun update_collec_price_per_token(
//     admin: &signer, 
//     collection_id: u64, 
//     new_price: u64
// ) acquires  CollecList {

//     // Ensure the caller is the admin (farmer)
//     let collect_list = borrow_global_mut<CollecList>(MARKETING_WALLET);
//     let  collection_info_ref = table::borrow_mut(&mut collect_list.info, collection_id);

//     assert!(address_of(admin) == collection_info_ref.collection_owner , NOT_ADMIN);
 
 
     
//     let  collection_info = *collection_info_ref;

//     // Update the `price_per_token` of the collection
//     collection_info.price_per_token = new_price;

//     // Use upsert to insert the updated collection back into the table (as a value, not a reference)
//     table::upsert(&mut collect_list.info, collection_id, collection_info);
// }



//   public entry fun mint_nft(user: &signer, collection_id: u64, count: u64) acquires MintInfo,  CollecList {

//     let user_addr = address_of(user);
//     let mint_info = borrow_global_mut<MintInfo>(MARKETING_WALLET);

//     let collect_list = borrow_global_mut<CollecList>(MARKETING_WALLET);
//     let metadata_ref = table::borrow_mut(&mut collect_list.info, collection_id);

//     // Ensure there are enough tokens remaining in the collection's total supply
//     assert!(metadata_ref.next_token_id + count - 1 <= metadata_ref.total_supply, EXCEED_MINT_COUNT);

//     token::initialize_token_store(user);
//     token::opt_in_direct_transfer(user, true);

//     let pool_signer = account::create_signer_with_capability(&mint_info.pool_cap);

//      coin::transfer<AptosCoin>(user,storage_address(), (metadata_ref.price_per_token*count));

//     let i = 0;
//     while (i < count) {
//         let token_name = metadata_ref.name;
//         let token_id = metadata_ref.next_token_id;

//         // Append token_id to token name
//         string::append(&mut token_name, utf8(b" #"));
//         string::append(&mut token_name, utf8(num_to_str(token_id)));

//         let token_uri = metadata_ref.base_url;
//         string::append(&mut token_uri, utf8(b"/"));
//         string::append(&mut token_uri, utf8(num_to_str(token_id)));
//         string::append(&mut token_uri, utf8(b".json"));

//         let token_data_id = token::create_tokendata(
//             &pool_signer,
//             metadata_ref.collection_name,
//             token_name,
//             metadata_ref.description,
//             1,
//             token_uri,
//             metadata_ref.collection_owner,
//             0,
//             0,
//             token::create_token_mutability_config(&vector<bool>[false, false, false, false, false]),
//             vector<String>[utf8(BURNABLE_BY_OWNER)],
//             vector<vector<u8>>[bcs::to_bytes<bool>(&true)],
//             vector<String>[utf8(b"bool")]
//         );

    
//      let escrow_instance = EscrowData{

//         user_address: user_addr,
//         name_token:token_name ,
//         name_collection:metadata_ref.collection_name  ,
//         price_per_token:metadata_ref.price_per_token ,
//         collection_ids:collection_id ,
//         token_id:token_id,
//         confirmed:false 
    

//      };

//      let escrow_vec  =  table::borrow_mut(&mut collect_list.escrow , collection_id) ;
//      vector::push_back(escrow_vec,escrow_instance);


//         token::mint_token_to(&pool_signer, user_addr, token_data_id, 1);

//       event::emit<NFTMinted>(NFTMinted {
//                 user: user_addr,
//                 token_Name: token_name,
//                 collection_name: metadata_ref.collection_name,
//                 token_Id: token_id
//             });

//         // Increment next_token_id for the collection
//         metadata_ref.next_token_id = metadata_ref.next_token_id + 1;

//         i = i + 1;
//     };

//     // Use upsert to update the metadata back in the table
//     table::upsert(&mut collect_list.info, collection_id, *metadata_ref);
// }

//    // Convert a number to a vector of bytes
//     public fun num_to_str(num: u64): vector<u8> {
//         let vec_data = vector::empty<u8>();
//         while (true) {
//             vector::push_back(&mut vec_data, (num % 10 + 48) as u8);
//             num = num / 10;
//             if (num == 0) {
//                 break
//             }
//         };
//         vector::reverse<u8>(&mut vec_data);
//         vec_data
//     }

   

// public entry fun buyer_confirm(
//     buyer: &signer,
//     collection_id: u64,
//     token_id: u64
// ) acquires CollecList, MintInfo {


//     let collect_list = borrow_global_mut<CollecList>(MARKETING_WALLET);
//     let collection_info_ref = table::borrow_mut(&mut collect_list.info, collection_id);
//     let escrow_vec = table::borrow_mut(&mut collect_list.escrow, collection_id);
//     let mint_info = borrow_global_mut<MintInfo>(MARKETING_WALLET);
//     let pool_signer = account::create_signer_with_capability(&mint_info.pool_cap);
//     let escrow_instance = vector::borrow_mut(escrow_vec, token_id-1);

//         assert!(escrow_instance.user_address==address_of(buyer),E_NOT_OWNER); 

//     let  found = false;

//         if (escrow_instance.collection_ids == collection_id) {
            
//             if (escrow_instance.confirmed ) {
//                 // If already confirmed, burn the NFT only
//                 token::burn(
//                     buyer,
//                     storage_address(),
//                     escrow_instance.name_collection,
//                     escrow_instance.name_token,
//                     0,
//                     1
//                 );

//             }
            
//              else {
//                 // Transfer funds to the farmer (only if not already confirmed)
//                 coin::transfer<AptosCoin>(&pool_signer,collection_info_ref.collection_owner , escrow_instance.price_per_token);
 
//                token::burn(
//                     buyer,
//                     storage_address(),
//                     escrow_instance.name_collection,
//                     escrow_instance.name_token,
//                     0,
//                     1
//                 );
//                 // Mark the transaction as confirmed
//                 escrow_instance.confirmed = true;
//             };

//             found = true;
//         };
//       event::emit<EscrowSaleConfirmed>(EscrowSaleConfirmed {
//             buyer: address_of(buyer),
//             seller: escrow_instance.user_address,
//             collection_name: escrow_instance.name_collection,
//             token_id: escrow_instance.token_id,
//             price: escrow_instance.price_per_token
//         });

//     // Ensure the escrow entry was found
//     assert!(found, VALUE_NOT_FOUND);
// }

// public entry fun farmer_confirm(
//     farmer: &signer,
//     collection_id: u64,
//     token_id: u64
// ) acquires  CollecList ,MintInfo{

//     let collect_list = borrow_global_mut<CollecList>(MARKETING_WALLET);
//      let  collection_info_ref = table::borrow_mut(&mut collect_list.info, collection_id);
//     let escrow_vec = table::borrow_mut(&mut collect_list.escrow, collection_id);
//     let escrow_instance = vector::borrow_mut(escrow_vec, token_id-1);

//         assert!(address_of(farmer) == collection_info_ref.collection_owner , NOT_ADMIN);
//          assert!(!escrow_instance.confirmed,E_ALREADY_CONFIRMED );

//     let mint_info = borrow_global_mut<MintInfo>(MARKETING_WALLET);
//     let pool_signer = account::create_signer_with_capability(&mint_info.pool_cap);

//         if (escrow_instance.collection_ids == collection_id && !escrow_instance.confirmed) {
        
//             coin::transfer<AptosCoin>(&pool_signer, collection_info_ref.collection_owner, escrow_instance.price_per_token);

//             escrow_instance.confirmed = true;
            
//         };
    

// }
// #[view]
// public fun get_escrow_detail(
//     customer_address: address  // The address of the customer
// ): vector<EscrowData> acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);

//     let customer_minted_tokens = vector::empty<EscrowData>();

//     let collection_id = 1;
//     while (collection_id <= collect_list.prop_id) {
//         let escrow_vec = table::borrow(&collect_list.escrow, collection_id);
//         let escrow_length = vector::length(escrow_vec);

//         let i = 0;
//         while (i < escrow_length) {
//             let escrow_instance = vector::borrow(escrow_vec, i);

//             if (escrow_instance.user_address == customer_address) {
//                 vector::push_back(&mut customer_minted_tokens, *escrow_instance);
//             };
//             i = i + 1;
//         };
//         collection_id = collection_id + 1;
//     };

//     customer_minted_tokens
// }





// #[view]

// public fun get_collection_details(
//     collection_id: u64
// ): (String, String, u64, u64, String, String, String, address
// , u64) acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);
//     let metadata = table::borrow(&collect_list.info, collection_id);

//     (
//         metadata.name,
//         metadata.collection_name,
//         metadata.total_supply,
//         metadata.price_per_token,
//         metadata.description,
//         metadata.base_url,
//         metadata.collection_url,
//         metadata.collection_owner,
//         metadata.next_token_id
//     )
// }

// #[view]

// public fun get_total_collections(): u64 acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);

//       collect_list.prop_id
// }



// public fun storage_address():address acquires MintInfo {

//      let mint_info = borrow_global<MintInfo>(MARKETING_WALLET);
//      let addr  = account::get_signer_capability_address(&mint_info.pool_cap);
//        addr
     
// }

//  // Function to get the escrow balance of a specific address for a specific collection.
// #[view]
// public fun get_farmers_collection_summary(
//     farmer_address: address  // The address of the collection owner (farmer)
// ): (
//     u64,                 // Total collections
//     u64, 
//     u64,                // Total minted tokens
//     vector<u64>,         // Collection IDs
//     u64,                 // Total remaining NFTs
//     vector<EscrowData>,  // Pending escrows
//     vector<EscrowData>   // Confirmed escrows
// ) acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);

//     // Initialize result variables
//     let  total_collections = 0;
//     let  coin_balance ;
//     let  total_minted_tokens = 0;
//     let  farmer_collections = vector::empty<u64>();  // Store collection IDs
//     let  total_remaining_nfts = 0;  // Track total remaining NFTs
//     let  pending_escrows = vector::empty<EscrowData>();  // Store pending escrows
//     let  confirmed_escrows = vector::empty<EscrowData>();  // Store confirmed escrows

//     // Iterate through all collections
//     let  collection_id = 1;
//     while (collection_id <= collect_list.prop_id) {
//         let metadata = table::borrow(&collect_list.info, collection_id);

//         // Check if the collection belongs to the given farmer
//         if (metadata.collection_owner == farmer_address) {
//             // Add the collection ID to the farmer's collection list
//             vector::push_back(&mut farmer_collections, collection_id);

//             // Count the collection
//             total_collections = total_collections + 1;

//             // Calculate minted tokens (next_token_id - 1 represents minted tokens)
//             let minted_tokens = metadata.next_token_id - 1;
//             total_minted_tokens = total_minted_tokens + minted_tokens;

//             // Calculate remaining NFTs for this collection and accumulate
//             let remaining_nfts = metadata.total_supply - minted_tokens;
//             total_remaining_nfts = total_remaining_nfts + remaining_nfts;

//             // Fetch the escrow vector for this collection
//             let escrow_vec = table::borrow(&collect_list.escrow, collection_id);
//             let escrow_length = vector::length(escrow_vec);

//             // Iterate over the escrow vector to collect confirmed and pending escrows
//             let  i = 0;
//             while (i < escrow_length) {
//                 let escrow_instance = vector::borrow(escrow_vec, i);

//                 // Check if escrow is confirmed or pending
//                 if (escrow_instance.confirmed) {
//                     // Push to confirmed escrows
//                     vector::push_back(&mut confirmed_escrows, *escrow_instance);
//                 } else {
//                     // Push to pending escrows
//                     vector::push_back(&mut pending_escrows, *escrow_instance);
//                 };
//                 i = i + 1;
//             };
//         };
//         collection_id = collection_id + 1;
//     };

//      if (coin::balance<AptosCoin>(farmer_address)>0) {
//       coin_balance =  coin::balance<AptosCoin>(farmer_address);
//     }
//      else {
//        coin_balance = 0; // Return 0 if the coin store does not exist.
//     };

//     // Return the summary
//     (
//         total_collections,
//         coin_balance,
//         total_minted_tokens,
//         farmer_collections,
//         total_remaining_nfts,
//         pending_escrows,
//         confirmed_escrows
//     )
// }


// #[view]
// public fun get_total_collections_minted_by_customer(
//     customer_address: address  // The address of the customer
// ): u64 acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);
//     let total_collections = 0;

//     let collection_id = 1;
//     while (collection_id <= collect_list.prop_id) {
//         let escrow_vec = table::borrow(&collect_list.escrow, collection_id);
//         let escrow_length = vector::length(escrow_vec);

//         let i = 0;
//         let found = false;

//         // Iterate through escrow data of this collection
//         while (i < escrow_length) {
//             let escrow_instance = vector::borrow(escrow_vec, i);

//             // If this customer has minted any tokens from this collection
//             if (escrow_instance.user_address == customer_address) {
//                 found = true;
//                 break
//             };
//             i = i + 1;
//         };

//         // If the customer minted in this collection, count it
//         if (found) {
//             total_collections = total_collections + 1;
//         };

//         collection_id = collection_id + 1;
//     };

//     total_collections
// }

// #[view]
// public fun get_total_tokens_minted_by_customer(
//     customer_address: address  // The address of the customer
// ): u64 acquires CollecList {
//     let collect_list = borrow_global<CollecList>(MARKETING_WALLET);
//     let total_tokens = 0;

//     let collection_id = 1;
//     while (collection_id <= collect_list.prop_id) {
//         let escrow_vec = table::borrow(&collect_list.escrow, collection_id);
//         let escrow_length = vector::length(escrow_vec);

//         let i = 0;

//         // Iterate through escrow data of this collection
//         while (i < escrow_length) {
//             let escrow_instance = vector::borrow(escrow_vec, i);

//             // If this customer minted the token, add to the count
//             if (escrow_instance.user_address == customer_address) {
//                 total_tokens = total_tokens + 1;
//             };
//             i = i + 1;
//         };

//         collection_id = collection_id + 1;
//     };

//     total_tokens
// }
// }


