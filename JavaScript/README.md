# JavaScript

## Retrying Promise until resolve them ( or reaches the limit ) .

```example.js
import { unbendingPromise } from '{path to/}unbendingPromise.js'

// JoJo won't stop beating Dio till Dio cry .
unbendingPromise(() => Promise.resolve(Dio.crying), 65535, 1000).then(() => Jonathan.beat.stop());
```
