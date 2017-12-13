#!/bin/bash
# Logan Nielsen -- HW 8: Automated Grading script

# delete all pre-existing folders in directory
rm -rf sampleInput
rm -rf expectedOutput
rm -rf submissions
rm -rf actualOutput
rm -rf grades.txt

# unzip  sample/submissions and create additional output folder
unzip sampleInput.zip -d sampleInput &> /dev/null
unzip expectedOutput.zip -d expectedOutput &> /dev/null
unzip submissions.zip -d submissions &> /dev/null
mkdir actualOutput
echo
# used as iterables
inputs=`ls sampleInput/Users/JLL/Desktop/sampleInput --ignore-backups`
submissions=`ls submissions/Users/JLL/Desktop/submissions --ignore-backups`
expectedOutputs=`ls expectedOutput/Users/JLL/Desktop/expectedOutput --ignore-backups`

# dos2unix fix for all files in provided directories
for file in $inputs; do dos2unix sampleInput/Users/JLL/Desktop/sampleInput/$file &> /dev/null; done
for file in $submissions; do dos2unix submissions/Users/JLL/Desktop/submissions/$file &> /dev/null; done
for file in $expectedOutputs; do dos2unix expectedOutput/Users/JLL/Desktop/expectedOutput/$file &> /dev/null; done

# iterate through each submission
for j in $submissions; do
    correct=0
    incorrect=0
    cheater=0
    # test sample inputs on student submission files
    for i in $inputs; do
        input=`cat sampleInput/Users/JLL/Desktop/sampleInput/$i`
        gcl -load submissions/Users/JLL/Desktop/submissions/$j -eval " (progn $input (quit)) " > actualOutput/"${j%%.*}_$i.out"
        output=`cat expectedOutput/Users/JLL/Desktop/expectedOutput/$i.out | sed -e "s/\n//g"`
        DIFF=`diff -w expectedOutput/Users/JLL/Desktop/expectedOutput/$i.out actualOutput/"${j%%.*}_$i.out"`
        if [$DIFF -ne ""]; then
            #increase correct counter
            let "correct += 1"
            #check to see if correct answer is inside the file -- cheater!
            if grep -x "$output" submissions/Users/JLL/Desktop/submissions/$j
            then
                let "cheater += 1"
            fi
        else
            #increase incorrect counter
            let "incorrect += 1"
        fi
    done

    flag=""
    if (("$cheater" > "0")); then
        flag="*"
    else
        flag=""
    fi
    total_files=$((correct + incorrect))
    grade=$((correct * 100 / total_files))
    echo "$flag ${j%%.*}, $grade" >> grades.txt
done
