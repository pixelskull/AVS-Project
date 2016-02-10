# Messages to Worker

## setup config (hash-algo and target) (.Extended)
```
{
  "status" : "setupConfig",
  "value" : {
    "algorithm" : "#HASH_ID",
    "target" : "#TARGET_HASH", 
    "worker_id" : "#WORKER_ID"
  }
}
```

## get work (.Extended)
```
{
  "status" : "newWorkBlog",
  "value" : ["#NEW_HASHES"]
}
```

# Messages to Master  

## new Client registration (.Basic)
```
{
  "status" : "newClientRegistration",
  "value" :  "#WORKER_ID"
}
```

## hit target hash (.Extended)
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

## finished work (.Basic)
```
{
  "status" : "finishedWork",
  "value" : "#WORKER_ID"
}
```

# Universal Messages

## still alive (.Basic)
```
{
  "status" : "stillAlive",
  "value" : ""
}
```

## reply alive (.Basic)
```
{
  "status" : "alive",
  "value" : "true/false"
}
```
