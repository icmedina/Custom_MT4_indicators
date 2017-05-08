//+------------------------------------------------------------------+
//|                                               CCI Divergence.mq4 |
//|                                                     "Lord, 2014" |
//+------------------------------------------------------------------+
#property copyright "Lord, 2014"
#import "speak_b6.dll"
 bool gSpeak(string text, int rate, int volume);
#import


//----
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Lime        // up 
#property indicator_color2 Red         // down
#property indicator_color3 DarkOrange  // trend cci
#property indicator_width3 2
#property indicator_style3 STYLE_SOLID
#property indicator_color4 Yellow      // turbo cci
#property indicator_width4 1
#property indicator_style4 STYLE_SOLID

#property indicator_level1 200
#property indicator_level2 100
#property indicator_level3 0
#property indicator_level4 -100
#property indicator_level5 -200
#property indicator_levelcolor  Silver
#property indicator_levelstyle  STYLE_DOT

//#property indicator_minimum -350
//#property indicator_maximum 350

//----
#define arrowsDisplacement 0.0003
//---- default input parameters
extern string  CCI = "*** Settings ***";
extern int     trend_period = 14;
extern int     turbo_period = 6;
extern string  price_options1 = "0: Close; 1: High;2: Low; 3: Median (HL/2)";
extern string  price_options2 = "4: Open; 5: Typical (HLC/3);6: Weighted (HLCC/4)";
extern int     price = 0;
extern int     bars_shift = 5;
extern string  Divergence = "*** Indicator Settings ***";
extern bool    drawIndicatorTrendLines = true;
extern bool    drawPriceTrendLines = false;
extern bool    SpeakAlert = true;
extern bool    DisplayClassicalDivergences = true;
extern bool    DisplayHiddenDivergences = true;

//---- buffers
double cci[];
double tcci[];
double bullishDivergence[];
double bearishDivergence[];
double divergencesType[];
double divergencesCCIDiff[];
double divergencesPriceDiff[];

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
   else if (Symbol()== "I.USDX"){
   SymbolStr = "US Dollar Index";
   }
   else if (Symbol()== "USDCHF"){
   SymbolStr = "Dollar-Swiss";
   }
   else SymbolStr = Symbol();
   return (SymbolStr);
}

int GetBarsShift() {
   if (Period()== 5){
   int BarsShift = 9;
   }
   else if (Period()== 15){
   BarsShift = 26;
   }
   else if (Period()== 30){
   BarsShift = 26;
   }
      else if (Period()== 60){
   BarsShift = 12;
   }
      else if (Period()== 240){
   BarsShift = 9;
   }   
   else BarsShift = bars_shift;
   return (BarsShift);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW); // up
   SetIndexStyle(1, DRAW_ARROW); // down
   SetIndexStyle(2, DRAW_LINE);  // trend CCI
   SetIndexStyle(3, DRAW_LINE);  // turbo (entry) CCI

//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, cci);  
   SetIndexBuffer(3, tcci);  
   SetIndexBuffer(4, divergencesType);   
   SetIndexBuffer(5, divergencesCCIDiff);   
   SetIndexBuffer(6, divergencesPriceDiff);   
   
//----   
   SetIndexArrow(0, 233);  // arrow up
   SetIndexArrow(1, 234);  // arrow down
//----
   indicatorName = "CCI Div, CCI:(" + trend_period + "), TCCI: (" + turbo_period + ")";
   SetIndexDrawBegin(3, trend_period);
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
        if(StringSubstr(label, 0, 18) != "CCI_DivergenceLine")
            continue;
        ObjectDelete(label);   
    }
    
    //ObjectsDeleteAll();
     
    return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int countedBars = IndicatorCounted();
   if (countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);   
   return(0);
}

void CalculateIndicator(int countedBars)
{
    for(int i = Bars - countedBars; i >= 0; i--)
    {
        CalculateCCI(i);
        CalculateTurboCCI(i);
        CatchBullishDivergence(i + 2);
        CatchBearishDivergence(i + 2);
    }              
}

void CalculateCCI(int i)
{
    cci[i] = iCCI(NULL, 0, trend_period, price, i);             
}

void CalculateTurboCCI(int i)
{
    tcci[i] = iCCI(NULL, 0, turbo_period, PRICE_CLOSE, i);             
}

