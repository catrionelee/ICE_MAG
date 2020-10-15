# Finding the ICE names from the ICEberg 2.0 database

### Trial 1 ###
```
awk 'NR==FNR {a[$1]++; next} $1 in a' SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_A.txt
```
Only retrieved **214** out of 303 detected ICEs.


### Trial 2 ###
```
grep -Fw -f SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_B.txt
```
Better, but only retrieved **243** out of 303 detected ICEs.


## Fin mising ref ids ##
1. ```grep -F -x -v -f <(grep -o '[^/]*$' ICEs_in_reads_A.txt) <(grep -o '[^/]*$' iceberg_name.txt) > missing_ref_A.txt``` **NOPE** that returns 338 "missing" ref IDs
2.```grep -F -x -v -f <(grep -o '[^/]*$' iceberg_name.txt) <(grep -o '[^/]*$' ICEs_in_reads_A.txt) > missing_ref_B.txt``` 0 missing ...
3.```grep -wf SRR6512893_list_ICE_ref.txt -r iceberg_name_list.txt > missing_z.txt```

# Rethinking the problem
Tried sorting each of the files ```SRR6512893_list_ICE_ref.txt``` and ```iceberg_name.txt``` then running trial 1's script. Got same result: 214 matches.
