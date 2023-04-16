from datetime import datetime, timedelta
import pandas as pd
from etl_covid_data import daily
from prefect import flow


@flow(name="covid_cases_backfill_flow")
def main(start_date: str, end_date: str, fmt="%Y-%m-%d"):

    start_date = datetime.strptime(start_date, fmt)
    end_date = datetime.strptime(end_date, fmt)
    date_range = pd.date_range(start_date,end_date-timedelta(days=1),freq='d')
    for run_date in date_range:
        daily(date=run_date)

if __name__ == "__main__":
    main(start_date='2021-08-01', end_date='2021-08-10')
