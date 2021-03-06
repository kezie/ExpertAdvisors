//+------------------------------------------------------------------+
//|                                                BB 2 BANDS MR.mq5 |
//|                                                         Chikezie |
//|                                              www.chikezie.com.ng |
//+------------------------------------------------------------------+
#property copyright "Chikezie"
#property link      "www.chikezie.com.ng"
#property version   "1.00"

#property script_show_inputs
#define EXPERT_MAGIC 123456
#include <CustomIndicator01.mqh>;
#include <Trade/Trade.mqh>;

   string mySymbol = Symbol();//Get current Symbol
   input int bbPeriod = 50; //Get time period or use default
   input int myShift = 0; //Get shift or use default
input int bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 6;
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
   input int rsiLowerLevel = 40;
input int rsiUpperLevel = 60;
ulong orderTicket;


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
   
   // Open Buffer
   double OpenBuffer[];
   
    // iRSI Buffer    
    double iRSIBuffer[]; 
    
    // CTrade Public Object
    CTrade trade;
    
   //Optimal Take Profit
   double optimalTakeProfit; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   Alert("");
   Alert("Starting Strategy BB 2Bans MR");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert("Stopping Strategy BB 2Bans MR");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   
   
   

   
      // Indicator Handles   
   
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
   
   // Arrange Open Buffer
   ArraySetAsSeries(OpenBuffer,true);
   


   //Copy Buffers
   
   CopyBuffer(Entryhandle,1,0,3,bbupperEntryBuffer);
   CopyBuffer(Entryhandle,2,0,3,bblowerEntryBuffer);
   CopyBuffer(TPhandle,1,0,3,bbupperProfitBuffer);
   CopyBuffer(TPhandle,2,0,3,bblowerProfitBuffer);
   CopyBuffer(SLhandle,1,0,3,bbupperLossBuffer);
   CopyBuffer(SLhandle,2,0,3,bblowerLossBuffer);
   
   //Copy Open
   
   CopyOpen(mySymbol,timeFrame,0,3,OpenBuffer);
   
   
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
   double RSI = NormalizeDouble(iRSIBuffer[0],2);



   
   
   
   
   
  if (isTradingAllowed()) {
  


            if(!CheckIfOpenOrdersByMagicNB(EXPERT_MAGIC))//if no open orders try to enter new position
         {
  
                    MqlTick latestPrice; //structure to get the latest prices
                    SymbolInfoTick(mySymbol, latestPrice); // Assign current prices to structure 
                    
                    MqlTradeRequest request = {};
                     MqlTradeResult result = {};  
                     
                     if ( latestPrice.ask <buyValue && OpenBuffer[0] > buyValue && RSI < rsiLowerLevel) { //Buying
                           
                           
                           Alert("Price is below signalPrice. Sending buy order");
                           
                           double optimalVolume = OptimalLotSize(risk,latestPrice.ask,buySLvalue);
                        
                          
                           //--- prepare a request style taken from internet
                           
                           request.action=TRADE_ACTION_PENDING;         // setting a pending order
                           request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
                           request.symbol= mySymbol;                      // symbol
                           request.volume= optimalVolume;                          // Calculated using custom function
                           request.sl=buySLvalue;                                // Stop Loss is not specified
                           request.tp= buyTPvalue;                                // Take Profit is not specified     
                           request.deviation = 10;                         //set slippage
                           request.comment = "bought using BB trader";
                           //--- form the order type
                           request.type= ORDER_TYPE_BUY_LIMIT;                // order type
                           //--- form the price for the pending order
                           request.price= latestPrice.ask;  // open price
                           //--- send a trade request
                           openOrderID  = OrderSend(request,result);
                           
                           orderTicket = trade.RequestPosition();
                           
                           if (openOrderID <0) Alert("order rejected. Order error: " + string(GetLastError()));
                        
                           
                            
                           
                           //--- write the server reply to log  
                           Print(__FUNCTION__,":",result.comment);
                           if(result.retcode==10016) Print(result.bid,result.ask,result.price);
                           //--- return code of the trade server reply
                           Alert( result.retcode);
                          
                              
                           
                           
                           
                    
                    }else if (latestPrice.bid <shortValue && OpenBuffer[0] > shortValue && RSI < rsiUpperLevel) //shorting
                    {
                           Alert("Price is above signalPrice. Sending Short order");
                        
                        
                           double optimalVolume = OptimalLotSize(risk,latestPrice.bid,shortSLvalue);
                           
                           
                           //--- prepare a request style taken from internet
                           
                           request.action=TRADE_ACTION_PENDING;         // setting a pending order
                           request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
                           request.symbol= mySymbol;                      // symbol
                           request.volume= optimalVolume;                          // calculated using custom lot size function
                           request.sl=shortSLvalue;                                // Stop Loss is not specified
                           request.tp= shortTPvalue;                                // Take Profit is not specified     
                           request.deviation = 10;                         //set slippage
                           request.comment = "bought using BB trader";
                           //--- form the order type
                           request.type= ORDER_TYPE_SELL_LIMIT;                // order type
                           //--- form the price for the pending order
                           request.price= latestPrice.bid;  // open price
                           //--- send a trade request
                           openOrderID = OrderSend(request,result);
                           
                           if (openOrderID <0) Alert("order rejected. Order error: " + string(GetLastError()));
                        
                           
                           
                           //--- write the server reply to log  
                           Print(__FUNCTION__,":",result.comment);
                           if(result.retcode==10016) Print(result.bid,result.ask,result.price);
                           //--- return code of the trade server reply
                           Alert( result.retcode);
                          
                              
                           
                           
                           
                           
                           
                     } else {
                     
                           
                     // in this loop we're checking all opened positions
                     for(int i=0; i<PositionsTotal();  i++){
                                 // processing orders with "our" symbols only
                                 if(Symbol()==PositionGetSymbol(i))
                                   {
                                          // we will change the values of StopLoss and TakeProfit
                                          request.action=TRADE_ACTION_SLTP;
                                          
                                                // long positions processing
                                                if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                                                  {
                                                   
                                                   optimalTakeProfit = NormalizeDouble(bbupperProfitBuffer[0],_Digits);
                                                 
                                                  }
                                                
                                                  if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) // short positions processing
                                                  {
                                                                                          
                                                      optimalTakeProfit = NormalizeDouble(bblowerProfitBuffer[0],_Digits);
                                                    
                                                     
                                                  }
                                         
                                          double TP = trade.RequestTP();
                                          double TPdistance = MathAbs(TP - optimalTakeProfit);
                                          if(TP != optimalTakeProfit && TPdistance > 0.0001)
                                             {
                                                bool Ans = trade.PositionModify(_Symbol,0,TP);
                                             
                                                if (Ans==true)                     
                                                {
                                                   Print("Order modified: ",openOrderID);
                                                   return;                           
                                                }else
                                                {
                                                   Print("Unable to modify order: ",openOrderID);
                                                }   
                                             }   
                                                     
                                         
                                         
                                         
                                   }
                       }
                           
                           
                     
                     
                           
          }
        }
  
  }

   
   
  }
//+------------------------------------------------------------------+
