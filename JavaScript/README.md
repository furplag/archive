# JavaScript

## Retrying Promise until resolve them ( or reaches the limit ) .

e.g., wait to load complete the class which very huge, and slow .
```example.js
import { unbendingPromise } from '{path to/}unbendingPromise.js'

unbendingPromise(() => Promise.resolve(someClass.launched), 100, 250).then(() => processing.to.nextStep);
```

JoJo won't stop beating Dio till Dio cry (infinity) .
```example.js
import { unbendingPromise } from '{path to/}unbendingPromise.js'

unbendingPromise(() => Promise.resolve(Dio.crying), -1).then(() => Jonathan.beat.stop());
```

JoJo won't stop beating Dio till Dio cry ( or 7 days past ) .
```example.js
import { unbendingPromise } from '{path to/}unbendingPromise.js'

let isAbort = false;
const bendThePromise = () => {
  isAbort = true;
}

unbendingPromise(() => Promise.resolve(someClass.launched), -1, 100, aborting).then(() => processing.to.nextStep);

setTimeout(() => bendThePromise(), 7* 86400000);
```
