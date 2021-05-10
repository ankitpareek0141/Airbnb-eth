// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Airbnb{
    
    // Property structure
    struct Property{
        uint id;
        string name;
        string description;
        bool isActive;
        address owner;
        uint price;
        bool[] isBooked;
    }
    uint public propertyId;
    mapping(uint => Property) public allProperties;
    
    // Property booking structure
    struct Booking{
        uint id;
        uint checkIn;
        uint checkOut;
        address user;
    }
    uint public bookingId;
    mapping(uint => Booking) public allBookings;
    
    // Events 
    event NewProperty(uint indexed propertyId);
    event NewBooking(uint indexed propertyId, uint indexed bookingId);
    
    // modifer to check weather the propertyId is valid or not
    modifier isValidId(uint _propertyId){
        require(_propertyId >=0 && _propertyId < propertyId, "Invalid property id...!");
        _;
    }
    
    // This will post the new Poperty on the app
    function rentOutProperty(string memory _name, string memory _description, uint _price)public {
        allProperties[propertyId] = Property(propertyId, _name, _description, true, msg.sender, _price, new bool[](365));
        emit NewProperty(propertyId++);
    }
    
    // This function will call by the person who wants to take property on rent
    function rentProperty(uint _propertyId, uint _checkInDate, uint _checkOutDate)public payable isValidId(_propertyId) {
        Property memory property = allProperties[_propertyId];
        for(uint i=_checkInDate; i<_checkOutDate; i++){
            require(property.isBooked[i] != true, "Property is not available between these dates!");
        }
        
        uint priceToBePaid = (property.price * 1 ether) * (_checkOutDate - _checkInDate);
        require(msg.value == priceToBePaid, "Insufficient amount for this property!");
        
        sendFund(property.owner, msg.value);
        createBooking(property, _propertyId, _checkInDate, _checkOutDate);
    }
    
    // This function transfer the funds to the property owner
    function sendFund(address _owner, uint amount)internal{
        address(uint160(_owner)).transfer(amount);
    }
    
    // This will createBooking with following parameters
    function createBooking(Property memory _property, uint _propertyId, uint _checkInDate, uint _checkOutDate)internal{
        
        for(uint i=_checkInDate; i<_checkOutDate ;i++){
            _property.isBooked[i] = true;            
        }
        allBookings[bookingId] = Booking(_propertyId, _checkInDate, _checkOutDate, msg.sender);
        emit NewBooking(propertyId, bookingId++);
    }
    
    // This will mark a Property active state to 'false'
    function markAsInactive(uint _propertyId)public isValidId(_propertyId){
        require(allProperties[_propertyId].owner == msg.sender,"THIS IS NOT YOUR PROPERTY");
        require(allProperties[_propertyId].isActive == true, "Already Inactive...!");
        allProperties[_propertyId].isActive == false;
    }
}