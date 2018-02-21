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
1. Convert URL to domain.<br>
2. Send the URL to function prepared like this depend on the domain.<br>
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
3. So. if you wnat to get information from another shop, you need to make new function.<br>
4. Get the HTML and extract URL of individual page of merchandise.<br>
5. From the individual page of merchandise, extract JAN code, price and name of merchandise.<br>
6. Repeat above according to the URLs.<br>

# Usage
1. Save URL of shop to input file, input.csv.<br>
(As an example, if you want "farber", you neet to check button, "５１件表示" to repeat flow "5." for 51 times.)<br>
(If you want to search 200 items on "farber" shop, 4 URLs are needed.)<br>
(A collection of some shops are saved in "input" directory. Therefore, if you want use the URLs, only copy the csv files as "input.csv".)<br>


2. Run by `Perl schime.pl`

3. Check the output file, output.csv


# Caution
Amazon prohibits scraping. So, now I do not use scraping for getting Amazon data but code to scrape from amazon has already wrriten. <br>
If you want to get from Amazon, Amazon API is available for creaters.





# Licence

CopyRight (c) 2018 Shuto Kawabata

Released under the MIT licence

https://opensource.org/licenses/MIT

# Author
Shuto Kawabata


