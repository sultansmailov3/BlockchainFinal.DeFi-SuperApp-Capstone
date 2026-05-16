import { useAccount, useConnect, useDisconnect, useBalance, useReadContract, useWriteContract, useChainId, useSwitchChain } from 'wagmi'
import { arbitrumSepolia } from 'wagmi/chains'

const GOV_TOKEN_ADDRESS = '0x0000000000000000000000000000000000000000'
const GOVERNOR_ADDRESS = '0x0000000000000000000000000000000000000000'

const govTokenAbi = [
  { name: 'balanceOf', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { name: 'getVotes', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { name: 'delegates', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'address' }] },
  { name: 'delegate', type: 'function', stateMutability: 'nonpayable', inputs: [{ name: 'delegatee', type: 'address' }], outputs: [] },
] as const

const governorAbi = [
  { name: 'castVote', type: 'function', stateMutability: 'nonpayable', inputs: [{ name: 'proposalId', type: 'uint256' }, { name: 'support', type: 'uint8' }], outputs: [{ type: 'uint256' }] },
] as const

const s = {
  app: { minHeight: '100vh', background: '#0f0f1a', color: '#e2e8f0', fontFamily: 'monospace', padding: '2rem' },
  header: { borderBottom: '1px solid #2d3748', paddingBottom: '1rem', marginBottom: '2rem' },
  title: { fontSize: '1.5rem', fontWeight: 'bold', color: '#7c3aed', margin: 0 },
  subtitle: { color: '#718096', fontSize: '0.85rem', margin: '4px 0 0 0' },
  card: { background: '#1a1a2e', border: '1px solid #2d3748', borderRadius: '12px', padding: '1.5rem', marginBottom: '1rem' },
  label: { color: '#718096', fontSize: '0.75rem', textTransform: 'uppercase' as const, letterSpacing: '0.05em' },
  value: { color: '#e2e8f0', fontSize: '0.9rem', marginTop: '4px', wordBreak: 'break-all' as const },
  btn: { background: '#7c3aed', color: 'white', border: 'none', borderRadius: '8px', padding: '10px 20px', cursor: 'pointer', marginRight: '8px', marginTop: '8px', fontSize: '0.85rem' },
  btnGreen: { background: '#059669', color: 'white', border: 'none', borderRadius: '8px', padding: '10px 20px', cursor: 'pointer', marginRight: '8px', marginTop: '8px', fontSize: '0.85rem' },
  btnRed: { background: '#dc2626', color: 'white', border: 'none', borderRadius: '8px', padding: '10px 20px', cursor: 'pointer', marginRight: '8px', marginTop: '8px', fontSize: '0.85rem' },
  btnOutline: { background: 'transparent', color: '#7c3aed', border: '1px solid #7c3aed', borderRadius: '8px', padding: '10px 20px', cursor: 'pointer', fontSize: '0.85rem' },
  error: { color: '#fc8181', fontSize: '0.8rem', marginTop: '8px' },
  connectPage: { display: 'flex', flexDirection: 'column' as const, alignItems: 'center', justifyContent: 'center', minHeight: '100vh', background: '#0f0f1a' },
  connectCard: { background: '#1a1a2e', border: '1px solid #2d3748', borderRadius: '16px', padding: '3rem', textAlign: 'center' as const, maxWidth: '400px', width: '100%' },
}