void CatchBullishDivergence(int shift)
{
    if(IsIndicatorTrough(shift) == false)
        return;  
        
    int currentTrough = shift;
    int lastTrough = GetIndicatorLastTrough(shift);

    //--CLASSIC DIVERGENCE--//
    if (DisplayClassicalDivergences == true)
    {
      if (cci[lastTrough] < -200){        // hook from extreme
        if(cci[currentTrough] > cci[lastTrough] && Low[currentTrough] <= Low[lastTrough])  //-- detect double bottom, last trough equals current trough 
        {
            bullishDivergence[currentTrough] = cci[currentTrough] - arrowsDisplacement;
       
            divergencesType[currentTrough] = 1; //"Classic Bullish";
            divergencesCCIDiff[currentTrough] = MathAbs(cci[currentTrough] - cci[lastTrough]);
            divergencesPriceDiff[currentTrough] = MathAbs(Low[currentTrough] - Low[lastTrough]);
        
            if(drawPriceTrendLines == true)
                DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                                   Low[currentTrough], 
                                   Low[lastTrough], Lime, STYLE_SOLID);
       
            if(drawIndicatorTrendLines == true)
                DrawIndicatorTrendLine(Time[currentTrough], 
                                       Time[lastTrough], 
                                       cci[currentTrough],
                                       cci[lastTrough], 
                                       Lime, STYLE_SOLID);
            if(SpeakAlert == true)
                SpeakAlert("CCI Classical Bullish Divergence on: ", currentTrough);  
        }
      }
    }
    
         //---- DOUBLE BOTTOM ----//
     if(cci[currentTrough] > cci[lastTrough] && Low[currentTrough] == Low[lastTrough] && SpeakAlert == true){ //-- detect double bottom, when last trough equals current trough
            SpeakAlert("CCI Double Bottom on: ", currentTrough);
      }   

   //-----HIDDEN DIVERGENCE--//
   if (DisplayHiddenDivergences == true)
   {
       if (cci[currentTrough] < cci[lastTrough] && Low[currentTrough] >= Low[lastTrough])
       {
           bullishDivergence[currentTrough] = cci[currentTrough] - arrowsDisplacement;
           
           divergencesType[currentTrough] = 2; //"Hidden Bullish";
           divergencesCCIDiff[currentTrough] = MathAbs(cci[currentTrough] - cci[lastTrough]);
           divergencesPriceDiff[currentTrough] = MathAbs(Low[currentTrough] - Low[lastTrough]);
               
           if(drawPriceTrendLines == true)
               DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                                  Low[currentTrough], 
                                  Low[lastTrough], Lime, STYLE_DOT);

           if(drawIndicatorTrendLines == true)                            
               DrawIndicatorTrendLine(Time[currentTrough], 
                                      Time[lastTrough], 
                                      cci[currentTrough],
                                      cci[lastTrough], 
                                      Lime, STYLE_DOT);

           if(SpeakAlert == true)
               SpeakAlert("CCI Hidden Bullish Divergence on: ", currentTrough);   
        } 
    }     
}

