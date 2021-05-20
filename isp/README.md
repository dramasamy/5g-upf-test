
## Start HTTP(S) Server
```bash
go build server.go
./server
```

## Create a file in server

```bash
dramasam@Dineshs-MacBook-Pro isp % curl -X POST "http://localhost/create?mb=500"
```

## Download the file

```bash
dramasam@Dineshs-MacBook-Pro isp % wget localhost/500mb.txt
--2021-05-19 22:31:48--  http://localhost/500mb.txt
Resolving localhost (localhost)... ::1, 127.0.0.1
Connecting to localhost (localhost)|::1|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 524288000 (500M) [text/plain]
Saving to: ‘500mb.txt’

500mb.txt                           100%[==================================================================>] 500.00M   377MB/s    in 1.3s    

2021-05-19 22:31:49 (377 MB/s) - ‘500mb.txt’ saved [524288000/524288000]
```

## Create a file with specific name
```bash
dramasam@Dineshs-MacBook-Pro isp % curl -X POST "http://localhost/create?mb=500&file=index.html"
```

## QUIC server
```bash
go buid quic_client.go
go buid server_client.go
quic_server -hostname 0.0.0.0 -port 1443 
quic_client -hostname 127.0.0.1 -port 1443 -necho 10
```

