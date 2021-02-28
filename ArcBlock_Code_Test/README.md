
### ArcBlock_Test: a list page


This is a single news list page.

### Key feature:
- Display news list page with data from network or local.
- Provider mockData to debug and test.
- Provider HTTPClient to send request from server.
- Download Image from server.
- Use image cache and  image render to reduce memory usage.
- Dynimic cell height.
- Pull to refresh in list.

### Main Class:
- News: the model of data. category different news type use enum.
- NewsCell: display news data in screen. Include text , image collectionView.
- HomeViewController: request data and refresh news list.
- HTTPClient: send request and download image.

A standard MVC archticture. All UI code are programmicly .



### Project Env:
Swift5.3.2
Xcode12.4


