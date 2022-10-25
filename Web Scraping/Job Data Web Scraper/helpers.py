
################################################
# Helper functions
################################################

import datetime


def clean_indeed_dates(date):

    if date == 'PostedToday' or date == 'Just posted':
        return datetime.date.today()

    days_ago = int(date.replace('Posted', '').replace(' days ago', '').replace(' day ago', ''))

    return datetime.date.today() - datetime.timedelta(days=days_ago)


def clean_reed_dates(date):

    if 'Today' in date:
        days_ago = 0
    if 'Yesterday' in date:
        days_ago = 1

    return datetime.date.today() - datetime.timedelta(days=days_ago)


def create_message_string(df):

    message_string = ''

    if not df.empty:
        for i, val in df.iterrows():
            message_string += val["title"] + ' at ' + val["company"] + '<br>'
            message_string += val["location"] + '<br>'
            message_string += f'<a href="https://www.indeed.co.uk">View on {val["website"]}</a><br><br>'
    else:
        message_string = 'No new jobs'

    return message_string
