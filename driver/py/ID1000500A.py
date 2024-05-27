import logging, time
from ipdi.ip.pyaip import pyaip, pyaip_init

class convolution:
    ## Class constructor of IP Convolution driver
    #
    # @param self Object pointer
    # @param connector Middleware object
    # @param nic_addr Network address IP
    # @param port Port number
    # @param csv_file Path to CSV configuration file
    def __init__(self, conector, nic_addr, port, csv_file):
        ## Pyaip object
        self.__pyaip = pyaip_init(connector, nic_addr, port, csv_file)
        
        if self.__pyaip is None:
            logging.debug(error)
           
        ## IP Convolution IP-ID
        self.IPID = 0
        
        self.__getID()
        
        self.__clearStatus()
        
        logging.debug(f"IP Driver created with IP ID {self.IPID:08x}")
        
    ## Write data in the IP Convolution input memory
    #
    # @param self Object pointer
    # @param data List with the data to write
    def writeData(self, mem_name, data):
        self.__pyaip.writeMem(mem_name, data, len(data), 0)
        
        logging.debug(f"Data written to {mem_name}")
        
    ## Read data from the IP output memory
    #
    # @param self Object pointer
    # @param size Amount of data to read
    def readData(self, mem_name, size):
        data = self.__pyaip.readMem(mem_name, size, 0)
        logging.debug(f"Data read from {mem_name}")
        return data
    
    ## Start processing in IP
    #
    # @param self Object pointer
    def startIP(self):
        self.__pyaip.start()

        logging.debug("Start sent")
        
    ## Write configuration register
    #
    # @param self Object pointer
    # @param reg_name Configuration register name
    # @param data Data to write
    def writeConfReg(self, reg_name, data):
        self.__pyaip.writeConfReg(reg_name, data, len(data), 0)
        
        logging.debug(f"Configuration register {reg_name} written with data {data}")
        
    ## Enable IP interruptions
    #
    # @param self Object pointer
    def enableINT(self):
        self.__pyaip.enableINT(0,None)

        logging.debug("Int enabled")
        
    ## Disable IP interruptions
    #
    # @param self Object pointer
    def disableINT(self):
        self.__pyaip.disableINT(0)

        logging.debug("Int disabled")
        
    ## Show IP status
    #
    # @param self Object pointer
    def status(self):
        status = self.__pyaip.getStatus()
        logging.info(f"Status: {status:08x}")

            
    ## Finish connection
    #
    # @param self Object pointer
    def finish(self):
        self.__pyaip.finish()
        logging.debug("Connection finished")
        
    ## Wait for the completion of the process
    #
    # @param self Object pointer
    def waitInt(self):
        waiting = True
        
        while waiting:

            status = self.__pyaip.getStatus()

            logging.debug(f"Status: {status:08x}")
            
            if status & 0x1:
                waiting = False
            
            time.sleep(0.1)
            
    ## Get IP ID
    #
    # @param self Object pointer
    def __getID(self):
        self.IPID = self.__pyaip.getID()
        logging.info(f"IP ID: {self.IPID:08X}")
        
    ## Clear status register of IP
    #
    # @param self Object pointer
    def __clearStatus(self):
        for i in range(8):
            self.__pyaip.clearINT(i)
            
    ## Convolve two signals
    #
    # @param self Object pointer
    # @param X First signal
    # @param Y Second signal
    # @return Convolution result
    def conv(self, X, Y):
        sizeX = len(X)
        sizeY = len(Y)
        size_aux = sizeX + sizeY - 1
        result = [0] * size_aux
        
        for i in range(sizeX):
            for j in range(sizeY):
                result[i + j] += X[i] * Y[j]
        
        logging.debug(f"Convolution result: {result}")
        return result
    
    
if __name__=="__main__":
    import sys
    
    logging.basicConfig(level=logging.INFO)
    connector = '/dev/ttyACM0'
    csv_file = '/home/a/Documents/HDL/ID1000500A_LuisLuna_MarthaOrozco/config/ID1000500A_config.csv'
    addr = 1
    port = 0
    
    X = [0x0000000A, 0x00000005, 0x00000001, 0x00000006, 0x00000008, 0x0000000B, 0x0000000C]
    
    Y = [0x00000002, 0x00000007, 0x00000001, 0x0000000A, 0x00000002]
    
    try:
        driver = convolution(connector, addr, port, csv_file)
        logging.info("Test Convolution: Driver created")
        
        driver.status()
    except:
        logging.error("Test Convolution: Driver not created")
        sys.exit()

        
    driver.disableINT()
    
    driver.writeData('MemX', X)
    logging.info(f'TX MemX Data: {[f"{x:08X}" for x in X]}')
    
    driver.writeData('MemY', Y)
    logging.info(f'TX MemY Data: {[f"{x:08X}" for x in Y]}')
    
    driver.startIP()
    driver.waitInt()
    
    conv_result = driver.conv(X,Y)
    logging.info(f'Convolution result: {[f"{x:08X}" for x in conv_result]}')
    
    driver.status()
    driver.finish()
    
    logging.info("The End")
    
