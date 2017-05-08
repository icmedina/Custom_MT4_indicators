//+------------------------------------------------------------------+
//|                                              Reversal Signals.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#import "speak_b6.dll"
 bool gSpeak(string text, int rate, int volume);
#import

//----
#property indicator_chart_window
#define arrowsDisplacement 0.0001
//---- input parameters
extern string separator1 = "*** Indicator Settings ***";
extern bool   drawPriceTrendLines = true;
extern bool   displayAlert = true;
//----
static datetime lastAlertTime;

string GetTimeFrameStr() {
   switch(Period())
   {
      case 1 : string TimeFrameStr=" 1 minute "; break;
      case 5 : TimeFrameStr=" 5 minute "; break;
      case 15 : TimeFrameStr=" 15 minute "; break;
      case 30 : TimeFrameStr=" 30 minute "; break;
      case 60 : TimeFrameStr=" 1 hour "; break;
      case 240 : TimeFrameStr=" 4 hour "; break;
      case 1440 : TimeFrameStr=" Daily "; break;
      case 10080 : TimeFrameStr=" Weekly "; break;
      case 43200 : TimeFrameStr=" Monthly "; break;
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
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);

   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       CatchDoubleBottom(i + 2);
       CatchDoubleTop(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CatchDoubleBottom(int shift)
  {
   int currentTrough = shift;
   int lastTrough = GetLastTrough(shift);

//-- DOUBLE BOTTOM
   if(Low[currentTrough] == Low[lastTrough])                                         //-- detect double bottom, when current trough is equal the last trough 
     {if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], Low[lastTrough], 
                              DeepSkyBlue, STYLE_SOLID);
      if(displayAlert == true)
          DisplayAlert("Double Bottom on: ", currentTrough);  
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchDoubleTop(int shift)
  {
   int currentPeak = shift;
   int lastPeak = GetLastPeak(shift);

//-- CLASSICAL BEARISH DIVERGENCE
   if(High[currentPeak] == High[lastPeak])                                          //-- detect double top, when current peak is equal the last peak
     {if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], High[lastPeak], 
                              DeepSkyBlue, STYLE_SOLID);
      if(displayAlert == true)
           DisplayAlert("Double Top on: ", currentPeak);  
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPeak(int shift)
  {
   if(High[shift] >= High[shift+1] && High[shift] >= High[shift-1])                                    // less sensitive, will alarm after 1 bar
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTrough(int shift)
  {
   if(Low[shift] <= Low[shift+1] && Low[shift] <= Low[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLastPeak(int shift)
  {
   for(int i = shift; i < Bars; i++)
     {
       if(High[i] >= High[i+1] && High[i] >= High[i-1])
         {
          return(i);
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetLastTrough(int shift)
  {
   for(int i = shift; i < Bars; i++)
     {
       if(Low[i] >= Low[i+1] && Low[i] >= Low[i-1])
         {
          return(i);
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), ", ", GetTimeFrameStr(), " chart");
       Print("gSpeak result = ", gSpeak(message+GetSymbolStr()+GetTimeFrameStr(), -1, 100));

     }
  }
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "Reversal# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+