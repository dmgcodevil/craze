# craze

## Run workers using docker

1. build image. from `./worker` run `docker build -t craze-worker .`
2. run worker1: `docker run -p 50023:22 --name worker1 -d craze-worker`
3. run worker2: `docker run -p 50024:22 --name worker2 -d craze-worker`
4. ssh to worker1 from host: `ssh -p 50023 root@localhost`
5. get IP address of `worker2`: `docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' worker2`
6. from worker1 ssh to worker2 to make sure ssh is working: `ssh root@<worker2-ip>`
7. from worker1 run julia: `/home/root/julia-1.8.3/bin/julia`
8. type the following:

```julia
julia> using Distributed
addprocs(["root@<worker2-ip>"], tunnel=true)
```

you should see:

`
1-element Vector{Int64}:
2
`