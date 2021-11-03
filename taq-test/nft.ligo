//ERRORS

const fa2_token_undefined = "FA2_TOKEN_UNDEFINED"
const fa2_insufficient_balance = "FA2_INSUFFICIENT_BALANCE"
const fa2_tx_denied = "FA2_TX_DENIED"
const fa2_not_owner = "FA2_NOT_OWNER"
const fa2_not_operator = "FA2_NOT_OPERATOR"
const fa2_operators_not_supported = "FA2_OPERATORS_UNSUPPORTED"
const fa2_receiver_hook_failed = "FA2_RECEIVER_HOOK_FAILED"
const fa2_sender_hook_failed = "FA2_SENDER_HOOK_FAILED"
const fa2_receiver_hook_undefined = "FA2_RECEIVER_HOOK_UNDEFINED"
const fa2_sender_hook_undefined = "FA2_SENDER_HOOK_UNDEFINED"

//INTERFACE

//declaring the token id type, a natural number
type token_id is nat

//declaring the types of input parameters the token transfer function assumes: recipient address, id, and the number of tokens. Adding the sender’s address to the type transfer
type transfer_destination is
[@layout:comb]
record [
 to_ : address;
 token_id : token_id;
 amount : nat;
]

type transfer is
[@layout:comb]
record [
 from_ : address;
 txs : list(transfer_destination);
]

//declaring types to read the balance: the owner’s address, token id
type balance_of_request is
[@layout:comb]
record [
 owner : address;
 token_id : token_id;
]

type balance_of_response is
[@layout:comb]
record [
 request : balance_of_request;
 balance : nat;
]

type balance_of_param is
[@layout:comb]
record [
 requests : list(balance_of_request);
 callback : contract (list(balance_of_response));
]

// declaring the operator type (the address that can send tokens)
type operator_param is
[@layout:comb]
record [
 owner : address;
 operator : address;
 token_id: token_id;
]

//declaring the type of params required to update the list of operators
type update_operator is
[@layout:comb]
 | Add_operator of operator_param
 | Remove_operator of operator_param

//declaring the type that contains NFT metadata: token ID and link to the JSON file
type token_info is (token_id * map(string, bytes))

type token_metadata is
big_map (token_id, token_info)

//declaring the type with the link to the smart contract’s metadata. The data will be shown in the wallet
type metadata is
big_map(string, bytes)

//declaring the type that can store records on several tokens and their metadata in the same contract
type token_metadata_param is
[@layout:comb]
record [
 token_ids : list(token_id);
 handler : (list(token_metadata)) -> unit;
]

//declaring the pseudo-entry points: token transfer, balance check, operator update, and metadata check
type fa2_entry_points is
 | Transfer of list(transfer)
 | Balance_of of balance_of_param
 | Update_operators of list(update_operator)
 | Token_metadata_registry of contract(address)

type fa2_token_metadata is
 | Token_metadata of token_metadata_param

//declaring the data types to change permissions to transfer tokens. E.g., they can create a token that can’t be sent elsewhere
type operator_transfer_policy is
 [@layout:comb]
 | No_transfer
 | Owner_transfer
 | Owner_or_operator_transfer

type owner_hook_policy is
 [@layout:comb]
 | Owner_no_hook
 | Optional_owner_hook
 | Required_owner_hook

type custom_permission_policy is
[@layout:comb]
record [
 tag : string;
 config_api: option(address);
]

type permissions_descriptor is
[@layout:comb]
record [
 operator : operator_transfer_policy;
 receiver : owner_hook_policy;
 sender : owner_hook_policy;
 custom : option(custom_permission_policy);
]

type transfer_destination_descriptor is
[@layout:comb]
record [
 to_ : option(address);
 token_id : token_id;
 amount : nat;
]

type transfer_descriptor is
[@layout:comb]
record [
 from_ : option(address);
 txs : list(transfer_destination_descriptor)
]

type transfer_descriptor_param is
[@layout:comb]
record [
 batch : list(transfer_descriptor);
 operator : address;
]

//OPERATORS

//declaring the type that stores records on operators in the same big_map
type operator_storage is big_map ((address * (address * token_id)), unit)

//declaring the function for updating the list of operators
function update_operators (const update : update_operator; const storage : operator_storage)
   : operator_storage is
 case update of
 | Add_operator (op) ->
   Big_map.update ((op.owner, (op.operator, op.token_id)), (Some (unit)), storage)
 | Remove_operator (op) ->
   Big_map.remove ((op.owner, (op.operator, op.token_id)), storage)
 end

//declaring the function that checks if the user can update the list of operators
function validate_update_operators_by_owner (const update : update_operator; const updater : address)
   : unit is block {
     const op = case update of
       | Add_operator (op) -> op
       | Remove_operator (op) -> op
     end;
     if (op.owner = updater) then skip else failwith (fa2_not_owner)
   } with unit

//declaring the function that checks if the user can update the list of owner addresses, and only in that case calls the update function
function fa2_update_operators (const updates : list(update_operator); const storage : operator_storage) : operator_storage is block {
 const updater = Tezos.sender;
 function process_update (const ops : operator_storage; const update : update_operator) is block {
   const u = validate_update_operators_by_owner (update, updater);
 } with update_operators(update, ops)
} with List.fold(process_update, updates, storage)

