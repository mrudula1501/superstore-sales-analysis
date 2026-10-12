import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('train.csv')

# Fix Sales column
df['Sales'] = pd.to_numeric(df['Sales'], errors='coerce')

# Fix dates
df['Order Date'] = pd.to_datetime(df['Order Date'], dayfirst=True)
df['Ship Date'] = pd.to_datetime(df['Ship Date'], dayfirst=True)
df['Order Year'] = df['Order Date'].dt.year
df['Delivery Days'] = (df['Ship Date'] - df['Order Date']).dt.days

# ── Chart 1: Sales by Region ──
plt.figure(figsize=(8,5))
region_sales = df.groupby('Region')['Sales'].sum().sort_values(ascending=False)
sns.barplot(x=region_sales.index, y=region_sales.values, palette='Blues_d')
plt.title('Total Sales by Region')
plt.ylabel('Sales ($)')
plt.tight_layout()
plt.savefig('sales_by_region.png')
plt.show()

# ── Chart 2: Sales by Category ──
plt.figure(figsize=(8,5))
cat_sales = df.groupby('Category')['Sales'].sum().sort_values(ascending=False)
sns.barplot(x=cat_sales.index, y=cat_sales.values, palette='Greens_d')
plt.title('Total Sales by Category')
plt.ylabel('Sales ($)')
plt.tight_layout()
plt.savefig('sales_by_category.png')
plt.show()

# ── Chart 3: Sales Trend by Year ──
plt.figure(figsize=(8,5))
year_sales = df.groupby('Order Year')['Sales'].sum()
plt.plot(year_sales.index, year_sales.values, marker='o', color='steelblue', linewidth=2)
plt.title('Sales Trend by Year')
plt.ylabel('Sales ($)')
plt.xlabel('Year')
plt.tight_layout()
plt.savefig('sales_by_year.png')
plt.show()

# ── Chart 4: Top 10 Customers ──
plt.figure(figsize=(10,6))
top_customers = df.groupby('Customer Name')['Sales'].sum().sort_values(ascending=False).head(10)
sns.barplot(x=top_customers.values, y=top_customers.index, palette='Oranges_d')
plt.title('Top 10 Customers by Sales')
plt.xlabel('Sales ($)')
plt.tight_layout()
plt.savefig('top_customers.png')
plt.show()

print("Total Sales: $", round(df['Sales'].sum(), 2))
print("Average Delivery Days:", round(df['Delivery Days'].mean(), 1))
print("Done! Charts saved.")