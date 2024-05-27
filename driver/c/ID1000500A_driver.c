#include "caip.h"

#include <stdint.h>
#include <stdio.h>

#include <conio.h>

int main(){
    const char *connector = "/dev/ttyACM0";
    uint8_t nic_addr = 1;
    uint8_t port = 0;
    const char *csv_file = "/home/a/Documents/HDL/ID1000500A_LuisLuna_MarthaOrozco/config/ID1000500A_config.csv";

    caip_t *aip = caip_init(connector, nic_addr, port, csv_file);

    aip->reset();

    /*========================================*/
    /* Code generated with IPAccelerator */

    uint32_t ID[1];


    aip->getID(ID);
    printf("Read ID: %08X\n\n", ID[0]);


    uint32_t STATUS[1];


    aip->getStatus(STATUS);
    printf("Read STATUS: %08X\n\n", STATUS[0]);


    uint32_t MemX[10] = {0x0000000A, 0x00000005, 0x00000001, 0x00000006, 0x00000008, 0x0000000B, 0x0000000C};
    uint32_t MemX_size = sizeof(MemX) / sizeof(uint32_t);


    printf("Write memory: MdataX\n");
    aip->writeMem("MdataX", MemX, 10, 0);
    printf("MemX Data: [");
    for(int i=0; i<MemX_size; i++){
        printf("0x%08X", MemX[i]);
        if(i != MemX_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");


    uint32_t MemY[5] = {0x00000002, 0x00000007, 0x00000001, 0x0000000A, 0x00000002};
    uint32_t MemY_size = sizeof(MemY) / sizeof(uint32_t);


    printf("Write memory: MdataY\n");
    aip->writeMem("MdataY", MemY, 5, 0);
    printf("MemY Data: [");
    for(int i=0; i<MemY_size; i++){
        printf("0x%08X", MemY[i]);
        if(i != MemY_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");


    uint32_t Size[1] = {0x000000AA};
    uint32_t Size_size = sizeof(Size) / sizeof(uint32_t);


    printf("Write configuration register: Csize\n");
    aip->writeConfReg("Csize", Size, 1, 0);
    printf("Size Data: [");
    for(int i=0; i<Size_size; i++){
        printf("0x%08X", Size[i]);
        if(i != Size_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");


    printf("Start IP\n\n");
    aip->start();


    aip->getStatus(STATUS);
    printf("Read STATUS: %08X\n\n", STATUS[0]);


    uint32_t MemZ[14];
    uint32_t MemZ_size = sizeof(MemZ) / sizeof(uint32_t);


    printf("Read memory: MdataZ\n");
    aip->readMem("MdataZ", MemZ, 14, 0);
    printf("MemZ Data: [");
    for(int i=0; i<MemZ_size; i++){
        printf("0x%08X", MemZ[i]);
        if(i != MemZ_size-1){
            printf(", ");
        }
    }
    printf("]\n\n");


    printf("Clear INT: 0\n");
    aip->clearINT(0);


    aip->getStatus(STATUS);
    printf("Read STATUS: %08X\n\n", STATUS[0]);



    /*========================================*/

    aip->finish();

    printf("\n\nPress key to close ... ");
    getch();

    return 0;

}
