import { BigInt } from '@graphprotocol/graph-ts'
import { ProposalCreated, VoteCast } from '../generated/Governor/Governor'
import { Proposal, Vote } from '../generated/schema'

export function handleProposalCreated(event: ProposalCreated): void {
  let proposal = new Proposal(event.params.proposalId.toString())
  proposal.proposalId = event.params.proposalId
  proposal.proposer = event.params.proposer
  proposal.description = event.params.description
  proposal.startBlock = event.params.startBlock
  proposal.endBlock = event.params.endBlock
  proposal.state = 'Pending'
  proposal.save()
}

export function handleVoteCast(event: VoteCast): void {
  let id = event.transaction.hash.toHex() + '-' + event.logIndex.toString()
  let vote = new Vote(id)
  vote.proposalId = event.params.proposalId
  vote.voter = event.params.voter
  vote.support = event.params.support
  vote.weight = event.params.weight
  vote.timestamp = event.block.timestamp
  vote.save()
}
