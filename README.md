# D3 Vault Clarity Smart Contract

A Clarity smart contract for managing an STX vault with even reward distribution among registered users.

## Features

- **Recipient Registration:** Users can register to receive STX rewards.
- **Admin Controls:** Only the admin can deposit STX and reset the recipient list.
- **Reward Distribution:** Admin can distribute deposited STX evenly among all registered recipients.
- **Claim Rewards:** Registered users can claim their allocated STX rewards.
- **View Functions:** Read-only functions to view assigned rewards and the recipient list.
- **Error Handling:** Custom error codes for common failure cases.

## Functions

### Public Functions

- `register-recipient`: Register the caller as a recipient.
- `deposit-rewards (amount)`: Admin deposits STX into the reward pool.
- `distribute`: Admin distributes the reward pool evenly among recipients.
- `claim-reward`: Recipients claim their allocated rewards.
- `reset-cycle`: Admin resets the recipient list for a new cycle.

### Read-Only Functions

- `get-reward (user)`: View the reward assigned to a specific address.
- `get-recipients`: View the list of all registered recipients.

## Error Codes

- `ERR_NOT_ADMIN (err u100)`: Caller is not the admin.
- `ERR_ALREADY_REGISTERED (err u101)`: User is already registered.
- `ERR_NO_REWARDS (err u102)`: No rewards available for distribution.
- `ERR_NOT_REGISTERED (err u103)`: User is not registered.
- `ERR_ALREADY_CLAIMED (err u104)`: Reward already claimed.

## Usage

1. **Deploy the contract** to the Stacks blockchain.
2. **Admin deposits STX** using `deposit-rewards`.
3. **Users register** using `register-recipient`.
4. **Admin distributes rewards** using `distribute`.
5. **Users claim rewards** using `claim-reward`.
6. **Admin can reset** the cycle with `reset-cycle`.
