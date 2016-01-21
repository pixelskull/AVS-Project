# Messages to Worker

## setup config (hash-algo and target)
```
{
  "status" : "setupConfig",
  "value" : {
    "algorithm" : "#HASH_ID",
    "target" : "#TARGET_HASH"
  }
}
```

## get work
```
{
  "status" : "newWorkBlog",
  "value" : "#NEW_HASH(ES)"
}
```

# Messages to Master  

## new Client registration
```
{
  "status" : "newClientRegistration",
  "value" : {
    "worker" : "#WORKER_ID"
  }
}
```

## hit target hash
```
{
  "status" : "hitTargetHash",
  "value" : {
    "hash" : "#HASH_VALUE",
    "password" : "#PASSWORD"
    "time_needed" : "#TIME"
  }
}
```

## finished work
```
{
  "status" : "finishedWork",
  "value" : "#WORKER_ID"
}
```

## finished work without hit
```
{
  "status" : "finishedWorkWithoutHit",
  "value" : "#WORKER_ID"
}
```


# Universal Messages

## still alive
```
{
  "status" : "stillAlive",
  "value" : ""
}
```

## reply alive
```
{
  "status" : "alive",
  "value" : "true/false"
}
```
