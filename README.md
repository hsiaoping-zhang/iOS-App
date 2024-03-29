# iOS-App 專題簡介  

**訊息鈴 : 好物地圖社群推薦語音互動 App**  
開發工具 : Xcode / Swift  
框架 : `SwiftUI`  
資料庫 : Firestore / Storage

## 簡介
目前 Google Map 所提供的服務僅只對店家非即時性評價累積的功能，並不能因應店家臨時情況而改變，因此我們設計一款 APP 提供使用者與店家進行「即時」互動，雙方使用者可在此平台上以文字或語音進行交流，對於每篇貼文，可以即時在底下留言，也能夠針對文章進行時效性設定,因應店家短期促銷活動的需求，此外，APP 也能對於使用者所興趣的分類，結合目前所在地點，過濾周圍附近的貼文。

地圖呈現畫面，目前提供主要三大方向：揪團、好物及美食，使用者能夠自行設定主題以切換不同地圖內容，根據不同的功能，讓使用者不再煩惱買一送一缺同伴分享的窘境，能夠找到周遭附近一樣落單的另一半；如果苦惱今天該吃什麼才好，那就打開地圖開啟小鈴鐺看看週遭附近有什麼熱門討論的美食吧！而如果你也有想要和大家一起分享的優惠活動，歡迎你在地圖上留下你的優惠資訊。

APP 主要有三大特色:
1. 因地制宜:以地圖視角呈現文章,讓使用者接受隨地而異的文章內容
2. 時效性:文章有存活的時間限制,符合好物消息具備的時間性
3. 語音訊息:除了文字訊息外,也可以留下語音內容

以下為系統架構圖:  

<img src="https://i.imgur.com/pXpfPsr.png" width="600"/>

## 畫面

- 地圖文章總覽 : 透過 icon 可先行預覽文章內容類型  
<img src="https://i.imgur.com/G5Z8mGv.png" width="300"/>

- 新增文章 : 提供選擇分類跟文章時效限制  
<img src="https://i.imgur.com/Yi9bMnU.png" width="300"/>


- 文章畫面 : 每篇文章皆有時間限制,等到時間一到,系統將自動刪除文章。  
底下的貼文留言區提供使用者進行訊息交流。  
<img src="https://i.imgur.com/EcdEv1g.png" width="300"/>

- 經緯度轉換 : 根據使用者所在經緯度轉換地址,自動提供地理區域範圍選項的篩選。  
<img src="https://i.imgur.com/2wLw6UU.png" width="300"/>



