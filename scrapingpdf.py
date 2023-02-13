import pdfplumber
path = "C:/Users/mark.cherrie/Documents/GitHub/EdinParkQuality/data/raw/Park_Quality_Assessment__Green_Flag_Award_Report_2022.pdf"
pdf = pdfplumber.open(path)
im = pdf.pages[12]
extract = im.extract_table()

import pandas as pd
output = pd.DataFrame(extract[1::],columns=extract[0])

import csv
with open('C:/Users/mark.cherrie/Documents/GitHub/EdinParkQuality/data/parksquality22.csv', mode='w', encoding='utf-8') as export_csv:
        csv_writer = csv.writer(export_csv, quoting=csv.QUOTE_NONE)
        csv_writer.writerow(output)