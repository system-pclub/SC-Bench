# SCBench
A Large-Scale Dataset for Smart Contract Auditing

## Dev
```bash
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pytest
```

## Err-Inj Database Info

|      | call | emit | throw | interface | assign | return | Total | # of Contracts |
|------|------|------|-------|-----------|--------|--------|-------|---|
| ERC-20  | 0    | 3621    | 566     | 4605         | 736      | 5930      | 15458     |  5212 |
| ERC-721 | 15    | 34    | 161     | 72         | 0      | 48      | 330     | 111 |
| ERC-1155| 4    | 0    | 18     | 30        | 0      | 9     | 61     | 27 |
| Total   | 19    | 3655    | 745     | 4707    | 736      | 5987      | 15849     | 5350 |

## Manual-Inspect Database Info

|      | call | emit | throw | interface | assign | return | Total |
|------|------|------|-------|-----------|--------|--------|-------|
| ERC-20  | 0    | 0    | 0     | 0         | 0      | 0      | 0     |