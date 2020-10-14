### Trial 1 ###
```
awk 'NR==FNR {a[$1]++; next} $1 in a' SRR6512893_list_ICE_ref.txt iceberg_name.txt
```

Only retrieved **214** out of 303 detected ICEs.


### Trial 2 ###
```
grep -Fw -f SRR6512893_list_ICE_ref.txt iceberg_name.txt
```

Better, but only retrieved **243** out of 303 detected ICEs.
