# Online-Store
Obtain JAN code and Price information from online stores by scraping and extracting.

# Purpose
Automatically obtain JAN code and price of merchandise from online stores.

# Application
Find discounted merchandise by commaring with Amazon or another store.

# Contents
## input file
input.csv

List of URL

URL is a catalog page of the store.<br>
For example,<br>
`・caraani: 20 items on the catalog page`<br>
`・hobby stock: 24 items on the catalog page`<br>
`・farber: 52 items on the catalog page`<br>
`・K's denki: 96 items on the catalog page`<br>
`・big camera: 100 items on the catalog page`<br>
`・Yamada denki: 20 items on the catalog page`<br>
`・nojima denki: 15 items on the catalog page`<br>


## output file
output.csv

<table>
  <th>JAN code<th>name of the merchandise<th>price
</table>
  
# Flow
1. 

```perl
  if($domain eq 'http://www.chara-ani.com'){
    &cara($url,$limiter);
  }elsif($domain eq 'http://www.hobbystock.jp'){
    &hobby_stock($url,$limiter);
  }elsif($domain eq 'https://shop.faber-hobby.jp'){
    &faber($url,$limiter);
  }elsif($domain eq 'http://www.ksdenki.com'){
    &Ks($url,$limiter);
  }elsif($domain eq 'http://www.biccamera.com'){
    &big($url,$limiter);
  }elsif($domain eq 'https://online.nojima.co.jp'){
    &nojima($url,$limiter);
  }elsif($domain eq 'http://www.yamada-denkiweb.com'){
    &yamada($url,$limiter);
  }
  ```

