
import pandas as pd
from bs4 import BeautifulSoup
import requests
import datetime
import time

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from helpers import clean_indeed_dates, clean_reed_dates, create_message_string


headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36'
}

# SMTP server login credentials have been removed
sender = "**************"
receiver = "**************"

server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login(sender, "*********")


search_terms = [
    "Graduate Data Analyst",
    "Junior Data Analyst",
    "Trainee Data Analyst"
]

while True:

    indeed = {}
    reed = {}

    indeed_df = pd.DataFrame()
    reed_df = pd.DataFrame()

    last_scrape = datetime.datetime.now().strftime("%H:%M:%S on %d/%m/%Y")
    print(f"Scrape commenced at {last_scrape}")
    print("Finding jobs for the following search terms:")
    for i, elem in enumerate(search_terms):
        if i != (len(search_terms) - 1):
            print(elem, end=", ")
        else:
            print(elem)

    # Retrieve pages
    for term in search_terms:

        ################################################
        # Retrieve and clean Indeed job data
        ################################################

        # Retrieve Indeed job data
        indeed_jobs = []

        indeed_page = requests.get(f'http://uk.indeed.com/jobs?q={term}&l=Northampton&sort=date&vjk=31a04db3954393de', headers=headers)

        soup = BeautifulSoup(indeed_page.content, 'html.parser')
        results = soup.find('div', id='mosaic-zone-jobcards')
        job_listings = results.find_all('a', class_='result')

        for job_listing in job_listings:
            title = job_listing.find('h2', class_='jobTitle').text
            company = job_listing.find('span', class_='companyName').text
            location = job_listing.find('div', class_='companyLocation').text
            date = job_listing.find('span', class_='date').text

            job = {
                'title': title,
                'company': company,
                'location': location,
                'date': date,
                'website': 'Indeed',
                #'link': href
            }

            indeed_jobs.append(job)
            indeed[term] = indeed_jobs

        # Clean/manipulate Indeed job data
        df = pd.DataFrame(indeed[term])
    
        df = df[~df["date"].str.contains('Active|\+')]
        df["title"] = df["title"].apply(lambda x: x.replace('new', '') if x[:3] == 'new' else x)
        df["date"] = df["date"].apply(lambda x: clean_indeed_dates(x))

        indeed_df = pd.concat([indeed_df, df], ignore_index=True)

        ################################################
        # Retrieve and clean Reed job data
        ################################################

        # Retrieve Reed job data
        reed_jobs = []

        reed_page = requests.get(f'http://www.reed.co.uk/jobs/{term}-jobs-in-northampton?sortby=DisplayDate&proximity=30', headers=headers)

        soup = BeautifulSoup(reed_page.content, 'html.parser')
        results = soup.find('div', class_='results-container')
        job_listings = results.find_all('article', class_='job-result')

        for job_listing in job_listings:
            title = job_listing.find('h3', class_='title').text.strip()
            company = job_listing.find('div', class_='posted-by').text.split('by ')[1].split('\n')[0].strip()
            location = job_listing.find('li', class_='location').text.strip().split('\r\n')[0]
            date = job_listing.find('div', class_='posted-by').text.split('by ')[0].strip()

            job = {
                'title': title,
                'company': company,
                'location': location,
                'date': date,
                'website': 'Reed',
                #'link': href
            }

            reed_jobs.append(job)
            reed[term] = reed_jobs

        # Clean/manipulate Reed job data
        df = pd.DataFrame(reed[term])

        df = df[df["date"].str.contains('Yesterday|Today')]
        df["date"] = df["date"].apply(lambda x: clean_reed_dates(x))

        reed_df = pd.concat([reed_df, df], ignore_index=True)

    ################################################
    # Combine results and filter recent jobs
    ################################################

    full_df = pd.concat([indeed_df, reed_df], ignore_index=True)

    todays_jobs = full_df[full_df["date"] == datetime.date.today()]
    yesterdays_jobs = full_df[full_df["date"] == datetime.date.today() - datetime.timedelta(1)]    

    ################################################
    # Form and send email
    ################################################

    # Form messages
    todays_jobs_string = create_message_string(todays_jobs)
    yesterdays_jobs_string = create_message_string(yesterdays_jobs)

    # Form email
    msg = MIMEMultipart('alternative')
    msg['Subject'] = f"Recent Data Analyst job posts {datetime.datetime.today().strftime('%d/%m/%Y')}"
    msg['From'] = sender
    msg['To'] = receiver

    html = f"""\
    <html>
    <head></head>
    <body>
        <h2>New jobs on Indeed and Reed</h2>
        <h3>Today:</h3>
        {todays_jobs_string}
        <h3>Yesterday:</h3>
        {yesterdays_jobs_string}
    </body>
    </html>
    """

    part1 = MIMEText(html, 'html')
    msg.attach(part1)

    # Send email
    server.sendmail(
        msg=msg.as_string(),
        from_addr=sender,
        to_addrs=receiver
    )

    # 1 day = 86400 seconds
    time.sleep(86400)
