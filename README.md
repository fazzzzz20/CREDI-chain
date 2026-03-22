# CREDI-Chain Smart Contract

A comprehensive digital badge registry smart contract built on the Stacks blockchain using Clarity. Enable secure badge creation, distribution, and management with role-based access controls.

## Overview

CREDI-Chain is a smart contract system for managing digital badges on the Stacks blockchain. It provides functionality for:
- Creating and managing verifiable digital badges
- Awarding badges to users
- Role-based access control with owner and admin tiers
- Emergency pause/unpause functionality
- Comprehensive badge lifecycle management

## Features

✅ **Badge Management**
- Create custom badges with name and description
- Disable badges without affecting existing awards
- Track badge creation and ownership

✅ **User Badge Tracking**
- Award badges to users
- Revoke badges when necessary
- Query user badge ownership

✅ **Role-Based Access Control**
- Contract owner with full permissions
- Admin role management
- Hierarchical authorization system

✅ **Emergency Controls**
- Pause contract to halt badge operations
- Unpause to resume normal operations

## Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks blockchain knowledge

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd CREDI-chain

# Install dependencies
npm install

# Verify contract syntax
clarinet check
```

### Running Tests

```bash
npm test
# or
clarinet test
```

## Contract Functions

### Public Functions

#### Badge Creation
```clarity
(create-badge (name (string-ascii 50)) (description (string-ascii 200)))
```
Creates a new badge. Requires admin privileges and contract must not be paused.

#### Award Badge
```clarity
(award-badge (user principal) (id uint))
```
Awards a badge to a user. Requires admin privileges and contract must not be paused.

#### Revoke Badge
```clarity
(revoke-badge (user principal) (id uint))
```
Removes a badge from a user. Requires admin privileges.

#### Disable Badge
```clarity
(disable-badge (id uint))
```
Deactivates a badge globally. Requires admin privileges.

#### Admin Management
```clarity
(add-admin (admin principal))
(remove-admin (admin principal))
```
Manage admin access. Requires contract owner privileges.

#### Emergency Controls
```clarity
(pause)
(unpause)
```
Pause or unpause badge operations. Requires contract owner privileges.

### Read-Only Functions

```clarity
(get-badge-info (id uint))                    ;; Get badge details
(has-badge (user principal) (id uint))        ;; Check if user has badge
(get-total-badges)                            ;; Get total badge count
(is-paused)                                   ;; Check contract pause status
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | ERR-UNAUTHORIZED | Caller lacks required permissions |
| u101 | ERR-PAUSED | Contract is paused |
| u102 | ERR-BADGE-NOT-FOUND | Badge does not exist or is inactive |
| u103 | ERR-BADGE-EXISTS | Badge already exists |
| u104 | ERR-ALREADY-AWARDED | User already has this badge |
| u105 | ERR-NOT-AWARDED | Badge not awarded to user |

## Usage Example

```clarity
;; Create a badge (as admin)
(contract-call? .CREDI-chain create-badge 
  "Verified Developer" 
  "Awarded to developers who pass verification"
)

;; Award badge to a user (as admin)
(contract-call? .CREDI-chain award-badge 
  'ST1234567890ABCDEF 
  u1
)

;; Check if user has badge
(contract-call? .CREDI-chain has-badge 
  'ST1234567890ABCDEF 
  u1
)
```

## Project Structure

```
CREDI-chain/
├── contracts/
│   └── CREDI-chain.clar        # Main smart contract
├── tests/
│   └── CREDI-chain.test.ts     # Contract tests
├── settings/
│   ├── Devnet.toml
│   ├── Testnet.toml
│   └── Mainnet.toml
├── Clarinet.toml               # Clarinet configuration
├── package.json
└── tsconfig.json
```

## Development

### Testing
Run the test suite to validate contract functionality:

```bash
npm test
```

### Checking Contract
Verify contract syntax and types:

```bash
clarinet check
```

## Deployment

1. Configure your network settings in settings
2. Deploy to Testnet:
   ```bash
   clarinet deployment apply --network testnet
   ```
3. Deploy to Mainnet:
   ```bash
   clarinet deployment apply --network mainnet
   ```

## Security Considerations

- Only owner can manage admins and emergency controls
- Only admins can create badges and award access
- Pause functionality provides emergency control mechanism
- All state changes require proper authorization checks


