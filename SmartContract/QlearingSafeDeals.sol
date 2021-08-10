// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Owners.sol";

/**
 * @title Qlearing
 * @dev Safe Deals
 */
contract QlearingSafeDeals is Owners {
    enum dealState { create, execution, confirmation, dispute, cancel, close  }
    enum dealResult { none, complete, notComplete, completeByArbitre, notCompleteByArbitre, cancel }
    enum disputeResult { fromRight, toRight }
    
    struct Deal {
        uint id;
        address payable personFrom; 
        address payable personTo;
        address payable arbitrator;
        uint amount;
        bool obligationsFulfilled;
        dealState state;
        uint stateBlock;
        uint executionBlocks;
        dealResult result;
        bool isActive;
        bytes32 conditionHash;
    }
    
    uint amount;
    uint blockWaiting;
    
    uint private lastDeal;
    uint private activeDeals;
    uint private commissionFrom;
    uint private commissionTo;
    uint private commissionArbitrator;
    uint private commissionArbitratorAdditional;
    uint private minAmount;
    mapping(uint => Deal) private deals;
    mapping(uint => mapping(address => bool)) private confirmedAccount;
    
    event newDeal(uint indexed dealId, address personTo, address personFrom, address arbitrator, uint amount);
    event closeDeal(uint indexed dealId, dealResult result);
    
    modifier contractIsActive() {
        require(isActive, "contract is no active");
        _;
    }
    
    modifier onState(uint id, dealState state) {
        require(deals[id].state == state, "contract started");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() Owners() {
        amount = 0;
        blockWaiting = 10000;
        lastDeal = 0;
        activeDeals = 0;
        commissionFrom = 2;
        commissionTo = 2;
        commissionArbitrator = 2;
        commissionArbitratorAdditional = 3;
        minAmount = 1000000000;
    }
    
    function createDeal(address payable personTo, address payable arbitrator, bytes32 conditionHash, uint executionBlocks) public payable contractIsActive returns (uint)
    {
        require(msg.value > minAmount, "Low amount");
        uint id = ++lastDeal;
        deals[lastDeal] = Deal({
            id: lastDeal,
            personFrom: payable(msg.sender), 
            personTo: personTo,
            arbitrator: arbitrator,
            amount: msg.value,
            obligationsFulfilled: false,
            state: dealState.create,
            stateBlock: block.number,
            executionBlocks: executionBlocks,
            result: dealResult.none,
            isActive: true,
            conditionHash: conditionHash
        });
        
        confirmedAccount[id][msg.sender] = true;
        amount += msg.value;
        activeDeals++;
        emit newDeal(id, msg.sender, personTo, arbitrator, msg.value);
        return id;
    }
    
    function confirmAccountDeal(uint id) public onState(id, dealState.create)
    {
        confirmedAccount[id][msg.sender] = true;
    }
    
    function confirmDeal(uint id) public onState(id, dealState.create)
    {
        Deal storage deal = deals[id];
        require(confirmedAccount[id][deal.personFrom]
            && confirmedAccount[id][deal.personTo]
            && confirmedAccount[id][deal.arbitrator],
            "not all members is confimed");
        deal.state = dealState.execution;
        deal.stateBlock = block.number;
    }
    
    function cancelDeal(uint id) public onState(id, dealState.create)
    {
        Deal storage deal = deals[id];
        require(deal.personFrom == msg.sender, "you are not initiator");
        require(deal.stateBlock + blockWaiting > block.number, "you need wait");
        
        uint totalCommisions = deal.amount / 1000 * commissionFrom;
        
        uint refund = deal.amount - totalCommisions;
        deal.personFrom.transfer(refund);
        amount -= refund;
        freeAmount += totalCommisions;
        
        activeDeals--;
        deal.state = dealState.cancel;
        deal.result = dealResult.cancel;
        deal.stateBlock = block.number;
        
        emit closeDeal(id, dealResult.cancel);
    }
    
    function renounceObligations(uint id) public onState(id, dealState.execution)
    {
        Deal storage deal = deals[id];
        require(deal.personTo == msg.sender, "you are not exectutor");
        
        uint totalCommisions = deal.amount / 1000 * (commissionFrom + commissionTo);
        uint totalCommisionsArbitrator = deal.amount / 1000 * commissionArbitrator;

        deal.personFrom.transfer(deal.amount - totalCommisions - totalCommisionsArbitrator);
        deal.arbitrator.transfer(totalCommisionsArbitrator);
        amount -= deal.amount - totalCommisions;
        freeAmount += totalCommisions;
        
        activeDeals--;
        deal.state = dealState.close;
        deal.result = dealResult.notComplete;
        deal.stateBlock = block.number;
        
        emit closeDeal(id, dealResult.notComplete);
    }
    
    function declareExecution(uint id) public onState(id, dealState.execution)
    {
        Deal storage deal = deals[id];
        require(deal.personTo == msg.sender, "you are not exectutor");
        deal.state = dealState.confirmation;
        deal.stateBlock = block.number;
    }
    
    function confirmExecution(uint id) public onState(id, dealState.confirmation)
    {
        Deal storage deal = deals[id];
        require(deal.personFrom == msg.sender, "you are not initiator");
        
        uint totalCommisions = deal.amount / 1000 * (commissionFrom + commissionTo);
        uint totalCommisionsArbitrator = deal.amount / 1000 * commissionArbitrator;

        deal.personTo.transfer(deal.amount - totalCommisions - totalCommisionsArbitrator);
        deal.arbitrator.transfer(totalCommisionsArbitrator);
        amount -= deal.amount - totalCommisions;
        freeAmount += totalCommisions;
        
        activeDeals--;
        deal.state = dealState.close;
        deal.result = dealResult.complete;
        deal.stateBlock = block.number;
        
        emit closeDeal(id, dealResult.complete);
    }
    
    function openDispute(uint id) public
    {
        Deal storage deal = deals[id];
        require(deal.personFrom == msg.sender, "you are not initiator");
        require(deal.state == dealState.confirmation || (deal.state == dealState.execution && deal.stateBlock + deal.executionBlocks < block.number), "can not open dispute");
        deal.stateBlock = block.number;
        deal.state = dealState.dispute;
    }
    
    
    
    function closeDispute(uint id, disputeResult result) public onState(id, dealState.dispute)
    {
        Deal storage deal = deals[id];
        require(deal.arbitrator == msg.sender, "you are not arbitrator");
        deal.stateBlock = block.number;
        deal.state = dealState.dispute;
        
        uint totalCommisions = deal.amount / 1000 * (commissionFrom + commissionTo);
        uint totalCommisionsArbitrator = deal.amount / 1000 * (commissionArbitrator + commissionArbitratorAdditional);

        if (result == disputeResult.fromRight)
        {
            deal.personFrom.transfer(deal.amount - totalCommisions - totalCommisionsArbitrator);
            deal.result = dealResult.notCompleteByArbitre;
        }
        else
        {
            deal.personTo.transfer(deal.amount - totalCommisions - totalCommisionsArbitrator);
            deal.result = dealResult.completeByArbitre;
        }
        
        deal.arbitrator.transfer(totalCommisionsArbitrator);
        amount -= deal.amount - totalCommisions;
        freeAmount += totalCommisions;
        
        activeDeals--;
        deal.state = dealState.close;
        deal.stateBlock = block.number;
        
        emit closeDeal(id, deal.result);
    }
}