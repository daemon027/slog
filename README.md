A small tool to search log files.

Suppose we have a K8S cluster and we collect all the pod log to a log server, the log files are in the directory ```/logs/$CLUSTER_NAME/$NAMESPACE/$SVC_NAME/$DAY_STR```.

The dir tree as follows:
```
├── logs
│   ├── k8s-test
│   │   ├── ns00
│   │   │   └── svc01
│   │   │       ├── 2024-12-31
│   │   │       │   ├── aa.log
│   │   │       ├── 2025-01-01
│   │   │       │   ├── bb.log
```

Run it like this:
```bash
slog.sh -c k8s-test -n ns00 -s svc01 -t "1 hour ago" -k "hi"
```