# README

### Building from source

```
opam switch create 4.14.0 4.14.0
opam install . --deps-only --with-test
```

### Running the server

`make && make run`

### Example URL

```
http://localhost:8080/api?q=<JSON>
```

[Full URL example](http://localhost:8080/api?q={%20%22left_hand_side%22:%20%22count%20=%200\\nfor%20e%20in%20es:\\n%20count%20+=%20e\\nprint(count)%22,%20%22right_hand_side%22:%20%22count%20=%20np.sum(es)%22,%20%22language%22:%20%22Python%22,%20%22exclude_tokens%22:%20[]%20})

### Example JSON inputs

```
{
  "left_hand_side": "count = 0\\nfor e in es:\\n count += e\\nprint(count)",
  "right_hand_side": "count = np.sum(es)",
  "language": "Python",
  "exclude_tokens": []
}
```

```
{
  "left_hand_side": "user, err := UserByIDInt32(ctx, s.db, s.event.UserID)",
  "right_hand_side": "user, err := UserByIDInt32(ctx, s.db, int32(s.event.UserID))",
  "language": "Python",
  "exclude_tokens": []
}
```

### Notes

Command invocation

```
./InferRules -b "count = 0\nfor e in es:\n count += e\nprint(count)" -a "count = np.sum(es)" -l "Python"

      - left_hand_side: count = 0\nfor e in es:\n count += e\nprint(count)
      - right_hand_side: count = np.sum(es)
      - language : "Python"
      - exclude_list : "..."
```
