// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owners {

    enum accountStatus { none, confirmed, owner }
    enum ballotKind { addOwner, changeOwner, excludeOwner, other }
    enum proposals { cons, pros }
    
    struct Ballot {
        uint id;
        address initiator; 
        uint pros;
        uint cons;
        uint votesToWin;
        uint startBlock;
        uint endBlock;
        ballotKind kind;
        bool accepted;
    }
    
    mapping(address => accountStatus) private accounts;
    uint private maxOwnersCount;
    uint private ownersCount;
    bool internal isActive;
    
    bool public activeBallot;
    uint private currentBallot;
    mapping(uint => Ballot) public ballots;
    mapping(uint => mapping(address => bool)) private votes;
    mapping(uint => address) private newOwners;
    mapping(uint => address) private excludedOwners;
    
    uint internal freeAmount;
    
    event OwnerSet(address indexed owner);
    event OwnerExcluded(address indexed owner);
    event newVote(uint indexed ballotId, address owner, proposals proposal);
    event newBallot(uint indexed ballotId, ballotKind kind);
    event closeBallot(uint indexed ballotId, ballotKind kind, bool accepted);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        require(accounts[msg.sender] == accountStatus.owner, "Caller is not owner");
        _;
    }
    
    modifier canStartBallot() {
        require(!activeBallot, "Ballots already underway");
        require(accounts[msg.sender] == accountStatus.owner, "Caller is not owner");
        _;
    }
    
    modifier isUnconfirmedOwner() {
        require(accounts[msg.sender] == accountStatus.none, "Caller is confirmed");
        _;
    }
    
    modifier canVote() {
        require(activeBallot, "Not active ballots");
        require(accounts[msg.sender] == accountStatus.owner, "Caller is not owner");
        require(votes[currentBallot][msg.sender], "Already voted");
        _;
    }
    
    modifier canCloseBallot(ballotKind kind) {
        require(activeBallot, "Not active ballots");
        require(ballots[currentBallot].pros >= ballots[currentBallot].votesToWin || ballots[currentBallot].cons > ballots[currentBallot].votesToWin, "not enough votes");
        require(ballots[currentBallot].kind == kind, "invalid ballot kind");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        accounts[msg.sender] = accountStatus.owner; 
        maxOwnersCount = 5;
        ownersCount = 1;
        isActive = true;
        emit OwnerSet(msg.sender);
    }

    /**
     * @dev Start add owner ballot
     * @param newOwner address of new owner
     */
    function startAddOwnerBallot(address newOwner) public canStartBallot {
        require(ownersCount < maxOwnersCount, "Maximum number of owners reached");
        require(accounts[newOwner] == accountStatus.confirmed, "New owner is unconfirmed");
        ballots[currentBallot] = Ballot({
            id: currentBallot,
            initiator: msg.sender, 
            pros: 1,
            cons: 0,
            votesToWin: ownersCount / 2 + 1,
            startBlock: block.number,
            endBlock: 0,
            kind: ballotKind.addOwner,
            accepted: false
        });
        
        votes[currentBallot][msg.sender] = true;
        newOwners[currentBallot] = newOwner;
        activeBallot = true;
        
        emit newBallot(currentBallot, ballotKind.addOwner);
        emit newVote(currentBallot, msg.sender, proposals.pros);
    }
    
    /**
     * @dev Start excluded owner ballot
     * @param excludeOwner address of new owner
     */
    function startExcludeOwnerBallot(address excludeOwner) public canStartBallot {
        require(accounts[excludeOwner] == accountStatus.owner, "Exclude account is not owner");
        require(excludeOwner != msg.sender, "You can't exclude yourself");
        ballots[currentBallot] = Ballot({
            id: currentBallot,
            initiator: msg.sender, 
            pros: 1,
            cons: 0,
            votesToWin: ownersCount / 2 + 1,
            startBlock: block.number,
            endBlock: 0,
            kind: ballotKind.excludeOwner,
            accepted: false
        });
        
        votes[currentBallot][msg.sender] = true;
        excludedOwners[currentBallot] = excludeOwner;
        activeBallot = true;
        
        emit newBallot(currentBallot, ballotKind.addOwner);
        emit newVote(currentBallot, msg.sender, proposals.pros);
    }
    
    /**
     * @dev Close add owner ballot
     */
    function closeAddOwnerBallot() public canCloseBallot(ballotKind.addOwner) {
        Ballot storage ballot = ballots[currentBallot];
        
        if (ballot.pros >= ballot.votesToWin)
        {
            accounts[newOwners[currentBallot]] = accountStatus.owner; 
            ownersCount++;
            emit OwnerSet(newOwners[currentBallot]);
        }
        
        currentBallot++;
        activeBallot = false;
        emit closeBallot(currentBallot, ballotKind.addOwner, ballot.accepted);
    }
    
    /**
     * @dev Close add owner ballot
     */
    function closeExcludeOwnerBallot() public canCloseBallot(ballotKind.excludeOwner) {
        Ballot storage ballot = ballots[currentBallot];
        if (ballot.pros >= ballot.votesToWin)
        {
            accounts[excludedOwners[currentBallot]] = accountStatus.owner; 
            ownersCount--;
            emit OwnerExcluded(excludedOwners[currentBallot]);
        }
        
        currentBallot++;
        activeBallot = false;
        emit closeBallot(currentBallot, ballotKind.addOwner, ballot.accepted);
    }
    
    function Vote(proposals proposal) public canVote
    {
        if (proposal == proposals.pros) {
            ballots[currentBallot].pros++;
        }
        if (proposal == proposals.cons) {
            ballots[currentBallot].cons++;
        }
        
        votes[currentBallot][msg.sender] = true;
        emit newVote(currentBallot, msg.sender, proposal);
    }
    
    /**
     * @dev Confirm owner
     */
    function confirm() public isUnconfirmedOwner {
        accounts[msg.sender] = accountStatus.confirmed;
    }
    
    // views functions

    /**
     * @dev Return owner status
     * @return owner status
     */
    function GetOwnersStatus(address owner) external view returns (accountStatus) {
        return accounts[owner];
    }
    
    /**
     * @dev Return max owners count 
     * @return max owners count
     */
    function GetMaxOwnersCount() external view returns (uint) {
        return maxOwnersCount;
    }
    
    /**
     * @dev Return owners count 
     * @return owners count 
     */
    function GetOwnersCount() external view returns (uint) {
        return ownersCount;
    }
}