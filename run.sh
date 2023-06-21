echo "Please enter file name: "
read file

if [ ! -e $file ]; then
	echo ""$file" is not exist"
	exit 1
fi

ope=0 #each statistics operation has a specific int value
columns_cnt=1
cnt=1
bFormat=false

# --> Dimensions
columns=$(head -1 $file | tr ',' '\12' | wc -l)
rows=$(wc -l <$file)

#checking if the file format is correct.
commas=$(((columns - 1) * rows))
calculated_commas=$(cat $file | tr -dc "," | wc -c)

if [ $calculated_commas -ne $commas ]; then
	printf "Please check the file format!!\n"
	bFormat=true
fi

#checking if the columns doesn't have a name "Each cell in the first row must be a name for it's column"
if head -1 $file | tr "," "\n" | grep ^$ >/dev/null; then
	col=$(head -1 $file | tr "," "\n" | grep -n ^$ | cut -c-1)
	printf "Column $col doesn't have a name\n"
	bFormat=true
fi

while [ $cnt -le $columns ]; do
	#Checking if there is a non numeric value inside data cells
	if cat $file | cut -d"," -f$cnt | sed "1d" | grep "[A-Za-z]" >/dev/null; then
		printf "There is a non numeric value in column $cnt\n"
		bFormat=true
	fi
	cnt=$((cnt + 1))
done

if [ $bFormat = true ]; then
	exit 1
fi

cnt=1
echo -n "" >temp1.txt

# --> Calculate basic Statistics "Max,Min,Mean,STDEV"
clear
while :; do
	printf "Choose an operation:\nD: Get the dimensions of the dataset.\nC: Compute a statistics on the dataset.\nS: Substitute missing value on each column\nE: Exit\nYour choice? "
	read choice
	case $choice in

	D) printf "The dimensions of the dataset is $rows x $columns\n\n" ;; #Print the dimensions of the dataset

	C)
		echo -n "" >result.csv
		echo -n "" >temp1.txt
		while [ $ope -lt 4 ]; do
			while [ $columns_cnt -le $columns ]; do
				if [ $ope -eq 0 ]; then #Searching for the min value by sorting the column then take the first value
					if [ $columns_cnt -eq 1 ]; then
						echo "Min" >>temp1.txt
					fi
					cat $file | cut -d"," -f$columns_cnt | sed "1d" | grep -v ^$ | sort -nk1,1 | head -1 >>temp1.txt

				elif [ $ope -eq 1 ]; then #Searching for the max value by sorting the column then reverse it and then taking the first value which will be the max value
					if [ $columns_cnt -eq 1 ]; then
						echo "Max" >>temp1.txt
					fi
					cat $file | cut -d"," -f$columns_cnt | sed "1d" | grep -v ^$ | sort -nrk1,1 | head -1 >>temp1.txt

				elif [ $ope -eq 2 ]; then
					if [ $columns_cnt -eq 1 ]; then
						echo "Mean" >>temp1.txt
					fi
					#number of empty lines
					empty=$(cat $file | cut -d"," -f$columns_cnt | sed "1d" | grep ^$ | wc -l)
					empty=$((empty + 1))
					over=$((rows - empty)) #number of cells with data "Will be used to calculate the mean"
					sum=$(cat $file | cut -d"," -f$columns_cnt | sed "1d" | grep -v ^$ | echo $(tr -s "\n" "+")0 | bc) #Calculating the summation of data using bc command
					echo "scale=2; $sum / $over" | bc -l >>temp1.txt #Calculating the mean

				else
					if [ $columns_cnt -eq 1 ]; then
						echo "STDEV" >>temp1.txt
					fi #Calculating the STDEV
					cat $file | cut -d"," -f$columns_cnt | sed "1d" | grep -v ^$ | awk '{sum+=$0;a[NR]=$0}END{for(i in a)y+=(a[i]-(sum/NR))^2;print sqrt(y/(NR-1))}' >>temp1.txt
				fi

				columns_cnt=$((columns_cnt + 1))
			done
			columns_cnt=1
			ope=$((ope + 1))
			printf ":" >>temp1.txt
		done
		ope=0
		columns_cnt=1
		cat temp1.txt | paste -sd ',' | sed 's/.$//' | tr ":" "\n" |  sed '5d' >result.csv #Getting the correct format of CSV file for the results of statistics operations
		printf "The output saved in result.csv file\n\n"
		sed 's/,,/, ,/g;s/,,/, ,/g' result.csv | column -s, -t #Printing csv table on the terminal
		printf "\n"
		;;

	S)
		blanks=$(cat $file | tr "," "\n" | grep ^$ | wc -l)
		if [ $blanks -ne 0 ]; then
			cnt=1
			while [ $cnt -le $columns ]; do
				i=1
				cat $file | cut -d"," -f$cnt >>temp2.txt
				em_lines=$(cat $file | cut -d"," -f$cnt | grep ^$ | wc -l)
				over=$((rows - (em_lines + 1)))
				while [ $i -le $em_lines ]; do
					sum=$(cat temp2.txt | sed "1d" | grep -v ^$ | echo $(tr -s "\n" "+")0 | bc)
					mean=$(echo "scale=2; $sum / $over" | bc -l)
					over=$((over + 1))
					cat temp2.txt | tr "\n" "," | sed 's/.$//' | sed "0,/,,/s/,,/,$mean,/" | sed -e 's/$/\n/' | tr "," "\n" >temp2.txt
					if [ $i -eq $em_lines ]; then
						str=$(cat temp2.txt | tr "\n" "," | sed 's/.$//' | grep .$)
						last=$(echo "${str: -1}")
						if [ $last = , ]; then
							cat temp2.txt | tr "\n" "," | sed 's/.$//' | sed "0,/,$/s/,$/,$mean/" | sed -e 's/$/\n/' | tr "," "\n" >temp2.txt
						fi
					fi
					i=$((i + 1))
				done

				if [ $cnt -eq 1 ]; then
					cp temp2.txt temp3.txt

				else
					paste -d"," temp3.txt temp2.txt >output.txt
					cp output.txt temp3.txt
				fi

				echo -n "" >temp2.txt
				cnt=$((cnt + 1))
			done
			cp temp3.txt $file
			echo "Blanks has been filled with data"
			printf "\n"
			sed 's/,,/, ,/g;s/,,/, ,/g' $file | column -s, -t
			printf "\n"

		else
			printf "\nThere is no empty data cells\n\n"
		fi
		;;

	E)
		rm temp.txt temp1.txt temp2.txt temp3.txt output.txt
		clear
		exit 1
		;;

	*) echo "Invalid input..." ;;

	esac
done
