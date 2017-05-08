//+------------------------------------------------------------------+
//|                          Accelerator/Decellerator_Divergence.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#import "speak_b6.dll"
 bool gSpeak(string text, int rate, int volume);
#import

//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_color3 STYLE_DOT
#property indicator_width3 1
#property indicator_level1 0
#property indicator_levelcolor  Silver
#property indicator_levelstyle  STYLE_DOT

//----
#define arrowsDisplacement 0.0001
//---- input parameters
extern string divergence = "*** Indicator Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines = false;
extern bool   displayAlert = true;
//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double ac[];

//----
static datetime lastAlertTime;
static string   indicatorName;

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
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
//   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, ac);
//----   
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
//----
 indicatorName = "AC_Div";
 IndicatorDigits(Digits + 2);
 IndicatorShortName(indicatorName);

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 19) != "AC_DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
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
       CalculateAC(i);
       CatchBullishDivergence(i + 2);
       CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateAC(int i)
  {
   ac[i] = iAC(NULL, 0, i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;  
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
//----   
   if(ac[currentTrough] > ac[lastTrough] && 
      Low[currentTrough] < Low[lastTrough])
     {
       bullishDivergence[currentTrough] = ac[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                             Low[lastTrough], Lime, STYLE_SOLID);
       //----
       if(drawIndicatorTrendLines == true)
          DrawIndicatorTrendLine(Time[currentTrough], 
                                 Time[lastTrough], 
                                 ac[currentTrough],
                                 ac[lastTrough], 
                                 Lime, STYLE_SOLID);
       //----
       if(displayAlert == true)
          DisplayAlert("AC Classical bullish divergence on: ", 
                        currentTrough);  
     }
//----   
   if(ac[currentTrough] < ac[lastTrough] && 
      Low[currentTrough] > Low[lastTrough])
     {
       bullishDivergence[currentTrough] = ac[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], Lime, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)                            
           DrawIndicatorTrendLine(Time[currentTrough], 
                                  Time[lastTrough], 
                                  ac[currentTrough],
                                  ac[lastTrough], 
                                  Lime, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("AC Hidden bullish divergence on: ", 
                        currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
//----   
   if(ac[currentPeak] < ac[lastPeak] && 
      High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = ac[currentPeak] + 
                                        arrowsDisplacement;
      
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
                            
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  ac[currentPeak],
                                  ac[lastPeak], Red, STYLE_SOLID);

       if(displayAlert == true)
           DisplayAlert("AC Classical bearish divergence on: ", 
                        currentPeak);  
     }
   if(ac[currentPeak] > ac[lastPeak] && 
      High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = ac[currentPeak] + 
                                        arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  ac[currentPeak],
                                  ac[lastPeak], Red, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("AC Hidden bearish divergence on: ", 
                        currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
//   if(ac[shift] >= ac[shift+1] && ac[shift] > ac[shift+2] && ac[shift] > ac[shift-1])  // less sensitive, will alarm after 2 bars
   if(ac[shift] >= ac[shift+1] && ac[shift] > ac[shift-1])                               // more sensitive, will alarm after 1 bar 

       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
//   if(ac[shift] <= ac[shift+1] && ac[shift] < ac[shift+2] && ac[shift] < ac[shift-1])   // less sensitive, will alarm after 2 bars
   if(ac[shift] <= ac[shift+1] && ac[shift] < ac[shift-1])                                // more sensitive, will alarm after 1 bar

       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
           for(int j = i; j < Bars; j++)
             {
//               if(ac[j] >= ac[j+1] && ac[j] > ac[j+2] && ac[j] >= ac[j-1] && ac[j] > ac[j-2])
               if(ac[j] >= ac[j+1] && ac[j] >= ac[j-1])
 
                   return(j);
             }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
            for (int j = i; j < Bars; j++)
              {
//                if(ac[j] <= ac[j+1] && ac[j] < ac[j+2] && ac[j] <= ac[j-1] && ac[j] < ac[j-2])
                 if(ac[j] <= ac[j+1] && ac[j] <= ac[j-1])

                    return(j);
              }
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", GetTimeFrameStr(), " chart");
       Print("gSpeak result = ", gSpeak(message+GetSymbolStr()+GetTimeFrameStr(), -1, 100));

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "AC_DivergenceLine_# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = "AC_DivergenceLine_$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+