# Architecture Document ? DeFi Super-App

## 1. System Context (C4 Level 1)

The DeFi Super-App is a decentralized protocol deployed on Arbitrum Sepolia L2.
External actors: Users, Liquidity Providers, Governance Token Holders.
External dependencies: Chainlink Price Feeds, The Graph, Arbitrum L2.

## 2. Container Diagram

### Smart Contracts
| Contract | Role |
|---|---|
| AMM.sol | Constant-product AMM (x*y=k), 0.3% fee, LP tokens |
| DeFiVault.sol | ERC-4626 tokenized yield vault |
| GovToken.sol | ERC20Votes + ERC20Permit governance token |
| ProtocolTimelock.sol | 2-day timelock for governance actions |
| ProtocolGovernor.sol | OpenZeppelin Governor, 4% quorum, 1 week voting |
| PriceOracle.sol | Chainlink feed wrapper with staleness check |
| ProtocolV1.sol | UUPS upgradeable proxy implementation |

### Access Control Roles
| Role | Holder | Powers |
|---|---|---|
| PROPOSER_ROLE | Governor | Can propose timelock transactions |
| EXECUTOR_ROLE | Governor | Can execute passed proposals |
| DEFAULT_ADMIN_ROLE | Renounced | No admin backdoor |

## 3. Proxy Layout (UUPS)

Storage layout V1:
| Slot | Variable | Type |
|---|---|---|
| 0 | value | uint256 |

Storage layout V2:
| Slot | Variable | Type |
|---|---|---|
| 0 | value | uint256 |
| 1 | version | uint256 |
| 2 | name | string |

No storage collisions - V2 only appends new slots.

## 4. Sequence Diagrams

### 4.1 AMM Swap
User calls swap(amountIn, minAmountOut)
AMM calculates amountOut using x*y=k formula
AMM checks slippage protection
AMM applies 0.3% fee and transfers tokens to user

### 4.2 Governance: Propose to Execute
1. TokenHolder calls propose() - needs 1% of supply
2. 1 day voting delay passes
3. TokenHolder calls castVote()
4. 1 week voting period passes
5. TokenHolder calls queue() - enters Timelock
6. 2 day Timelock delay passes
7. TokenHolder calls execute()

### 4.3 Vault Deposit
User approves ERC20 to vault
User calls deposit(amount, receiver)
Vault pulls tokens and mints shares to receiver

## 5. Data Model

### AMM Storage
| Variable | Type | Description |
|---|---|---|
| reserve0 | uint256 | Token0 reserve |
| reserve1 | uint256 | Token1 reserve |
| token0 | address | Token0 address |
| token1 | address | Token1 address |

### Governor Storage
| Variable | Type | Description |
|---|---|---|
| _proposals | mapping | proposalId to ProposalCore |
| _quorumNumerator | uint256 | 4 percent |

## 6. Trust Assumptions and Design Decisions

### Trust Assumptions
- Timelock controls treasury with 2 day delay
- Governor holds PROPOSER and EXECUTOR roles only
- DEFAULT_ADMIN_ROLE renounced after deployment
- Chainlink staleness check set to 1 hour
- If multisig compromised: Timelock delay gives community time to react

### ADR-01: UUPS over Transparent Proxy
Context: Need upgradeability
Decision: UUPS - cheaper calls, upgrade logic in implementation
Consequences: Must protect _authorizeUpgrade with onlyOwner

### ADR-02: Chainlink over custom oracle
Context: Need reliable price feed
Decision: Chainlink - battle-tested and decentralized
Consequences: Dependency on Chainlink node availability

### ADR-03: Arbitrum Sepolia for L2
Context: Need L2 deployment
Decision: Arbitrum Sepolia - good tooling, EVM compatible
Consequences: Need testnet ETH for deployment
