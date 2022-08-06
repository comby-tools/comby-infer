# comby-infer

Infer comby rewrite rules from concrete examples

## Docker image

## Local source build

**Build inference binary**

```
cd InferRules && ./gradlew build -x test
```

**Build and run server**

```
make -C client release && make -C server run
```

## Docker source build

```
docker build --platform linux/amd64 --tag auto-comby-ubuntu-20.04 .
```