void CatchBearishDivergence(int shift)
{
    if(IsIndicatorPeak(shift) == false)
        return;
    int currentPeak = shift;
    int lastPeak = GetIndicatorLastPeak(shift);

    //-- CLASSIC DIVERGENCE --//
    if (DisplayClassicalDivergences == true)
    {
      if (cci[lastPeak] > 200) {       // hook from extreme
        if(cci[currentPeak] < cci[lastPeak] && High[currentPeak] >= High[lastPeak]) //-- detect double top, when last peak equals current peak
        {
            bearishDivergence[currentPeak] = cci[currentPeak] + arrowsDisplacement;
        
            divergencesType[currentPeak] = 3; //"Classic Bearish";
            divergencesCCIDiff[currentPeak] = MathAbs(cci[currentPeak] - cci[lastPeak]);
            divergencesPriceDiff[currentPeak] = MathAbs(Low[currentPeak] - Low[lastPeak]);
      
            if(drawPriceTrendLines == true)
                DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                                   High[currentPeak], 
                                   High[lastPeak], Red, STYLE_SOLID);
                            
           if(drawIndicatorTrendLines == true)
               DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                      cci[currentPeak],
                                      cci[lastPeak], Red, STYLE_SOLID);

           if(SpeakAlert == true)
               SpeakAlert("CCI Classical Bearish Divergence on: ", currentPeak);  
         }
       }
     }
     
     //---- DOUBLE TOP ----//
     if(cci[currentPeak] < cci[lastPeak] && High[currentPeak] == High[lastPeak] && SpeakAlert == true){ //-- detect double top, when last peak equals current peak
            SpeakAlert("CCI Double Top on: ", currentPeak);
      }   
     
     //----HIDDEN DIVERGENCE----//
     if (DisplayHiddenDivergences == true)
     {
         if(cci[currentPeak] > cci[lastPeak] && High[currentPeak] <= High[lastPeak])
         {
              bearishDivergence[currentPeak] = cci[currentPeak] + arrowsDisplacement;
              
              divergencesType[currentPeak] = 4;//"Hidden Bearish";
              divergencesCCIDiff[currentPeak] = MathAbs(cci[currentPeak] - cci[lastPeak]);
              divergencesPriceDiff[currentPeak] = MathAbs(Low[currentPeak] - Low[lastPeak]);
        
              if(drawPriceTrendLines == true)
                  DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                                     High[currentPeak], 
                                     High[lastPeak], Red, STYLE_DOT);
       
              if(drawIndicatorTrendLines == true)
                  DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                         cci[currentPeak],
                                         cci[lastPeak], Red, STYLE_DOT);
   
              if(SpeakAlert == true)
                  SpeakAlert("CCI Hidden Bearish Divergence on: ", currentPeak);   
         }   
     }
}

bool IsIndicatorPeak(int shift)
{
    // if(cci[shift] >= cci[shift+1] && cci[shift] > cci[shift+2] && cci[shift] > cci[shift-1])
    if(cci[shift] >= cci[shift+1] && cci[shift] >= cci[shift-1])        
      return(true);
    else 
        return(false);
}

bool IsIndicatorTrough(int shift)
{
//    if(cci[shift] <= cci[shift+1] && cci[shift] < cci[shift+2] && cci[shift] < cci[shift-1])     // less sensitive, will alarm after 2 bars
    if(cci[shift] <= cci[shift+1] && cci[shift] <= cci[shift-1])                                    // more sensitive, will alarm after 1 bar   
        return(true);
    else 
        return(false);
}

int GetIndicatorLastPeak(int shift)
{
    for(int j = shift + GetBarsShift(); j < Bars; j++)
    {
//        if(cci[j] >= cci[j+1] && cci[j] > cci[j+2] && cci[j] >= cci[j-1] && cci[j] > cci[j-2])
        if(cci[j] >= cci[j+1]&& cci[j] >= cci[j-1])

            return(j);
    }
    return(-1);
}

int GetIndicatorLastTrough(int shift)
{
    for(int j = shift + GetBarsShift(); j < Bars; j++)
    {
//        if(cci[j] <= cci[j+1] && cci[j] < cci[j+2] && cci[j] <= cci[j-1] && cci[j] < cci[j-2])
        if(cci[j] <= cci[j+1] &&cci[j] <= cci[j-1])

            return(j);
    }
    return(-1);
}

void SpeakAlert(string message, int shift)
{
    if(shift <= 2 && Time[shift] != lastAlertTime)
    {
        lastAlertTime = Time[shift];
        Alert(message, Symbol(), " , ", GetTimeFrameStr(), "chart");
        Print("gSpeak result = ", gSpeak(message+GetSymbolStr()+GetTimeFrameStr()+" chart", -1, 100));
    }
}

void DrawPriceTrendLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style)
{
    string label = "CCI_DivergenceLine# " + DoubleToStr(x1, 0);
    ObjectDelete(label);
    ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
    ObjectSet(label, OBJPROP_RAY, 0);
    ObjectSet(label, OBJPROP_COLOR, lineColor);
    ObjectSet(label, OBJPROP_STYLE, style);
}

void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style)
{
    int indicatorWindow = WindowFind(indicatorName);
    if(indicatorWindow < 0)
        return;
    string label = "CCI_DivergenceLine$# " + DoubleToStr(x1, 0);
    ObjectDelete(label);
    ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
    ObjectSet(label, OBJPROP_RAY, 0);
    ObjectSet(label, OBJPROP_COLOR, lineColor);
    ObjectSet(label, OBJPROP_STYLE, style);
}