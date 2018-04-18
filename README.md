# Safe-Compiler
A Bash script to compile and run C, C++, Java, Python 2.x and Python 3.x codes including shield and easysandbox(for black boxing) to prevent any type of malicious code by the source code. 
It also supports limiting the code resources such as time, memory and output size.

## Using Manual:
The main code runner script located at ```tester/run.sh``` .

You can run it like below:

``` ./run.sh /home/user/Desktop/codes 107 cpp ```

Here,
The 1st parameter is ```CodePath```. Write the directory path where your code exists.
The 2nd parameter is ```Submissions ID```. It is basically required for file identification. It should be numeric value.
    
The code file should be named after Submission ID. Example: ```submission_{SUBMIT_ID}.cpp``` or ```submission_{SUBMIT_ID}.java```
The input file should follow this rule too. Input file name should be like this ```input_{SUBMIT_ID}.txt```
    
Basically, The default source limits are:
1. Time Limit: 3 seconds
2. Memory Limit: 64 MB
3. Output Size Limit: 2 MB

After running the script, It will show either ```Compilation Error``` or ```Success``` message on console.
This script will produce another two file in the CODE_PATH named ```output_{SUBMIT_ID}``` and ```log_{SUBMIT_ID}```

If it is Compilation Error, the output file will contain the error message.
If it is Success, the output file will contain the code output for that input file.

It should be mentioned that, if the code violates any of the limits the verdicts of them will also be written in the output file but the console will show "Success" message in this case.
