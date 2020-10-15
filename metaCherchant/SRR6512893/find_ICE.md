# Finding the ICE names from the ICEberg 2.0 database

### Trial 1 ###
```
SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_A.txt
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

3.```grep -wf SRR6512893_list_ICE_ref.txt -r iceberg_name_list.txt > missing_z.txt``` missing 214 ...

# Rethinking the problem
Tried sorting each of the files ```SRR6512893_list_ICE_ref.txt``` and ```iceberg_name.txt``` then running trial 1's script. Got same result: 214 matches.

Tried the sorted files into trial2 code: ```grep -Fw -f SRR6512893_list_ICE_sort.txt iceberg_sort.txt > ICEs_in_reads_1.txt```. Got 243.

Counted the total number of ICE in the ICEberg 2.0 database. got **552** total ICEs.

```grep -vf SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_l.txt``` 0 "ICE in reads"
```grep -f SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_m.txt``` 552 "ICE in reads"
```grep -vf SRR6512893_list_ICE_ref.txt iceberg_name.txt > ICEs_in_reads_n.txt``` 0 "ICE in reads"

```grep -vf iceberg_name.txt SRR6512893_list_ICE_ref.txt > ICEs_in_reads_o.txt``` 303 "ICE in reads". This looks like its it. But no, its just the entire ```SRR6512893_list_ICE_ref.txt``` again.

It seems like ```grep``` has to be the right tool, I just need to find the right paraceters...

# Back to the missing "ICEs"
I still can't seem to extract them. Well, there's ~ 1/3 chance that I will randomly pick one that doesn't appear ...

Using the sorted files, found ref IDs **3** and **5** that were not within the ```ICEs_in_reads_A.txt```. Looked them up in the ICEberg database that I used and they are missing... So **what do the folder names in the output actually mean?** It's the same database that I supplied metacherchant with so it should match up, but it doesn't.
