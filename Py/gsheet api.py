import gspread
from oauth2client.service_account import ServiceAccountCredentials
import json
import pandas as pd
import numpy as np
from gspread_pandas import Spread, Client
from gspread_dataframe import get_as_dataframe, set_with_dataframe
import sys

scopes = [
'https://www.googleapis.com/auth/spreadsheets',
'https://www.googleapis.com/auth/drive'
]
credentials = ServiceAccountCredentials.from_json_keyfile_name("credentials.json", scopes) #access the json key you downloaded earlier
file = gspread.authorize(credentials) # authenticate the JSON key with gspread
workbook = file.open("DRT Shopee L1 Server List") #open sheet
sheet = workbook.worksheet("IP TO ST FINDER") #select worksheet by name

pd.set_option('display.max_rows', None)

#Save IP to a List
def get_ip():
    global ips
    ips = []
    for line in sys.stdin:
        ips.append(line.strip())

#Append row to google sheet
def update_IPtoST_finder():
    for ip in ips:
        sheet.update_cell(ips.index(ip)+2, 1, ip)

#Convert List to Dataframe
def convert_to_dataframe():
    global df
    df = pd.DataFrame(ips)

#Update Dataframe to google sheet
def update_df_to_gs():
    set_with_dataframe(sheet, df, row=999, col=1, include_index=False, include_column_header=False)

#Get google sheet info
def read_server_info():
    df_get = get_as_dataframe(sheet, skiprows=range(1, 998), evaluate_formulas=True, usecols=range(0, 6), dtype=str)
    df_get.dropna(axis=0, how='all', thresh=None, subset=None, inplace=True)
    print(df_get)

#Clear updated cells
def clear_gs():
    df.loc[:] = np.nan

get_ip()
convert_to_dataframe()
update_df_to_gs()
read_server_info()
clear_gs()
update_df_to_gs()