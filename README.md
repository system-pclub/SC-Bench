# SCBench
A Large-Scale Dataset for Smart Contract Auditing

## Dev
```bash
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pytest
```

## Err-Inj Database Info

|      | call | emit | throw | interface | assign | return | total | # of contracts |
|------|------|------|-------|-----------|--------|--------|-------|---|
| ERC-20  | 0    | 3612    | 566     | 4605         | 736      | 5930      | 15449     |  5211 |
| ERC-721 | 15    | 33    | 158     | 72         | 0      | 48      | 326     | 110 |
| ERC-1155| 4    | 0    | 18     | 30        | 0      | 9     | 61     | 26 |
| Total   | 19    | 3645    | 742     | 4707    | 736      | 5987      | 15836     | 5347 |


### Method 1 (LLM: Full Contract + Full ERC)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (3,0,3659)     |  (83, 5, 7381)   |  (16,0, 533)  |   (102,5,11573)   |
| ERC-721 | (0,0,108)     |  (0,0,195)   |  (0,0,17)  |   (0,0,320)   |  
| ERC-1155| (0,0,4)     |  (0,0,31)   |  (0,0,8)  |   (0,0,43)    |  
| Total   | (3,0,3771)	| (83,5,7607) |	(16,0,558) |	(102,5,11936) |

### Method 2 (LLM: Full Contract + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (739, 1273)     |  (2037, 7788)   |  (823, 2789)  |   (3599, 11850)    |
| ERC-721 | (2, 185)     |  (1, 105)   |  (0, 33)  |   (3, 323)    |  
| ERC-1155| (4, 27)     |  (0, 30)   |  (0,0)  |   (4, 57)    |  
| Total   | (745, 1485) |	(2038, 7923) |	(823, 2822)	 | (3606, 12230) |

### Method 3 (LLM: Sliced Code + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (1232, 780)     |  (8761, 1064)   |  (1794, 1818) |   (11787, 3662)    |
| ERC-721 | (84, 103)     |  (73, 33)   |  (3, 30)  |   (160, 166)    |  
| ERC-1155| (11, 20)     |  (24, 6)   |  (0,0)  |   (35, 26)   |  
| Total   | (1327, 903)	 | (8858, 1103)	 | (1797, 1848)	 | (11982, 3854) |



## Manual-Inspect Database Info

|      | call | emit | throw | interface | assign | return | total | # of contracts |
|------|------|------|-------|-----------|--------|--------|-------|---| 
| ERC-20  | 0    | 57    | 48     | 35         | 1      | 4      | 145     | 30|

### Method 1 (LLM: Full Contract + Full ERC)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (16,0,40)     |  (21, 0, 36)   |  (5,2, 6)  |   (42,2,82)   |

### Method 2 (LLM: Full Contract + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (3, 18)     |  (29, 30)   |  (30, 35)  |   (62, 83)    |

### Method 3 (LLM: Sliced Code + Single Violated Rule)
|         | high | medium | low | total |
|------   |------|------|-------|-----------|
| ERC-20  | (8, 13)     |  (48, 11)   |  (54, 11) |   (110, 35)    |