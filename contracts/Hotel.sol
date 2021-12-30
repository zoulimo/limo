// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Hotel {
    event LogNewRoomRegistered(uint256 roomNumber);
    event LogRoomBooked(
        uint256 roomNumber,
        address guest,
        uint256 bookedUntil
    );
    event LogRoomDeregistered(uint256 roomNumber);
    event LogWithdrawn(uint256 amount);
     // create an Event-limo
    event Occupy(address _occupant, uint _value);

    address public owner;
    address public paymentToken;
    uint256 public paymentPerDay;
    
    
    // payment address-limo
    address payable public owner;
    // Hotel room status-limo
    enum Statuses { Vacant, Occupied } Statuses currentStatus;
    
   
    
    
    modifier onlyOwner() {
        require(msg.sender == owner, "ERROR::AUTH");
        currentStatus = Statuses.Vacant;
        _;
    }
    
    modifier onlyWhileVacant {
        // Check room status    
        require(currentStatus == Statuses.Vacant, "Currently occupied.");
        _; // execute the function button
    }
    
    // Price modifier
    modifier costs (uint _amount){
        // Check the price
        require(msg.value >= _amount, "Not enough Ether provided");
        _;
    }

    // book room by a payment, then this will be executed-limo
    receive() external payable onlyWhileVacant costs(2 ether) {
        currentStatus = Statuses.Occupied;
        owner.transfer(msg.value);
        
        // emit the event
        emit Occupy(msg.sender, msg.value);
    }
    
    
    
    
    
    struct Room {
        bool available;
        address guest;
        uint256 bookedUntil;
    }
    // RoomNumber => Room
    mapping(uint256 => Room) public rooms;

    constructor(
        address owner_,
        address paymentToken_,
        //
        address public owner;
        uint256 paymentPerDay_
        
        
    ) {
        owner = owner_;
        paymentToken = paymentToken_;
        paymentPerDay = paymentPerDay_;
    }

    function registerRoom(uint256 roomNumber_) external onlyOwner {
        require(roomNumber_ > 0 && rooms[roomNumber_].available == false, "ERROR::ALREADY_AVAILABLE");
        rooms[roomNumber_].available = true;
        emit LogNewRoomRegistered(roomNumber_);
    }

    function deregisterRoom(uint256 roomNumber_) external onlyOwner {
        require(
            rooms[roomNumber_].available == true &&
            rooms[roomNumber_].bookedUntil < block.timestamp,
            "ERROR::INVALID_ACTION"
        );

        delete rooms[roomNumber_];

        emit LogRoomDeregistered(roomNumber_);
    }

    function pay(uint256 roomNumber_, uint256 days_) external {
        require(
            days_ > 0 && days_ <= 365 &&
            rooms[roomNumber_].available == true &&
            rooms[roomNumber_].bookedUntil <= block.timestamp,
            "ERROR::NOT_AVAILABLE"
        );

        uint256 total = paymentPerDay * days_;

        rooms[roomNumber_].guest = msg.sender;
        rooms[roomNumber_].bookedUntil = block.timestamp + days_ * 1 days;

        IERC20(paymentToken).transferFrom(msg.sender, address(this), total);

        emit LogRoomBooked(roomNumber_, msg.sender, rooms[roomNumber_].bookedUntil);
    }

    function roomIsBooked(uint256 roomNumber_, address guest_) external view returns (bool) {
        return rooms[roomNumber_].guest == guest_ && block.timestamp < rooms[roomNumber_].bookedUntil;
    }

    function withdraw() external onlyOwner {
        uint256 balance = IERC20(paymentToken).balanceOf(address(this));
        IERC20(paymentToken).transferFrom(address(this), owner, balance);
        emit LogWithdrawn(balance);
    }
    
    /*
    
}
