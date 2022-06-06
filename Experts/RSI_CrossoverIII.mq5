//+------------------------------------------------------------------+
//|                                             RSI_CrossoverIII.mq5 |
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
#include <Trade/Trade.mqh>;

   string mySymbol = Symbol();//Get current Symbol
   input int bbPeriod = 20; //Get time period or use default
   input int myShift = 0; //Get shift or use default
input int bandStdEntry = 2;
input int bandStdProfitExit = 1;
input int bandStdLossExit = 3;
   input ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE; //get the price to apply
   input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; //Get the period to use or use default
   input double risk = 0.02; //Get Maximum Account risk per trade
   input double adjustmentFactor = 0.0002; //set variance in price from BB to enter trade
   
   double shortValue;
   double buyValue;
   double buyTPvalue;
   double TPvalue;
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
    
    // CTrade Public Object
    CTrade trade;
    
   //Optimal Take Profit
   double optimalTakeProfit; 
   
   
   //For Trailing Stoploss
   input int TslTriggerPoints = 5000;
   input int TslPoints = 20;
   
   input ENUM_TIMEFRAMES TSLMaTimeFrame = PERIOD_CURRENT;
   input int TslMaPeriod = 20;
   input ENUM_MA_METHOD TslMaMethod = MODE_SMA;
   input ENUM_APPLIED_PRICE TslMaAppPrice = PRICE_CLOSE;
   
   // INitialize Indicator Handles  
   
   int handleMa;  
   
   int Entryhandle;
   
   int SLhandle;
   
   int TPhandle; 
   
   int rsiValue;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

      Alert("");
      Alert("Starting Strategy RSI Crossover Test");
    
      // Indicator Handles   
   
      Entryhandle= iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdEntry,appliedPrice);
   
      SLhandle = iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdLossExit,appliedPrice);
   
      TPhandle = iBands(mySymbol,timeFrame,bbPeriod,myShift,bandStdProfitExit,appliedPrice); 
      handleMa = iMA(_Symbol, TSLMaTimeFrame,TslMaPeriod,0,TslMaMethod,TslMaAppPrice);
      
      rsiValue = iRSI(mySymbol,timeFrame,rsiPeriod, PRICE_CLOSE);
   
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

  
   
   
   //sort the price array from the cuurent candle downwards
   ArraySetAsSeries(bbupperEntryBuffer,true);
   ArraySetAsSeries(bblowerEntryBuffer,true);
    ArraySetAsSeries(bbMidBuffer,true);
   ArraySetAsSeries(bbupperProfitBuffer,true);
   ArraySetAsSeries(bblowerProfitBuffer,true);
   ArraySetAsSeries(bbupperLossBuffer,true);
   ArraySetAsSeries(bblowerLossBuffer,true);
   

   


   //Copy Buffers
   
   CopyBuffer(Entryhandle,1,0,3,bbupperEntryBuffer);
   CopyBuffer(Entryhandle,2,0,3,bblowerEntryBuffer);
   CopyBuffer(TPhandle,0,0,3,bbMidBuffer);
   CopyBuffer(TPhandle,1,0,3,bbupperProfitBuffer);
   CopyBuffer(TPhandle,2,0,3,bblowerProfitBuffer);
   CopyBuffer(SLhandle,1,0,3,bbupperLossBuffer);
   CopyBuffer(SLhandle,2,0,3,bblowerLossBuffer);
   

   
   
  //calcualte EA for the cuurent candle
   shortValue= NormalizeDouble(bbupperEntryBuffer[0], _Digits);
    buyValue= NormalizeDouble(bblowerEntryBuffer[0], _Digits);
   buyTPvalue= NormalizeDouble(bbupperProfitBuffer[0], _Digits);
   TPvalue= NormalizeDouble(bbMidBuffer[0], _Digits);
    shortTPvalue= NormalizeDouble(bblowerProfitBuffer[0], _Digits);
    shortSLvalue= NormalizeDouble(bbupperLossBuffer[0], _Digits);
    buySLvalue= NormalizeDouble(bblowerLossBuffer[0], _Digits);
   
   // For RSI
   
   CopyBuffer(rsiValue,0,0,3,iRSIBuffer);
   ArraySetAsSeries(iRSIBuffer,true);
   double currentRSI = NormalizeDouble(iRSIBuffer[0],2);
   double previousRSI = NormalizeDouble(iRSIBuffer[1],2);


   
   
   
   
   
  if (isTradingAllowed()) {
  


            if(!CheckIfOpenOrdersByMagicNB(EXPERT_MAGIC))//if no open orders try to enter new position
         {
  
                    MqlTick latestPrice; //structure to get the latest prices
                    SymbolInfoTick(mySymbol, latestPrice); // Assign current prices to structure 
                    
                    MqlTradeRequest request = {};
                     MqlTradeResult result = {};  
                     
                     if (currentRSI >= rsiLowerLevel && previousRSI < rsiLowerLevel) { //Buying
                     
                           double lowerSellBand = buyValue -= adjustmentFactor;
                           double upperSellBand = buyValue += adjustmentFactor;
         
                           if ( latestPrice.ask >= lowerSellBand || latestPrice.ask <= upperSellBand) {
                           
                           
                           Alert("Price is below signalPrice. Sending buy order");
                           
                           
                           
                                          double optimalVolume = OptimalLotSize(risk,latestPrice.ask,buySLvalue);
                                       
                                         
                                          //--- prepare a request style taken from internet
                                          
                                          request.action=TRADE_ACTION_PENDING;         // setting a pending order
                                          request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
                                          request.symbol= mySymbol;                      // symbol
                                          request.volume= optimalVolume;                          // Calculated using custom function
                                          request.sl=buySLvalue;                                // Stop Loss is not specified
                                          request.tp= TPvalue;                                // Take Profit is not specified     
                                          request.deviation = 10;                         //set slippage
                                          request.comment = "bought using BB trader";
                                          //--- form the order type
                                          request.type= ORDER_TYPE_BUY_LIMIT;                // order type
                                          //--- form the price for the pending order
                                          request.price= latestPrice.ask;  // open price
                                          //--- send a trade request
                                          openOrderID  = OrderSend(request,result);
                                          
                                          
                                          
                                          if (openOrderID <0) Alert("order rejected. Order error: " + string(GetLastError()));
                                       
                                          
                                           
                                          
                                          //--- write the server reply to log  
                                          Print(__FUNCTION__,":",result.comment);
                                          if(result.retcode==10016) Print(result.bid,result.ask,result.price);
                                          //--- return code of the trade server reply
                                          Alert( result.retcode);
                                         
                            }                 
                                          
                                          
                           
                    
                    }
                    
                    
                    if(currentRSI <= rsiUpperLevel && previousRSI > rsiUpperLevel) {
                    
                           double lowerSellBand = shortValue -= adjustmentFactor;
                           double upperSellBand = shortValue += adjustmentFactor;
         
                           if ( latestPrice.bid >= lowerSellBand || latestPrice.bid <= upperSellBand) { //Shorting
                    
                                          Alert("Price is above signalPrice. Sending Short order");
                                       
                                       
                                          double optimalVolume = OptimalLotSize(risk,latestPrice.bid,shortSLvalue);
                                          
                                          
                                          //--- prepare a request style taken from internet
                                          
                                          request.action=TRADE_ACTION_PENDING;         // setting a pending order
                                          request.magic= EXPERT_MAGIC;                  // ORDER_MAGIC
                                          request.symbol= mySymbol;                      // symbol
                                          request.volume= optimalVolume;                          // calculated using custom lot size function
                                          request.sl=shortSLvalue;                                // Stop Loss is not specified
                                          request.tp= TPvalue;                                // Take Profit is not specified     
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
                          
                              
                           
                           } 
                           
                           
                           
                     } 
                           
                           
                     
                     
                           
          }
          
                if (CheckIfOpenOrdersByMagicNB(EXPERT_MAGIC)) {
                
                
                     for (int i = PositionsTotal()-1; i>=0; i--) {
                                    ulong posTicket = PositionGetTicket(i);
                                    
                                    if(PositionSelectByTicket(posTicket)) {
                                          
                                          
                                          double PosOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                                          double posSL = PositionGetDouble(POSITION_SL);
                                          double posTP = PositionGetDouble(POSITION_TP);
                                          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                                          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                                          
                                          double ma[];
                                          CopyBuffer(handleMa,MAIN_LINE,0,1,ma);
                                          
                                          if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                                          
                                                   if(bid >PosOpenPrice + TslTriggerPoints* _Point) {
                                                         double sl = bid - TslPoints * _Point;
                                                         
                                                         if(sl > posSL){
                                                         
                                                               if(trade.PositionModify(posTicket,sl,posTP)) {
                                                               
                                                                     Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                                               }
                                                         
                                                         }
                                                   }      
                                                         
                                                   if(ArraySize(ma) > 0) {
                                                   
                                                         double sl = ma[0];
                                                         sl = NormalizeDouble(sl, _Digits);
                                                         
                                                         if((sl> posSL || posSL == 0) && sl < bid) {
                                                         
                                                               if(trade.PositionModify(posTicket,sl,posTP)) {
                                                               
                                                                  Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                                               }
                                                         }
                                                   }
                                                        
                                                
                                                } else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                                                
                                                      if(ask <PosOpenPrice-+ TslTriggerPoints* _Point) {
                                                      double sl = ask + TslPoints * _Point;
                                                      
                                                            if(sl < posSL|| posSL == 0){
                                                            
                                                                  if(trade.PositionModify(posTicket,sl,posTP)) {
                                                                  
                                                                        Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                                                    }
                                                            
                                                              } 
                                                        
                                                        }
                                                      
                                                      if(ArraySize(ma) > 0) {
                                                   
                                                         double sl = ma[0];
                                                         sl = NormalizeDouble(sl, _Digits);
                                                         
                                                         if((sl< posSL || posSL == 0) && sl > ask) {
                                                         
                                                               if(trade.PositionModify(posTicket,sl,posTP)) {
                                                               
                                                                  Print(__FUNCTION__," > Pos #",posTicket, " was modified by ma tsl ..." );
                                                                 }
                                                           }
                                                        }     
                                                
                                                                                    
                                                   }
                                    
                                    }
                                    
                              
                                                     
                              }
                     
                
                }
        }
  
  }
   
  
//+------------------------------------------------------------------+
