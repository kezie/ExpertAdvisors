//+------------------------------------------------------------------+
//|                                               RSI_CossoverII.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"


#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"

#property script_show_inputs
#define EXPERT_MAGIC 1111424
#include <CustomIndicator01.mqh>;

   string mySymbol = Symbol();//Get current Symbol
   input int bbPeriod = 50; //Get time period or use default
   input int myShift = 0; //Get shift or use default
input int bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 4;
   input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE; //get the price to apply
   input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; //Get the period to use or use default
   input double risk = 0.02; //Get Maximum Account risk per trade
   
   double shortValue;
   double buyValue;
   double buyTPvalue;
   double shortTPvalue;
   double shortSLvalue;
   double buySLvalue;
   int openOrderID;
   int rsiPeriod = 14;
   input int rsiLowerLevel = 30;
   input int rsiUpperLevel = 70;
   
   

   // Price Entry Buffer  
   double bbupperEntryBuffer[]; 
   double bbMidBuffer[];
   double bblowerEntryBuffer[];
   
   //TP Buffer
   double bbupperProfitBuffer[]; 
   double bblowerProfitBuffer[];
   
   //SL Buffer
   double bbupperLossBuffer[]; 
   double bblowerLossBuffer[];
   

   
    // iRSI Buffer    
    double iRSIBuffer[]; 

    
   //Optimal Take Profit
   double optimalTakeProfit; 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    Alert("");
    Alert("Starting Strategy RSI Crossover Alert");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    
      // Bollinger Bands Indicator Handles   
   
   int Entryhandle= iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdEntry,appliedPrice);
   
   int SLhandle = iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdLossExit,appliedPrice);
   
   int TPhandle = iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdProfitExit,appliedPrice); 
   
   
   //sort the price array from the cuurent candle downwards
   ArraySetAsSeries(bbupperEntryBuffer,true);
   ArraySetAsSeries(bblowerEntryBuffer,true);
   ArraySetAsSeries(bbupperProfitBuffer,true);
   ArraySetAsSeries(bblowerProfitBuffer,true);
   ArraySetAsSeries(bbupperLossBuffer,true);
   ArraySetAsSeries(bblowerLossBuffer,true);
   

   


   //Copy Bollinger Band Buffers
  
   CopyBuffer(Entryhandle,1,0,3,bbupperEntryBuffer);
   CopyBuffer(Entryhandle,2,0,3,bblowerEntryBuffer);
   CopyBuffer(TPhandle,1,0,3,bbupperProfitBuffer);
   CopyBuffer(TPhandle,2,0,3,bblowerProfitBuffer);
   CopyBuffer(SLhandle,1,0,3,bbupperLossBuffer);
   CopyBuffer(SLhandle,2,0,3,bblowerLossBuffer);
   

   
 
   
   
  //calcualte EA for the cuurent candle
   shortValue= NormalizeDouble(bbupperEntryBuffer[0], _Digits);
   buyValue= NormalizeDouble(bblowerEntryBuffer[0], _Digits);
   buyTPvalue= NormalizeDouble(bbupperProfitBuffer[0], _Digits);
   shortTPvalue= NormalizeDouble(bblowerProfitBuffer[0], _Digits);
   shortSLvalue= NormalizeDouble(bbupperLossBuffer[0], _Digits);
   buySLvalue= NormalizeDouble(bblowerLossBuffer[0], _Digits);
   
   // For RSI
   int rsiValue = iRSI(mySymbol,timeFrame,rsiPeriod, PRICE_CLOSE);
   CopyBuffer(rsiValue,0,0,3,iRSIBuffer);
   ArraySetAsSeries(iRSIBuffer,true);
   double currentRSI = NormalizeDouble(iRSIBuffer[0],2);
   double previousRSI = NormalizeDouble(iRSIBuffer[1],2);
   
   
   
                      MqlTick latestPrice; //structure to get the latest prices
                      SymbolInfoTick(mySymbol, latestPrice); // Assign current prices to structure 
                    
                        if (currentRSI == rsiLowerLevel && previousRSI < rsiLowerLevel) {
                     
                                             if ( latestPrice.ask == buyValue) { //Buying
                                                
                                                
                                                Alert("Buy signal. Computing order");
                                                
                                                double optimalVolume = OptimalLotSize(risk,latestPrice.ask,buySLvalue);
                                             
                              
                                             
                                                Alert("Buy ", optimalVolume, " ", mySymbol, "at ", latestPrice.ask, "TP: ", buyTPvalue, "SL: ", buySLvalue);
                                                                                                                                                                                          
                                                }
                                                
                                         
                             }
                             
                             
                        if (currentRSI == rsiUpperLevel && previousRSI > rsiUpperLevel) {
                        
                                          if ( latestPrice.bid == shortValue) { //Shorting
                                 
                                          Alert("Short signal. Computing order");
                                       
                                       
                                          double optimalVolume = OptimalLotSize(risk,latestPrice.bid,shortSLvalue);
                                          
                                          Alert("Buy ", optimalVolume, " ", mySymbol, "at ", latestPrice.bid, "TP: ", shortTPvalue, "SL: ", shortSLvalue);
                                          }
                                                
                                                
                                               
                           }
                           
                           
                           
                           
                           
                     
   
  }
//+------------------------------------------------------------------+
