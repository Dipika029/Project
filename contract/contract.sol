// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IndustryCollaborationDAO {
    address public chairperson;
    mapping(address => bool) public members;
    mapping(address => uint256) public memberVotes;
    uint256 public totalVotes;
    uint256 public quorum;
    uint256 public proposalCount;

    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;

    event MemberAdded(address member);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Not chairperson");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    constructor(uint256 _quorum) {
        chairperson = msg.sender;
        quorum = _quorum;
    }

    function addMember(address _member) external onlyChairperson {
        members[_member] = true;
        emit MemberAdded(_member);
    }

    function createProposal(string calldata _description) external onlyMember {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.description = _description;
        p.voteCount = 0;
        p.executed = false;
        emit ProposalCreated(proposalCount, _description);
    }

    function vote(uint256 _proposalId) external onlyMember {
        Proposal storage p = proposals[_proposalId];
        require(!p.voted[msg.sender], "Already voted");
        require(!p.executed, "Proposal already executed");

        p.voted[msg.sender] = true;
        p.voteCount++;
        totalVotes++;
        emit Voted(_proposalId, msg.sender);

        if (p.voteCount >= quorum) {
            executeProposal(_proposalId);
        }
    }

    function executeProposal(uint256 _proposalId) internal {
        Proposal storage p = proposals[_proposalId];
        require(p.voteCount >= quorum, "Not enough votes");
        require(!p.executed, "Already executed");

        p.executed = true;
        emit ProposalExecuted(_proposalId);

        // Add logic here to handle what happens when a proposal passes
    }

    function getProposal(uint256 _proposalId) external view returns (string memory description, uint256 voteCount, bool executed) {
        Proposal storage p = proposals[_proposalId];
        return (p.description, p.voteCount, p.executed);
    }
}
