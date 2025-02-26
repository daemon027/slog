A small tool to search log files.

Suppose we have a K8S cluster and we collect all the pod log to a log server.

The log files are in the direcotry ```/logs/$CLUSTER_NAME/$NAMESPACE/$SVC_NAME/$DAY_STR```.

The dir tree as follows:
```
├── log-files
│   ├── k8s-test
│   │   ├── hello
│   │   │   └── svc01
│   │   │       ├── 2024-12-31
│   │   │       │   ├── aa.log
│   │   │       ├── 2025-01-01
│   │   │       │   ├── bb.log
```

Run it like this:
```bash
slog.sh -t "1 hour ago" -k "hi"
```