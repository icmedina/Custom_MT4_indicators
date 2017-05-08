//+-------------------------------------------------------------------+
//|                                        MACD-Crossover_Alerts.mq4  |
//| MACD alert on zero line cross & signal-histogram crossover        |
//+-------------------------------------------------------------------+

#property copyright "Lord, 2014"

#import "speak_b6.dll"
 bool gSpeak(string text, int rate, int volume);
#import

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 SteelBlue
#property indicator_color4 DarkOrange

 
extern string Setting = "************";
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern bool AlertOn = true;

double CrossUpZero[];
double CrossDownZero[];
double CrossUpSignal[];
double CrossDownSignal[];
string AlertPostfix;

string GetTimeFrameStr() {
   switch(Period())
   {
      case 1 : string TimeFrameStr=" 1 minute "; break;
      case 5 : TimeFrameStr=" 5 minute "; break;
      case 15 : TimeFrameStr=" 15 minute "; break;
      case 30 : TimeFrameStr=" 30 minute "; break;
      case 60 : TimeFrameStr=" 1 hour "; break;
      case 240 : TimeFrameStr=" 4 hour "; break;
      case 1440 : TimeFrameStr=" daily "; break;
      case 10080 : TimeFrameStr=" weekly "; break;
      case 43200 : TimeFrameStr=" monthly "; break;
      default : TimeFrameStr=Period();
   } 
   return (TimeFrameStr);
}

string GetSymbolStr() {
   if (Symbol()== "USDJPY"){
   string SymbolStr = "Dollar-Yen";
   }
   else if (Symbol()== "EURJPY"){
   SymbolStr = "Euro-Yen";
   }
   else if (Symbol()== "EURUSD"){
   SymbolStr = "Euro-Dollar";
   }   
   else if (Symbol()== "USDCHF"){
   SymbolStr = "Dollar-Swiss";
   }
   else if (Symbol()== "I.USDX"){
   SymbolStr = "US Dollar Index";
   }   
   else SymbolStr = Symbol();
   return (SymbolStr);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUpZero);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDownZero);
   SetIndexStyle(2, DRAW_ARROW, EMPTY);
   SetIndexArrow(2, 225);
   SetIndexBuffer(2, CrossUpSignal);
   SetIndexStyle(3, DRAW_ARROW, EMPTY);
   SetIndexArrow(3, 226);
   SetIndexBuffer(3, CrossDownSignal);

  AlertPostfix = GetSymbolStr()+", "+GetTimeFrameStr();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }
  
bool NewBar()
{  static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar == 0)
      {  lastbar=curbar;
         return(false);
      }
   else if(lastbar!=curbar)
      {   lastbar=curbar;
          return (true);
      }
   else return(false);
} 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double Range, AvgRange;

   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+10;counter++) 
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      double MACD_Main_curr = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i);
      double MACD_Main_prev= iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i+1);
      double MACD_Main_prev2= iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i+2);
      
      double MACD_Signal_curr = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
      double MACD_Signal_prev = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i+1);
      double MACD_Signal_prev2 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i+2);

     if ((MACD_Main_curr < 0) && (MACD_Main_prev > 0) && (MACD_Main_prev2 > 0)){ 
         CrossDownZero[i] = High[i] + Range*1.5;
      }
      else if ((MACD_Main_curr > 0) && (MACD_Main_prev > 0) && (MACD_Main_prev2 < 0)){ 
         CrossUpZero[i] = Low[i] - Range*1.5;
      }
      else if ((MACD_Main_curr < MACD_Signal_curr) && (MACD_Main_prev > MACD_Signal_prev) && (MACD_Main_prev2 > MACD_Signal_prev2)){ 
         CrossDownSignal[i] = High[i] + Range*1.5;
      }
      else if ((MACD_Main_curr > MACD_Signal_curr) && (MACD_Main_prev < MACD_Signal_prev) && (MACD_Main_prev2 < MACD_Signal_prev2)){ 
         CrossUpSignal[i] = Low[i] - Range*1.5;
      } 
 
   }
   
   if((NewBar()) && (AlertOn))
      {  if(CrossUpZero[1]!=EMPTY_VALUE)
            {
               Alert("MAC D Bullish Territory: "+AlertPostfix);
               Print("gSpeak result = ", gSpeak("MAC D Bullish Territory "+AlertPostfix+" chart", -1, 100));
            }
         else if(CrossDownZero[1]!=EMPTY_VALUE)
            {
               Alert("MAC D Bearish Territory: "+AlertPostfix);
               Print("gSpeak result = ", gSpeak("MAC D Bearish Territory "+AlertPostfix+" chart", -1, 100));
            }
         else if(CrossUpSignal[1]!=EMPTY_VALUE)
            {
               Alert("MAC D Bullish Crossover: "+AlertPostfix);
               Print("gSpeak result = ", gSpeak("MAC D Bullish Crossover "+AlertPostfix+" chart", -1, 100));
            }
         else if(CrossDownSignal[1]!=EMPTY_VALUE)
            {
               Alert("MAC D Bearish Crossover: "+AlertPostfix);
               Print("gSpeak result = ", gSpeak("MAC D Bearish Crossover"+AlertPostfix+" chart", -1, 100));
            }
      }
   
   return(0);
}

//------------------------------------------------------------+