function App() {
  const { address, isConnected } = useAccount()
  const { connectors, connect, error: connectError } = useConnect()
  const { disconnect } = useDisconnect()
  const { data: balance } = useBalance({ address })
  const chainId = useChainId()
  const { switchChain } = useSwitchChain()
  const { writeContract, isPending, error: writeError } = useWriteContract()

  const { data: govBalance } = useReadContract({
    address: GOV_TOKEN_ADDRESS,
    abi: govTokenAbi,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
  })

  const { data: votingPower } = useReadContract({
    address: GOV_TOKEN_ADDRESS,
    abi: govTokenAbi,
    functionName: 'getVotes',
    args: address ? [address] : undefined,
  })

  const { data: delegateAddress } = useReadContract({
    address: GOV_TOKEN_ADDRESS,
    abi: govTokenAbi,
    functionName: 'delegates',
    args: address ? [address] : undefined,
  })

  const isWrongNetwork = chainId !== arbitrumSepolia.id

  if (!isConnected) {
    return (
      <div style={s.connectPage}>
        <div style={s.connectCard}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚡</div>
          <h2 style={{ color: '#7c3aed', margin: '0 0 0.5rem 0' }}>DeFi Super-App</h2>
          <p style={{ color: '#718096', marginBottom: '2rem' }}>Connect your wallet to continue</p>
          {connectors.map((connector) => (
            <button key={connector.uid} style={{ ...s.btn, display: 'block', width: '100%', marginBottom: '8px' }}
              onClick={() => connect({ connector })}>
              Connect {connector.name}
            </button>
          ))}
          {connectError && <p style={s.error}>{connectError.message}</p>}
        </div>
      </div>
    )
  }

  if (isWrongNetwork) {
    return (
      <div style={s.connectPage}>
        <div style={s.connectCard}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚠️</div>
          <h2 style={{ color: '#f59e0b', margin: '0 0 1rem 0' }}>Wrong Network</h2>
          <p style={{ color: '#718096', marginBottom: '2rem' }}>Please switch to Arbitrum Sepolia</p>
          <button style={s.btn} onClick={() => switchChain({ chainId: arbitrumSepolia.id })}>
            Switch Network
          </button>
        </div>
      </div>
    )
  }

  return (
    <div style={s.app}>
      <div style={s.header}>
        <h1 style={s.title}>⚡ DeFi Super-App</h1>
        <p style={s.subtitle}>Arbitrum Sepolia Testnet</p>
      </div>

      <div style={s.card}>
        <h3 style={{ margin: '0 0 1rem 0', color: '#a78bfa' }}>Account</h3>
        <div style={{ marginBottom: '0.75rem' }}>
          <div style={s.label}>Address</div>
          <div style={s.value}>{address}</div>
        </div>
        <div style={{ marginBottom: '0.75rem' }}>
          <div style={s.label}>ETH Balance</div>
          <div style={s.value}>{balance ? `${Number(balance.formatted).toFixed(4)} ETH` : '...'}</div>
        </div>
        <div style={{ marginBottom: '0.75rem' }}>
          <div style={s.label}>GOV Balance</div>
          <div style={s.value}>{govBalance !== undefined ? govBalance.toString() : '...'}</div>
        </div>
        <div style={{ marginBottom: '0.75rem' }}>
          <div style={s.label}>Voting Power</div>
          <div style={s.value}>{votingPower !== undefined ? votingPower.toString() : '...'}</div>
        </div>
        <div style={{ marginBottom: '0.75rem' }}>
          <div style={s.label}>Delegate</div>
          <div style={s.value}>{delegateAddress || '...'}</div>
        </div>
        <button style={s.btnOutline} onClick={() => disconnect()}>Disconnect</button>
      </div>

      <div style={s.card}>
        <h3 style={{ margin: '0 0 1rem 0', color: '#a78bfa' }}>Governance Actions</h3>
        <button style={s.btn} disabled={isPending}
          onClick={() => address && writeContract({ address: GOV_TOKEN_ADDRESS, abi: govTokenAbi, functionName: 'delegate', args: [address] })}>
          {isPending ? 'Pending...' : '🗳️ Self Delegate'}
        </button>
        <button style={s.btnGreen} disabled={isPending}
          onClick={() => writeContract({ address: GOVERNOR_ADDRESS, abi: governorAbi, functionName: 'castVote', args: [BigInt(1), 1] })}>
          ✅ Vote YES #1
        </button>
        <button style={s.btnRed} disabled={isPending}
          onClick={() => writeContract({ address: GOVERNOR_ADDRESS, abi: governorAbi, functionName: 'castVote', args: [BigInt(1), 0] })}>
          ❌ Vote NO #1
        </button>
        {writeError && <p style={s.error}>{writeError.message}</p>}
      </div>
    </div>
  )
}

export default App