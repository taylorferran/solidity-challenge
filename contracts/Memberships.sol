// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Memberships {


    event CreateUser(uint _id, string _username);
    event UpdateUser(uint id, string _newUsername);

    // Create struct containing all necessary members details
    struct members 
    {
        uint creationDate;
        uint expirationDate;
        address addr;
        string username;
        bool isActive;
    }

    uint public memberCount = 1;
    mapping (uint => members) public memberByID;
    mapping (string => bool) public nameInUse;
    mapping (address => bool) public membershipActiveForThisAddress;

    modifier checkUsernameValidity(string memory _username) 
    {
        // Require username to not already be in use
        require(!nameInUse[_username], "Username taken.");
        // Require entered username to not be empty 
        bytes memory _usernameEmptyCheck = bytes(_username);
        require(_usernameEmptyCheck.length > 0, "Username empty.");
        _;
    }

    modifier checkAddressMatchesAccount(uint _id) 
    {
        // Require user only able to edit membership with their address 
        require(memberByID[_id].addr == msg.sender, "ID not accessible with this address.");
        _;
    }

    function createMembership(string memory _username) public checkUsernameValidity(_username)
    {
        // Only allow one membership per address 
        require(!membershipActiveForThisAddress[msg.sender], "Address already used to activate a memebership");
        //require(!nameInUse[_username], "Username taken.");

        // MemberID starts at 1 and increments for each member created
        memberByID[memberCount] = members (
            {
                 // Set creation to unix time now
                creationDate : block.timestamp,
                // Set expiration to unix time + 30 days
                expirationDate : block.timestamp + 5 minutes,
                // Set address to user creating the account
                addr : msg.sender,
                // Set username to desired username
                username : _username, 
                // Set active
                isActive : true
            }
        );
        // Increment member count to keep track of memberIDs
        memberCount++;
        // Set name in use so that another user cannot use the same one
        nameInUse[_username] = true;
        emit CreateUser(memberCount-1, _username);
    }


    function checkMembershipValidity(uint _id) public view returns (bool) 
    {
        // If the the expiration date minus the current timestamp is less than 0, we know that the expiry time has been passed
        // Therefore we can return false to use this in requires elsewhere, if it is valid we can return true.
        //bool validity = ((memberByID[_id].expirationDate - block.timestamp < 0) ? false : true);

        if((memberByID[_id].expirationDate - block.timestamp) < 0) {
            return false;
        } else {
        return true;
        } 
        //return validity;
    }

    function getMembership(uint _id) public view returns (members memory) 
    {
        require(memberByID[_id].isActive, "Membership inactive.");
        // Return membership struct with all details
        return memberByID[_id];
    }

    function deleteMembership(uint _id) public checkAddressMatchesAccount(_id)
    {
        memberByID[_id].isActive = false;
    }

    function updateMembership(uint _id, string memory _username) public checkUsernameValidity(_username) checkAddressMatchesAccount(_id)
    {
        require(checkMembershipValidity(_id), "Membership expired.");
        nameInUse[memberByID[_id].username] = false;
        memberByID[_id].username = _username;
        nameInUse[_username] = true;
        emit UpdateUser(_id, _username);
    }
}