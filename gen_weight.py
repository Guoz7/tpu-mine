import random

# Define the file name
file_name = "D:/project_verilog/tpu-mine/weight.txt"

# Define the number of rows and columns
rows = 4
columns = 4

# Generate and write random data to the file
with open(file_name, "w") as file:
    for i in range(rows):
        row_data = [random.randint(0, 65535) for _ in range(columns)]  # Generate random 16-bit numbers
        row_data_str = " ".join(f"{x:04X}" for x in row_data)  # Convert to hexadecimal format
        file.write(row_data_str + "\n")

print(f"Random data has been written to {file_name}")
