# Olist Brazilian E-Commerce SQL Analysis & Power BI Dashboard

This project consists of querying the Olist Brazilian e-commerce dataset using SQL, preparing the appropriate data ready for import into Power BI and creating a data visualization dashboard.

Dataset Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/olistbr/brazilian-ecommerce)

## Understanding the data

![Database Schema](https://i.ibb.co/CsCSQZP/schema.png)

The dataset consists of various pieces of data collected by Olist surrounding the orders made on their e-commerce platform. Upon importing the dataset CSV files into Microsoft SQL Server Management Studio the following tables are created:

- orders - Immediate order data including when it was placed, its status and when it was delivered
- customers - Data regarding the customers which placed the orders including their city and state
- order_payments - Data regarding the payments fulfilled by customers including the payment type and payment value
- order_items - Data regarding the different products which make up each order including the item price and the freight cost
- products - Data regarding all products sold on the platform including their category and their dimensions
- sellers - Data regarding the sellers which sell products on the platform including their city and their state

## Querying the data with SQL
Relevant file: FULL EDA.sql

The goal of this task is to demonstrate knowledge of querying data using SQL, especially in the context of data analysis.

## Creating the Power BI dashboard
Relevant files: Finished Dashboard.png

A quick dashboard has been thrown together in Microsoft Power BI to demonstrate how visuals can be used to display key insights from the same dataset.

 ![Finished Dashboard](https://i.ibb.co/k1wBmgq/Finished-Dashboard.png)


