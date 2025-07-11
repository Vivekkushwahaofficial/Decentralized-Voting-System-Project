// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Decentralized Voting System
 * @dev A smart contract for conducting transparent and secure elections
 * @author Decentralized Voting Team
 */
contract Project {
    // Struct to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // Contract owner (election administrator)
    address public owner;
    
    // Election state variables
    string public electionName;
    bool public votingOpen;
    uint256 public totalVotes;
    uint256 public candidateCount;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 candidateId, string name);
    event VoterRegistered(address voter);
    event VoteCasted(address voter, uint256 candidateId);
    event VotingStatusChanged(bool isOpen);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier votingIsOpen() {
        require(votingOpen, "Voting is not currently open");
        _;
    }
    
    modifier votingIsClosed() {
        require(!votingOpen, "Voting is currently open");
        _;
    }
    
    /**
     * @dev Constructor to initialize the contract
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingOpen = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    /**
     * @dev Core Function 1: Add a candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner votingIsClosed {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Core Function 2: Register a voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyOwner {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 3: Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public votingIsOpen {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        
        // Update total votes
        totalVotes++;
        
        emit VoteCasted(msg.sender, _candidateId);
    }
    
    /**
     * @dev Start the voting process
     */
    function startVoting() public onlyOwner votingIsClosed {
        require(candidateCount > 0, "No candidates added yet");
        votingOpen = true;
        emit VotingStatusChanged(true);
    }
    
    /**
     * @dev End the voting process
     */
    function endVoting() public onlyOwner votingIsOpen {
        votingOpen = false;
        emit VotingStatusChanged(false);
    }
    
    /**
     * @dev Get candidate information
     * @param _candidateId ID of the candidate
     * @return id, name, voteCount
     */
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get voter information
     * @param _voter Address of the voter
     * @return isRegistered, hasVoted, votedCandidateId
     */
    function getVoter(address _voter) public view returns (bool, bool, uint256) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    /**
     * @dev Get election results (winner)
     * @return winnerId, winnerName, winnerVoteCount
     */
    function getWinner() public view votingIsClosed returns (uint256, string memory, uint256) {
        require(candidateCount > 0, "No candidates in the election");
        
        uint256 winnerId = 1;
        uint256 maxVotes = candidates[1].voteCount;
        
        for (uint256 i = 2; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }
        
        return (winnerId, candidates[winnerId].name, maxVotes);
    }
    
    /**
     * @dev Get total number of registered voters
     * @return count of registered voters
     */
    function getRegisteredVotersCount() public view returns (uint256) {
        // Note: This is a simplified implementation
        // In a real-world scenario, you'd maintain a separate counter
        return totalVotes; // This represents voters who have voted
    }
    
    /**
     * @dev Check if voting is currently open
     * @return current voting status
     */
    function isVotingOpen() public view returns (bool) {
        return votingOpen;
    }
}
