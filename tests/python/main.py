# %%
import polars as pl
import matplotlib.pyplot as plt

# %%
# Create sample data with polars
df = pl.DataFrame({
    "x": range(1, 11),
    "y": [2, 4, 5, 4, 8, 7, 9, 10, 12, 11],
    "category": ["A", "B", "A", "B", "A", "B", "A", "B", "A", "B"],
})
print(df)

# %%
# Basic statistics
print("Statistics:")
print(df.describe())

# %%
# Group by category
grouped = df.group_by("category").agg([
    pl.col("y").mean().alias("mean_y"),
    pl.col("y").sum().alias("sum_y"),
])
print(grouped)

# %%
# Plot the data
plt.figure(figsize=(8, 5))
plt.scatter(df["x"], df["y"], c=df["category"].cast(pl.Categorical).to_physical(), cmap="viridis")
plt.plot(df["x"], df["y"], alpha=0.5)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("Sample Plot with Polars Data")
plt.colorbar(label="Category")
plt.show()

# %%
# Line plot by category
fig, ax = plt.subplots(figsize=(8, 5))
for cat in df["category"].unique():
    subset = df.filter(pl.col("category") == cat)
    ax.plot(subset["x"], subset["y"], marker="o", label=f"Category {cat}")
ax.legend()
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_title("Data by Category")
plt.show()
# %%
