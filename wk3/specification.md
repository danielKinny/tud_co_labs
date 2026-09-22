In pseudocode,

void decode(int address){

    int nextAddress = address + address[3:7]; #assume when slicing an integer [3:7] it means you're extracting bytes 3-6
    processor(address); #print the initial character once before looping

    while(nextAddress!=address){ #checks if next address leads back to initial parameter address
        processor(nextAddress);
        nextAddress = address + nextAddress[3:7] #next address is offset from the initial parameter
    }

}

void processor(int address){
   for(int i = 0; i < address[1]; i++){
        print(address[0]) #prints the character as many times as the 2nd byte says
    }
}
