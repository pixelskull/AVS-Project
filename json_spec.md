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
  "value" : {
    "worker_id" : "#WORKER_ID"
    "hashes" : ["#NEW_HASHES"]
  }
}
```

## stop work (.Basic)
```
{
  "status" : "stopWorking",
  "value" : ""
}
```

## still alive (.Basic)
```
{
  "status" : "stillAlive",
  "value" : ""
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
    "password" : "#PASSWORD",
    "worker_id" : "#WORKER_ID"
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

## hashes per time (.Extended)
```
{
  "status" : "hashesPerTime"
  "value" : {
    "worker_id" : "#WORKER_ID"
    "hash_count" : "#NUMBER_COMPUTED_HASHES"
    "time_needed" : "#TIME"
  }
}
```

## reply alive (.Basic)
```
{
  "status" : "alive",
  "value" : "#WORKER_ID"
}
```

##NOTE:
WORKER_ID == Hostname/IP
