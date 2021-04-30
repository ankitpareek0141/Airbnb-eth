pragma solidity >=0.5.0 <0.9.0;

contract Airbnb{
    
    struct Property{
        string name;
        string description;
        bool isActive;
        uint price;
        address owner;
        bool[] isBooked;
    }
    uint public propertyId;
    mapping(uint => Property) public properties;
    
    
    struct Booking{
        uint propertyId;
        uint checkInDate;
        uint checkOutDate;
        address user;
    }
    uint public bookingId;
    mapping(uint => Booking) public bookings;
    
    
    event NewProperty(uint indexed propertyId);
    event NewBooking(uint indexed propertyId, uint indexed bookingId);
    
    
    // function rentOutProperty
    function rentOutProperty(string memory _name
    , string memory _description
    , uint _price)public {
        
        Property memory newProperty = Property(_name, _description, true, _price, msg.sender, new bool[](365));
        
        properties[propertyId] = newProperty;
        
        emit NewProperty(propertyId++);
    }
    
    
    // funtion rentProperty 
    function rentProperty(uint _propertyId
    , uint _checkInDate
    , uint _checkOutDate)public payable {
        
        Property memory property = properties[_propertyId];
        require(property.isActive == true, "Property is currently Inactive");
        
        for(uint i=_checkInDate; i<_checkOutDate;i++){
            if(property.isBooked[i] == true){
                revert("Already booked on this date!");
            }
        }
        uint totalAmt = property.price * (_checkOutDate-_checkInDate);
        require(msg.value == (totalAmt * 1 ether), "Insufficient fund for this property");
        
        payable(property.owner).transfer(msg.value);
        
        createBooking(_propertyId, _checkInDate, _checkOutDate);
    }
    
    
    
    function createBooking(uint _propertyId, uint _checkInDate, uint _checkOutDate)internal{
        bookings[bookingId] = Booking(_propertyId, _checkInDate, _checkOutDate, msg.sender);
        
        Property memory property = properties[_propertyId];
        
        for(uint i=_checkInDate; i<_checkOutDate; i++){
            property.isBooked[i] = true;
        }
        
        emit NewBooking(_propertyId, bookingId++);
    }
    
    /*
     * @dev Make a property inactive form the market means
     * no one can can take it on a rent for now
     */
    function markPropertyAsInActive(uint _propertyId)public{
        require(_propertyId >= propertyId, "Invalid propertyId");
        require(properties[_propertyId].owner == msg.sender, "You aren't the owner of this property");
        properties[_propertyId].isActive = false;
    }
}
