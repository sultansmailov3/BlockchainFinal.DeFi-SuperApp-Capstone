import { useAccount, useConnect, useDisconnect, useBalance, useReadContract, useWriteContract, useChainId, useSwitchChain } from 'wagmi'
import { arbitrumSepolia } from 'wagmi/chains'

const GOV_TOKEN_ADDRESS = '0x0000000000000000000000000000000000000000' as `0x${string}`
const GOVERNOR_ADDRESS = '0x0000000000000000000000000000000000000000' as `0x${string}`

const govTokenAbi = [
  { name: 'balanceOf', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { name: 'getVotes', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { name: 'delegates', type: 'function', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'address' }] },
  { name: 'delegate', type: 'function', stateMutability: 'nonpayable', inputs: [{ name: 'delegatee', type: 'address' }], outputs: [] },
] as const

const governorAbi = [
  { name: 'castVote', type: 'function', stateMutability: 'nonpayable', inputs: [{ name: 'proposalId', type: 'uint256' }, { name: 'support', type: 'uint8' }], outputs: [{ type: 'uint256' }] },
] as const

export default function App() {
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

  const { data: delegateAddr } = useReadContract({
    address: GOV_TOKEN_ADDRESS,
    abi: govTokenAbi,
    functionName: 'delegates',
    args: address ? [address] : undefined,
  })

  const isWrongNetwork = chainId !== arbitrumSepolia.id

  const shortAddr = (addr: string) => `${addr.slice(0, 6)}...${addr.slice(-4)}`

  if (!isConnected) return (
    <div style={{
      minHeight: '100vh', background: 'linear-gradient(135deg, #0f0c29, #302b63, #24243e)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: "'Inter', monospace"
    }}>
      <div style={{
        background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(20px)',
        border: '1px solid rgba(255,255,255,0.1)', borderRadius: '24px',
        padding: '3rem', textAlign: 'center', maxWidth: '420px', width: '90%'
      }}>
        <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>⚡</div>
        <h1 style={{ color: '#fff', fontSize: '1.8rem', fontWeight: 800, margin: '0 0 0.5rem' }}>DeFi Super-App</h1>
        <p style={{ color: 'rgba(255,255,255,0.5)', marginBottom: '2rem', fontSize: '0.9rem' }}>
          AMM · Vault · Governance · L2
        </p>
        {connectors.map(c => (
          <button key={c.uid} onClick={() => connect({ connector: c })} style={{
            display: 'block', width: '100%', marginBottom: '12px',
            background: 'linear-gradient(135deg, #667eea, #764ba2)',
            color: '#fff', border: 'none', borderRadius: '12px',
            padding: '14px', fontSize: '1rem', fontWeight: 600, cursor: 'pointer',
            transition: 'opacity 0.2s'
          }}>
            Connect {c.name}
          </button>
        ))}
        {connectError && <p style={{ color: '#ff6b6b', fontSize: '0.8rem', marginTop: '1rem' }}>{connectError.message}</p>}
        <p style={{ color: 'rgba(255,255,255,0.3)', fontSize: '0.75rem', marginTop: '1.5rem' }}>
          Arbitrum Sepolia Testnet
        </p>
      </div>
    </div>
  )

  if (isWrongNetwork) return (
    <div style={{
      minHeight: '100vh', background: 'linear-gradient(135deg, #0f0c29, #302b63, #24243e)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: "'Inter', monospace"
    }}>
      <div style={{
        background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(20px)',
        border: '1px solid rgba(255,165,0,0.3)', borderRadius: '24px',
        padding: '3rem', textAlign: 'center', maxWidth: '420px'
      }}>
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⚠️</div>
        <h2 style={{ color: '#ffa500', margin: '0 0 1rem' }}>Wrong Network</h2>
        <p style={{ color: 'rgba(255,255,255,0.6)', marginBottom: '2rem' }}>Please switch to Arbitrum Sepolia</p>
        <button onClick={() => switchChain({ chainId: arbitrumSepolia.id })} style={{
          background: 'linear-gradient(135deg, #f093fb, #f5576c)',
          color: '#fff', border: 'none', borderRadius: '12px',
          padding: '14px 28px', fontSize: '1rem', fontWeight: 600, cursor: 'pointer'
        }}>
          Switch Network
        </button>
      </div>
    </div>
  )

  return (
    <div style={{
      minHeight: '100vh', background: 'linear-gradient(135deg, #0f0c29, #302b63, #24243e)',
      fontFamily: "'Inter', monospace", color: '#fff', padding: '2rem'
    }}>
      {/* Header */}
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        marginBottom: '2rem', paddingBottom: '1rem',
        borderBottom: '1px solid rgba(255,255,255,0.1)'
      }}>
        <div>
          <h1 style={{ margin: 0, fontSize: '1.5rem', fontWeight: 800 }}>⚡ DeFi Super-App</h1>
          <p style={{ margin: 0, color: 'rgba(255,255,255,0.4)', fontSize: '0.8rem' }}>Arbitrum Sepolia</p>
        </div>
        <button onClick={() => disconnect()} style={{
          background: 'rgba(255,255,255,0.1)', color: '#fff',
          border: '1px solid rgba(255,255,255,0.2)', borderRadius: '10px',
          padding: '8px 16px', cursor: 'pointer', fontSize: '0.85rem'
        }}>
          {shortAddr(address!)} ✕
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem' }}>

        {/* Account Card */}
        <div style={{
          background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.1)', borderRadius: '20px', padding: '1.5rem'
        }}>
          <h3 style={{ margin: '0 0 1.2rem', color: '#a78bfa', fontSize: '0.85rem', textTransform: 'uppercase', letterSpacing: '0.1em' }}>
            👤 Account
          </h3>
          {[
            { label: 'Address', value: shortAddr(address!) },
            { label: 'ETH Balance', value: balance ? `${Number(balance.formatted).toFixed(4)} ETH` : '...' },
            { label: 'GOV Balance', value: govBalance !== undefined ? Number(govBalance).toLocaleString() : '...' },
            { label: 'Voting Power', value: votingPower !== undefined ? Number(votingPower).toLocaleString() : '...' },
            { label: 'Delegate', value: delegateAddr ? shortAddr(delegateAddr) : '...' },
          ].map(({ label, value }) => (
            <div key={label} style={{
              display: 'flex', justifyContent: 'space-between',
              padding: '10px 0', borderBottom: '1px solid rgba(255,255,255,0.06)'
            }}>
              <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: '0.85rem' }}>{label}</span>
              <span style={{ color: '#fff', fontSize: '0.85rem', fontWeight: 500 }}>{value}</span>
            </div>
          ))}
        </div>

        {/* Governance Card */}
        <div style={{
          background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.1)', borderRadius: '20px', padding: '1.5rem'
        }}>
          <h3 style={{ margin: '0 0 1.2rem', color: '#a78bfa', fontSize: '0.85rem', textTransform: 'uppercase', letterSpacing: '0.1em' }}>
            🗳️ Governance
          </h3>
          <p style={{ color: 'rgba(255,255,255,0.4)', fontSize: '0.8rem', marginBottom: '1rem' }}>
            Delegate your tokens to participate in voting
          </p>
          <button
            disabled={isPending}
            onClick={() => address && writeContract({ address: GOV_TOKEN_ADDRESS, abi: govTokenAbi, functionName: 'delegate', args: [address] })}
            style={{
              width: '100%', marginBottom: '10px',
              background: isPending ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #667eea, #764ba2)',
              color: '#fff', border: 'none', borderRadius: '12px',
              padding: '12px', fontSize: '0.9rem', fontWeight: 600, cursor: isPending ? 'not-allowed' : 'pointer'
            }}>
            {isPending ? '⏳ Pending...' : '🔗 Self Delegate'}
          </button>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
            <button
              disabled={isPending}
              onClick={() => writeContract({ address: GOVERNOR_ADDRESS, abi: governorAbi, functionName: 'castVote', args: [BigInt(1), 1] })}
              style={{
                background: isPending ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #11998e, #38ef7d)',
                color: '#fff', border: 'none', borderRadius: '12px',
                padding: '12px', fontSize: '0.85rem', fontWeight: 600, cursor: isPending ? 'not-allowed' : 'pointer'
              }}>
              ✅ Vote YES
            </button>
            <button
              disabled={isPending}
              onClick={() => writeContract({ address: GOVERNOR_ADDRESS, abi: governorAbi, functionName: 'castVote', args: [BigInt(1), 0] })}
              style={{
                background: isPending ? 'rgba(255,255,255,0.1)' : 'linear-gradient(135deg, #eb3349, #f45c43)',
                color: '#fff', border: 'none', borderRadius: '12px',
                padding: '12px', fontSize: '0.85rem', fontWeight: 600, cursor: isPending ? 'not-allowed' : 'pointer'
              }}>
              ❌ Vote NO
            </button>
          </div>
          {writeError && <p style={{ color: '#ff6b6b', fontSize: '0.75rem', marginTop: '10px' }}>{writeError.message}</p>}
        </div>

        {/* Protocol Stats */}
        <div style={{
          background: 'rgba(255,255,255,0.05)', backdropFilter: 'blur(20px)',
          border: '1px solid rgba(255,255,255,0.1)', borderRadius: '20px', padding: '1.5rem'
        }}>
          <h3 style={{ margin: '0 0 1.2rem', color: '#a78bfa', fontSize: '0.85rem', textTransform: 'uppercase', letterSpacing: '0.1em' }}>
            📊 Protocol
          </h3>
          {[
            { label: 'Network', value: 'Arbitrum Sepolia', color: '#38ef7d' },
            { label: 'Voting Delay', value: '1 day', color: '#fff' },
            { label: 'Voting Period', value: '1 week', color: '#fff' },
            { label: 'Quorum', value: '4%', color: '#fff' },
            { label: 'Timelock', value: '2 days', color: '#fff' },
          ].map(({ label, value, color }) => (
            <div key={label} style={{
              display: 'flex', justifyContent: 'space-between',
              padding: '10px 0', borderBottom: '1px solid rgba(255,255,255,0.06)'
            }}>
              <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: '0.85rem' }}>{label}</span>
              <span style={{ color, fontSize: '0.85rem', fontWeight: 500 }}>{value}</span>
            </div>
          ))}
        </div>

      </div>
    </div>
  )
}