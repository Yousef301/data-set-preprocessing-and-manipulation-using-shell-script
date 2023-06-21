# Data set preprocessing and manipulation using shell script
Design and write a shell script program that does basic dataset preprocessing and manipulations. The program must ask user to enter the dataset file name and the type of operation needed. The dataset must be is CSV format and the first row contains the name of the feature or column. Here is a subset sample from the Iris Data set:
![image](https://github.com/Yousef301/data-set-preprocessing-and-manipulation-using-shell-script/assets/102422691/b12e89ab-9eba-4a3c-9e53-bd9a437c3b55)
The data set contains four features named sepal.length, sepal.width, petal.length, and petal.width. each feature has numeric values. For example, the second row contains the values of the sepal.length, sepal.width, petal.length, and petal.width features.
The program provides the following functionality: get dimension, compute basic statistics, and can substitutes missing values. Below is the description of each operation:
    
    • Dimension: is the number of rows and columns in the input dataset. For the above example, the dimension is 5 X 4
    
    • Basic statistics: is the Min, Max, Mean and the standard Deviation of each column. For the above example, the output will look like this:

![image](https://github.com/Yousef301/data-set-preprocessing-and-manipulation-using-shell-script/assets/102422691/a682fa09-362b-4881-897d-4da4aaa36e4d)

    • Substitutes missing values: if a sample row contains a missed value as below, the program will substitute the missed value by the mean of the column. In this example, the missed value will be substituted by         3.35
    
![image](https://github.com/Yousef301/data-set-preprocessing-and-manipulation-using-shell-script/assets/102422691/181bfffe-5046-4dc3-94f5-3e892dfe5a31)