type operator_validator is (address * address * token_id * operator_storage) -> unit

//declaring the function that checks the permissions to transfer tokens. If the user can’t send a token, the function terminates the contract’s execution
function make_operator_validator (const tx_policy : operator_transfer_policy) : operator_validator is block {
 const x = case tx_policy of
 | No_transfer -> (failwith (fa2_tx_denied) : bool * bool)
 | Owner_transfer -> (True, False)
 | Owner_or_operator_transfer -> (True, True)
 end;
 const can_owner_tx = x.0;
 const can_operator_tx = x.1;
 const inner = function (const owner : address; const operator : address; const token_id : token_id; const ops_storage : operator_storage):unit is
   if (can_owner_tx and owner = operator)
   then unit
   else if not (can_operator_tx)
   then failwith (fa2_not_owner)
   else if (Big_map.mem  ((owner, (operator, token_id)), ops_storage))
   then unit
   else failwith (fa2_not_operator)
} with inner

//declaring the function for the owner to transfer the token
function default_operator_validator (const owner : address; const operator : address; const token_id : token_id; const ops_storage : operator_storage) : unit is
 if (owner = operator)
 then unit
 else if Big_map.mem ((owner, (operator, token_id)), ops_storage)
 then unit
 else failwith (fa2_not_operator)

//declaring the function that collects all transactions of the same token in one batch
function validate_operator (const tx_policy : operator_transfer_policy; const txs : list(transfer); const ops_storage : operator_storage) : unit is block {
 const validator = make_operator_validator (tx_policy);
 List.iter (function (const tx : transfer) is
   List.iter (function (const dst : transfer_destination) is
     validator (tx.from_, Tezos.sender, dst.token_id ,ops_storage),
     tx.txs),
   txs)
} with unit

//MAIN


//declaring the data type to store records on which address keeps the token with the given id
type ledger is big_map (token_id, address)

//declaring the contract storage: TZIP-16 metadata, ledger of addresses and tokens, list of operators, and on-chain metadata
type collection_storage is record [
 metadata : big_map (string, bytes);
 ledger : ledger;
 operators : operator_storage;
 token_metadata : token_metadata;
]


//declaring the token transfer function. It will get the token’s id, the addresses of the sender and the recipient, and checks whether the sender has the right to transfer the token
function transfer (
 const txs : list(transfer);
 const validate : operator_validator;
 const ops_storage : operator_storage;
 const ledger : ledger) : ledger is block {
   //checking the sender’s right to transfer the token
   function make_transfer (const l : ledger; const tx : transfer) is
     List.fold (
       function (const ll : ledger; const dst : transfer_destination) is block {
         const u = validate (tx.from_, Tezos.sender, dst.token_id, ops_storage);
       } with
         //checking the number of transferred NFT. We imply that the contract has issued just 1 token with this ID
         //if the user wants to send 0, 0.5, 2 or any other number of tokens, the function will terminate the contract’s execution
         if (dst.amount = 0n) then
		ll
         else if (dst.amount =/= 1n)
         then (failwith(fa2_insufficient_balance): ledger)
         else block {
           const owner = Big_map.find_opt(dst.token_id, ll);
         } with
           case owner of
             Some (o) ->
             //checking whether the sender has the token
             if (o =/= tx.from_)
             then (failwith(fa2_insufficient_balance) : ledger)
             else Big_map.update(dst.token_id, Some(dst.to_), ll)
           | None -> (failwith(fa2_token_undefined) : ledger)
           end
       ,
       tx.txs,
       l
     )
} with List.fold(make_transfer, txs, ledger)

//declaring the function that returns the sender’s balance
function get_balance (const p : balance_of_param; const ledger : ledger) : operation is block {
 function to_balance (const r : balance_of_request) is block {
   const owner = Big_map.find_opt(r.token_id, ledger);
 }
 with
   case owner of
     None -> (failwith (fa2_token_undefined): record[balance: nat; request: record[owner: address ; token_id : nat]])
   | Some (o) -> block {
     const bal = if o = r.owner then 1n else 0n;
   } with record [request = r; balance = bal]
   end;
 const responses = List.map (to_balance, p.requests);
} with Tezos.transaction(responses, 0mutez, p.callback)

//declaring the function with pseudo-entry points which underpin the very FA2 standard
function main (const param : fa2_entry_points; const storage : collection_storage) : (list (operation) * collection_storage) is
 case param of
   | Transfer (txs) -> block {
     const new_ledger = transfer (txs, default_operator_validator, storage.operators, storage.ledger);
     const new_storage = storage with record [ ledger = new_ledger ]
   } with ((list [] : list(operation)), new_storage)
   | Balance_of (p) -> block {
     const op = get_balance (p, storage.ledger);
   } with (list [op], storage)
   | Update_operators (updates) -> block {
     const new_operators = fa2_update_operators(updates, storage.operators);
     const new_storage = storage with record [ operators = new_operators ];
   } with ((list [] : list(operation)), new_storage)
   | Token_metadata_registry (callback) -> block {
     const callback_op = Tezos.transaction(Tezos.self_address, 0mutez, callback);
   } with (list [callback_op], storage)
 end