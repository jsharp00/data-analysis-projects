# Job Data Scraper

This project focuses on demonstrating proficiency in web scraping and cleaning/manipulating data using Python and its respective libraries such as BeautifulSoup and Pandas.

The Python script scrapes job listings returned from specified search terms and routinely sends an email regarding these new job advertisements.
This sends a single email daily containing a compiled list of recently uploaded jobs scraped from multiple sources. 
The data is scraped from leading UK job sites [Indeed](https://uk.indeed.com/) and [Reed](https://www.reed.co.uk/) but could just as easily be expanded to cover more websites.

The script bares a great resemblance to the opt-in feature available on most job sites which notify the user of new jobs they may be interested in. However, a benefit of this script is that only a single email containing new job details from multiple websites is sent per day, rather than the user sharing their email address with the website and being inundated with both relevant and not so relevant emails.

Example of an email containing new jobs returned by the search terms 'Graduate Data Analyst', 'Junior Data Analyst' and 'Trainee Data Analyst':

![Web Scraper Email](https://i.ibb.co/mFpJf9x/web-scraper-email.png)
