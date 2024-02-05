// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract ProposalContract {
    // ****************** Data ***********************

    //Owner
    address owner;

    uint256 private counter;

    struct Proposal {
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

    address[] private voted_addresses; 

    //constructor
    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }


//     // ****************** Execute Functions ***********************
    function isVoted(address _address) internal view returns (bool) {
    for (uint256 i = 0; i < voted_addresses.length; i++) {
        if (voted_addresses[i] == _address) {
            return true;
        }
    }
    return false;
}
    function getProposalStatus(uint256 proposalId) external view returns (bool) {               //My code
    Proposal storage proposal = proposal_history[proposalId];
    return proposal.current_state;

    }
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function create(string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_description, 0, 0, 0, _total_vote_to_end, false, true);
    }

// ****************** Query Functions ***********************

    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }
}
