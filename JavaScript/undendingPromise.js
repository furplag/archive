/**
 * Unbending Promise
 * useful for retrying an operation that may sometimes fail for transient reasons, and you want 
 * to implement a mechanism to handle these failures automatically .
 *
 * you can set the abort parameter to true to stop the infinite loop whenever you want, in order to exit the loop 
 * gracefully without waiting for the limit to be reached. And also avoid infinite loop .
 * 
 * @function unbendingPromise
 * @param {Function} fn - a function to retry . it should return a promise that resolves to a boolean indicating success or failure .
 * @param {string} [beacon] - a string to identify the process being retried .
 * @param {number} [limit=100] - the number of times to retry the function .
 * @param {number} [delay=100] - the delay in milliseconds between retries .
 * @param {boolean} [abort=false] - the delay in milliseconds between retries .
 * 
 * @returns {Promise} - a promise that will resolve if the provided function resolve to true, otherwise it will retry with a delay .
 * the promise will be rejected if the limit is reached or the abort flag is true .
 */
function unbendingPromise(fn = () => Promise.resolve(true), beacon, limit = 100, delay = 100, abort = false) {
  let counter = limit;
  const attempt = (resolve, reject) => {
    if (counter === 0 || abort) {
      return reject(`🚧 limit reached: ${beacon || 'a process'} (limit: ${limit}) .`);
    }
    fn().then(result => {
      if (result) {
          return resolve(result);
      } else {
          counter--;
          console.debug(`⌛ ${beacon || 'processing'}${limit < 0 ? '' : ` ( ${limit - counter} / ${limit} )`} ... `);
          return setTimeout(() => attempt(resolve, reject), delay);
      }
    }).catch(error => reject(error));
  };

  return new Promise(attempt);
}

export { unbendingPromise }
