# -*- coding: utf-8 -*-
"""
Created on Mon Oct  6 00:35:50 2025

@author: E1cal
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


#%% Load data, clean, and obtain time series to forecast
from datetime import datetime
# df_customers = pd.read_csv("C:\\Users\\E1cal\\OneDrive\\Documents\\SQL_Notes\\PostgreSQL_Files\\E-commerce_Data\\customersUTF8.csv")
# df_products = pd.read_csv("C:\\Users\\E1cal\\OneDrive\\Documents\\SQL_Notes\\PostgreSQL_Files\\E-commerce_Data\\productsUTF8.csv")
# df_orders = pd.read_csv("C:\\Users\\E1cal\\OneDrive\\Documents\\SQL_Notes\\PostgreSQL_Files\\E-commerce_Data\\ordersUTF8.csv")

df = pd.read_csv("C:\\Users\\E1cal\\OneDrive\\Documents\\SQL_Notes\\PostgreSQL_Files\\E-commerce_Data\\ordersUTF8.csv")
df = df.dropna()

# df['order_date'] = pd.to_datetime(df['invoice_date'])

format_string = "%m/%d/%Y %H:%M"

dt = [datetime.strptime(df_str, format_string) for df_str in df['invoice_date']]

df['month'] = [inv.month for inv in dt]
df['day'] = [inv.day for inv in dt]
df['year'] = [inv.year for inv in dt]
df['date_times'] = dt
df['order_total'] = df['quantity']*df['unit_price']

data_year_month_day = df.groupby(by=['year','month','day'])

total_profit_by_day = data_year_month_day['order_total'].sum().to_numpy()
dates_for_day_sums = data_year_month_day['date_times'].min().to_numpy()

plt.plot(dates_for_day_sums, total_profit_by_day)
#%%

# df = pd.read_csv("C:\\Users\\E1cal\\OneDrive\\Documents\\SQL_Notes\\PostgreSQL_Files\\E-commerce_Data\\AirPassengers.csv")
# df['Month'] = pd.to_datetime(df['Month'])
# dates_for_day_sums = df['Month'].to_numpy()
# total_profit_by_day = df['#Passengers'].to_numpy()

#%% imposing stationarity in variance

from scipy.stats import boxcox

day_sum_boxcox, lam = boxcox(total_profit_by_day)


#%% imposing statinarity in mean and plotting PACF and ACF to estimate orders of AR and MA model componenets

from statsmodels.graphics.tsaplots import plot_pacf, plot_acf
from statsmodels.tsa.stattools import adfuller
import pmdarima as pm
# day_sum_diff = np.diff(day_sum_boxcox)

idx_train = -int(len(total_profit_by_day)*0.2)
idx_test = -int(len(total_profit_by_day)*0.2)
# train = day_sum_boxcox[:idx_train]
# test = day_sum_boxcox[idx_test:]
train = day_sum_boxcox[:idx_train]
test = day_sum_boxcox[idx_test:]

day_sum_diff = np.diff(day_sum_boxcox)
adf_res = adfuller(day_sum_diff)

arima = pm.auto_arima(train, error_action='ignore', trace=True, 
                      suppress_warnings=True, maxiter=10,
                      seasonal=False, m=1)

plot_acf(day_sum_diff)
plot_pacf(day_sum_diff, method='ywm')

#%% Prophet

from prophet import Prophet 

mf = pd.DataFrame({'ds' : dates_for_day_sums[:idx_train], 'y' : total_profit_by_day[:idx_train]})
ff = pd.DataFrame({'ds' : dates_for_day_sums[idx_test:]})

model_prophet = Prophet()
model_prophet.fit(mf)

forecast_prophet = model_prophet.predict(ff)

#%% model fitting

from statsmodels.tsa.arima.model import ARIMA
from scipy.special import inv_boxcox



model = ARIMA(train, order=(5,1,18)).fit()
boxcox_forcast = model.forecast(len(test))
forecasts = inv_boxcox(boxcox_forcast, lam)
ax1.tick_params(axis='both', labelsize=12)
ax2.tick_params(axis='both', labelsize=12)
plt.show()

#%%
import plotly.io as pio
import plotly.graph_objects as go

pio.renderers.default = 'browser'

def plot_forecasts(forecasts: list[float], title: str) -> None:
    """function to plot the forecasts."""
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=dates_for_day_sums[:idx_train], y=total_profit_by_day[:idx_train], name='Train'))
    fig.add_trace(go.Scatter(x=dates_for_day_sums[idx_test:], y=total_profit_by_day[idx_test:], name='Test'))
    fig.add_trace(go.Scatter(x=dates_for_day_sums[idx_test:], y=forecasts, name='Forecast'))
    fig.update_layout(template="simple_white", font=dict(size=18), title_text=title,
                      width=650, title_x=0.5, height=400, xaxis_title='Date',
                      yaxis_title='Passenger Volume')
    return fig.show()

plot_forecasts(forecasts, 'ARIMA')







