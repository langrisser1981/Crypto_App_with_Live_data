#  <#Title#>

## 輸入參數
  * dataModel:[CGFloat]
  * theme:Color
  
### 資料轉換
  將原始的[CGFloat]轉換為[CGPoint]
  * 找出資料中最大與最小值
  * 得到path物件

## 把所有的東西包在geometryReader
  * 利用geometryProxy取得畫面長寬
  * geometryReader寬度是expanding(延伸到最大)，高度是neutral(根據容器內的view)

## 利用ZStack畫線與背景
### 線
  遍歷資料點，利用path畫線
  * strokePath描線
  * fill可以把線畫上漸層

### 背景
  在線的下方畫下背景色塊，可以使用漸層
  * linearGradient畫背景
  * 對漸層套用clipShape放入path (補上右、下線段將path封閉)

## 製作drag indicator
  * 用overlay疊加在zstack
  * 將Text、Rectangle、Circle用VStack由上到下排列
  * 利用contentShape定義感應區
## 套用dragGesture
  * 在手勢的開始與結束利用state控制indicator是否顯示
    ** 在withAnimation中修改狀態變數
    ** 注意，這邊不要用if，用opacity控制顯示與否，避免動畫錯亂
    ** 為了計算位置，將indicator設定固定的長寬
  * 這邊為了讓indicator隨著拖曳 ++黏到(snap)++ 線段上，必須根據拖曳的位移，計算要黏到哪一個資料點上
    ** 將(translation.value.x/點到點的寬度).round()就可以得到最接近資料點的index
    ** 但因為拖曳的時候可能會超出範圍，所以要注意不可以小於0，或是大於資料陣列的個數
  * 要注意算出的offset，如果會讓indicator上的文字超出畫面(通常是手指拖曳到畫面的最左或最右)，要把offset移回一點

## 標註文字
  * 在geometryReader上套用overlay或是在zstack新增一個vstack
  * 標註最大值、spacer、最小值
  
