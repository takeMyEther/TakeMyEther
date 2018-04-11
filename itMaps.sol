pragma solidity ^0.4.18;

library itMaps {
    /* itMapAddressUint
         address =>  Uint
    */
    struct entryAddressUint {
    // Equal to the index of the key of this item in keys, plus 1.
    uint keyIndex;
    uint value;
    }

    struct itMapAddressUint {
    mapping(address => entryAddressUint) data;
    address[] keys;
    }

    function insert(itMapAddressUint storage self, address key, uint value) internal returns (bool replaced) {
        entryAddressUint storage e = self.data[key];
        e.value = value;
        if (e.keyIndex > 0) {
            return true;
        } else {
            e.keyIndex = ++self.keys.length;
            self.keys[e.keyIndex - 1] = key;
            return false;
        }
    }

    function remove(itMapAddressUint storage self, address key) internal returns (bool success) {
        entryAddressUint storage e = self.data[key];
        if (e.keyIndex == 0)
        return false;

        if (e.keyIndex <= self.keys.length) {
            // Move an existing element into the vacated key slot.
            self.data[self.keys[self.keys.length - 1]].keyIndex = e.keyIndex;
            self.keys[e.keyIndex - 1] = self.keys[self.keys.length - 1];
            self.keys.length -= 1;
            delete self.data[key];
            return true;
        }
    }

    function destroy(itMapAddressUint storage self) internal  {
        for (uint i; i<self.keys.length; i++) {
            delete self.data[ self.keys[i]];
        }
        delete self.keys;
        return ;
    }

    function contains(itMapAddressUint storage self, address key) internal constant returns (bool exists) {
        return self.data[key].keyIndex > 0;
    }

    function size(itMapAddressUint storage self) internal constant returns (uint) {
        return self.keys.length;
    }

    function get(itMapAddressUint storage self, address key) internal constant returns (uint) {
        return self.data[key].value;
    }

    function getKeyByIndex(itMapAddressUint storage self, uint idx) internal constant returns (address) {
        return self.keys[idx];
    }

    function getValueByIndex(itMapAddressUint storage self, uint idx) internal constant returns (uint) {
        return self.data[self.keys[idx]].value;
    }
}
