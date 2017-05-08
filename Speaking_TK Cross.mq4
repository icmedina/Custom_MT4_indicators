//+------------------------------------------------------------------+
//|                                                Talking TK Cross  |
//|                              Gives speaking alert of Symbol and  |
//|                         timeframe on Tenkan-sen:Kijun-sen cross  |
//|                                                     Lord, 2014   |
//+------------------------------------------------------------------+

#property copyright "Lord., 2014"
#property link      ""

#import "speak_b6.dll"
 bool gSpeak(string text, int rate, int volume);
#import

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2

extern string Setting = "************";
extern bool AlertOn = true;

double CrossUp[];
double CrossDown[];
string AlertPrefix;

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
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 241);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 242);
   SetIndexBuffer(1, CrossDown);

//---- indicator short name
   AlertPrefix = GetSymbolStr()+", "+GetTimeFrameStr();
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

//+------------------------------------------------------------------+
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
      
   // double iIchimoku(string symbol, int timeframe, int tenkan_sen, int kijun_sen,int senkou_span_b, int mode, int shift)
      double kijun_sen_curr = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, i);
      double kijun_sen_prev = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, i+1);
      double kijun_sen_nxt = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, i-1);
      
      double tenkan_sen_curr = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, i);
      double tenkan_sen_prev = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, i+1);
      double tenkan_sen_nxt = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, i-1);
     
      if ((tenkan_sen_curr > kijun_sen_curr) && ((tenkan_sen_prev < kijun_sen_prev) || (tenkan_sen_prev == kijun_sen_prev)) && (tenkan_sen_nxt > kijun_sen_nxt) ) 
         CrossUp[i] = Low[i] - Range*1.5;
         
      else if ((tenkan_sen_curr < kijun_sen_curr) && ((tenkan_sen_prev > kijun_sen_prev) || (tenkan_sen_prev == kijun_sen_prev)) && (tenkan_sen_nxt < kijun_sen_nxt) )
         CrossDown[i] = High[i] + Range*1.5;
   }

   if(NewBar())
      {  if((CrossUp[1]!=EMPTY_VALUE) && (AlertOn))
            {
               Alert("Bullish TK Cross: "+AlertPrefix);
               Print("gSpeak result = ", gSpeak("Bullish T-K Cross "+AlertPrefix, -1, 100));
            }
         else if((CrossDown[1]!=EMPTY_VALUE) && (AlertOn))
            {
               Alert("Bearish TK Cross: "+AlertPrefix);
               Print("gSpeak result = ", gSpeak("Bearish T-K Cross "+AlertPrefix, -1, 100));
            }
      }
   return(0);
}