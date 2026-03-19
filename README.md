
# BLOCK-CHECKPOINT-log

A Clarity smart contract for recording permanent, immutable checkpoints on the Stacks blockchain. Each checkpoint acts as an auditable log entry, storing the creator’s address, a sequential checkpoint ID, and an optional message reference.

## Features

- **Append-only registry:** No deletions or modifications, ensuring a tamper-proof audit trail.
- **No admin required:** Anyone can create and query checkpoints.
- **Transparent and deterministic:** All logic is on-chain and easy to audit.
- **Flexible use cases:** Protocol milestones, audit trails, timestamp proofs, governance events, and more.

## How It Works

1. A user calls `create-checkpoint` with an optional message ID.
2. The contract records:
   - The caller’s address (`tx-sender`)
   - The next sequential checkpoint ID
   - The provided message ID (if any)
3. The checkpoint is stored in the contract’s registry.
4. Anyone can query checkpoints by ID or check if a checkpoint exists.

## Contract Functions

| Function                  | Type            | Description                                                      |
|---------------------------|-----------------|------------------------------------------------------------------|
| `create-checkpoint`       | Public          | Creates a new checkpoint. Returns the new checkpoint ID.         |
| `get-checkpoint`          | Read-only       | Retrieves checkpoint data by ID. Returns `some` or `none`.       |
| `get-checkpoint-count`    | Read-only       | Returns the total number of checkpoints recorded.                |
| `checkpoint-exists`       | Read-only       | Returns `true` if a checkpoint exists for the given ID.          |

## Example Usage

```clarity
;; Create a checkpoint with a message ID
(create-checkpoint (some u12345))

;; Create a checkpoint without a message ID
(create-checkpoint none)

;; Get checkpoint data
(get-checkpoint u0)

;; Get total number of checkpoints
(get-checkpoint-count)

;; Check if a checkpoint exists
(checkpoint-exists u0)
```

## Use Cases

- Protocol milestone tracking
- Audit trail logging
- Timestamp proof for data
- Governance event recording
- On-chain documentation history

## Design Principles

- **Immutable:** Once created, checkpoints cannot be changed or removed.
- **Open:** No special permissions required to interact with the contract.
- **Auditable:** All data is on-chain and queryable by anyone.

## File Structure

```
contracts/
  BLOCK-CHECKPOINT-log.clar   # Clarity contract source
settings/
  Devnet.toml, Mainnet.toml, Testnet.toml   # Network configs
tests/
  BLOCK-CHECKPOINT-log.test.ts # Contract tests
```
